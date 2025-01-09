Function Invoke-Backup {
    <#
    .SYNOPSIS
        Backs up files from source to destination directories based on an XML configuration.
     
    .NOTES
        Name: Invoke-Backup
        Author: Script Ranger
        Version: 2.0
        DateCreated: 2025.01.08
     
    .EXAMPLE
        Invoke-Backup
     
    .LINK
        https://github.com/YourRepositoryLinkHere
    #>
    
    <# [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string] $ConfigFile
    ) #>

    BEGIN {
        $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

        $myRootPath = $PSScriptRoot
        $myFunctionName = $MyInvocation.MyCommand.Name

        Push-Location $myRootPath

        $logDir = Join-Path -Path "$myRootPath" -ChildPath "_log"
        $outputDir = Join-Path -Path "$myRootPath" -ChildPath "_output"
        $logFile = Join-Path -Path $logDir -ChildPath "$((Get-Date).ToString('yyyy.MM.dd.HHmmss')).$myFunctionName.log"
        $lastBackupFile = Join-Path -Path $outputDir -ChildPath "LastBackup.log"
        $configFile = "$myFunctionName.xml"

        # Ensure directories exist
        if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir }
        if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir }

        Start-Transcript -Path $logFile

        # Clear old logs (older than 30 days)
        Get-ChildItem -Path $logDir -Filter "*.log" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force

        # Check config file
        if (!(Test-Path $ConfigFile)) {
            throw "Configuration file '$ConfigFile' does not exist."
        }

        # Load XML configuration
        if (Test-Path $configFile) {
            [xml]$config = Get-Content $configFile
            if (!$config.BackupSettings) {
                throw "Invalid XML structure. Ensure the file contains a 'BackupSettings' root element."
            }
            
            $backupPairs = $config.BackupSettings.Sources.Source

             # Parse included and excluded extensions
            $filterIncludedExtensions = $config.BackupSettings.IncludedFileExtensions.Enable -eq "true"
            $filterExcludedExtensions = $config.BackupSettings.ExcludedFileExtensions.Enable -eq "true"

            $includedExtensions = @()
            $excludedExtensions = @()

            if ($filterIncludedExtensions) {
                $includedExtensions = $config.BackupSettings.IncludedFileExtensions.Extension | ForEach-Object { $_.TrimStart('.') }
            }

            if ($filterExcludedExtensions) {
                $excludedExtensions = $config.BackupSettings.ExcludedFileExtensions.Extension | ForEach-Object { $_.TrimStart('.') }
            }
        }

        # Load last backup time
        if (Test-Path $lastBackupFile) {
            $lastBackupTime = Get-Content $lastBackupFile | Out-String | ConvertTo-DateTime
        } else {
            $lastBackupTime = Get-Date "1900-01-01"
        }
    }

    PROCESS {
        foreach ($pair in $backupPairs) {
            $source = $pair.SourcePath
            $destination = $pair.DestinationPath
    
            if (!(Test-Path $source)) {
                Write-Warning "Source path '$source' does not exist. Skipping."
                continue
            }
    
            if (!(Test-Path $destination)) {
                Write-Output "Destination path '$destination' does not exist. Creating."
                New-Item -ItemType Directory -Path $destination -Force
            }
    
            # Normalize paths for consistency
            $normalizedSource = [System.IO.Path]::GetFullPath($source)
            $normalizedDestination = [System.IO.Path]::GetFullPath($destination)
    
            # Backup files based on extensions, flags, and modification date
            Get-ChildItem -Path $normalizedSource -Recurse | Where-Object {
                $_.LastWriteTime -gt $lastBackupTime -and
                (!$filterIncludedExtensions -or $_.Extension.TrimStart('.') -in $includedExtensions) -and
                (!$filterExcludedExtensions -or $_.Extension.TrimStart('.') -notin $excludedExtensions)
            } | ForEach-Object {
                # Ensure proper formatting of destination path
                $relativePath = $_.FullName.Substring($normalizedSource.Length).TrimStart('\')
                $targetPath = Join-Path -Path $normalizedDestination -ChildPath $relativePath
    
                $targetDir = Split-Path -Path $targetPath -Parent
    
                if (!(Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force
                }
    
                Write-Output "Backing up: $_.FullName to $targetPath"
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
            }
        }
    }

    END {
        # Log the completion time
        (Get-Date).ToString("o") | Out-File -FilePath $lastBackupFile -Force

        $stopWatch.Stop()
        Write-Output "$myFunctionName Completed"
        Write-Output $stopWatch.Elapsed
        Stop-Transcript
        Pop-Location
    }
}


Invoke-Backup