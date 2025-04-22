$vmName = $env:VM_NAME
$vmSize = $env:VM_SIZE
$adminUsername = $env:ADMIN_USERNAME
$adminPassword = $env:ADMIN_PASSWORD
$resourceGroupName = $env:RESOURCE_GROUP
$location = $env:LOCATION
$vmImage = $env:VM_IMAGE
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force


# Initialize a flag for missing parameters
$missingParams = @()

# Check for missing parameters and store the missing ones
if ([string]::IsNullOrEmpty($vmName)) { $missingParams += "vmName" }
if ([string]::IsNullOrEmpty($vmSize)) { $missingParams += "vmSize" }
if ([string]::IsNullOrEmpty($adminUsername)) { $missingParams += "adminUsername" }
if ([string]::IsNullOrEmpty($adminPassword)) { $missingParams += "adminPassword" }
if ([string]::IsNullOrEmpty($resourceGroupName)) { $missingParams += "resourceGroupName" }
if ([string]::IsNullOrEmpty($location)) { $missingParams += "location" }
if ([string]::IsNullOrEmpty($vmImage)) { $missingParams += "vmImage" }

# If there are any missing parameters, output them and exit
if ($missingParams.Count -gt 0) {
    Write-Host "Error: The following parameters are missing: $($missingParams -join ', ')"
    exit 1
}

Write-Host "Creating VM with the following parameters:"
Write-Host "VM Name: $vmName"
Write-Host "VM Size: $vmSize"
Write-Host "Admin Username: $adminUsername"
Write-Host "Resource Group: $resourceGroupName"
Write-Host "Location: $location"
Write-Host "VM Image: $vmImage"
$parts = $vmImage -split ":"
$publisher = $parts[0]
$offer     = $parts[1]
$sku       = $parts[2]
$version   = $parts[3]

# 3) NIC + Public IP names
$nicName      = "$vmName-nic"
$publicIpName = "$vmName-pip"
$vnetName     = "virtual-nw-dev"    # replace with your VNet
$subnetName   = "subnet-frontend"   # replace with your Subnet

# 4) Get existing VNet & Subnet
$vnet   = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

# 5) Create a Basic SKU Public IP with Dynamic allocation
$publicIp = New-AzPublicIpAddress `
  -Name $publicIpName `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -Sku Basic `
  -AllocationMethod Dynamic

# 6) Create the NIC, referencing the Public IP’s Id
$nic = New-AzNetworkInterface `
  -Name $nicName `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -SubnetId $subnet.Id `
  -PublicIpAddressId $publicIp.Id

# 7) Build the VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

# 8) Apply the Marketplace image first
$vmConfig = Set-AzVMSourceImage `
  -VM $vmConfig `
  -PublisherName $publisher `
  -Offer $offer `
  -Sku $sku `
  -Version $version

# 9) Enable Linux OS + password auth
$vmConfig = Set-AzVMOperatingSystem `
  -VM $vmConfig `
  -Linux `
  -ComputerName $vmName `
  -Credential (New-Object System.Management.Automation.PSCredential($adminUsername, $securePassword)) `
  -DisablePasswordAuthentication:$false

# 10) Attach the NIC by its Id
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# 11) Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host "VM creation initiated: $vmName"
