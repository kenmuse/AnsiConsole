Set-StrictMode -Version 'Latest'
#Requires -Version 5.0

$script:ModuleName = $MyInvocation.MyCommand.Name -replace '.tests.ps1'
$testRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scriptRoot = $testRoot -replace 'tests', 'src'
$script:AnsiConsoleModulePath = "$scriptRoot/$ModuleName.psm1"

BeforeAll {
    Import-Module $AnsiConsoleModulePath -Force
}

Describe "Automatic reset disabled" {
    Context "Given a request to set the console text color to red with reset disabled" {
        It "Should not automatically reset the state at the end" {
            Set-AnsiAutoReset $false
            "Test" `
            | Set-AnsiConsole -Foreground Red `
            | Should -Be ("$([char]0x001B)[31mTest")
        }

        AfterAll {
            Set-AnsiAutoReset $true
        }
    }
}

Describe "Automatic reset" {
    Context "Given a request to set the console text color to red" {
        It "Should automatically reset the state at the end" {
            "Test" `
            | Set-AnsiConsole -Foreground Red `
            | Should -Be ("$([char]0x001B)[31mTest$([char]0x001B)[0m")
        }
    }
}

Describe "Parse RGB Hex values using Convert-ToRgbArray" {
    Context "Given an RGB string value 12ABEF" {
        It "Should parse the RGB value to an RGB array" {
            InModuleScope $ModuleName {
                Convert-ToRgbArray -Value "12ABEF" `
                | Should -Be @([byte]0x12, [byte]0xAB, [byte]0xEF)
            }
        }
    }

    Context "Given an RGB string value #CA2345" {
        It "Should parse the prefixed RGB value to an RGB array" {
            InModuleScope $ModuleName {
                Convert-ToRgbArray -Value "#CA2345" `
                | Should -Be @([byte]0xCA, [byte]0x23, [byte]0x45)
            }
        }
    }

    Context "Given an RGB string value 12ABEFA" {
        It "Should fail to parse" {
            InModuleScope $ModuleName {
                { Convert-ToRgbArray -Value "12ABEFA" } `
                | Should -Throw
            }
        }
    }

    Context "Given an RGB string value #CA2345A" {
        It "Should fail to parse" {
            InModuleScope $ModuleName {
                { Convert-ToRgbArray -Value "#CA2345A" } `
                | Should -Throw
            }
        }
    }
}
