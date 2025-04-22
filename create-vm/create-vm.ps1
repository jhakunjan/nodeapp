param(
    [string]$vmName,
    [string]$vmSize,
    [string]$adminUsername,
    [string]$adminPassword,
    [string]$resourceGroupName,
    [string]$location,
    [string]$vmImage
)

# Create a new VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

# Set the operating system of the VM (using the image provided)
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName `
    -Credential (New-Object System.Management.Automation.PSCredential($adminUsername, $adminPassword)) `
    -DisablePasswordAuthentication $false

# Set the image for the VM (provided in the parameters)
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName ( ($vmImage -split ":")[0] ) `
    -Offer ( ($vmImage -split ":")[1] ) -Sku ( ($vmImage -split ":")[2] ) `
    -Version ( ($vmImage -split ":")[3] )

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host "VM creation initiated: $vmName"
