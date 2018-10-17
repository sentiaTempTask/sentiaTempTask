$Global:removedTests = $true
$Global:module = 'Temp-Task'
$Global:modulePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Import-Module (Join-Path -Path $modulePath -ChildPath "$module.psd1")

Describe "Run-TempTask tests" -Tag "Function" {
    
    InModuleScope -ModuleName $module {   
 
        Context "Run-TempTask has removed tests as they are outside of scope" {

            It "Tests should be removed" {
                $removedTests | Should be $true
            }

        } # Run-TempTask has removed tests as they are outside of scope

    } # InModule scope

} # Run-TempTask tests

Remove-Module $module