function Enter-TempTask {
    <#
       .SYNOPSIS
           Creates what needs to be created
       .DESCRIPTION
           Function created all the necessary objects using template and parameter files
        .PARAMETER prefix
            Prefeix for all the names
        .PARAMETER location
            Location for all resources
        .PARAMETER subnetworks
            Number of subnetworks
        .PARAMETER adressPrefix
            Prefix of network address
   
       .EXAMPLE
           Enter-TempTask
              #>
    [CmdletBinding()]
    Param
    (
        [string]$prefix = 'sentia',
        [string]$location = 'westeurope',
        [int]$subnetworks = 3,
        [string]$adressPrefix = '172.16.0.0/12',
        $ErrorActionPreference = "stop"
   
    )
    <#$parameters = (Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath '.\Templates\sentiaParameters.json') | ConvertFrom-Json)
    $prefix = $parameters.parameters.prefix.value
    $location = $parameters.parameters.location.value
    $subnetworks = $parameters.parameters.subnetworks.value
    $adressPrefix = $parameters.parameters.addressPrefix.value#>

    #log in to Azure
    Write-Host "Checking if there is azure account connected"
        try{
            Get-AzureRmSubscription | Out-Null
        }
        catch{
            Write-Host "No azure account connected, please log in"
            Connect-AzureRmAccount
        }
        $tenantID = (Get-AzureRmSubscription).TenantId
    Write-Host "Azure connected"

    <#Write-Host "Checking if there is azure ad connected"
    #required Install-Module -Name AzureAD
    try{
        Get-AzureADTenantDetail | Out-Null
    }catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException]{
        Connect-AzureAD -TenantId $tenantID
    }
    #>
    
    #create a resource group
    Write-Host "Resource group creation"
    $rgName = New-ResourceGroup -Prefix $prefix -location $location
    Write-Host "Resource group is ready"
    #create a policy
    Write-Host "Policy creation"
    $policyName = New-Policy -PathToFiles $PSScriptRoot -Prefix $prefix
    Write-Host "Policy created"

    <# not being able to make it work this way. Encryption will be done by "default" mechanism.
    Write-Host "Creating key vault"
    $kvName = New-KeyVault -Prefix $prefix -ResourceGroupName $rgName
    Write-Host "Key vault created"
    #>

    #create a storage account
    Write-Host "Creating encrypted storage account"
    New-StorageAccount -Prefix $prefix -ResourceGroupName $rgName -KeyVaultName 'not used' #$kvName.VaultName
    Write-Host "Encrypted storage account created"

    #create a vritual network
    #create 3 subnets
    Write-Host "Creating virtual network"
    New-Network -Prefix $prefix -ResourceGroupName $rgName -AddressPrefix $adressPrefix -NoSubnetworks $subnetworks
    Write-Host "Virtual network created"

    #apply tags on resource group
    New-AzureRmTag -Name Company -Value 'Sentia' | Out-Null
    New-AzureRmTag -Name Environment -Value 'Test' | Out-Null

    Get-AzureRmResource -ResourceGroupName $rgName  | Set-AzureRmResource -Tag @{Company="Sentia";Environment="Test"} -Force | Out-Null

    #apply policy on a resource group and subscription
    $rg = Get-AzureRmResourceGroup -Name $rgName
    $subs = Get-AzureRmSubscription
    $definition = Get-AzureRmPolicyDefinition | Where-Object {$_.Name -match $policyName}
    Write-Host "Assigning policy to resource group"
    New-AzureRmPolicyAssignment -Name 'allowed-resource-types-rg' -DisplayName 'Allowed resource types on resource group' -Scope $rg.ResourceId -PolicyDefinition $definition | Out-Null
    if ($subs.Count -gt 1){
        $subScope = ('/subscriptions/{0}' -f $subs[0].SubscriptionId)
    }else{
        $subScope = ('/subscriptions/{0}' -f $subs.SubscriptionId)
    }
    New-AzureRmPolicyAssignment -Name 'allowed-resource-types-sub' -DisplayName 'Allowed resource types on subscription' -Scope $subScope -PolicyDefinition $definition | Out-Null

    Write-Host "Policies assigned"
}