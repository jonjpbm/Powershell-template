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
    [Parameter(mandatory=$false)] [switch]$UniqLog
    ,[Parameter(mandatory=$false)] [string]$LogDirectory
    ,[Parameter(mandatory=$false)] [switch]$NoLog
)
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#Set Error Action to Silently Continue

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Any Global Declarations go here
$scriptName = [IO.Path]::GetFileNameWithoutExtension($($MyInvocation.MyCommand.Name))
if($PSBoundParameters.ContainsKey('LogDirectory')){
    Write-Verbose "Log Directory Passed: $LogDirectory"
    if ($False -eq $(test-path -PathType Container -path $LogDirectory)){
        Write-Verbose "Can't Find Passed Log Directory. Attempting To Create Log Directory"
        try {
            New-Item -ItemType Directory -Force -Path $LogDirectory
        }
        catch {
            $Exception = $error[0].Exception; $PositionMessage = $error[0].InvocationInfo.PositionMessage ;$ScriptStackTrace = $error[0].ScriptStackTrace
            Write-Error "$Exception - $PositionMessage - $ScriptStackTrace"
        }
    }
}Else{
    $LogDirectory = $PWD
}
#Create a unique log file
if($UniqLog){
    Write-Verbose "Unique Log switch passed"
    $ScriptLog= "$LogDirectory\$ScriptName`_$(Get-Date -format 'yyyyMMddHHmmss').log"
}else {
    $ScriptLog= "$LogDirectory\$ScriptName.log"
}
#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Script_Information {
    param ()
    Write-Verbose "Starting Function: $($MyInvocation.MyCommand)"
    Write-Verbose "$(Get-date)`nScript: $PSCommandPath`nScript Root: $($MyInvocation.PSScriptRoot)`nComputer Name: $($env:COMPUTERNAME)`nPowerShell Version: $($PSVersionTable.PSVersion)`nPresent Working Directory: $PWD"
    if($False -eq $NoLog){
        Write-Verbose "ScriptLog: $ScriptLog"
    }
}
#-----------------------------------------------------------[Main]------------------------------------------------------------
Function Main {
    Param ()
    Begin {
        Write-Verbose "Starting Function: $($MyInvocation.MyCommand)"
        $StopWatch = [System.diagnostics.stopwatch]::StartNew()
        Script_Information
    }
    Process {
        Try {
            #code here
        }
        Catch {
            Write-Verbose "Outside catch"
            $Exception = $error[0].Exception; $PositionMessage = $error[0].InvocationInfo.PositionMessage ;$ScriptStackTrace = $error[0].ScriptStackTrace
            Write-Error "$Exception - $PositionMessage - $ScriptStackTrace"
        }
    }
    End {
        If ($?) {
            $StopWatch.Stop()
            Write-Verbose "Complated Successfully. Elapsed Seconds $($StopWatch.Elapsed.TotalSeconds)"
        }
    }
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Call main
if($NoLog){
    Write-Verbose "No log file switch passed."
    Main *>&1
}Else{
    Main *>&1 | Tee-Object $ScriptLog
}