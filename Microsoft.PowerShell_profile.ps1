#************************** General Variables for the Profile **************************#
# Sets the directory you open up into when you start Powershell
#Set-Location $env:userprofile\Documents\WindowsPowerShell\


# Console Settings
#Sets the title of the Window
$host.ui.RawUI.WindowTitle = "($env:userdomain\$env:username) Windows PowerShell"

#***************************Import Modules******************************#
import-module \\ccistb11sat\Modules\ihm-salesadtech-tools\ihm-salesadtech-tools.psm1

#************************** Profile Functions **************************#
function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  "$p> "
}

#Change to PSScripts Directory
function Go-PSScripts {
    Set-Location \\ccistb11sat\d$\PSScripts
}

#Change to DBA_Scripts Directory
function Go-DBA_Scripts {
    Set-Location \\ccistb11sat\d$\DBA_Scripts
}

#Get UTC time
Function Get-UTC {
  $TimeNow = Get-Date
  get-date $TimeNow -f "MMddyy HH:mm:ss"
  $TimeNow.ToUniversalTime().ToString("MMddyy HH:mm:ss")
}

#Get Logical drive information of a given computer`
Function Get-DriveInfo {
  Param ([string] $c)
  Get-WmiObject -Class Win32_logicaldisk -Computername $c
}

#Get the list of Viero serser objects and put then in a variable
Function Get-VieroDBServerList {
  Param()
  Get-dbaregisteredServer -SqlInstance ccistb11sat\sql01 -Group AllVieroServers\VieroServers | Select-Object -ExpandProperty servername
}

#**************************Aliases **************************#
Set-Alias im Import-Module
Set-Alias fu Find-ADUser
Set-Alias utc Get-UTC
Set-Alias DI Get-DriveInfo
Set-Alias gh Get-Help
Set-Alias gvv Get-VieroList
Set-Alias pss Go-PSScripts
Set-Alias dss Go-DBA_Scripts
