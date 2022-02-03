# Azure function to start Azure Container Instance
param($Timer)

$subscriptionId = "my-subscriptionId"
$tenantId = "my-tenant-id"
$storageResourceGroupName = 'minecraft'
$resourceGroupName = "minecraft"
$containerGroupName = "minecraft-dropper"
$dnsNameLabel = "mc-dropper"
$shareName = "dropper"
$storageAccountName = "mystorage-persistance-volume"
$location = "canadacentral"
$environmentVariables = @{ 
    EULA = "TRUE"; 
    OPS = "admin_account"; 
    VERSION = "1.13.2"; 
    MAX_PLAYERS="4"; 
    ONLINE_MODE="FALSE"; 
    ALLOW_FLIGHT="TRUE"; 
    MODE="adventure"; 
    MEMORY="1G"; 
    WORLD="https://www.minecraftmaps.com/dropper-maps/world-drop/download"
}

Select-AzSubscription -SubscriptionID $subscriptionId -TenantID $tenantId

# get storage account
$storageAccount = Get-AzStorageAccount `
            -ResourceGroupName $storageResourceGroupName `
            -Name $storageAccountName

if ($storageAccount -eq $null) {
        # create the storage account
        $storageAccount = New-AzStorageAccount `
            -ResourceGroupName $storageResourceGroupName `
            -Name $storageAccountName `
            -SkuName Standard_LRS `
            -Location $location
    }

# check if the file share already exists
$share = Get-AzStorageShare `
    -Name $shareName -Context $storageAccount.Context `
    -ErrorAction SilentlyContinue

if ($share -eq $null) {
    # create the share
    $share = New-AzStorageShare `
        -Name $shareName `
        -Context $storageAccount.Context
}

# get the credentials
$storageAccountKeys = Get-AzStorageAccountKey `
    -ResourceGroupName $storageResourceGroupName `
    -Name $storageAccountName

$storageAccountKey = $storageAccountKeys[0].Value# check if storage account exists
$storageAccountKeySecureString = ConvertTo-SecureString $storageAccountKey -AsPlainText -Force
$storageAccountCredentials = New-Object System.Management.Automation.PSCredential ($storageAccountName, $storageAccountKeySecureString)

New-AzContainerGroup -ResourceGroupName $resourceGroupName `
    -Name $containerGroupName `
    -Image "itzg/minecraft-server" `
    -AzureFileVolumeAccountCredential $storageAccountCredentials `
    -AzureFileVolumeShareName $shareName `
    -AzureFileVolumeMountPath "/data" `
    -IpAddressType Public `
    -OsType Linux `
    -DnsNameLabel $dnsNameLabel `
    -Port 25565 `
    -Cpu 1 `
    -MemoryInGB 2 `
    -EnvironmentVariable $environmentVariables
