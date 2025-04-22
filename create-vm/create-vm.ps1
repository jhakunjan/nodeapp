$vmName = $env:VM_NAME
$vmSize = $env:VM_SIZE
$adminUsername = $env:ADMIN_USERNAME
$adminPassword = $env:ADMIN_PASSWORD
$resourceGroupName = $env:RESOURCE_GROUP
$location = $env:LOCATION
$vmImage = $env:VM_IMAGE
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force

# PowerShell script to create an Azure Virtual Machine

# Prerequisites:
# 1. Install Azure PowerShell module: Install-Module -Name Az -AllowClobber
# 2. Connect to your Azure account: Connect-AzAccount



# Create resource group if it doesn't exist
if (!(Get-AzResourceGroup -Name $resourceGroupName)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}


$subnet = "virtual-nw-dev"
$vnet =  "subnet-frontend"

# Create a public IP address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name myPublicIP -AllocationMethod Dynamic

# Create a network interface
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name myNIC -VirtualNetworkName $vnet -SubnetName $subnet -PublicIpAddressId $publicIp.Id

# Create the VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize -Credential (New-Credential -Username $adminUsername -Password $securePassword )
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -ProvisionVMAgent
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter" -Version "latest"
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host "Azure virtual machine '$vmName' created successfully."
