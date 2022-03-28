# Troubleshooting Azure VMSS Agent Pool

Here's some troubleshooting notes for working with the [Azure VMSS Agent Pool](/infra/terraform/bootstrap/README.md/#step-5-setup-your-azure-devops-agent-pool).

## Table of contents

1. Connect from your [Jumpbox to your Azure VMSS Instance](#connect-from-your-jumpbox-to-your-azure-vmss-instance)
2. Confirm your [Azure VMSS instance dependencies installed](#confirm-your-azure-vmss-instance-dependencies-installed)
    * Check your [cloud-init status](#check-your-cloud-init-status) in the Azure VMSS Instance

## Connect from your Jumpbox to your Azure VMSS Instance

If you are using an Azure Windows VM, you will want to make sure you have an SSH client installed.  For example, you can use [OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?msclkid=cd10026da94511ec9ca88f3c45bc432f) with Windows.

1. Connect to your Jumpbox
  * For Linux you can use [SSH](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#ssh-into-your-vm)
  * For Windows you can use [RDP](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/connect-logon#:~:text=%20Connect%20to%20the%20virtual%20machine%20%201,address%20and%20Port%20number.%20In%20most...%20More%20?msclkid=07369b43a94711ecba4891e8a9b234bc)

2. In the Azure Portal, navigate to your Azure Virtual Network to check the connected devices.
  ![Get Azure VMSS Instance IP](/docs/media/connect_to_azure_vmss_instance_1.png)

3. In your Jumpbox, SSH using the IP address for the desired Azure VMSS Instance

    ```bash
    ssh azureuser@<azure.vmss.instance.ip>
    ```

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