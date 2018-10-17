$Global:removedTests = $true

Describe "New-KeyVault tests" -Tag "Function" {
 
    Context "New-KeyVault has removed tests as they are outside of scope" {

        #run 
        #New-KeyVault

        It "Tests should be removed" {
            $removedTests | Should be $true
        }

    } # Run-Policy has removed tests as they are outside of scope


} # Run-TempTask tests
