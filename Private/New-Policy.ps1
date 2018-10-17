function New-Policy {
    <#
       .SYNOPSIS
           Creates new policy
       .DESCRIPTION
           Creates new policy using parameter
       .PARAMETER PathToFiles
           Path to the paramteres and template files
        .PARAMETER Prefix
            Prefix used in names

       .EXAMPLE
           New-Policy -PathToFiles 'c:\temp'
              #>
    [CmdletBinding()]
    Param
    (
        [Parameter (Mandatory)]
        [string]$PathToFiles,
        [string]$Prefix,
        $ErrorActionPreference = "stop"
   
    )

    $paramFile = ('{0}\Templates\{1}PolicyParameters.json' -f $PathToFiles, $Prefix)
    $templateFle = ('{0}\Templates\{1}Policy.json' -f $PathToFiles, $Prefix)
    #Verify if files exist - based on provided name
    if (!(Test-Path -Path $paramFile)) {
        Throw ("Parameters file is missing! {0}" -f $paramFile)
    }
    if (!(Test-Path -Path $templateFle)) {
        Throw ("Template file is missing! {0}" -f $templateFle)
    }

    Write-Host "Looking for allowed resource policy..."
    $policy = Get-AzureRmPolicyDefinition | Where-Object {$_.Name -match "allowed-resourcetypes"}
    if ($null -eq $policy){
        Write-Host "Policy not found, creating"
        $policy = New-AzureRmPolicyDefinition -Name "allowed-resourcetypes" -DisplayName "Allowed resource types" -description "This policy enables you to specify the resource types that your organization can deploy." -Policy $templateFle -Parameter $paramFile -Mode All
    }else{
        Write-Host "Policy found, skipping creation of new one"
    }
    
    return $policy.Name
}