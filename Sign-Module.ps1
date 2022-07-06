$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'
#Requires -Version 5.0

function Add-CodeSigning {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $SourceCodePath = "./src",

        [Parameter()]
        [string] $PfxContent,

        [Parameter()]
        [securestring] $CertificatePassword
    )

    $decoded = [Convert]::FromBase64String($PfxContent)
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($decoded, $CertificatePassword)

    try {
        Write-Output "Signing Files"
        Get-ChildItem -Path $SourceCodePath -Filter *.ps* -Include *.ps1,*.psm1,*.psd1 -Recurse
            | Where-Object {
                ($_ | Get-AuthenticodeSignature).Status -eq 'NotSigned'
            }
            | Set-AuthenticodeSignature -Certificate $cert -TimestampServer 'http://timestamp.digicert.com'
    }
    catch {
        $_ | Format-List -Force
        Write-Error "Failed to sign scripts"
    }
}