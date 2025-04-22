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
$nicName = "$vmName-nic"
$publicIpName = "$vmName-pip"
$vnetName = "virtual-nw-dev"
$subnetName = "subnet-frontend" 

# Get existing VNet and Subnet
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

# Create Public IP
$publicIp = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName `
    -Location $location -AllocationMethod Dynamic

# Create NIC
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName `
    -Location $location -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id    

# Create a new VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName ( ($vmImage -split ":")[0] ) `
    -Offer ( ($vmImage -split ":")[1] ) -Sku ( ($vmImage -split ":")[2] ) `
    -Version ( ($vmImage -split ":")[3] )

# Set the operating system of the VM (using the image provided)
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName `
    -Credential (New-Object System.Management.Automation.PSCredential($adminUsername, $securePassword)) `
    -DisablePasswordAuthentication $false

# Set the image for the VM (provided in the parameters)

#  Attach the NIC to the VM
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host "VM creation initiated: $vmName"
