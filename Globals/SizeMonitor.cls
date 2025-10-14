Class Globals.SizeMonitor Extends %CSP.Page
{

Parameter Title As STRING [ Final ] = "Global Memory Viewer";

ClassMethod OnPage() As %Status
{
	Do ..OnPageCSPROOT()
	Return $$$OK
}

ClassMethod OnPageCSPROOT() As %Boolean
{
	Do ..OnPageHTML()
}

ClassMethod OnPageHTML() As %Boolean
{
	Write "<html>"
	Write !
	Do ..OnPageHEAD()
	Do ..OnPageBODY()
	Write !,"</html>"
	Return $$$OK
}

ClassMethod OnPageHEAD() As %Boolean
{
	Write "<head>",!
	Write "<link rel=""shortcut icon"" href=""portal/ISC_IRIS_icon.ico"">"
	Write !,"<title>"_..#Title_"</title>",!
	Write " <link rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"">",!
	Write "<script src=""https://cdn.jsdelivr.net/npm/chart.js""></script>"
	Write "<script src=""https://cdn.jsdelivr.net/npm/chartjs-plugin-zoom""></script>"
	Write "<style>",!
	Write "</style>",!
	Write "</head>",!
	W ..HyperEventHead(0,0)
	Return $$$OK
}

ClassMethod OnPageBODY() As %Boolean
{
	Do ..RenderChart()
	Return $$$OK
}

ClassMethod RenderChart() As %Status
{
	&HTML<
	<h1>Global Memory Viewer</h1>
	<label for="namespaceSelect">Namespace:</label>
                    <select id="namespaceSelect">
     >
	Set rs = ##class(%SQL.Statement).%ExecDirect(, "SELECT Nsp FROM %SYS.Namespace_List()")
	While rs.%Next() {
		Write "<option value="""_rs.Nsp_""">"_rs.Nsp_"</option>"
	}
   &HTML<
	</select>
	>
	&HTML<
	<html>
<head>
    <style>
      body { font-family: Arial, sans-serif; margin: 20px; }
      #globalsTable { border-collapse: collapse; width: 100%; margin-top: 30px; }
      #globalsTable th, #globalsTable td { border: 1px solid #ccc; padding: 8px; text-align: left; }
      #globalsTable th { background-color: #f0f0f0; }
      #searchBox { margin-bottom: 10px; padding: 6px; width: 300px; }
      #paginationControls { margin: 10px 0; }
      button { padding: 6px 12px; margin-right: 8px; }
    </style>
</head>
<body>
    <p>Note: This may take sometime to calculate the global size</p>
    <canvas id="globalsChart" style="max-width: 100%; height: 400px;"></canvas>
    <div id="paginationControls">
        <button id="prevBtn" disabled>Previous</button>
        <span>Page <span id="currentPage">1</span> of <span id="totalPages">1</span></span>
        <button id="nextBtn">Next</button>
    </div>
    <h2>All Globals (Searchable)</h2>
    <input type="text" id="searchBox" placeholder="Search globals by name...">
    <table id="globalsTable" >
      <thead>
        <tr>
          <th>Name</th>
          <th>Allocated MB</th>
          <th>Used MB</th>
        </tr>
      </thead>
      <tbody>
        <!-- Filled by JavaScript -->
      </tbody>
    </table>
<script language="javascript">
    let globalsData = [];
	const itemsPerPage = 20;
    let currentPage = 1;
    const totalPages = Math.ceil(globalsData.length / itemsPerPage);
	const namespaceSelect = document.getElementById('namespaceSelect');
    if (namespaceSelect) namespaceSelect.addEventListener('change', changeNamespace);
	globalsData = #server(..GetGlobalSize())#;
	globalsData = JSON.parse(globalsData);
    globalsData.sort((a,b) => b.used - a.used);
    document.getElementById('totalPages').textContent = totalPages;
    const ctx = document.getElementById('globalsChart').getContext('2d');
    let globalsChart;
    function renderChartPage(page) {
        const start = (page - 1) * itemsPerPage;
        const end = start + itemsPerPage;
        const pageData = globalsData.slice(start, end);
        const labels = pageData.map(g => g.name);
        const allocatedMB = pageData.map(g => g.allocated);
        const usedMB = pageData.map(g => g.used);
        if (globalsChart) {
            globalsChart.data.labels = labels;
            globalsChart.data.datasets[0].data = allocatedMB;
            globalsChart.data.datasets[1].data = usedMB;
            globalsChart.update();
        } else {
            globalsChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'Allocated MB',
                            data: allocatedMB,
                            backgroundColor: 'rgba(54, 162, 235, 0.6)'
                        },
                        {
                            label: 'Used MB',
                            data: usedMB,
                            backgroundColor: 'rgba(255, 159, 64, 0.6)'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    scales: {
                        x: {
                            ticks: {
                                maxRotation: 90,
                                minRotation: 90,
                                autoSkip: false
                            }
                        },
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'MB'
                            }
                        }
                    },
                    plugins: {
                        legend: { position: 'top' },
                        title: {
                            display: true,
                            text: `Globals Usage - Page ${page} of ${totalPages}`
                        },
                        zoom: {
                            pan: {
                                enabled: true,
                                mode: 'x'
                            },
                            zoom: {
                                wheel: { enabled: true },
                                pinch: { enabled: true },
                                mode: 'x'
                            }
                        }
                    }
                }
            });
        }

        document.getElementById('currentPage').textContent = page;
        document.getElementById('prevBtn').disabled = (page <= 1);
        document.getElementById('nextBtn').disabled = (page >= totalPages);
    }
    document.getElementById('prevBtn').addEventListener('click', () => {
        if(currentPage > 1) {
            currentPage--;
            renderChartPage(currentPage);
        }
    });
    document.getElementById('nextBtn').addEventListener('click', () => {
        if(currentPage < totalPages) {
            currentPage++;
            renderChartPage(currentPage);
        }
    });
    const tableBody = document.querySelector('#globalsTable tbody');
    const searchBox = document.getElementById('searchBox');
    function renderTable(filterText = '') {
        const filtered = globalsData.filter(g => g.name.toLowerCase().includes(filterText.toLowerCase()));
        tableBody.innerHTML = '';

        for (const g of filtered) {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${g.name}</td>
                <td>${g.allocated.toFixed(3)}</td>
                <td>${g.used.toFixed(3)}</td>
            `;
            tableBody.appendChild(row);
        }
    }

    searchBox.addEventListener('input', () => {
        renderTable(searchBox.value);
    });

    // Initial render
    renderChartPage(currentPage);
    renderTable();
    
    function changeNamespace() {
	    const namespaceSelect = document.getElementById('namespaceSelect');
	    globalsData = #server(..GetGlobalSize(namespaceSelect.value))#;
		globalsData = JSON.parse(globalsData);
    	globalsData.sort((a,b) => b.used - a.used);
    	document.getElementById('totalPages').textContent = totalPages;
	    renderChartPage(currentPage);
    	renderTable();
    }
</script>
</body>
</html>
	>
	Quit $$$OK
}

ClassMethod GetGlobalSize(Namespace As %String = "%SYS") As %String
{
	Set response = []
	Set:Namespace="%SYS" Namespace="IRISLIB"
	Set dir = $LG(^["%SYS"]SYS("CONFIG","IRIS","Databases",$ZCVT(Namespace,"U")),3)
	If dir="" Quit response.%ToJSON()
	Set ResultSet= ##class(%SYS.GlobalQuery).SizeFunc(dir)
	While ResultSet.%Next() {
		Set json = { "name":(ResultSet.%GetData(1))}
		Do json.%Set("allocated",ResultSet.%GetData(2),"number")
		Do json.%Set("used",ResultSet.%GetData(3),"number")
		Do response.%Push(json)
	}
	Return response.%ToJSON()
}

}
