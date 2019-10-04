<#
.SYNOPSIS
  <Overview of script>
.DESCRIPTION
  <Brief description of script>
.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None>
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
.EXAMPLE
  <Example explanation goes here>

  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

[CmdletBinding()]
Param (
  #Script parameters go here
  [Parameter(Mandatory = $false)] [String] $Path
  ,[Parameter(mandatory=$false)] [switch]$RunningLog
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = 'Stop'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Any Global Declarations go here
$computerName = $env:COMPUTERNAME
$ScriptRoot=$PSScriptRoot
$ScriptLogTime = Get-Date -format "yyyyMMddmmss"
$ScriptName = (Get-Item $PSCommandPath).Basename
$LogDirectory = $ScriptRoot
$PSVersionReturned=$PSVersionTable.PSVersion
$Date = Get-Date

if($RunningLog){
  Write-Verbose "Running Log switch passed"
  $ScriptLog= "$LogDirectory\$ScriptName`_$ScriptLogTime.log"
}else {
  $ScriptLog= "$LogDirectory\$ScriptName.log"
}


#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Script_Information {
    param (
  )
    Write-Output "$($MyInvocation.MyCommand)"
    $Date.DateTime
    Write-Output "Computer Name: $computerName"
    Write-Output "PowerShell Version $PSVersionReturned"
    Write-Output "ScriptRoot: $ScriptRoot"
    Write-Output "ScriptName: $ScriptName"
    Write-output "ScriptLog: $ScriptLog"

}

function Test_FileLock {
  param ([parameter(Mandatory=$true)][string]$Path)
  Write-Output "$($MyInvocation.MyCommand)"
  $oFile = New-Object System.IO.FileInfo $Path
  if ((Test-Path -Path $Path) -eq $false){
    Write-Verbose "Default log file does not exist"
    Return 0
  }else{
    try{
      $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
      if ($oStream){
        $oStream.Close()
      }
      Return 0
    }catch{
      # file is locked by a process.
      return 1
    }
  }
}
#-----------------------------------------------------------[End Of Functions]------------------------------------------------------------

#-----------------------------------------------------------[Main]------------------------------------------------------------
Function Main {
  Param ()
  Begin {
    Write-Output "$($MyInvocation.MyCommand)"
    Write-Output '<description of what is going on>...'
    $StopWatch = [System.diagnostics.stopwatch]::StartNew()
    Script_Information
  }
  Process {
    Try {
      Write-Output "Code Goes Here"
    }
    Catch {
        Write-Error $PSItem -ErrorAction Stop
    }
  }
  End {
    If ($?) {
      write-output 'Completed Successfully.'
      $StopWatch.Stop()
      Write-Output "Elapsed Seconds $($StopWatch.Elapsed.TotalSeconds)"
    }
  }
}
#-----------------------------------------------------------[End Of Main]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Call main
$IsFileLocked=Test_Filelock($Scriptlog)
Write-verbose "IsFileLocked: $IsFileLocked"
if($IsFileLocked -eq 1){
  Write-Verbose "Default log file in use"
  $ScriptLog= "$LogDirectory\$ScriptName`_$ScriptLogTime.log"
}
Main *>&1 | Tee-Object $ScriptLog
#-----------------------------------------------------------[End Of Execution]------------------------------------------------------------
