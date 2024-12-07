Disable-AzContextAutosave -Scope Process

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
    Write-Error "Random generator decided this demo job is going to fail."
    throw "Throwing a demo exception to generate an error"
}