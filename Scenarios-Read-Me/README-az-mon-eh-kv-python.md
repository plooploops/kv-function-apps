## Azure Monitor Alerts with Azure Functions, Event Hub, and Key Vault Integration

The goal is to able to take [Azure Monitor Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-overview) with [Common Alert Schema Definitions](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-common-schema-definitions) and to be able to transform the alert.

We can use [Azure Monitor Action Groups](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups) to point to our 'sender' Azure Function.

We'll use an Event Hub for downstream processing by an Azure Function.  We'll want to ensure that both Azure Functions are able to use [Key Vault References](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references#granting-your-app-access-to-key-vault) in order to point to appropriate settings for storage and the Event Hub itself.

We're going to also set up a test Virtual Machine so we can target it for alerting purposes from Azure Monitor.  This could also later be used for checking on Event Hub and Azure function connectivity from within the VNET, but that would be a stretch goal.

We're going to test ip filtering on the sending function, as well as looking into use service endpoints for Event Hub, Key Vault, and Storage Account for the subnets hosting our Azure Functions.  Since we're using Azure Functions with [VNET Integration](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#virtual-network-integration) and [IP Filtering](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#inbound-ip-restrictions), we can test with [Azure Functions Premium Plan](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale#premium-plan).

For now, we'll use the  [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python#publishing-to-azure) to publish our Python Azure Functions, but this is something that can also be later handled with CI/CD (e.g. Azure DevOps Pipelines).

![Event Hub triggered Azure Function](../Media/scenario-az-mon-eh-kv-python/scenario.png 'Event Hub Triggered Azure Function')

We would like to make sure that we can retrieve the secret from Key Vault, but also keep a copy so that we can avoid making additional calls to Key Vault which could potentially cause an issue with [Key Vault rate limiting](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-service-limits).

Of course, this will not be a cure-all, and each scenario / workload will need to be evaluated.  This is merely an approach to keep in mind when working with Key Vault.

We're going to refer to this [Getting Secrets in Key Vault](https://medium.com/statuscode/getting-key-vault-secrets-in-azure-functions-37620fd20a0b) post as guidance.

### Links

These will describe some of the concepts that we're using in this scenario.

1. [Key Vault rate limiting](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-service-limits)
1. [Getting Secrets in KV from Azure Functions](https://medium.com/statuscode/getting-key-vault-secrets-in-azure-functions-37620fd20a0b)
1. [Azure Functions Event Hub Bindings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-hubs)
1. [Managed Identities with Azure Functions](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity)
1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest)
1. [Azure Function App Config cli](https://docs.microsoft.com/en-us/cli/azure/functionapp/config/appsettings?view=azure-cli-latest)
1. [Azure Functions Python Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python#publishing-to-azure)
1. [Azure Event Hub cli](https://docs.microsoft.com/en-us/cli/azure/eventhubs/eventhub?view=azure-cli-latest)
1. [Azure Event Hub Connection String](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string)
1. [Azure Event Hub Consumer Group](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-features#consumer-groups)
1. [Azure Key Vault Logging](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity)
1. [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer)
1. [Generate Random Letters in Powershell](https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/)
1. [Azure Monitor Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-overview)
1. [Azure Monitor Metric Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-metric-overview)
1. [Azure Monitor Common Alert Schema Definitions](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-common-schema-definitions)
1. [Azure Monitor Action Groups](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups)
1. [Azure Monitor Webhooks](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups#webhook)
1. [Azure Functions Authentication Options](https://docs.microsoft.com/en-us/azure/app-service/app-service-authentication-how-to?toc=%2fazure%2fazure-functions%2ftoc.json)]
1. [Azure Functions Deployment Options](https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies)
1. [Azure Functions Premium Plan](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale#premium-plan)
1. [Azure Functions VNET Integration Options](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#virtual-network-integration)
1. [Azure Functions IP Filtering](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#inbound-ip-restrictions)
1. [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools)
1. [Azure Functions Extension](https://github.com/Microsoft/vscode-azurefunctions/wiki)
1. [Retrieve an Azure Function Key](https://stackoverflow.com/questions/46338239/retrieve-the-host-keys-from-an-azure-function-app)
1. [Azure Functions Create VNET](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-vnet)
1. [Azure App Service VNET Integration](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet)
1. [Azure Virtual Network Service Endpoints](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)
1. [Azure Event Hub Service Endpoints](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-service-endpoints)
1. [Azure Storage Account Service Endpoints](https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security?toc=%2fazure%2fvirtual-network%2ftoc.json#grant-access-from-a-virtual-network)
1. [Azure Key Vault Service Endpoints](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-overview-vnet-service-endpoints)
1. [Azure Key Vault Network Security](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-network-security)
1. [Azure App Service with Key Vault References](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references#granting-your-app-access-to-key-vault)
1. [Azure App Service Environment](https://docs.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-network-architecture-overview)

### Deploy Components

Clone this repo to pull down the bits.

Assuming we have a fresh Azure subscription, we can put together a test resource group along with Azure Event Hubs, Azure Functions, Azure Monitor, and a Key Vault.

Please ensure that we use [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest) and login to the Azure subscription.

```powershell
az login
az account set -s <subscription id>
```

For reference we can use this [deployment script](../Scenarios/az-mon-eh-kv-python/deploy.ps1) from the **Scenario's root directory** to stand up the components for this exercise.

#### Deployment Script Notes

For convenience we can run the script, but we'll discuss some of the details here.

We can create a resource group and a virtual network with placeholder subnets.  We'll also add service endpoints to each of the subnets for Event Hub, Storage, and Key Vault.

```powershell
#create an rg
az group create -n $rg -l $location

#create VNET / subnets
az network vnet create -g $rg -n $vnetName --address-prefixes $vnetAddressPrefix --subnet-name $subnetName --subnet-prefixes $subnetAddressPrefix
$subnetID = $(az network vnet show -g $rg -n $vnetName --query "subnets[?name=='$subnetName'].id" -o tsv)

$vmSubnetObject = $(az network vnet subnet create -g $rg --vnet-name $vnetName -n $vmSubnetName --address-prefixes $vmSubnetAddressPrefix) | ConvertFrom-Json
$receiveSubnetObject = $(az network vnet subnet create -g $rg --vnet-name $vnetName -n $receiveSubnetName --address-prefixes $receiveSubnetAddressPrefix) | ConvertFrom-Json

az network vnet subnet update --resource-group $rg --vnet-name $vnetName --name $subnetName --service-endpoints "Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.EventHub"
az network vnet subnet update --resource-group $rg --vnet-name $vnetName --name $vmSubnetName --service-endpoints "Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.EventHub"
az network vnet subnet update --resource-group $rg --vnet-name $vnetName --name $receiveSubnetName --service-endpoints "Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.EventHub"
```

We can now add a VM to the VM subnet.  We'll later point Azure Monitor to target this VM for an Alert.  This test VM can also be used to confirm VNET integration with the functions, as well as general VNET connectivity.

```powershell
#This subnet is hosting a VM.
Write-Host "Creating a VM"
$defaultSubnetID = "/subscriptions/$subscriptionID/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$vmSubnetName"
#need to asssociate with a static ip address
az vm create --image $vmImage --admin-username $vmAdminUserName --admin-password $vmAdminPassword -l $location -g $rg -n $vmName --subnet $defaultSubnetID --public-ip-address-allocation $vmPublicIpAddressAllocation --size $vmSize
```

We can now add a storage account for the Azure Functions.  This storage account must have blob containers for syncing Azure Functions.  We'll also add in network rules to allow access to the subnets hosting our Azure Functions.

```powershell
# Create a storage account in the resource group.
az storage account create --name $saName --location $location --resource-group $rg --sku Standard_LRS
az storage account network-rule add -g $rg -n $saName --subnet $subnetID
az storage account network-rule add -g $rg -n $saName --subnet $receiveSubnetObject.id
```

We'll now stand up both the sender and receiver function apps.  We'll use the App service plan as the location for the function app, and we'll need  to ensure we're using the [Azure Functions Premium Plan](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale#premium-plan). Further, since we're using [Python Azure Functions Python](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python#publishing-to-azure), we'll need to use a **Linux** host.  We can add [VNET Integration](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#virtual-network-integration) to point to the placeholder subnets created earlier, and also add in a [Managed Identity](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity) for the function.  This Managed Identity will be used for retrieving secrets from [Key Vault](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references#granting-your-app-access-to-key-vault).


```powershell
#create app service plan and function for Sender
az appservice plan create --name $sendAspName --resource-group $rg --sku P2V2 --is-linux
az functionapp create --name $sendFaName --resource-group $rg --plan $sendAspName --storage-account $saName --os-type Linux --runtime python --runtime-version 3.7
az functionapp vnet-integration add -g $rg -n $sendFaName --vnet $vnetName --subnet $subnetName

az functionapp identity assign --name $sendFaName --resource-group $rg

#create app service plan and function for Receiver
az appservice plan create --name $receiveAspName --resource-group $rg --sku P2V2 --is-linux
az functionapp create --name $receiveFaName --resource-group $rg --plan $receiveAspName --storage-account $saName --os-type Linux --runtime python --runtime-version 3.7
#need a separate subnet to avoid conflict with hosting another function app.
az functionapp vnet-integration add -g $rg -n $receiveFaName --vnet $vnetName --subnet $receiveSubnetName

az functionapp identity assign --name $receiveFaName --resource-group $rg
```

We'll now retrieve the service principal for the Managed Identity of the Azure Functions.  We'll use this with a Key Vault policy.

```powershell
#get service principal ID attached to function app
$sendSpID=$(az functionapp show --resource-group $rg --name $sendFaName --query identity.principalId --out tsv)

$receiveSpID=$(az functionapp show --resource-group $rg --name $receiveFaName --query identity.principalId --out tsv)
```

We'll create a Key Vault.  We'll also add network rules to allow access to the placeholder subnets.

We can also add in a test secret, and then add a policy on Key Vault to allow access to the Service Principals (Managed Identities) for the Azure Functions.

```powershell
#create a key vault
az keyvault create --name $kvName --resource-group $rg --location $location

az keyvault network-rule add -g $rg -n $kvName --vnet $vnetName --subnet $subnetName
az keyvault network-rule add -g $rg -n $kvName --vnet $vnetName --subnet $vmSubnetName
az keyvault network-rule add -g $rg -n $kvName --vnet $vnetName --subnet $receiveSubnetName

#create a secret for Key Vault
az keyvault secret set --name $kvSecretName --value $kvSecretValue --description FunctionAppsecret  --vault-name $kvName

#grant access to key vault.  The Service Principal bound to the Function App needs rights to access the secret in Key vault.
az keyvault set-policy --name $kvName --resource-group $rg --object-id $sendSpID --secret-permissions get

az keyvault set-policy --name $kvName --resource-group $rg --object-id $receiveSpID --secret-permissions get
```

We can now bind a sample secret to the function app.  This can be a test Key Vault Reference.

```powershell
#get secret URI
$secretURI = $(az keyvault secret show --name $kvSecretName --vault-name $kvName --query id --output tsv)

#bind app setting / environment variable for Azure Function app to key vault secret URI.  Note the extra space for parsing the secret.
az functionapp config appsettings set --name $sendFaName --resource-group $rg --settings "$kvSecretName=@Microsoft.KeyVault(SecretUri=$secretURI) "

az functionapp config appsettings set --name $receiveFaName --resource-group $rg --settings "$kvSecretName=@Microsoft.KeyVault(SecretUri=$secretURI) "
```

Let's create our Event Hub Namespace and Event Hub.  We'll also want to add the placeholder subnets as part of the network rules to have access to the Event Hub Namespace.  We'll also want to create a test [Azure Event Hub Consumer Group](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-features#consumer-groups).

```powershell
#create event hub
az eventhubs namespace create --resource-group $rg --name $ehNamespace --location $location

az eventhubs namespace network-rule add --action Allow -g $rg --namespace-name $ehNamespace --vnet $vnetName --subnet $subnetName
az eventhubs namespace network-rule add --action Allow -g $rg --namespace-name $ehNamespace --vnet $vnetName --subnet $receiveSubnetName
az eventhubs namespace network-rule add --action Allow -g $rg --namespace-name $ehNamespace --vnet $vnetName --subnet $vmSubnetName

az eventhubs eventhub create --resource-group $rg --namespace-name $ehNamespace --name $ehName --message-retention 4 --partition-count 15
az eventhubs eventhub consumer-group create --resource-group $rg --name $ehConsumerGroup --namespace-name $ehNamespace --eventhub-name $ehName
```

Let's start working through saving secrets for the Azure Functions to bind from Key Vault for Storage and Event Hubs.

For Event Hub, we can retrieve the connection information and store this in key vault as a secret.  We can then bind the function apps to use the secret as a key vault reference.

```powershell
#store event hub connection string in key vault, and bind key vault to function app settings for event hub trigger use
$ehcs = $(az eventhubs namespace authorization-rule keys list --resource-group $rg --namespace-name $ehNamespace --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
$kvEHSecretValue = "$ehcs;EntityPath=$ehName"

az keyvault secret set --name $kvEHSecretName --value $kvEHSecretValue --description FunctionAppsecret  --vault-name $kvName
$ehsecretURI = $(az keyvault secret show --name $kvEHSecretName --vault-name $kvName --query id --output tsv)

#bind app setting / environment variable for Azure Function app to key vault secret URI.  Note the extra space for parsing the secret.
az functionapp config appsettings set --name $sendFaName --resource-group $rg --settings "$faEventHubAppConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "

az functionapp config appsettings set --name $receiveFaName --resource-group $rg --settings "$faEventHubAppConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "
```

We can also store the storage account information for function apps, and use a key vault secret reference too.

```powershell
#storage account for function app
$saKey = $(az storage account keys list -n $saName -g $rg --query [0].value --output tsv)
$kvSASecretValue = "DefaultEndpointsProtocol=https;AccountName=$saName;AccountKey=$saKey;EndpointSuffix=core.windows.net"

az keyvault secret set --name $kvSASecretName --value $kvSASecretValue --description FunctionAppsecret  --vault-name $kvName
$sasecretURI = $(az keyvault secret show --name $kvSASecretName --vault-name $kvName --query id --output tsv)

az functionapp config appsettings set --name $sendFaName --resource-group $rg --settings "$faStorageAccountConfig=@Microsoft.KeyVault(SecretUri=$sasecretURI) "

az functionapp config appsettings set --name $receiveFaName --resource-group $rg --settings "$faStorageAccountConfig=@Microsoft.KeyVault(SecretUri=$sasecretURI) "
```

For now, the send function uses broken out secrets for the event hub to form the connection string.  We can also store broken out secrets and retrieve them from Key Vault for our Azure Function.
```powershell
az keyvault secret set --name $kvEHHostNameSecretName --value $kvEHHostNameSecretValue --description FunctionAppsecret  --vault-name $kvName
$ehsecretURI = $(az keyvault secret show --name $kvEHHostNameSecretName --vault-name $kvName --query id --output tsv)

az functionapp config appsettings set --name $sendFaName --resource-group $rg --settings "$faEHHostNameConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "
az functionapp config appsettings set --name $receiveFaName --resource-group $rg --settings "$faEHHostNameConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "

az keyvault secret set --name $kvEHSasPolicyConfigName --value $kvEHSasSecretValue --description FunctionAppsecret  --vault-name $kvName
$ehsecretURI = $(az keyvault secret show --name $kvEHSasPolicyConfigName --vault-name $kvName --query id --output tsv)

az functionapp config appsettings set --name $sendFaName --resource-group $rg --settings "$faEHSasPolicyConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "
az functionapp config appsettings set --name $receiveFaName --resource-group $rg --settings "$faEHSasPolicyConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "

$kvEHSasKeySecretValue = $(az eventhubs namespace authorization-rule keys list --resource-group $rg --namespace-name $ehNamespace --name RootManageSharedAccessKey --query primaryKey --output tsv)
az keyvault secret set --name $kvEHSasKeyName --value $kvEHSasKeySecretValue --description FunctionAppsecret  --vault-name $kvName
$ehsecretURI = $(az keyvault secret show --name $kvEHSasKeyName --vault-name $kvName --query id --output tsv)

az functionapp config appsettings set --name $sendFaName --resource-group $rg --settings "$faEHSasKeyConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "
az functionapp config appsettings set --name $receiveFaName --resource-group $rg --settings "$faEHSasKeyConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "

$kvEHNameSecretValue = $ehName
az keyvault secret set --name $kvEhName --value $kvEHNameSecretValue --description FunctionAppsecret  --vault-name $kvName
$ehsecretURI = $(az keyvault secret show --name $kvEhName --vault-name $kvName --query id --output tsv)

az functionapp config appsettings set --name $sendFaName --resource-group $rg --settings "$faEHNameConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "
az functionapp config appsettings set --name $receiveFaName --resource-group $rg --settings "$faEHNameConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "
```

We can now attempt to deploy the Azure Functions to the function app.  While there are multiple [Azure Functions Deployment Options](https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies), for simplicity, we'll use the [Azure Functions Python Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python#publishing-to-azure) to deploy the function app.  This will attempt to build the function remotely based off the local bits.

> Note, for now this will attempt to publish the function **twice** in a row.  If we end up publishing while the function app is still cycling, we may get 400 response codes.  Wait for the function app to finish cycling, which can also manually restart in the Azure Portal for the function app.
>  The remote build looks to have a timeout so the second call appears to push the function.  This also assumes that the subfolder for each of the application holds the function itself (e.g. scenario/send-function and scenario/receive-function).  Also be sure that the **requirements.txt** will have the appropriate dependencies or else the newly built version may not deploy correctly.

```powershell
    Push-Location $sendFaFolder
    #might need to check if the publish was successful, or run twice?
    func azure functionapp publish $sendFaName
    func azure functionapp publish $sendFaName
    Pop-Location

    Write-Host "Publishing Receive Function"
    Push-Location $receiveFaFolder
    func azure functionapp publish $receiveFaName
    func azure functionapp publish $receiveFaName
    Pop-Location
```

Once we have the function app deployed, let's add [IP Filtering](https://docs.microsoft.com/en-us/azure/azure-functions/functions-networking-options#inbound-ip-restrictions).  In this case, we'll want to restrict the send function app to allow calls from [Azure Monitor Webhooks](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups#webhook).

```powershell
#add network restriction on function app for sender.
$priority = 10
$index = 0
$ruleName = "AzureMonitorWebhookRule"
$azMonIPs.ForEach({
    $ipToAdd = "$_/32"; #this needs to use a /32 to add for the rule
    az functionapp config access-restriction add -g $rg -n $sendFaName --rule-name "$ruleName-$index" --action Allow --ip-address $ipToAdd --priority $priority;
    $priority += 10;
    $index += 1;
    Write-Host "Added Rule for $_"
})
```

We can now set up an Action Group for Azure Monitor to point to the Send Azure Function.  Since the Azure Function uses an HTTP trigger, we'll need to [Retrieve an Azure Function Key](https://stackoverflow.com/questions/46338239/retrieve-the-host-keys-from-an-azure-function-app) to ensure that Azure Monitor can trigger the function.

> In this scenario we're using the function host key to call the Azure Function.  There are other [Azure Functions Authentication Options](https://docs.microsoft.com/en-us/azure/app-service/app-service-authentication-how-to?toc=%2fazure%2fazure-functions%2ftoc.json)], but we're using this approach for simplicity, while in real-world scenarios this would likely need to be evaluated further.

```powershell
$faSender = $(az functionapp show -n $sendFaName -g $rg)
$faSenderObject = $faSender | ConvertFrom-Json
$faSenderId = $faSenderObject.id
$faSendKey = $(az rest --method post --uri "$faSenderId/host/default/listKeys?api-version=2018-11-01" --query functionKeys.default --output tsv)

$faHostName = $faSenderObject.defaultHostName
$faSendURI = "https://$faHostName/$sendURIPath" + "?code=$faSendKey"

$sendActionGroup = $(az monitor action-group create -g $rg -n $sendActionGroupName -a azurefunction $sendActionGroupReceiverName $faSenderObject.id $sendFuncName $faSendURI useCommonAlertSchema)
$sendActionGroupObject = $sendActionGroup | ConvertFrom-Json
```

Let's set up an Alert for Azure Storage Account, as well as the test VM.  We'll tie the [Azure Monitor Metric Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-metric-overview) to the Action Group that will trigger the 'Send' Azure Function.

> We're using simple / easy to meet conditions just to see that the alerts will fire.  For a real-world scenario, we'd want to update the alert conditions to reflect proper alerting conditions.

```powershell
$saId = $(az storage account show -n $saName -g $rg --query id -o tsv)
##simpler metric alert on storage account.
$saAlert = $(az monitor metrics alert create -n $saAlertName -g $rg --scopes $saId --evaluation-frequency 1m --window-size 1m --action $sendActionGroupObject.id --description "Storage Transactions" --condition "total transactions >= 0")

$saAlert

$vmId = $(az vm show -g $rg -n $vmName --query id -o tsv)
$vmAlert = $(az monitor metrics alert create -n $vmAlertName -g $rg --scopes $vmId --evaluation-frequency 1m --window-size 1m --action $sendActionGroupObject.id --description "Percentage CPU Used" --condition "avg Percentage CPU >= 0")

$vmAlert
```

We can then make sure to start and stop the test VM.

```powershell
az vm stop --ids $vmId
#wait for a minute to start up the VM again.
sleep 60
az vm start --ids $vmId

sleep 600
az vm stop --ids $vmId
```

### Debugging Locally

We're also going to assume that we can use VS Code with the Azure Functions extension installed too.  We'll also want to clone this repo to pull in the sample functions.

Be sure to install the latest version of [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools).

> Work Around for Azure Functions Core Tools for Chocolatey install path: https://github.com/Azure/azure-functions-core-tools/issues/693#issuecomment-533713275.
>  1. Run choco uninstall azure-functions-core-tools
>  2. Download nupkg file from [here](https://chocolatey.org/packages/azure-functions-core-tools) (see the [Download Link for nupkg for Azure Functions Core Tools](https://chocolatey.org/api/v2/package/azure-functions-core-tools/2.7.1724)).
>  3. Open the nupkg in Package Explorer and edit the **tools\chocolateyinstall.ps1** script (change **x86** to **x64** in the package URL).  Be sure to save the nupkg with the changes!
>  ```powershell
>  choco install nugetpackageexplorer
>  ```
>  4. Run this command in the folder where edited nupkg file is, and be sure to ignore the checksums since we did not make an update to the checksum but instead edited the URL for the nupkg.
>  ```powershell
>  choco install azure-functions-core-tools -source . --ignore-checksums
>  ```  
>  

#### Debugging the Send Function

Assuming we have a **local.settings.json** file associated with the function app, we can fill in the details and rely on the functions core tools runtime to debug locally:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=mysa;AccountKey=key123==;EndpointSuffix=core.windows.net",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "EVENT_HUB_HOSTNAME": "myeh.servicebus.windows.net",
    "EVENT_HUB_SAS_POLICY": "RootManageSharedAccessKey",
    "EVENT_HUB_SAS_KEY": "ehkey123=",
    "EVENT_HUB_NAME": "alert-eh",
    "my_RootManageSharedAccessKey_EVENTHUB" : "Endpoint=sb://myeh.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=ehkey123=;EntityPath=alert-eh"
  }
}

```

Make sure that the VSCode tasks.json points to the appropriate function to debug.

```json
...
{
            "type": "func",
            "command": "host start",
            "problemMatcher": "$func-watch",
            "isBackground": true,
            "dependsOn": "pipInstall",
            "options": {
                "cwd": "${workspaceFolder}/Scenarios\\az-mon-eh-kv-python\\az-mon-eh-send-kv-python"
            }
        },
        {
            "label": "pipInstall",
            "type": "shell",
            "osx": {
                "command": "${config:azureFunctions.pythonVenv}/bin/python -m pip install -r requirements.txt"
            },
            "windows": {
                "command": "${config:azureFunctions.pythonVenv}\\Scripts\\python -m pip install -r requirements.txt"
            },
            "linux": {
                "command": "${config:azureFunctions.pythonVenv}/bin/python -m pip install -r requirements.txt"
            },
            "problemMatcher": [],
            "options": {
                "cwd": "${workspaceFolder}/Scenarios\\az-mon-eh-kv-python\\az-mon-eh-send-kv-python"
            }
        }
...
```

We can set a break point in the Send Function, and then hit F5 in VSCode.

In order to trigger the function, we can use a POST call with a [sample payload](../Scenarios/az-mon-eh-kv-python/az-mon-eh-send-kv-python/sample-payload.json).  We can then post to the locally running Send API.

```powershell
body = Get-Content .\az-mon-eh-send-kv-python\sample-payload.json | ConvertTo-Json

invoke-webrequest -Method POST -uri http://localhost:7071/api/SendAlertHttpTrigger -body $body
```
![HTTP triggered Azure Function Debugging](../Media/scenario-az-mon-eh-kv-python/debug-send.png 'HTTP Triggered Azure Function Debugging')

> If we want to send to the event hub we created as part of the deployment script, we'll want to be sure to add the debugging client's IP address in order to have access to Event Hub.
![Add Client IP to Event Hub](../Media/scenario-az-mon-eh-kv-python/add-client-ip-to-eh.png 'Add Client IP to Event Hub')

#### Debugging the Receive Function

We'll want to make sure the function.json has a placeholder to point to the local settings.

```json
{
  "scriptFile": "__init__.py",
  "bindings": [
    {
      "type": "eventHubTrigger",
      "name": "event",
      "direction": "in",
      "eventHubName": "alert-eh",
      "connection": "my_RootManageSharedAccessKey_EVENTHUB",
      "cardinality": "many",
      "consumerGroup": "myconsumergroup"
    }
  ]
}
```
> Note, when we deploy, the connection should point to RootManageSharedAccessKey_EVENTHUB.  The "my_" prepended in the connection works for local debugging.  For deployment, we tested without using the "my_" prepended in the connection setting.

Assuming we have a **local.settings.json** file associated with the function app, we can fill in the details and rely on the functions core tools runtime to debug locally:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=myeh;AccountKey=ehkey123==;EndpointSuffix=core.windows.net",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "my_RootManageSharedAccessKey_EVENTHUB": "Endpoint=sb://myeh.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=ehkey123=;EntityPath=alert-eh"
  }
}
```

Make sure that the VSCode tasks.json points to the appropriate function to debug.

```json
...
{
            "type": "func",
            "command": "host start",
            "problemMatcher": "$func-watch",
            "isBackground": true,
            "dependsOn": "pipInstall",
            "options": {
                "cwd": "${workspaceFolder}/Scenarios\\az-mon-eh-kv-python\\az-mon-eh-receive-kv-python"
            }
        },
        {
            "label": "pipInstall",
            "type": "shell",
            "osx": {
                "command": "${config:azureFunctions.pythonVenv}/bin/python -m pip install -r requirements.txt"
            },
            "windows": {
                "command": "${config:azureFunctions.pythonVenv}\\Scripts\\python -m pip install -r requirements.txt"
            },
            "linux": {
                "command": "${config:azureFunctions.pythonVenv}/bin/python -m pip install -r requirements.txt"
            },
            "problemMatcher": [],
            "options": {
                "cwd": "${workspaceFolder}/Scenarios\\az-mon-eh-kv-python\\az-mon-eh-receive-kv-python"
            }
        }
...
```

We can set a break point in the function, and then hit F5 in VSCode.  We can also use [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer) and pass in the [Azure Event Hub Connection String](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string) to send an event to the event hub to trigger the function.

![Event Hub triggered Azure Function Debugging](../Media/scenario-az-mon-eh-kv-python/debug.png 'Event Hub Triggered Azure Function Debugging')

> If we want to send to the event hub we created as part of the deployment script, we'll want to be sure to add the debugging client's IP address in order to have access to Event Hub.
![Add Client IP to Event Hub](../Media/scenario-az-mon-eh-kv-python/add-client-ip-to-eh.png 'Add Client IP to Event Hub')

### Validate The Scenario

We can check the alerts have fired in the resource group's alerts in the Azure Portal.

![Validate Alerts Fired in Portal](../Media/scenario-az-mon-eh-kv-python/validate-0.png 'Validate Alerts Fired in Portal')

We should be able to check that the action group which is linked to the Azure Monitor Metric Alerts will point to the 'Send' Azure function.

![Validate Action Group in Portal](../Media/scenario-az-mon-eh-kv-python/validate-1.png 'Validate Action Group in Portal')

We should be able to see that the Send Function App had successful calls.
![Validate Send Triggered in Portal](../Media/scenario-az-mon-eh-kv-python/validate-2.png 'Validate Send Triggered in Portal')

We should be able to see that the Send Function App was triggered, and be able to examine details for the function.  This depends on what was logged in the function.

![Validate Send Triggered Details in Portal](../Media/scenario-az-mon-eh-kv-python/validate-3.png 'Validate Send Triggered Details in Portal')

We should be able to check for the key vault references in the app settings.
Click on Manage Application Settings.  Then we can see that the Key Vault references should be working (assuming network access and permissions are granted).
![Validate Azure Function KV Reference App Settings In Portal](../Media/scenario-az-mon-eh-kv-python/validate-4.png 'Validate Azure Function KV Reference App Settings In Portal')

We should be able to check VNET Integration in the Azure Function network settings.
Click on Manage Application Settings.
![Validate Azure Function VNET Integration In Portal](../Media/scenario-az-mon-eh-kv-python/validate-5.png 'Validate Azure Function VNET Integration In Portal')

We should be able to check VNET Integration in the Azure Function network settings.
Click on Manage Application Settings.
![Validate Azure Function VNET Integration In Portal](../Media/scenario-az-mon-eh-kv-python/validate-5.png 'Validate Azure Function VNET Integration In Portal')

We should be able to check the IP Filtering in the Azure Function network settings.
Click on Manage Application Settings.
![Validate Azure Function IP Filtering In Portal](../Media/scenario-az-mon-eh-kv-python/validate-6.png 'Validate Azure Function IP Filtering In Portal')

> We did not update the scm IP Filtering in this case, but this could be further restricted for appropriate access.

We can check on the Event Hub next.  We can see that an Event was sent to Event Hub.
![Validate Event sent to Event Hub In Portal](../Media/scenario-az-mon-eh-kv-python/validate-7.png 'Validate Event sent to Event Hub In Portal')

We can check that Event Hub allows access to our subnets in the Firewall and Virtual Network settings.
![Validate Event Hub Subnet Access In Portal](../Media/scenario-az-mon-eh-kv-python/validate-8.png 'Validate Event Hub Subnet Access In Portal')

We can check that Key Vault allows access to our subnets in the Firewall and Virtual Network settings.
![Validate Key Vault Subnet Access In Portal](../Media/scenario-az-mon-eh-kv-python/validate-9.png 'Validate Key Vault Subnet Access In Portal')
> During the deployment this shows as 'all networks'.  However, when we click on 'selected networks', the network rules appear.  This merits **further investigation** to validate the scenario.  In the case that Azure Functions cannot resolve the Key Vault Reference due to IP filtering, we can add the **outbound IP addresses** associated with the Azure Functions that need to reach Azure Key Vault as a **workaround**.
![Get Outbound IPs for Azure Function In Portal](../Media/scenario-az-mon-eh-kv-python/outbound-ips.png 'Get Outbound IPs for Azure Function In Portal')
> With Premium Azure Functions, the outbound IP addresses can **possibly change** and are **not dedicated** to the Azure Function; should we want **dedicated outbound IP addresses**, we should look into hosting the Azure Function in an [App Service Environment](https://docs.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-network-architecture-overview).

We can check that Storage Account allows access to our subnets in the Firewall and Virtual Network settings.
![Validate Storage Account Subnet Access In Portal](../Media/scenario-az-mon-eh-kv-python/validate-10.png 'Validate Storage Account Subnet Access In Portal')
> During the deployment this shows as 'all networks'.  However, when we click on 'selected networks', the network rules appear.  This merits **further investigation** to validate the scenario.  If the Azure Function doesn't have access to the storage account, then the function runtime will have an error starting.  The subnet reference should be sufficient in this case.

We can check that Receiver Azure Function by clicking on Monitor.  We can see prior triggers and whether they were successful.
![Validate Receiver Azure Function In Portal](../Media/scenario-az-mon-eh-kv-python/validate-11.png 'Validate Receiver Azure Function In Portal')

We can check that Receiver Azure Function Key Vault References in the Function app Settings.
![Validate Receiver Azure Function Key Vault References In Portal](../Media/scenario-az-mon-eh-kv-python/validate-12.png 'Validate Receiver Azure Function Key Vault References In Portal')

We should be able to check VNET Integration in the Azure Function network settings.
Click on Manage Application Settings.
![Validate Azure Function VNET Integration In Portal](../Media/scenario-az-mon-eh-kv-python/validate-13.png 'Validate Azure Function VNET Integration In Portal')

We did not set IP filtering on the receiver Azure Function as this will reach out to Event Hub (as an outbound request) instead of Event Hub sending an inbound request.  We did not update the scm IP Filtering in this case, but this could be further restricted for appropriate access.

When we are satisified with the test, we can clean up with the following az cli command:

```powershell
az group delete -n $rg
```

### Additional Notes

While this is an example for how we can use VNET integration, IP Filtering, Event Hubs, Key Vault, and Azure Functions to work with Azure Monitor, the base idea can work.  Of course, additional lockdown details should be explored for real-world scenarios.

We can look into redundancy / geo-replication if required. The base deployment should be evaluated to see if it's suitable or can be adjusted for a given scenario, and then base stamp can be deployed for potential geo-replication scenarios.