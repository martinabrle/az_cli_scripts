# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

Connect-AzAccount -Identity

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    Write-Output "Processing subscription: $($subscription.Name)"
    # Set the current subscription context
    Set-AzContext -SubscriptionId $subscription.Id

    $resourceGroups = Get-AzResourceGroup
    foreach ($resourceGroup in $resourceGroups) {
        $delete = $false
        if (-not $_.Tags.ContainsKey('WORKLOAD')) {
            Write-Output "WORKLOAD tag is missing on resource group $($resourceGroup.ResourceGroupName), marking it for deletion"
            $delete=$true
        } else {
            if ($_.Tags['WORKLOAD'] -ne 'PRODUCTION') {
                if (-ne $_.Tags.ContainsKey('DeleteWeekly')) {
                    Write-Output "DeleteWeekly tag is missing on resource group $($resourceGroup.ResourceGroupName) and it's a non-production workload,  marking it for deletion"
                    $delete=$true
                }
                else {
                    $delete=$_.Tags['DeleteWeekly']
                    if ($delete -eq $true) {
                        Write-Output "DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), marking it for deletion"
                    }
                    else {
                        Write-Output "DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), skipping it"
                    }
                    
                }
            } else {
                if (-ne $_.Tags.ContainsKey('DeleteWeekly')) {
                    # If it's a production workload, and 'DeleteWeekly' is not set, it's a mistake / missing classification, display an error
                    # and the admin will be notified automatically
                    Write-Error "Resource group $($resourceGroup.ResourceGroupName) is tagged as 'PRODUCTION' but does not have a 'DeleteWeekly' tag. Please review."
                }
                else {
                    $delete=$_.Tags['DeleteWeekly']
                    if ($delete -eq $true) {
                        Write-Output "Even though it's a PRODUCTION workload, DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), marking it for deletion"
                    }
                    else {
                        Write-Output "DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), skipping it"
                    }
                }
            }
        }
        if ($delete -eq $true) {
            Write-Output "Deleting resource group: $($resourceGroup.ResourceGroupName)"
            #Remove-AzResourceGroup -Name $resourceGroup.ResourceGroupName -Force
        }
    }
}
