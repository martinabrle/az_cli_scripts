# System assigned / user assigned identity of the automation account needs to have "Contributor" on all subscriptions

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

Connect-AzAccount -Identity

# Returns true is the resource group should be deleted. Can be made more concise and less readable
function ShouldDeleteResourceGroup {
    param (
        [string]$resourceGroupName
    )
    $resourceGroupExists = Get-AzResourceGroup -Name $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue
    if ($resourceGroupExists -eq $null) {
        Write-Output "Resource group: $($resourceGroup.ResourceGroupName) does not exist anymore"
        return $false
    }

    if ($resourceGroup.Tags -eq $null)
    {
        Write-Output "Resource group $($resourceGroup.ResourceGroupName) is missing any tags, marking it for deletion"
        return $true
    }
        
    if ($resourceGroup.Tags.ContainsKey('Workload') -eq $false) {
        Write-Output "Workload tag is missing on resource group $($resourceGroup.ResourceGroupName), marking it for deletion"
        return $true
    }

    if ($resourceGroup.Tags['Workload'] -ne 'PRODUCTION') {
        if ($resourceGroup.Tags.ContainsKey('DeleteWeekly') -eq $false) {
            Write-Output "DeleteWeekly tag is missing on resource group $($resourceGroup.ResourceGroupName) and it's a non-production workload,  marking it for deletion"
            return $true
        }
        $delete=$resourceGroup.Tags['DeleteWeekly']
        if ($delete -eq $true) {
            Write-Output "DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), marking it for deletion"
        } else {
            Write-Output "DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), skipping it"
        }
        return $delete
    }
            
    if ($resourceGroup.Tags.ContainsKey('DeleteWeekly') -eq $false) {
        # If it's a production workload, and 'DeleteWeekly' is not set, it's a mistake / missing classification, display an error
        # and the admin will be notified automatically
        Write-Error "Resource group $($resourceGroup.ResourceGroupName) is tagged as 'PRODUCTION' but does not have a 'DeleteWeekly' tag. Please review."
        return $false
    }
}

    $delete=$resourceGroup.Tags['DeleteWeekly']
    if ($delete -eq $true) {
        Write-Output "Even though it's a PRODUCTION workload, DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), marking it for deletion"
    } else {
        Write-Output "DeleteWeekly tag is set to $($delete) on resource group $($resourceGroup.ResourceGroupName), skipping it"
    }
    return $delete
}

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    Write-Output "Processing subscription: $($subscription.Name)"
    # Set the current subscription context
    Set-AzContext -SubscriptionId $subscription.Id

    $resourceGroups = Get-AzResourceGroup
    foreach ($resourceGroup in $resourceGroups) {
        $delete = ShouldDeleteResourceGroup -resourceGroupName $resourceGroup.ResourceGroupName
        if ($delete -eq $true) {
            Write-Output "Deleting resource group: $($resourceGroup.ResourceGroupName)"
            Remove-AzResourceGroup -Name $resourceGroup.ResourceGroupName -Force
        }
    }
}
