$vmName = $env:VM_NAME
$vmSize = $env:VM_SIZE
$adminUsername = $env:ADMIN_USERNAME
$adminPassword = $env:ADMIN_PASSWORD
$resourceGroupName = $env:RESOURCE_GROUP
$location = $env:LOCATION
$vmImage = $env:VM_IMAGE
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force

# Names
$vnetName     = "virtual-nw-dev"    # your existing VNet name
$subnetName   = "subnet-frontend"   # your existing Subnet name
$nicName      = "$vmName-nic"
$publicIpName = "$vmName-pip"

# 1) Get the VNet and Subnet
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -ErrorAction Stop
$subnet = $vnet.Subnets | Where-Object Name -EQ $subnetName
if (-not $subnet) {
    Write-Error "Subnet '$subnetName' not found in VNet '$vnetName'"
    exit 1
}

# 2) Create (or reuse) a basic dynamic Public IP
$publicIp = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if (-not $publicIp) {
    $publicIp = New-AzPublicIpAddress `
        -Name $publicIpName `
        -ResourceGroupName $resourceGroupName `
        -Location $location `
        -Sku Basic `
        -AllocationMethod Dynamic `
        -ErrorAction Stop
}

# 3) Create the NIC using SubnetId
$nic = New-AzNetworkInterface `
    -Name $nicName `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -SubnetId $subnet.Id `
    -PublicIpAddressId $publicIp.Id `
    -ErrorAction Stop

# 4) Build VM configuration
$cred = New-Object System.Management.Automation.PSCredential($adminUsername, $securePassword)
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

# 5) Set OS (Windows) with the credential and provision agent
$vmConfig = Set-AzVMOperatingSystem `
    -VM $vmConfig `
    -Windows `
    -ComputerName $vmName `
    -Credential $cred `
    -ProvisionVMAgent

# 6) (Optional) Set your image here, or Azure will use default
# Example: Windows Server 2022 Datacenter
$vmConfig = Set-AzVMSourceImage `
    -VM $vmConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Sku "2022-datacenter" `
    -Version "latest"

# 7) Attach the NIC
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# 8) Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig -ErrorAction Stop

Write-Host "✅ Azure virtual machine '$vmName' creation initiated."