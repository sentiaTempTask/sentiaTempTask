#assumptions

$Global:module = 'Temp-Task'
$Global:functionsToExport = @(
    'Enter-TempTask'
)
$functionsToHide = @(
    'New-KeyVault'
    'New-Network'
    'New-Policy'
    'New-ResourceGroup'
    'New-StorageAccount'
)
$skipFunctionTestFiles = $false


#variables used in tests based on assumptions

$Global:modulePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Import-Module (Join-Path -Path $modulePath -ChildPath "$module.psd1")

#Tests

Describe "basic module tests" -Tag "Module" {

    Context "$module has required files" {

        It "$module file is existing" {
            $p = Join-Path -Path $modulePath -ChildPath "$module.psm1"
            $p | Should -Exist
        }

        It "$module description file is existing" {
            $p = Join-Path -Path $modulePath -ChildPath "$module.psd1"
            (Test-Path -Path $p) | Should -be $true
        }

        It "$module has functions files " {
            Join-Path -Path $modulePath -ChildPath "*.ps1" | Should -Exist
        }

    }# Context "$module has required files"

    Context "$module has basic powershell functionality" {

        It "$module has valid code" {
            $ps = Get-Content -Path (Join-Path -Path $modulePath -ChildPath "$module.psm1") -ErrorAction Stop
            $error = $null
            [System.Management.Automation.PSParser]::Tokenize($ps,[ref]$error) | Out-Null
            $error.Count | Should -be 0
        } 

        It "$module exports any methods" {
            $mod = get-module -Name $module
            $mod.ExportedCommands.Count | Should -not -be 0
        }
        
        It "$module exports the same number of methods as expected" {
            (Get-Module $module).ExportedCommands.Count | Should Be $functionsToExport.Count
        }

        foreach ($function in $functionsToExport){
            It "$module exports function $function" {
                $mod = get-module -Name $module
                ($mod.ExportedCommands.Keys -contains "$function")| Should -be $true
            }
        }

        foreach ($function in $functionsToHide){
            It "$module doesn't export hidden function $function" {
                $mod = get-module -Name $module
                ($mod.ExportedCommands.Keys -contains "$function")| Should -be $false
            }
        }
    
    } # Context "$module basic Powershell functionality"

    #InModuleScope $module { #tests executed in the context of module

    #module variables
    $skipFunctionTestFiles = $false

        Context "$module exported functions structure test" {

            foreach($function in $functionsToExport){
                $file = (Join-Path $modulePath -ChildPath "$function.ps1")

                It "function $function is exported" {
                    $mod = get-module -Name $module
                    ($mod.ExportedCommands.Keys -contains "$function") | Should -be $true
                }

                It "function $function has valid code" {
                    $ps = Get-Content -Path $file -ErrorAction Stop
                    $error = $null
                    [System.Management.Automation.PSParser]::Tokenize($ps,[ref]$error) | Out-Null
                    $error.Count | Should -be 0
                } 

                It "function $function is an advanced function" {
                    $file | Should -FileContentMatch "function"
                    $file | Should -FileContentMatch "cmdletbinding"
                    $file | Should -FileContentMatch "param"
                }

                It "function $function has file with tests" -Skip:$skipFunctionTestFiles {
                    $testsFile = (Join-Path $modulePath -ChildPath "Tests\$function.Tests.ps1")
                    $testsFile | Should -Exist
                }

                It "function $function has help block" {
                    $file | Should -FileContentMatch '<#'
                    $file | Should -FileContentMatch '#>'
                }

                It "function $function has Synopsis block" {
                    $file | Should -FileContentMatch 'SYNOPSIS'
                }
            
                It "function $function has Description block" {
                    $file | Should -FileContentMatch 'DESCRIPTION'
                }
            
                It "function $function has Parameter block" {
                    $file | Should -FileContentMatch 'PARAMETER'
                }
            
                It "function $function has Example block" {
                    $file | Should -FileContentMatch 'EXAMPLE'
                }


            }

        }# "$module exported functions"

    #}

}

#cleanup
Remove-Module $module


#inny plik

#clean dbs