$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'
#Requires -Version 5.0

function Update-Module {
    param
    (
        [string] $PsdPath,
        [string] $VersionNumber
    )

    process {
        $manifest = Import-PowerShellDataFile $PsdPath
        [version]$version = $manifest.ModuleVersion
        Write-Output "Updating version from $version to $VersionNumber"
        [version]$newVersion = $VersionNumber

        # Update the manifest file
        try {
            (Get-Content $file) -replace $version, $newVersion | Set-Content $file -Encoding string
        }
        catch {
            Write-Error "Failed to update the module: $_"
        }
    }
}