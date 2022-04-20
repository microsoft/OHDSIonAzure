# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install MS build
choco install visualstudio2022buildtools -y
# check for msbuild
powershell "& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\msbuild.exe' -version"

# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?view=vs-2022#data-storage-and-processing
# Include SSDT
choco install visualstudio2022community -y --package-parameters "--add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.Data"
# check for SSDT
Get-ChildItem "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VisualStudio\v17.0\SSDT"

# Include .NET 4.8
choco install netfx-4.8-devpack -y

# confirm the version is at least 4.8
# https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed#minimum-version

$dotnet48ReleaseNumber = 528040
$dotnet48Installed = $((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge $dotnet48ReleaseNumber)
Write-Output "Checking if at least .NET 4.8 is installed: $dotnet48Installed"

if ($dotnet48Installed -eq $false)
{
    Restart-Computer -Force
}
else
{
    Write-Output "Installation steps should be complete.  You can check the logs: cat C:\WindowsAzure\Logs\build-agent-dependencies.log"
}

