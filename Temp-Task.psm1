
    #Load assemblies
    #[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    #[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    #$currentLocation = (Get-Location).Path
    #Import-Module SQLPS -DisableNameChecking
    #Set-Location $currentLocation


#Get function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )
    $Private  = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }


    #Here for future use: Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename