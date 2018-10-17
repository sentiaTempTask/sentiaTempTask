function New-KeyVault {
    <#
       .SYNOPSIS
           Creates new key vault
       .DESCRIPTION
           Creates new key vault and add some secret there
       .PARAMETER Prefix
           Prefix of the storage account
        .PARAMETER ResourceGroupName
           Name of the resource group

       .EXAMPLE
           New-KeyVault -Prefix 'temp' -ResourceGroupName 'tempResourceGroup'
              #>
    [CmdletBinding()]
    Param
    (
        [Parameter (Mandatory)]
        [string]$Prefix,
        [Parameter (Mandatory)]
        [string]$ResourceGroupName,
        $ErrorActionPreference = "stop"
   
    )

    Write-Host "Looking for existing key vault"
    $Name = ("{0}KeyVa" -f $Prefix)
    $kv = Get-AzureRmKeyVault | Where-Object {$_.VaultName -match $Name}
    if ($null -ne $kv){
        $Name = ('{0}0{1}' -f $Name, $kv.Count)
        Write-Host ("Some key vaults were found: {0}, creating another one..." -f $kv.Count)
    }
    else{
        Write-Host "No key vault found, creating..."
    }
    $rg = Get-AzureRmResourceGroup -Name $ResourceGroupName
    $kv = New-AzureRmKeyVault -VaultName $Name -ResourceGroupName $rg.ResourceGroupName -Location $rg.Location -EnabledForDiskEncryption -EnableSoftDelete #-EnablePurgeProtection
    Write-Host "Key vault created"
    Write-Host "Creating secret"
    #$keyValue = -join ((65..90) + (97..122) | Get-Random -Count 25 | ForEach-Object {[char]$_})
    #$secretKeyValue = ConvertTo-SecureString $keyValue -AsPlainText -Force
    #Set-AzureKeyVaultSecret -VaultName $kv.VaultName -Name ("{0}EncryptionPassword" -f $Prefix) -SecretValue $secretKeyValue | Out-Null
    Add-AzureKeyVaultKey -VaultName $kv.VaultName -Name ("{0}EncryptionPassword" -f $Prefix) -Destination 'Software'
    Write-Host "Secret created"
    return $kv.VaultName
}