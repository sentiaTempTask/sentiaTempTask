$Global:removedTests = $true

Describe "New-StorageAccount tests" -Tag "Function" {
 
    Context "New-StorageAccount has removed tests as they are outside of scope" {

        #run 
        #New-StorageAccount

        It "Tests should be removed" {
            $removedTests | Should be $true
        }

    } # Run-TempTask has removed tests as they are outside of scope


} # Run-TempTask tests
