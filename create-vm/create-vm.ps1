# Suppress interactive prompts and force errors to stop
$ConfirmPreference     = 'None'
$ErrorActionPreference = 'Stop'

# Grab Jenkins‑exported env vars
$vmName            = $env:VM_NAME
$vmSize            = $env:VM_SIZE
$adminUsername     = $env:ADMIN_USERNAME
$adminPassword     = $env:ADMIN_PASSWORD
$resourceGroupName = $env:RESOURCE_GROUP
$location          = $env:LOCATION
$vmImage           = $env:VM_IMAGE

# Secure the password
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force

# Networking names
$vnetName     = "virtual-nw-dev"    # existing VNet
$subnetName   = "subnet-frontend"   # existing Subnet
$nicName      = "$vmName-nic"
$publicIpName = "$vmName-pip"

# 1) Validate VNet & Subnet
$vnet   = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$subnet = $vnet.Subnets | Where-Object Name -EQ $subnetName
if (-not $subnet) { Throw "Subnet '$subnetName' not found in VNet '$vnetName'" }

# 2) Create or reuse Public IP
$publicIp = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if (-not $publicIp) {
    $publicIp = New-AzPublicIpAddress `
        -Name $publicIpName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Sku Basic `
        -AllocationMethod Dynamic
}

# 3) Create or reuse NIC
$nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if (-not $nic) {
    Write-Host "Creating NIC: $nicName"
    $nic = New-AzNetworkInterface `
        -Name $nicName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $publicIp.Id
} else {
    Write-Host "Reusing existing NIC: $nicName"
}

# 4) Build VM configuration & set image
$parts = $vmImage -split ":"
$publisher = $parts[0]
$offer     = $parts[1]
$sku       = $parts[2]
$version   = $parts[3]

$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vmConfig = Set-AzVMSourceImage `
    -VM $vmConfig `
    -PublisherName $publisher `
    -Offer $offer `
    -Sku $sku `
    -Version $version

# 5) OS-specific configuration
$cred = New-Object System.Management.Automation.PSCredential($adminUsername, $securePassword)

if ($publisher -match 'Windows') {
    Write-Host "Configuring Windows profile"
    $vmConfig = Set-AzVMOperatingSystem `
        -VM $vmConfig `
        -Windows `
        -ComputerName $vmName `
        -Credential $cred `
        -ProvisionVMAgent
} else {
    Write-Host "Configuring Linux profile"
    $vmConfig = Set-AzVMOperatingSystem `
        -VM $vmConfig `
        -Linux `
        -ComputerName $vmName `
        -Credential $cred `
        -DisablePasswordAuthentication:$false
}

# 6) Attach NIC
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# 7) Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host " Azure virtual machine '$vmName' creation initiated."
