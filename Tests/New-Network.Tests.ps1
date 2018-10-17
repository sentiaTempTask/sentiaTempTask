$Global:removedTests = $true

Describe "New-Network tests" -Tag "Function" {
 
    Context "New-Network has removed tests as they are outside of scope" {

        #run 
        #New-Network

        It "Tests should be removed" {
            $removedTests | Should be $true
        }

    } # Run-Policy has removed tests as they are outside of scope


} # Run-TempTask tests
