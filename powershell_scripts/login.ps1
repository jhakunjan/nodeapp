$creds = $env:AZURE_CREDENTIALS_JSON | ConvertFrom-Json
$securePassword = ConvertTo-SecureString $creds.clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($creds.clientId, $securePassword)

Connect-AzAccount -ServicePrincipal `
    -TenantId $creds.tenantId `
    -Credential $credential | Out-Null

Set-AzContext -SubscriptionId $creds.subscriptionId | Out-Null
Write-Host " Azure login successful"
