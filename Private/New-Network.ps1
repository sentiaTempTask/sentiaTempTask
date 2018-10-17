function New-Network {
    <#
       .SYNOPSIS
           Creates new network
       .DESCRIPTION
           Creates new network
       .PARAMETER Prefix
           Prefix of the storage account
        .PARAMETER ResourceGroupName
           Name of the resource group
        .PARAMETER AddressPrefix
            Network address prefix
        .PARAMATER NoSubnetworks
            Number of subnetworks

       .EXAMPLE
           New-Network -Prefix 'temp' -ResourceGroupName 'tempResourceGroup' -AddressPrefix '172.16.0.0/12' -NoSubnetworks 3
              #>
    [CmdletBinding()]
    Param
    (
        [Parameter (Mandatory)]
        [string]$Prefix,
        [Parameter (Mandatory)]
        [string]$ResourceGroupName,
        [Parameter (Mandatory)]
        [string]$AddressPrefix,
        [Parameter (Mandatory)]
        [int]$NoSubnetworks,
        $ErrorActionPreference = "stop"
   
    )

    Write-Host "Looking for existing virtual network"
    $Name = ("{0}vNetwork" -f $Prefix)
    $vn = Get-AzureRmVirtualNetwork | Where-Object {$_.Name -match $Name}
    if ($null -ne $vn){
        $Name = ('{0}{1}' -f $Name, $vn.Count)
        Write-Host ("Some virtual networks were found: {0}, creating another one..." -f $vn.Count)
    }
    else{
        Write-Host "No virtual network found, creating..."
    }
    $rg = Get-AzureRmResourceGroup -Name $ResourceGroupName
    Write-Host "Creating subnets"
    $subnets = New-Object System.Collections.ArrayList
    For ($i = 0; $i -lt $NoSubnetworks; $i++){
        $sn = New-AzureRmVirtualNetworkSubnetConfig -Name ("{0}subnet{1}" -f $Prefix, $i) -AddressPrefix ("172.16.{0}.0/24" -f ($i + 1))
        $subnets.Add($sn) | Out-Null
    }
    
    $vn = New-AzureRmVirtualNetwork -ResourceGroupName $rg.ResourceGroupName -Location $rg.Location -Name $Name -AddressPrefix $AddressPrefix -Subnet $subnets
    Write-Host "Virtual Network updated"

    #return $vn.Name
}