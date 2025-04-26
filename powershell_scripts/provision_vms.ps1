# Suppress interactive prompts and force errors to stop
$ConfirmPreference     = 'None'
$ErrorActionPreference = 'Stop'

# Grab Jenkins‑exported env vars
$config = Get-Content -Path ".\..\configs\vm-config.json" -ErrorAction Stop | ConvertFrom-Json

$vmList = $config.vm_details

foreach ($vm in $vmList) {
    # Extract values from JSON
    if ($vm.vmType -eq "Windows") {
        Write-Host "Deploying a Windows VM: $($vm.vmName)"
        $vmName            = $vm.vmName
        $vmSize            = $vm.vmSize
        $adminUsername     = $vm.adminUsername
        $adminPassword     = $vm.adminPassword
        $resourceGroupName = $vm.resourceGroupName
        $location          = $vm.location
        $vmImage           = $vm.vmImage.urn
        $vnetName          = $vm.vnetName
        $subnetName        = $vm.subnetName
        $publicIpName      = "$vmName-pip"
        $SecurityGroupName = "$vmName-sg"

        Write-Host "`n Starting VM deployment: $vmName" 

        # Secure the password
        $securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential($adminUsername, $securePassword)

        # Get VNet & Subnet
        $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
        $subnet = $vnet.Subnets | Where-Object Name -EQ $subnetName
        if (-not $subnet) { Throw " Subnet '$subnetName' not found in VNet '$vnetName'" }

        # Create the VM
        New-AzVm -ResourceGroupName $resourceGroupName -Name $vmName -Location $location -VirtualNetworkName $vnetName -SubnetName $subnetName -SecurityGroupName $SecurityGroupName -PublicIpAddressName $publicIpName -ImageName $vmImage -Credential $cred -Size $vmSize

        Write-Host " Azure virtual machine '$vmName' creation initiated." 
    } 
    else {
        Write-Host "Deploying a Linux VM: $($vm.vmName)"
        $vmName            = $vm.vmName
        $vmSize            = $vm.vmSize
        $adminUsername     = $vm.adminUsername
        $adminPassword     = $vm.adminPassword
        $resourceGroupName = $vm.resourceGroupName
        $location          = $vm.location
        $vmImage           = $vm.vmImage.urn
        $vnetName          = $vm.vnetName
        $subnetName        = $vm.subnetName
        $publicIpName      = "$vmName-pip"
        $SecurityGroupName = "$vmName-sg"

        Write-Host "`n Starting VM deployment: $vmName" 

        # Secure the password
        $securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential($adminUsername, $securePassword)

        # Get VNet & Subnet
        $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
        $subnet = $vnet.Subnets | Where-Object Name -EQ $subnetName
        if (-not $subnet) { Throw " Subnet '$subnetName' not found in VNet '$vnetName'" }
      


        #Create the VM
        New-AzVm -ResourceGroupName $resourceGroupName -Name $vmName -Location $location -VirtualNetworkName $vnetName -SubnetName $subnetName -SecurityGroupName $SecurityGroupName -PublicIpAddressName $publicIpName -ImageName $vmImage -Credential $cred -Size $vmSize

        Write-Host " Azure virtual machine '$vmName' creation initiated." 
    }
    
}
