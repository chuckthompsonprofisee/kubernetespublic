#configure powershell exec
Set-ExecutionPolicy unrestricted -Force

#set timezone
& "$env:windir\system32\tzutil.exe" /s "Eastern Standard Time"
#& "$env:windir\system32\tzutil.exe" /s "Central Standard Time"

#windows update
#Install-Module PSWindowsUpdate  -Force
#Get-WindowsUpdate
#Install-WindowsUpdate

#install choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#install terminal
choco install microsoft-windows-terminal -y

#install kubectl
choco install kubernetes-cli -y

#install helm
choco install kubernetes-helm -y

#install azure cli
choco install azure-cli -y

#install lens
choco install lens -y

#install notepad++
choco install notepadplusplus -y

#install ssms
choco install sql-server-management-studio -y

#install vs code
choco install vscode -y

#install visual studio
choco install visualstudio2019enterprise -y

#install azure storage explorer
choco install microsoftazurestorageexplorer -y

#install docker desktop
#choco install docker-desktop -y
