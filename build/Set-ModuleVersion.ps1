$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'
#Requires -Version 5.0

function Set-ModuleVersion {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
    param
    (
        [string] $PsdPath,
        [string] $VersionNumber,
        [switch] $Force
    )

    process {
        $manifest = Import-PowerShellDataFile $PsdPath
        [version]$version = $manifest.ModuleVersion
        if ($Force -or $PSCmdlet.ShouldProcess($PsdPath, "Update manifest from $version to $VersionNumber")){
            Write-Information "Updating version from $version to $VersionNumber"
            [version]$newVersion = $VersionNumber

            # Update the manifest file
            try {
                (Get-Content $PsdPath) -replace $version, $newVersion | Set-Content $PsdPath -Encoding utf8NoBOM
            }
            catch {
                Write-Error "Failed to update the module: $_"
            }
        }
    }
}
