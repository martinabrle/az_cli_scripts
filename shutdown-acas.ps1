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

    # Get all running Container Apps with the tag 'StopNightly' either missing or set to anything different from 'false'
    $acaApps = Get-AzContainerApp | Where-Object { $_.Tags['StopNightly'] -ne 'false' -and $_.PowerState.Code -eq 'Running' }
    
    foreach ($acaApp in $acaApps) {
        # Stop the Container App
        Stop-AzContainerApp -ResourceGroupName $acaApp.ResourceGroupName -Name $acaApp.Name
        Write-Output "Stopped container App: $($acaApp.Name) in resource group: $($acaApp.ResourceGroupName)"
    }
}

Write-Output "All Container Apps have been processed."
