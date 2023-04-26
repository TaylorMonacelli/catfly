Install-PackageProvider -Force -Name NuGet
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Start-Transcript -Append -Path c:\\user-data.log
Set-PSDebug -Trace 2

Set-ExecutionPolicy Bypass -Scope Process -Force

# assign public ip
# already installed: Install-Module -Name AWSPowerShell -Scope CurrentUser
Import-Module AWSPowerShell
$url = "http://169.254.169.254/latest/meta-data/instance-id"
$InstanceId = (Invoke-WebRequest -UseBasicParsing -Uri $url).content
$InstanceId
# Register-EC2Address -Region ${cdk.Aws.REGION} -InstanceId $InstanceId -AllocationId ${props.eip.attrAllocationId}

# enable ping
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

# install chocolatey package manager
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
$env:path += ";C:\\ProgramData\\chocolatey\\bin"
setx PATH $env:path -m
if(-Not(Test-Path($profile))) {
  New-Item -path $profile -type file -force
}
Add-Content $profile '$ChocolateyProfile = "$env:ChocolateyInstall\\helpers\\chocolateyProfile.psm1"'
Add-Content $profile 'if (Test-Path($ChocolateyProfile)) { Import-Module "$ChocolateyProfile" }'
. $profile
choco feature enable -n allowGlobalConfirmation

# set windows Administrator password
# fixme: need to create cdk for this.  As of now I've hardcoded ssm AdminPass
# in Systems Management Parameter Store
$pass=(Get-SSMParameter -Name AdminPass).Value
Write-Host "pass: $pass"
net.exe user Administrator "$pass"

# send text message to self indicating host is ready
$cell=(Get-SSMParameter -Name CellNumber).Value
Write-Host "cell: $cell"
Publish-SNSMessage -Message "${props.hostName} instance is ready" -PhoneNumber $cell

choco install 7zip
choco install awscli
choco install firefox
choco install git
choco install powershell-core
choco install googlechrome
choco install neovim
choco install python
choco install setdefaultbrowser
choco install vscode

SetDefaultBrowser HKLM "Google Chrome"

# nuget and psgallery
Set-ExecutionPolicy -Force bypass
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$nuget = Get-PackageProvider -Force -ErrorAction SilentlyContinue -Name NuGet
if(!$nuget) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force }
$psgallery = Get-PSRepository -ErrorAction SilentlyContinue -Name PSGallery
if(!$psgallery.Trusted) { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

# pester
Find-Package Pester
Install-Module Pester -Force -SkipPublisherCheck
Get-Module Pester -ListAvailable
Update-Module Pester -Force
Import-Module -MinimumVersion 5.1.1 -Force Pester
Install-Module -Verbose -Name 7Zip4Powershell

# fixme: todo: pin chrome icon, powershell icon to taskbar
