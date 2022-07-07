$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'
#Requires -Version 5.0

function Get-Unexported {
    $module = Import-Module -Name "./src/AnsiConsole.psm1" -PassThru
    $all = $module.Invoke({(Get-Command -Module AnsiConsole)})
    $exported = Get-Command -Module AnsiConsole
    $items = Compare-Object -ReferenceObject $all -DifferenceObject $exported |
        Select-Object -ExpandProperty InputObject
    $items
}
