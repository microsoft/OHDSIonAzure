# Troubleshooting Azure VMSS Agent Pool

Here's some troubleshooting notes for working with the [Azure VMSS Agent Pool](/infra/terraform/bootstrap/README.md/#step-5-setup-your-azure-devops-agent-pool).

## Table of contents

1. Connect from your [Jumpbox to your Azure VMSS Instance](#connect-from-your-jumpbox-to-your-azure-vmss-instance)
2. Confirm your [Azure VMSS instance dependencies installed](#confirm-your-azure-vmss-instance-dependencies-installed)
    * Check your [cloud-init status](#check-your-cloud-init-status) in the Azure VMSS Instance
    * Confirm your [Azure Windows VMSS Instance Dependencies Installed](#confirm-your-azure-windows-vmss-instance-dependencies-installed)
3. Manually Connect Your [Azure DevOps VMSS Agent Pool to your Azure DevOps Pipeline](#manually-connect-your-azure-devops-vmss-agent-pool-to-your-azure-devops-pipeline)

## Connect from your Jumpbox to your Azure VMSS Instance

If you are using an Azure Windows VM, you will want to make sure you have an SSH client installed.  For example, you can use [OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse) with Windows.

1. Connect to your Jumpbox
  * For Linux you can use [SSH](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#ssh-into-your-vm)
  * For Windows you can use [RDP](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/connect-logon)

  > Your jumpbox credentials should be setup through your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md#step-1-update-your-variables)

2. In the Azure Portal, navigate to your Azure Virtual Network to check the connected devices.
  ![Get Azure VMSS Instance IP](/docs/media/connect_to_azure_vmss_instance_1.png)

3. In your Jumpbox, SSH using the IP address for the desired Azure VMSS Instance

    ```bash
    ssh azureuser@<azure.vmss.instance.ip>
    ```

    > Your credentials should be setup through your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md#step-1-update-your-variables)

## Confirm your Azure VMSS Instance Dependencies Installed

You can use the following steps to confirm your Azure VMSS instance has its dependencies installed:

1. Connect to your [Azure VMSS Instance using your Jumpbox](#connect-from-your-jumpbox-to-your-azure-vmss-instance)

2. Within a bash shell, you can confirm the following dependencies are available:
  * Git
    ```bash
    git --version
    ```

  * Docker
    ```bash
    docker --version
    ```

  * Azure CLI
    ```bash
    az --version
    ```
  
  * unzip
    ```bash
    unzip --version
    ```

  * jq
    ```bash
    jq --version
    ```

  * dotnet
    ```bash
    dotnet --version
    ```

3. If these dependencies aren't available, you may need to check the cloud-init status:
    ```bash
    sudo cloud-init status
    ```
    > If the status returns `status: running` then you can wait for the cloud-init process to finish.  If the status returns `status: done` then you may need to have `cloud-init` re-install, see the [notes](#check-your-cloud-init-status) in the following section for more details.

### Check your Cloud Init Status

You can use the following steps to confirm your Azure VMSS instance has its [cloud-init configuration](/infra/terraform/bootstrap/adobuilder.conf) dependencies installed:

1. Connect to your [Azure VMSS Instance using your Jumpbox](#connect-from-your-jumpbox-to-your-azure-vmss-instance)

2. Check your logs:

    ```bash
    tail /var/log/cloud-init-output.log
    ```

3. You can also check using `analyze dump`:

    ```bash
    sudo cloud-init analyze dump
    ```
      > This should return the status for the various stages of cloud init.
  
4. If you are finding stages which have failed, you may need to reboot to complete the installation:

    ```bash
    sudo cloud-init clean --reboot
    ```

    > You can also manually restart the VMSS instance in the Azure Portal.

    ![Restart Azure VMSS Instance](/docs/media/azure_vmss_restart_instance.png)

## Confirm your Azure Windows VMSS Instance Dependencies Installed

You can use the following steps to confirm your Azure Windows VMSS instance has its dependencies installed:

1. Connect to your [Azure Windows VMSS Instance using your Jumpbox](#connect-from-your-jumpbox-to-your-azure-vmss-instance)

  > Your credentials should be setup through your [bootstrap Terraform project](/infra/terraform/bootstrap/README.md#step-1-update-your-variables)

2. Within a shell, you can confirm the following dependencies are available:
  * .NET 4.8

    ```powershell
    Write-Host "Confirm .NET 4.8 is installed"
    (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 528040
    ```
    > See the [docs](https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed#minimum-version) for more details

  * SSDT

    ```powershell
    ls -l "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VisualStudio\v17.0\SSDT"
    ```

    > Alternatively you can use `test-path`, which help in cases where the installation path or versions are different:
    
    ```powershell
    test-path "C:\Program Files\Microsoft Visual Studio\2022\*\MSBuild\Microsoft\VisualStudio\*\SSDT"
    ```

  * msbuild

    ```powershell
    powershell "& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\msbuild.exe' -version"
    ```
  
3. If these dependencies aren't available you can also check the [build script](/infra/terraform/bootstrap/scripts/build-agent-dependencies.ps1) logs:

  ```powershell
  cat C:\WindowsAzure\Logs\build-agent-dependencies.log
  ```

  > You can also manually restart the VMSS instance in the Azure Portal.

  ![Restart Azure VMSS Instance](/docs/media/azure_windows_vmss_restart_instance.png)

## Manually Connect Your Azure DevOps VMSS Agent Pool to your Azure DevOps Pipeline

If you are facing issues with your Azure DevOps VMSS Agent Pool, you can also look to manually connect your [Azure DevOps Agent Pool to your Azure VMSS](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops) to investigate further.

You can look to authorize your Azure DevOps pipelines with your Azure DevOps agent pool using the following steps:

1. As a one-time step, you will need to ensure that you have a matching name for you Azure DevOps Agent Pool in your Azure DevOps pipeline before you run the pipeline, which will allow Azure DevOps to authorize your pipeline with your newly added Azure DevOps Agent Pool.

2. Once you have authorized your pipeline, you can update the pipeline to instead pull the Azure DevOps Agent pool name from a variable in your [Variable Group](/docs/update_your_variables.md/#3-environment-vg).
  * This approach is applicable to the [pipelines](/pipelines/README.md/) which can use the Variable Group to source the pool name.
  
3. The following example shows how you can enable your pipeline to authorize the pool.  This is for your [Broadsea Release Pipeline](/pipelines/README.md#broadsea-release-pipeline), but the same approach can be applied for your [Broadsea Build Pipeline](/pipelines/README.md#broadsea-build-pipeline), your [Vocabulary Release Pipeline](/pipelines/README.md#vocabulary-release-pipeline), and your [Environment Pipeline](/pipelines/README.md#environment-pipeline):

  ```yaml
  ...
  # pool: $(adoVMSSBuildAgentPoolName) # re-enable when VMSS is ready and you have granted access to the agent pool
  
  pool: 'some-ado-build-linux-vmss-agent-pool' # this should match the name of your azure devops VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```
  
  You should see a prompt similar to the following to authorize your pipeline:

  ![Authorize Broadsea Release Pipeline](/docs/media/broadsea_release_pipeline_achilles_etl_synthea_0.png)

  Once you have authorized the pipeline to use your Azure DevOps Agent Pool, you can update your [Broadsea Release Pipeline](/pipelines/README.md/#broadsea-release-pipeline) to use a variable from your [Variable Group](/docs/update_your_variables.md/#3-environment-vg) instead:

  ```yaml
  ...
  pool: $(adoVMSSBuildAgentPoolName) # re-enable when VMSS is ready and you have granted access to the agent pool
  
  # pool: 'some-ado-build-linux-vmss-agent-pool' # this should match the name of your azure devops VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```

  For your [Vocabulary Build Pipeline](/pipelines/README.md#vocabulary-build-pipeline), you can also use a similar approach to authorize the pipeline to use the Agent Pool VMSS.

  You can use the name of the Agent Pool
  ```yaml
  ...
  # pool: $(adoWindowsVMSSBuildAgentPoolName) # re-enable when Azure Windows VMSS is ready and you have granted access to the agent pool
  
  pool: 'some-ado-build-windows-vmss-agent-pool' # this should match the name of your azure devops Windows VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```

  Once you have authorized the agent pool for your pipeline, you can update the pipeline to use your variable group instead:
  
  ```yaml
  ...
  pool: $(adoWindowsVMSSBuildAgentPoolName) # re-enable when Azure Windows VMSS is ready and you have granted access to the agent pool
  
  # pool: 'some-ado-build-windows-vmss-agent-pool' # this should match the name of your azure devops Windows VMSS agent pool.  You can comment this out when you have authorized your Azure DevOps agent pool and then rely on the variable from your Variable Group.
  ...
  ```