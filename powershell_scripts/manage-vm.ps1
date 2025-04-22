param (
    [string]$resourceGroupName,
    [string]$vmName,
    [string]$action # "start", "stop", or "status"
)

function Start-VM {
    param (
        [string]$resourceGroupName,
        [string]$vmName
    )
    
    Write-Host "Starting VM: $vmName in Resource Group: $resourceGroupName"
    Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
    Write-Host "VM $vmName has been started."
}

function Stop-VM {
    param (
        [string]$resourceGroupName,
        [string]$vmName
    )

    Write-Host "Stopping VM: $vmName in Resource Group: $resourceGroupName"
    Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
    Write-Host "VM $vmName has been stopped."
}

function Get-VMStatus {
    param (
        [string]$resourceGroupName,
        [string]$vmName
    )

    $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
    Write-Host "VM Status for $vmName in Resource Group $resourceGroupName: $($vm.PowerState)"
}

# Check the action and perform the respective task
switch ($action.ToLower()) {
    "start" {
        Start-VM -resourceGroupName $resourceGroupName -vmName $vmName
    }
    "stop" {
        Stop-VM -resourceGroupName $resourceGroupName -vmName $vmName
    }
    "status" {
        Get-VMStatus -resourceGroupName $resourceGroupName -vmName $vmName
    }
    default {
        Write-Host "Invalid action. Use 'start', 'stop', or 'status'."
    }
}
