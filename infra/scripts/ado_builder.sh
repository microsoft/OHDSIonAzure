# https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#update-an-existing-scale-set-with-a-new-custom-image
# Check the 1804 install scripts https://github.com/actions/virtual-environments/blob/main/images/linux/Ubuntu1804-Readme.md

### The following steps should be taken in your Azure VM ###
# Make sure you can ssh into your Azure VM: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#ssh-into-your-vm

### Step 1. Install Dependencies

### Step 1a. Install git
GIT_REPO="ppa:git-core/ppa"

sudo add-apt-repository $GIT_REPO -y
sudo apt-get update
sudo apt-get install git -y
git --version

### Step 1b. Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

### Step 1c. Install Docker
sudo apt-get install docker -y
sudo apt-get install docker.io -y

### Step 2. Reboot the VM
# Once installs are finished you can reboot the VM.
sudo shutdown -r

### Step 3. Reconnect to the VM
# Use SSH: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#ssh-into-your-vm

### Step 4. Remove machine information from Azure VM
sudo waagent -deprovision+user -force

