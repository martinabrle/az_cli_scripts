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

    # Get all VMs with the tag 'PROD' set to 'false'
    $vms = Get-AzVM -Status | Where-Object { $_.Tags['PROD'] -ne 'true'  -and $_.PowerState -eq 'RUNNING' }

    foreach ($vm in $vms) {
        # Deallocate the VM
        Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force -AsJob
        Write-Output "Deallocating VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName)"
    }
}
Write-Output "All VMs have been processed."
