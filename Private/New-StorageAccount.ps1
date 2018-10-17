function New-StorageAccount {
    <#
       .SYNOPSIS
           Creates new storage account
       .DESCRIPTION
           Creates new storage account with provided parameters
       .PARAMETER Prefix
           Prefix of the storage account
        .PARAMETER ResourceGroupName
           Name of the resource group
        .PARAMETER KeyVaultName
           Name of the key vault

       .EXAMPLE
           New-StorageAccount -Prefix 'temp' -ResourceGroupName 'tempResourceGroup' -KeyVaultName 'tempKeyVault'
              #>
    [CmdletBinding()]
    Param
    (
        [Parameter (Mandatory)]
        [string]$Prefix,
        [Parameter (Mandatory)]
        [string]$ResourceGroupName,
        [Parameter (Mandatory)]
        [string]$KeyVaultName,
        $ErrorActionPreference = "stop"
   
    )

    Write-Host "Looking for existing storage accounts"
    $Name = ("{0}storageaccount" -f $Prefix.ToLower())
    $sa = Get-AzureRmStorageAccount | Where-Object {$_.StorageAccountName -match $Name}
    if ($null -ne $sa){
        $Name = ('{0}{1}' -f $Name, $sa.Count)
        Write-Host ("Some storage accounts were found: {0}, creating another one..." -f $sa.Count)
        #apparently there already such account as sentiastorageaccount1
        if ($sa.Count -eq 1){
            $Name = ("{0}storageaccount01" -f $Prefix.ToLower())
        }
    }
    else{
        Write-Host "No storage account found, creating..."
    }
    $rg = Get-AzureRmResourceGroup -Name $ResourceGroupName
    $sa = New-AzureRmStorageAccount -ResourceGroupName $rg.ResourceGroupName -Name $Name -Location $rg.Location -SkuName Standard_LRS -Kind StorageV2 -AssignIdentity
    Write-Host "Storage account created"

    Write-Host "Enabling encryption"
    <# $kv = Get-AzureRmKeyVault -VaultName $KeyVaultName
    $sa = Get-AzureRmStorageAccount -StorageAccountName $Name -ResourceGroupName $rg.ResourceGroupName
    $key = Get-AzureKeyVaultKey -VaultName $kv.VaultName -Name ("{0}EncryptionPassword" -f $Prefix)

    #Identity for storage account needs some time to be created - so wait to Azure AD to pick it up
    Start-Sleep -Seconds 30
    # Create Azure Active Directory Security Group 
    #hardcoded as I've spend too much time on this to create a automation
    $aadGroup = Get-AzureADGroup | Where-Object {$_.DisplayName -eq 'SentiaAppGroup'}
    if ($null -eq $aadGroup){
        $aadGroup = New-AzureADGroup -Description "Sentia App Group" -DisplayName "SentiaAppGroup" -MailEnabled 0 -MailNickName none -SecurityEnabled 1 
    }
    Add-AzureADGroupMember -ObjectId $aadGroup.ObjectId -RefObjectId $sa.Identity.PrincipalId

    #and enable encryption using this key
    Set-AzureRmKeyVaultAccessPolicy -VaultName $kv.VaultName -ObjectId $sa.Identity.PrincipalId -PermissionsToKeys wrapkey,unwrapkey,get
    Set-AzureRmStorageAccount -ResourceGroupName $sa.ResourceGroupName -AccountName $sa.StorageAccountName -KeyvaultEncryption -KeyName $key.Name -KeyVersion $key.Version -KeyVaultUri $kv.VaultUri
    
    #>
    
    Set-AzureRmStorageAccount -ResourceGroupName $rg.ResourceGroupName -AccountName $sa.StorageAccountName -StorageEncryption #-KeyvaultEncryption -KeyName $key.Name -KeyVersion $key.Version -KeyVaultUri $keyVault.VaultUri
    Write-Host "Encryption enabled"

    #return $Name
}