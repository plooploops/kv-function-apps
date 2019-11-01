
#get a random lowercase string https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/
$RANDOM = $(-join ((97..122) | Get-Random -Count 5 | % {[char]$_}))

$rg = "myResourceGroup$RANDOM"
$location = 'westus'
$saName = "mystorageaccount$RANDOM"
$aspName = "myPlan$RANDOM"
$faName = "myfunctionapp$RANDOM"
$faEventHubAppConfig = "my_RootManageSharedAccessKey_EVENTHUB"
$kvName = "mykeyvault$RANDOM"
$kvSecretName = 'SuperSecret'
$kvSecretValue = 'My super secret!'
$kvEHSecretName = 'EventHubConnection'
$kvMonitorName = 'monitoring-my-kv'
$ehName = "samples-workitems"
$ehNamespace = "mynamespace"

#create an rg
az group create -n $rg -l $location

# Create a storage account in the resource group.
az storage account create --name $saName --location $location --resource-group $rg --sku Standard_LRS

#create app service plan and function
az appservice plan create --name $aspName --resource-group $rg --sku S1
az functionapp create --name $faName --resource-group $rg --plan $aspName --storage-account $saName
az functionapp identity assign --name $faName --resource-group $rg

#get service principal ID attached to function app
$spID=$(az functionapp show --resource-group $rg --name $faName --query identity.principalId --out tsv)

#create a key vault
az keyvault create --name $kvName --resource-group $rg --location $location

#create a secret for Key Vault
az keyvault secret set --name $kvSecretName --value $kvSecretValue --description FunctionAppsecret  --vault-name $kvName

#grant access to key vault.  The Service Principal bound to the Function App needs rights to access the secret in Key vault.
az keyvault set-policy --name $kvName --resource-group $rg --object-id $spID --secret-permissions get

#get secret URI
$secretURI = $(az keyvault secret show --name $kvSecretName --vault-name $kvName --query id --output tsv)

#bind app setting / environment variable for Azure Function app to key vault secret URI.  Note the extra space for parsing the secret.
az functionapp config appsettings set --name $faName --resource-group $rg --settings "$kvSecretName=@Microsoft.KeyVault(SecretUri=$secretURI) "

#create event hub
az eventhubs namespace create --resource-group $rg --name $ehNamespace --location $location
az eventhubs eventhub create --resource-group $rg --namespace-name $ehNamespace --name $ehName --message-retention 4 --partition-count 15

#store event hub connection string in key vault, and bind key vault to function app settings for event hub trigger use
$kvEHSecretValue = $(az eventhubs namespace authorization-rule keys list --resource-group $rg --namespace-name $ehNamespace --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
az keyvault secret set --name $kvEHSecretName --value $kvEHSecretValue --description FunctionAppsecret  --vault-name $kvName
$ehsecretURI = $(az keyvault secret show --name $kvEHSecretName --vault-name $kvName --query id --output tsv)

#bind app setting / environment variable for Azure Function app to key vault secret URI.  Note the extra space for parsing the secret.
az functionapp config appsettings set --name $faName --resource-group $rg --settings "$faEventHubAppConfig=@Microsoft.KeyVault(SecretUri=$ehsecretURI) "

#storage account for function app
$saKey = $(az storage account keys list -n $saName -g $rg --query [0].value --output tsv)
$saConnection = "DefaultEndpointsProtocol=https;AccountName=$saName;AccountKey=$saKey;EndpointSuffix=core.windows.net"

az functionapp config appsettings set --name $faName --resource-group $rg --settings "AzureWebJobsStorage=$saConnection "

#azure monitor for key vault metrics + logging
#get key vault reference
$kvID = $(az keyvault show -n $kvName -g $rg --query id --output tsv)

#get storage account reference
$saID = $(az storage account show  -n $saName -g $rg --query id --output tsv)

#get logging JSON.  Azure Key Vault has a category for AuditEvent
$logJSON = '[ { "category": "AuditEvent", "enabled": true, "retentionPolicy": { "enabled": false, "days": 0 } } ]' | ConvertTo-Json

#get metrics JSON.  Azure Key Vault has a category for AllMetrics
$metricJSON = '[ { "category": "AllMetrics", "enabled": true, "retentionPolicy": { "enabled": false, "days": 0 } } ]' | ConvertTo-Json

#add azure monitor diagnostic settings to point to key vault.  Use RootManageSharedAccessKey as the eventhub policy.
az monitor diagnostic-settings create --resource $kvID -n $kvMonitorName --storage-account $saID --logs $logJSON --metrics $metricJSON

#Another option is for Azure Monitor to stream to Event Hub
#get event hub reference
#az eventhubs eventhub create --resource-group $rg --namespace-name $ehNamespace --name monitoring-sample --message-retention 4 --partition-count 15
#$ehID = $(az eventhubs eventhub show -g $rg --namespace-name $ehNamespace -n monitoring-sample --query id --output tsv)
#az monitor diagnostic-settings create --resource $kvID -n $kvMonitorName --event-hub $ehID --event-hub-rule RootManageSharedAccessKey --storage-account $saID --logs $logJSON --metrics $metricJSON

#deploy azure function https://github.com/Azure/azure-functions-core-tools
func azure functionapp publish $faName
