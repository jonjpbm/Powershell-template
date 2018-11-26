#requires -version 4
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
  [Parameter(mandatory=$false)] [switch]$RunningLog
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'Stop'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Any Global Declarations go here
$ScriptRoot=$PSScriptRoot
$ScriptLogTime = Get-Date -format "yyyyMMddmmss"
$ScriptName = (Get-Item $PSCommandPath).Basename
$LogDirectory = "$ScriptRoot\Log"

If( not (Test-path $LogDirectory))
{
  New-Item -ItemType Directory -Force -Path $LogDirectory
}

if($RunningLog){
  $ScriptLog= "$ScriptRoot\$LogDirectory\$ScriptName`_$ScriptLogTime.log"
}else {
  $ScriptLog= "$ScriptRoot\$LogDirectory\$ScriptName.log"
}


#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function Main {
  Param ()

  Begin {
    Write-Output '<description of what is going on>...'

  }
  Process {
    Try {
      '<code goes here>'
    }
    Catch {
      Write-Error "Error: $($_.Exception)"
      Break
    }
  }
  End {
    If ($?) {
      write-output 'Completed Successfully.'
      write-output ' '
    }
  }
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here
Write-Output "ScriptRoot: $ScriptRoot"
Write-Output "ScriptName: $ScriptName"
Write-output "ScriptLog: $ScriptLog"
Get-Date
Main *>&1 | Tee-Object $ScriptLog
Get-Date
