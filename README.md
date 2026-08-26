## 📖 How to Use

### Run From CMD Console as Administrator

---

> [!WARNING]
> **Do Not Interrupt or Power Off During Execution:**
> Please allow each process to complete fully to prevent potential file system or OS corruption.

#### 🛠️ Available Menu Options

* **[1] Schedule Disk Scan (CHKDSK):** Marks drive `C:` for a disk check on next reboot to find and fix file system errors.
* **[2] Full System Repair (DISM + SFC):** Repairs corrupted Windows system files using DISM and SFC scans.
* **[3] Clean Temp Files / Cache:** Deletes temp files and Windows Update cache, then runs Disk Cleanup to free up space.
* **[4] Toggle Hibernate:** Turns hibernate on/off — disabling it frees up disk space (removes `hiberfil.sys`).
* **[5] Run All Tasks [1,2,3,4]:** Runs tasks 1–4 automatically in sequence, one after another.
* **[6] Create System Restore Point:** Saves a system snapshot so you can roll back if something goes wrong later.
* **[7] Check Disk Space:** Shows used, free, and total space for every drive on the computer.
* **[8] Reset Network:** Flushes DNS, renews IP, and resets Winsock/TCP-IP to fix internet connection issues.
* **[9] Restart Computer Now:** Restarts the PC after a 5-second countdown and confirmation prompt.

---

### 🚀 How to Launch / Run Script

#### Option 1: Download File directly
* Download [`Cleanup.bat`](https://github.com/Itzchxion/Disk-Cleanup/raw/main/Cleanup.bat) or [`Cleanup_code.cmd`](https://github.com/Itzchxion/Disk-Cleanup/raw/main/Cleanup_code.cmd)
* Right-click the downloaded file and select **"Run as administrator"**

#### Option 2: Copy Code & Run manually
1. Copy all source code from [`Cleanup.bat`](https://raw.githubusercontent.com/Itzchxion/Disk-Cleanup/main/Cleanup.bat)
2. Open **Command Prompt (CMD)** as **Administrator**
3. Paste the code into the console and press **Enter**
