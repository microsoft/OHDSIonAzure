# Bootstrap Variables
rgName=ado-omop-bootstrap-rg
location=westus3
backendStorageAccountName=omopdevtfstatestoracc
backendStorageAccountContainerName=dev-omop-statefile-container
spForServiceConnectionName=sp-for-omop-service-connection
spForACRName=sp-for-acr
vgName=ado-omop-bootstrap-vg # bootstrap Variable Group Name
# For an Azure DevOps URL https://dev.azure.com/<my-org>/<my-project> use https://dev.azure.com/<my-org>/
adoOrgName=https://dev.azure.com/US-HLS-AppInnovations/
# For an Azure DevOps URL https://dev.azure.com/<my-org>/<my-project> use `my-project`
adoProjectName=OHDSIonAzure
# you should replace this with your own value.  This will be populated in the variable group, which will be used to update your Azure SQL DB administrative password through TF.
omopPassword=replaceP@SSWORD
kvName=ado-omop-bootstrap-kv

# ADO Build Agent Variables
adoBuildAgentPoolName=vmssagentspool
adoBuildAgentImage=UbuntuLTS
adoBuildAgentVMSku=Standard_D2_v3
adoBuildAgentStorageSku=StandardSSD_LRS
adoBuildAgentAuthenticationType=SSH
adoBuildAgentInstanceCount=2
adoBuildAgentUpgradePolicy=manual
adoBuildAgentSinglePlacementGroup=false
adoBuildAgentPlatformFaultDomainCount=1
adoBuildAgentLoadBalancer=""

# ADO Builder VM
adoBuilderVMName=ado-ubuntu
adoBuilderAgentImage=UbuntuLTS # Start with a basic ubuntu image, then install afterwards
adoBuilderPublicIPSku=Standard

### Setup Environment for Service Connection, Ado Builder, and TF State ###

# This RG will be used for the Service connection / TF state (could be split out further)
az group create -g $rgName -l $location  --tags Deployment="OHDSI on Azure"

## Setup TF State ##
### Step 1. Setup Backend State Storage Account
# create a storage account for TF state
az storage account create -n $backendStorageAccountName -g $rgName -l $location --sku Standard_LRS

# create a container in the storage account for TF state
storageConnectionString=$(az storage account show-connection-string -g ${rgName} -n ${backendStorageAccountName} -o tsv)
az storage container create -n $backendStorageAccountContainerName --connection-string $storageConnectionString

### Step 2. Push TF Backend State to your Azure Blob Storage Container
# As a one time step, you can now push the TF backend state file to your Azure Blob Storage container
# See https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli

## Setup Azure Service Connection ##
### Step 1. Create SP for Service Connection
spJson=$(az ad sp create-for-rbac -n $spForServiceConnectionName --role Owner)
# use the following to fill in your ADO Service Connection Details to provide for the SP manual flow
spAppId=$(echo $spJson | jq -r ".appId")
spPassword=$(echo $spJson | jq -r ".password")
spTenantId=$(echo $spJson | jq -r ".tenant")
# for use later with the AAD group for Azure SQL admin
spObjectId=$(az ad sp show --id $spAppId | jq -r ".objectId")

### Step 2: Link SP to service connection in Azure DevOps
# See https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#create-a-service-connection


## Setup Azure DevOpsBuild Agent (VMSS) ##
# See https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops

### Step 1. Set up an Azure VM

# create Azure VM for custom image use later.  First attach VM to ADO builder VNET.
az vm create \
  --resource-group $rgName \
  --name $adoBuilderVMName \
  --image $adoBuilderAgentImage \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku $adoBuilderPublicIPSku
  
adoBuilderVMJson=$(az vm show -g $rgName -n "$adoBuilderVMname")
adoBuilderVMNicId=$(echo $adoBuilderVMJson | jq -r ".value[0].properties.networkProfile.networkInterfaces[0].id")
adoBuilderVMNicJson=$(az network nic show --ids $adoBuilderVMNicId)
adoBuilderPublicIpId=$(echo $adoBuilderVMNicJson | jq -r ".ipConfigurations[0].publicIpAddress.id")
adoBuilderVMPublicIpJson=$(az network public-ip show --ids $adoBuilderPublicIpId)
adoBuilderVMPublicIP=$(echo $adoBuilderVMPublicIpJson | jq -r ".ipAddress")

ssh "azureuser@$adoBuilderVMPublicIP"

### Step 2. Setup the Azure VM to prepare for an image
# you can work through the notes in ./scripts/ado_builder.sh on the VM to make the necessary changes
# then you can work through the ./scripts/ado_builder_capture.sh to capture the image to use for the ADO VMSS build agent

### Step 3. Setup an Azure custom image
# This assumes that the builder agent has been captured in the RG (see the ./ado_builder_capture.sh for more context)
builderImageJson=$(az image create  -g $rgName -n $adoBuilderImageName --source $adoBuilderVMName)
builderImageId=$(echo $builderImageJson | jq -r ".id") # use to link to VMSS

### Step 4. Create Azure VMSS with the custom image
az vmss create -n $adoBuildAgentPoolName -g $rgName \
--image $builderImageId --vm-sku $adoBuildAgentVMSku \
--storage-sku $adoBuildAgentStorageSku --authentication-type $adoBuildAgentAuthenticationType \
--instance-count $adoBuildAgentInstanceCount --disable-overprovision \
--upgrade-policy-mode $adoBuildAgentUpgradePolicy --single-placement-group $adoBuildAgentSinglePlacementGroup \
--platform-fault-domain-count $adoBuildAgentPlatformFaultDomainCount --lb "$adoBuildAgentLoadBalancer"

vmssIdentityJson=$(az vmss identity assign --identities '[system]' -n $adoBuildAgentPoolName -g $rgName)
vmssIdentityObjectId=$(echo $vmssIdentityJson | jq -r ".systemAssignedIdentity") # add this identity to DB admin group

az vmss show -g $rgName -n $adoBuildAgentPoolName -o table

### Step 5. Create an Azure DevOps Variable Group and link to KV
# https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault

# requires installing the extension for azure-devops
vgJson=$(az pipelines variable-group create --name $vgName --org $adoOrgName --project $adoProjectName --variables omopPassword="")
vgId=$(echo $vgJson | jq -r ".id")

# for testing the VG without Key Vault you can update the variable 
# az pipelines variable-group variable update --group-id $vgId --name omopPassword --secret true --value $omopPassword
az keyvault create -g $rgName -n $kvName
az keyvault secret set --vault-name $kvName -n omopPassword --value $omopPassword

# Add SP Service Connection Access to KV
az keyvault set-policy -n $kvName --secret-permissions get list --object-id $spObjectId

# At this point, you will need to link the newly created Azure DevOps VG with the KV using the service connection
