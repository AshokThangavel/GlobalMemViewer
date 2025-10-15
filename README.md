# 🌐 Global Memory Viewer

The **Global Memory Viewer** is a lightweight, web-based CSP application for **InterSystems IRIS** that allows developers and administrators to:

- View **allocated** and **used** memory space of all **globals** in the current namespace.
- Interact with a **chart-based visual representation** of global sizes.
- Browse and **search** global usage data in a **sortable, filterable table**.
- Switch between **namespaces** to view global storage details per namespace.

---

## 🔧 Features

✅ Interactive **bar chart** of global usage  
✅ Pagination support for large numbers of globals  
✅ Searchable **global details table**  
✅ Dropdown to select **IRIS namespaces**  
✅ Displays **Allocated MB** vs **Used MB**  
✅ Uses **Chart.js** and pure CSP – no external frameworks required

---
## ⚙️ Installation

You can install ZIRIS DevHub by cloning this repository or importing the classes into your IRIS namespace:
1. **Clone the repository**:
   ```bash
   git clone https://github.com/AshokThangavel/GlobalMemViewer.git
2. **Navigate to the project directory**:

   ```bash
   cd GlobalMemViewer
   ```

3. **Run the docker compose file**:

   ```bash
   docker compose -f docker-compose.yml up -d --build
   ```
---

http://localhost/csp/user/Globals.SizeMonitor.cls

## 📸 Screenshots

### 📊 Chart View (Paginated)
<img width="1900" height="888" alt="image" src="https://github.com/user-attachments/assets/3c9c94e1-3a9c-43d1-a0da-bc42ce5b12f7" />


### 📋 Globals Table View
<img width="1389" height="836" alt="image" src="https://github.com/user-attachments/assets/b31e2225-0586-4bf9-8e35-a0fe33f3c903" />

----

