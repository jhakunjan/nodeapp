# Ensure the environment variable AZURE_CREDENTIALS_JSON is set
if (-not $env:AZURE_CREDS_JSON) {
    Write-Host "Error: AZURE_CREDENTIALS_JSON is not set!"
    exit 1
}

# Convert the JSON string to a PowerShell object
$creds = $env:AZURE_CREDS_JSON | ConvertFrom-Json

# Check if the necessary fields are available in the credentials
if (-not $creds.clientId -or -not $creds.clientSecret -or -not $creds.tenantId -or -not $creds.subscriptionId) {
    Write-Host "Error: Missing required credentials (clientId, clientSecret, tenantId, or subscriptionId)!"
    exit 1
}

# Convert the client secret to a secure string
$securePassword = ConvertTo-SecureString $creds.clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($creds.clientId, $securePassword)

# Login to Azure using the provided Service Principal credentials
Connect-AzAccount -ServicePrincipal `
    -TenantId $creds.tenantId `
    -Credential $credential | Out-Null

# Set the Azure subscription context
Set-AzContext -SubscriptionId $creds.subscriptionId | Out-Null

Write-Host "Azure login successful"
