# Invoke-Backup PowerShell Script

## Overview

The `Invoke-Backup` PowerShell script is designed to back up files from source to destination directories based on an XML configuration file. The script follows SOLID principles, KISS, YAGNI, and DRY while adhering to clean code practices to ensure maintainability and scalability.

---

## Key Features

- **Configurable via XML:** Reads source and destination directories, included file extensions, and excluded file extensions from an XML file.
- **Incremental Backup:** Only backs up files modified since the last backup.
- **File Filtering:** Includes or excludes files based on extensions specified in the XML configuration file.
- **Logging:** Creates detailed logs of backup operations and removes logs older than 30 days.
- **Path Normalization:** Ensures compatibility with both local and network paths.
- **Error Handling:** Handles invalid paths and missing configuration gracefully.

---

## XML Configuration File

The script relies on an XML configuration file to define the backup sources, destinations, and file filtering rules. Here's an example:

```xml
<BackupSettings>
    <Sources>
        <Source>
            <SourcePath>C:\Users\Admin\Documents</SourcePath>
            <DestinationPath>\\MyNAS\Backup\Admin\Documents</DestinationPath>
        </Source>
        <Source>
            <SourcePath>C:\Users\Development</SourcePath>
            <DestinationPath>\\MyNAS\Backup\Admin\Development</DestinationPath>
        </Source>
    </Sources>
    <IncludedFileExtensions Enable="false">
        <Extension>.docx</Extension>
        <Extension>.xlsx</Extension>
        <Extension>.pdf</Extension>
    </IncludedFileExtensions>
    <ExcludedFileExtensions Enable="true">
        <Extension>.tmp</Extension>
        <Extension>.log</Extension>
        <Extension>.bak</Extension>
    </ExcludedFileExtensions>
</BackupSettings>
```
- **Sources:** Defines source directories to back up and their corresponding destinations. 
- **IncludedFileExtensions:** Files with these extensions are included in the backup if Enable is set to true. 
- **ExcludedFileExtensions:** Files with these extensions are excluded from the backup if Enable is set to true. 

### Running the Script

1. Save the script to a `.ps1` file (e.g., `Invoke-Backup.ps1`).
2. Place the XML configuration file (e.g., `BackupConfig.xml`) in the same directory as the script.
3. Execute the script using the following command:

   ```powershell
   .\Invoke-Backup.ps1

> Note that you do not need to specifiy the XML Configuration file, as the script automatically looks for an XML file of the same name of the Invoke-Backup script.

## Automating with Task Scheduler

To schedule the backup script to run weekly:

1. Open **Task Scheduler**.
2. Select **Create Task** from the right-hand menu.
3. Under the **General** tab:
   - Provide a name for the task (e.g., "Weekly Backup").
   - Select **Run whether user is logged on or not**.
   - Check **Run with highest privileges**.
4. Navigate to the **Triggers** tab:
   - Click **New**.
   - Set the task to run weekly and select the desired day and time.
5. Go to the **Actions** tab:
   - Click **New**.
   - In the **Action** dropdown, select **Start a program**.
   - In the **Program/script** field, enter:
     ```plaintext
     powershell.exe
     ```
   - In the **Add arguments (optional)** field, enter:
     ```plaintext
     -NoProfile -ExecutionPolicy Bypass -File "C:\Path\To\Invoke-Backup.ps1" -ConfigFile "C:\Path\To\BackupConfig.xml"
     ```
6. (Optional) Set conditions and advanced settings under the **Conditions** and **Settings** tabs.
7. Click **OK** and provide your credentials if prompted.

## Contribution

Contributions are welcome! Please fork the repository and submit pull requests to enhance functionality or fix bugs.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Contact

For any questions, suggestions, or issues, please open an issue or contact **Script Ranger**.
