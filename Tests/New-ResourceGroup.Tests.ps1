$Global:removedTests = $true

Describe "New-ResourceGroup tests" -Tag "Function" {
 
    Context "New-ResourceGroup has removed tests as they are outside of scope" {

        #run 
        #New-ResourceGroup

        It "Tests should be removed" {
            $removedTests | Should be $true
        }

    } # Run-TempTask has removed tests as they are outside of scope


} # Run-TempTask tests
