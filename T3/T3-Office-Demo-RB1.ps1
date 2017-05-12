$domainName = "ned.mtc-bos.com"
$azureCredentialName = "Get-AutomationPSCredential -Name 'AzureOrgIdCredential'
$Location = "United States"

$cred = Get-AutomationPSCredential -Name $azureCredentialName
Connect-MsolService -Credential $cred

$users = get-msoluser -all -DomainName $domainName
$groups = get-msolgroup | Where-Object { 
    $_.displayname -like "LICENSE*" 
}

Get-MsolAccountSku
$users = get-msoluser -all
$users