# https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#update-an-existing-scale-set-with-a-new-custom-image

### Back in your local terminal ###

adoBuilderVMName=ado-ubuntu
rgName=ado-omop-bootstrap-rg
adoBuilderImageName=ado-builder-image
adoBuildAgentPoolName=vmssagentspool

### Step 1. Deallocate the prepared Azure VM
az vm deallocate -g $rgName -n $adoBuilderVMName

### Step 2. Generalize the Azure VM
az vm generalize -g $rgName -n $adoBuilderVMName

### Step 3. Create an image based on the Azure VM
builderImageJson=$(az image create  -g $rgName -n $adoBuilderImageName --source $adoBuilderVMName)
builderImageId=$(echo $builderImageJson | jq -r ".id") # use to link to VMSS

# You can use the builder image id when standing up Azure Virtual Machines or Azure Virtual Machine Scale Sets
echo $builderImageId