# Azure function to stop Azure Container Instance

param($Timer)

$subscriptionId = "my-subscription-id"
$tenantId = "my-tenant-id"
$resourceGroupName = "minecraft"
$containerGroupName = "minecraft-dropper"

Select-AzSubscription -SubscriptionID $subscriptionId -TenantID $tenantId

Remove-AzContainerGroup -ResourceGroupName $resourceGroupName -Name $containerGroupName
