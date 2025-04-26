try {
    Write-Host "Loading configuration..." 
    $config = Get-Content -Path ".\..\configs\create-rg-config.json" -ErrorAction Stop | ConvertFrom-Json

    # Accessing values from JSON
    $rgName = $config.resourceGroup.name
    $location = $config.resourceGroup.location
    $vnetName = $config.virtualNetwork.name
    $addressPrefix = $config.virtualNetwork.addressSpace

    Write-Host "Configuration loaded successfully." 
    Write-Host " Resource Group: $rgName"
    Write-Host " Location: $location"
    Write-Host " Virtual Network: $vnetName"
    Write-Host " Address Space: $addressPrefix"

    # Create Resource Group
    Write-Host " Creating Resource Group..." 
    New-AzResourceGroup -Name $rgName -Location $location -ErrorAction Stop
    Write-Host " Resource Group created." 

    # Configure subnets
    Write-Host "Configuring subnets..." 
    $subnet1 = New-AzVirtualNetworkSubnetConfig -Name $config.virtualNetwork.subnets[0].name -AddressPrefix $config.virtualNetwork.subnets[0].addressPrefix
    $subnet2 = New-AzVirtualNetworkSubnetConfig -Name $config.virtualNetwork.subnets[1].name -AddressPrefix $config.virtualNetwork.subnets[1].addressPrefix
    Write-Host " Subnets configured."

    # Create the Virtual Network
    Write-Host "`n Creating Virtual Network..." 
    New-AzVirtualNetwork -Name $vnetName `
        -ResourceGroupName $rgName `
        -Location $location `
        -AddressPrefix @($addressPrefix) `
        -Subnet $subnet1, $subnet2 `
        -ErrorAction Stop
    Write-Host "Virtual Network created successfully." 
}
catch {
    Write-Host "` Error occurred: $($_.Exception.Message)" 
    # Optionally: Exit script with error code
    exit 1
}
