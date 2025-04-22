try {
    $vms = Get-AzVM
} catch {
    Write-Host "❌ Failed to fetch VMs. Check Azure login or permissions."
    exit 1
}

$vmInfo = @()

foreach ($vm in $vms) {
    try {
        $status = (Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status).Statuses |
                  Where-Object { $_.Code -like 'PowerState/*' } |
                  Select-Object -ExpandProperty DisplayStatus
    } catch {
        $status = "Unknown"
    }

    $vmDetails = [PSCustomObject]@{
        Name     = $vm.Name
        Size     = $vm.HardwareProfile.VmSize
        State    = $status
        Location = $vm.Location
    }

    $vmInfo += $vmDetails
}

$outputPath = Join-Path -Path $env:WORKSPACE -ChildPath 'vm_info.csv'
$vmInfo | Export-Csv -Path $outputPath -NoTypeInformation

if (Test-Path $outputPath) {
    Write-Host "✅ VM info exported to $outputPath"
} else {
    Write-Host "❌ Export failed. File not found at $outputPath"
    exit 1
}