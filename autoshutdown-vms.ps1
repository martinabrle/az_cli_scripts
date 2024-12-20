# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

Connect-AzAccount -Identity

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Iterate through each subscription
Write-Output "Processing subscriptions..."
foreach ($subscription in $subscriptions) {
    Write-Output "Processing subscription: $($subscription.Name)"
    
    # Set the current subscription context
    Set-AzContext -SubscriptionId $subscription.Id -TenantId $subscription.TenantId

    # Get all running VMs with the tag 'StopNightly' either missing or set to anything different from 'false'
    $vms = Get-AzVM -Status | Where-Object { $_.Tags['StopNightly'] -ne 'false' -and $_.PowerState -eq 'VM running' }

    foreach ($vm in $vms) {
        # Deallocate the VM
        Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force -AsJob
        Write-Output "Deallocating VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName)"
    }
}
Write-Output "All VMs have been processed."
