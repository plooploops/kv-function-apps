## Event Hub Trigger with Azure Function and Key Vault Integration

The goal is to deploy an Event Hub, and bind an Azure Function to retrieve a secret from Key Vault.  We can use Azure Monitor to validate the number of calls to key vault from azure functions.

![Event Hub triggered Azure Function](../Media/scenario-eh-az-function-kv/scenario.png 'Event Hub Triggered Azure Function')

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
1. [Azure Event Hub cli](https://docs.microsoft.com/en-us/cli/azure/eventhubs/eventhub?view=azure-cli-latest)
1. [Azure Event Hub Connection String](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string)
1. [Azure Key Vault Logging](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity)
1. [Azure Monitor with Key Vault](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/azure-key-vault)
1. [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer)
1. [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/)
1. [Generate Random Letters in Powershell](https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/)
1. [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools)
1. [Azure Functions Extension](https://github.com/Microsoft/vscode-azurefunctions/wiki)

### Deploy Components

Assuming we have a fresh Azure subscription, we can put together a test resource group along with Azure Event Hubs, Azure Functions, and a Key Vault.

Please ensure that we use [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest) and login to the Azure subscription.

```powershell
az login
az account set -s <subscription id>
```

For reference we can use this [deployment script](../Scenarios/eh-az-function-kv/deploy.ps1) from the project root directory to stand up the components for this exercise.

We can create a resource group, a storage account, and a function app with an app service plan.  We will also assign a managed identity to the function app.

```powershell
az group create -n myResourceGroup -l westus

# Create a storage account in the resource group.
az storage account create --name mystorageaccount --location westus --resource-group myResourceGroup --sku Standard_LRS

#create app service plan and function
az appservice plan create --name myappserviceplan --resource-group myResourceGroup --sku S1
az functionapp create --name myfunctionapp --resource-group myResourceGroup --plan myappserviceplan --storage-account mystorageaccount
az functionapp identity assign --name myfunctionapp --resource-group myResourceGroup
```

We can then get a service principal, which in this case is a managed identity for the function app, and then grant access to a key vault to that service principal.  We'll then add a secret in key vault to use later.

```powershell
#get service principal ID attached to function app
$spID=$(az functionapp show --resource-group myResourceGroup --name myfunctionapp --query identity.principalId --out tsv)

#create a key vault
az keyvault create --name mykeyvault --resource-group myResourceGroup --location westus

#create a secret for Key Vault
az keyvault secret set --name SuperSecret --value 'Super Secret Value!' --description FunctionAppsecret  --vault-name mykeyvault

#grant access to key vault.  The Service Principal bound to the Function App needs rights to access the secret in Key vault.
az keyvault set-policy --name mykeyvault --resource-group myResourceGroup --object-id $spID --secret-permissions get
```

We'll get the secret URI and add a reference to the Secret URI in the Function App Settings.  

> The function app picks up the secret from Key Vault only once when the app is spinning up, so only during scale operations.  The secret will be securely cached and reused for a provisioned instance of the function app.

```powershell
#get secret URI
$secretURI = $(az keyvault secret show --name SuperSecret --vault-name mykeyvault --query id --output tsv)

#bind app setting / environment variable for Azure Function app to key vault secret URI.  Note the extra space for parsing the secret.
az functionapp config appsettings set --name myfunctionapp --resource-group myResourceGroup --settings "SuperSecret=@Microsoft.KeyVault(SecretUri=$secretURI) "
```

We can now create an event hub (which should match with the function app event hub trigger), and then add the event hub connection as well to Key Vault and point the function app to the Key Vault secret holding the event hub connection string.

```powershell
#create event hub
az eventhubs namespace create --resource-group myResourceGroup --name myehnamespace --location westus
az eventhubs eventhub create --resource-group myResourceGroup --namespace-name myehnamespace --name sample-workitems --message-retention 4 --partition-count 15

#store event hub connection string in key vault, and bind key vault to function app settings for event hub trigger use
$kvEHSecretValue = $(az eventhubs namespace authorization-rule keys list --resource-group myResourceGroup --namespace-name myehnamespace --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
az keyvault secret set --name EventHubConnection --value $kvEHSecretValue --description FunctionAppsecret  --vault-name mykeyvault
$ehsecretURI = $(az keyvault secret show --name EventHubConnection --vault-name mykeyvault --query id --output tsv)

#bind app setting / environment variable for Azure Function app to key vault secret URI.  Note the extra space for parsing the secret.
az functionapp config appsettings set --name myfunctionapp --resource-group myResourceGroup --settings "my_RootManageSharedAccessKey_EVENTHUB=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "
```

We can also get the storage account and add a placeholder in the function app for storage account access.
```powershell
#storage account for function app
$saKey = $(az storage account keys list -n mystorageaccount -g myResourceGroup --query [0].value --output tsv)
$saConnection = "DefaultEndpointsProtocol=https;AccountName=mystorageaccount;AccountKey=$saKey;EndpointSuffix=core.windows.net"

az functionapp config appsettings set --name myfunctionapp --resource-group myResourceGroup --settings "AzureWebJobsStorage=$saConnection "
```

We can now add azure monitor for key vault metrics + logging.

```powershell
#azure monitor for key vault metrics + logging
#get key vault reference
$kvID = $(az keyvault show -n mykeyvault -g myResourceGroup --query id --output tsv)

#get storage account reference
$saID = $(az storage account show  -n mystorageaccount -g myResourceGroup --query id --output tsv)

#get logging JSON.  Azure Key Vault has a category for AuditEvent
$logJSON = '[ { "category": "AuditEvent", "enabled": true, "retentionPolicy": { "enabled": false, "days": 0 } } ]' | ConvertTo-Json

#get logging JSON.  Azure Key Vault has a category for AllMetrics
$metricJSON = '[ { "category": "AllMetrics", "enabled": true, "retentionPolicy": { "enabled": false, "days": 0 } } ]' | ConvertTo-Json

#add azure monitor diagnostic settings to point to key vault.  Use RootManageSharedAccessKey as the eventhub policy.
az monitor diagnostic-settings create --resource $kvID -n monitoring-my-kv --storage-account $saID --logs $logJSON --metrics $metricJSON
```

Another option is for Azure Monitor to stream to Event Hub.
```powershell
#get event hub reference
$ehID = $(az eventhubs eventhub show -g $rg --namespace-name $ehNamespace -n $ehName --query id --output tsv)

#include event hub as well as storage for streaming from Azure Monitor for Logging + Metrics for Azure Key Vault
az monitor diagnostic-settings create --resource $kvID -n monitoring-my-kv --event-hub $ehID --event-hub-rule RootManageSharedAccessKey --storage-account $saID --logs $logJSON --metrics $metricJSON
```

We can use the [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools) to now deploy the function app.  We should run this from the project root directory.

> Note that if we end up publishing while the function app is stil cycling, we may get 400 response codes.  Wait for the function app to finish cycling, which can also manually restart in the Azure Portal for the function app.

```powershell
#deploy azure function https://github.com/Azure/azure-functions-core-tools
func azure functionapp publish $faName
```

### Debugging Locally

We're also going to assume that we can use VS Code with the Azure Functions extension installed too.  We'll also want to clone this repo to pull in the sample function.

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
  
Assuming we have a **local.settings.json** file associated with the function app, we can fill in the details and rely on the functions core tools runtime to debug locally:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=mysa;AccountKey=mysaKey;EndpointSuffix=core.windows.net",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    "my_RootManageSharedAccessKey_EVENTHUB": "Endpoint=sb://myeh.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=myehKey",
    "SuperSecret" : "My super secret value!"
  }
}
```

We can set a break point in the function, and then hit F5 in VSCode.  We can also use [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer) and pass in the [Azure Event Hub Connection String](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string) to send an event to the event hub to trigger the function.

![Event Hub triggered Azure Function Debugging](../Media/scenario-eh-az-function-kv/debug.png 'Event Hub Triggered Azure Function Debugging')

### Validate The Scenario

We can check on the Azure Function in the Azure Portal.  We can click on restart on the function app to trigger a sync of the app settings.

![Validate Azure Function In Portal](../Media/scenario-eh-az-function-kv/validate-0.png 'Validate Azure Function In Portal')

We should be able to check that the app settings are pointing to key vault secrets.

Check out the function app settings.
![Validate Azure Function App Settings In Portal](../Media/scenario-eh-az-function-kv/validate-1.png 'Validate Azure Function App Settings In Portal')

Click on Manage Application Settings.
![Validate Azure Function App Settings In Portal](../Media/scenario-eh-az-function-kv/validate-2.png 'Validate Azure Function App Settings In Portal')

We should be able to check for the key vault refernces in the app settings.
Click on Manage Application Settings.
![Validate Azure Function KV Reference App Settings In Portal](../Media/scenario-eh-az-function-kv/validate-3.png 'Validate Azure Function KV Reference App Settings In Portal')

We can also navigate to the function app and click on 'run' to do a test call to the function.  We should see the secret in the logging (for demo purposes!).

![Validate Azure Function KV Reference In Portal](../Media/scenario-eh-az-function-kv/validate-4.png 'Validate Azure Function KV Reference In Portal')

We can also use [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/), and assuming that our diagnostic settings have flowed through, we can point to the blob container with the Metrics for Key Vault.

![Validate Azure KV Metrics in Storage Explorer](../Media/scenario-eh-az-function-kv/validate-5.png 'Validate Azure KV Metrics in Storage Explorer')

We can check on the Key Vault Diagnostic Setting and see if we have storage accounts set up.  We could also point to event hub or log analytics.

![Validate Key Vault Diagnostic Setting In Portal](../Media/scenario-eh-az-function-kv/validate-5.1.png 'Validate Key Vault Diagnostic Setting In Portal')

We should be able to see a payload similar to this in the JSON file.
```JSON
{ "count": 4, "total": 4, "minimum": 1, "maximum": 1, "average": 1, "resourceId": "/SUBSCRIPTIONS/subid/RESOURCEGROUPS/myresourcegroup/PROVIDERS/MICROSOFT.KEYVAULT/VAULTS/mykeyvault", "time": "some time", "metricName": "ServiceApiHit", "timeGrain": "PT1M"}
```

Of course, we can also send a batch of messages to Event Hub to trigger the Azure Function using [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer).

![Validate Azure Function with KV by sending Events to Event Hub with Service Bus Explorer](../Media/scenario-eh-az-function-kv/validate-6.png 'Validate Azure Function with KV by sending Events to Event Hub with Service Bus Explorer')

When we are satisified with the test, we can clean up with the following az cli command:

```powershell
az group delete -n myResourceGroup
```

### Additional Notes

Based on this test, we can see the function app will pick up the settings from Key Vault whenever the function app cycles for scaling operations.  Since these secrets will be securely cached we can reuse the secrets in the function without hitting key vault again.

While this approach will help reduce calls to KeyVault, there could be a case with multiple apps refreshing from Key Vault at the same time; whether this solution will fit needs to take into consideration the greater system / solution.  This is definitely a first step that can be taken but there's other approaches that would need to account for the project's needs and constraints.