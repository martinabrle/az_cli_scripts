# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect
Connect-AzAccount -Identity

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Iterate through each subscription and display it
Write-Output "Processing subscriptions..."
foreach ($subscription in $subscriptions) {
    Write-Output "Processing subscription: $($subscription.Name)"
}

# Throw a random exception
$rand = Get-Random -Minimum 0 -Maximum 3
if ( $rand -eq 1) {
    Write-Error "Random generator decided to output this error to the error output stream. Exception will not be issued"
}