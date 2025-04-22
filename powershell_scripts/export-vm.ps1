

# Get all VMs in the subscription
$vms = Get-AzVM

# Create an empty array to store VM information
$vmInfo = @()

foreach ($vm in $vms) {
    # Capture the VM's power state (requires instance view)
    $status = (Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status).Statuses |
              Where-Object { $_.Code -like 'PowerState/*' } |
              Select-Object -ExpandProperty DisplayStatus

    # Build a PSObject for each VM
    $vmDetails = [PSCustomObject]@{
        Name     = $vm.Name
        Size     = $vm.HardwareProfile.VmSize
        State    = $status
        Location = $vm.Location
    }

    $vmInfo += $vmDetails
}

# Output to Jenkins console in table format
Write-Host "===== VM Inventory ====="
$vmInfo | Format-Table -AutoSize

# Optional: Export to CSV for archiving (uncomment if needed)
# $vmInfo | Export-Csv -Path "$env:WORKSPACE/vm_info.csv" -NoTypeInformation

Write-Host "`nVM information output completed."
