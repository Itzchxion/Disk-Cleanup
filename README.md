## How to Use

### Run From CMD Console as Administrator

---

> [!WARNING]
> Do Not Interrupt or Power Off During Execution:
CHKDSK: Never force power-off your PC while it is scanning drive C: during reboot. Interruption can corrupt file entries or render the system unbootable.
DISM & SFC: Do not close the Command Prompt window while these tasks are running, as incomplete repairs may leave system files in an unstable state.
Expect Varying Execution Times:
CHKDSK (/f /r): Can take anywhere from 30 minutes to several hours depending on drive size and hardware health (traditional HDDs take significantly longer than SSDs).
DISM /Restorehealth: Requires an active internet connection, as Windows downloads clean replacement files directly from Microsoft servers.
Impact of Disabling Hibernate (Option 4):
Disabling Hibernate automatically turns off Windows Fast Startup. While modern NVMe/SSDs won't notice a speed difference, traditional hard drives (HDDs) may experience slightly longer boot times.
Save Your Work First:
Before selecting Option [1] or Option [5], save all open documents and close applications, as a system reboot will be required to perform the disk check.

### Launch with UI
- None
