function New-ResourceGroup {
    <#
       .SYNOPSIS
           Creates new resource group
       .DESCRIPTION
           Creates new resource group using files with parameters and tempalte
       .PARAMETER Prefix
           Prefix of the resource group
        .PARAMETER Location
           Location of the resource group

       .EXAMPLE
           New-ResourceGroup 'temp' -location 'easteuropa'
              #>
    [CmdletBinding()]
    Param
    (
        [Parameter (Mandatory)]
        [string]$Prefix,
        [string]$Location,
        $ErrorActionPreference = "stop"
   
    )

    Write-Host "Looking for existing resource groups"
    $rg = Get-AzureRmResourceGroup | Where-Object {$_.ResourceGroupName -match $Prefix}
    $Name = ('{0}ResourceGroup' -f $Prefix)
    if ($null -ne $rg){
        $Name = ('{0}{1}' -f $Name, $rg.Count)
        Write-Host ("Some resource groups were found: {0}, creating another one..." -f $rg.Count)
    }
    else{
        Write-Host "No resource group found, creating..."
    }
    New-AzureRmResourceGroup -Name $Name -Location $Location | Out-Null
    Write-Host ("Resource group {0} created" -f $Name)

    return $Name
}