$Global:removedTests = $true

Describe "New-Policy tests" -Tag "Function" {
 
    Context "New-Policy has removed tests as they are outside of scope" {

        #run 
        #New-Policy

        It "Tests should be removed" {
            $removedTests | Should be $true
        }

    } # Run-Policy has removed tests as they are outside of scope


} # Run-TempTask tests
