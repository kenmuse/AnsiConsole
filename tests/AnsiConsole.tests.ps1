Set-StrictMode -Version 'Latest'
#Requires -Version 5.0

$moduleName = $MyInvocation.MyCommand.Name -replace '.tests.ps1'
$testRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scriptRoot = $testRoot -replace 'tests','src'
Get-Module $moduleName | Remove-Module -Force
Import-Module "$scriptRoot/$moduleName.psm1" -Force

InModuleScope $moduleName {
    Describe "Automatic Reset Disabled" {
        Context "Given a request to set the console text color to red with reset disabled" {
            Set-AnsiAutoReset $false
            It "Should not automatically reset the state at the end" {
               "Test"
                | Set-AnsiConsole -Foreground Red
                |  Should -Match 'Test$'
            }
        }
    }

    Describe "Automatic Reset" {
        Context "Given a request to set the console text color to red" {

            It "Should automatically reset the state at the end" {
               "Test"
                | Set-AnsiConsole -Foreground Red
                |  Should -Match ([char]0x001B)+'[0m$'
            }
        }
    }
}