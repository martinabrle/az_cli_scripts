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

    # Get all running AKS clusters with the tag 'StopNightly' either missing or set to anything different from 'false'
    $aksClusters = Get-AzAksCluster | Where-Object { $_.Tags['StopNightly'] -ne 'false' -and $_.PowerState -eq 'Running' }
    
    foreach ($aksCluster in $aksClusters) {
        # Stop the AKS cluster
        Stop-AzAksCluster -ResourceGroupName $aksCluster.ResourceGroupName -Name $aksCluster.Name
        Write-Output "Stopped AKS cluster: $($aksCluster.Name) in resource group: $($aksCluster.ResourceGroupName)"
    }
}

Write-Output "All AKSes have been processed."
