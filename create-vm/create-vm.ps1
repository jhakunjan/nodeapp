$vmName = $env:VM_NAME
$vmSize = $env:VM_SIZE
$adminUsername = $env:ADMIN_USERNAME
$adminPassword = $env:ADMIN_PASSWORD
$resourceGroupName = $env:RESOURCE_GROUP
$location = $env:LOCATION
$vmImage = $env:VM_IMAGE
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force

# Parse the image string
$imageParts = $vmImage -split ":"
$publisher = $imageParts[0]
$offer     = $imageParts[1]
$sku       = $imageParts[2]
$version   = $imageParts[3]

# Names for NIC and Public IP
$nicName      = "$vmName-nic"
$publicIpName = "$vmName-pip"
$vnetName     = "virtual-nw-dev"    # replace with your VNet name
$subnetName   = "subnet-frontend"   # replace with your Subnet name

# 1) Validate VNet
try {
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -ErrorAction Stop
} catch {
    Write-Error "Virtual network '$vnetName' not found in RG '$resourceGroupName'"
    exit 1
}

# 2) Validate Subnet
$subnet = $vnet.Subnets | Where-Object Name -EQ $subnetName
if (-not $subnet) {
    Write-Error "Subnet '$subnetName' not found in VNet '$vnetName'"
    exit 1
}

# 3) Create or get Public IP (Basic SKU, Dynamic)
try {
    $publicIp = New-AzPublicIpAddress `
        -Name $publicIpName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Sku Basic `
        -AllocationMethod Dynamic `
        -ErrorAction Stop
} catch {
    Write-Error "Failed to create Public IP '$publicIpName': $_"
    exit 1
}

if (-not $publicIp.Id) {
    Write-Error "Public IP Id is null"
    exit 1
}

# 4) Create NIC
try {
    $nic = New-AzNetworkInterface `
        -Name $nicName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $publicIp.Id `
        -ErrorAction Stop
} catch {
    Write-Error "Failed to create NIC '$nicName': $_"
    exit 1
}

if (-not $nic.Id) {
    Write-Error "NIC Id is null"
    exit 1
}

# 5) Build VM config
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

# 6) Set Marketplace image first
$vmConfig = Set-AzVMSourceImage `
    -VM $vmConfig `
    -PublisherName $publisher `
    -Offer $offer `
    -Sku $sku `
    -Version $version

# 7) Enable Linux OS + password auth
$vmConfig = Set-AzVMOperatingSystem `
    -VM $vmConfig `
    -Linux `
    -ComputerName $vmName `
    -Credential (New-Object PSCredential($adminUsername, $securePassword)) `
    -DisablePasswordAuthentication:$false

# 8) Attach the NIC
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# 9) Create the VM
try {
    New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig -ErrorAction Stop
    Write-Host "✅ VM creation initiated: $vmName"
} catch {
    Write-Error "Failed to create VM '$vmName': $_"
    exit 1
}