param (
    [Parameter(Mandatory=$true)][string]$action,
    [Parameter(Mandatory=$true)][string]$vmName,
    [Parameter(Mandatory=$true)][string]$resourceGroup
)

$ErrorActionPreference = "Stop"
$ConfirmPreference = "None"

Write-Host "🔁 Action: $action on VM: $vmName in RG: $resourceGroup"

switch ($action.ToLower()) {
    "start" {
        Start-AzVM -Name $vmName -ResourceGroupName $resourceGroup
        Write-Host " VM '$vmName' started."
    }
    "stop" {
        Stop-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Force
        Write-Host " VM '$vmName' stopped."
    }
    "status" {
        $vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup -Status
        $status = $vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' }
        Write-Host " Status: $($status.DisplayStatus)"
    }
    default {
        throw " Invalid action: $action"
    }
}
