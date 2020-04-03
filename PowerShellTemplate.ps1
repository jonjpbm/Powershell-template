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
    ,[Parameter(mandatory=$false)] [string]$LogDirectory
    ,[Parameter(mandatory=$false)] [switch]$NoLog
)
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#Set Error Action to Silently Continue

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Any Global Declarations go here
$computerName = $env:COMPUTERNAME
$script = $MyInvocation.MyCommand.Name
$scriptName = [IO.Path]::GetFileNameWithoutExtension($Script)
$ScriptLogTime = Get-Date -format "yyyyMMddHHmmss"
$PSVersionReturned=$PSVersionTable.PSVersion
$Date = Get-Date
if ($NoLog){
    #Do not create a log file
    Write-Verbose "No log file switch passed"
    Write-Verbose "Getting PWD"
    $PresentWorkingDirectory = Get-Location
}Else{
    Write-Verbose "Getting PWD"
    $PresentWorkingDirectory = Get-Location
    #Did you pass your own directory for the log?
    if($PSBoundParameters.ContainsKey('LogDirectory')){
        Write-Verbose "Log Directory Passed"
        Write-Verbose $LogDirectory
    }Else{
        $LogDirectory = $PresentWorkingDirectory
    }
    #Create a unique log file
    if($RunningLog){
        Write-Verbose "Running Log switch passed"
        $ScriptLog= "$LogDirectory\$ScriptName`_$ScriptLogTime.log"
    }else {
        $ScriptLog= "$LogDirectory\$ScriptName.log"
    }
}
#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Script_Information {
    param ()
    Write-Verbose "Function: $($MyInvocation.MyCommand)"
    Write-Verbose $Date.DateTime
    Write-Verbose "Computer Name: $computerName"
    Write-Verbose "PowerShell Version $PSVersionReturned"
    Write-Verbose "ScriptName: $ScriptName"
    Write-Verbose "Present Working Directory: $PresentWorkingDirectory"
    if($False -eq $NoLog){
        Write-Verbose "ScriptLog: $ScriptLog"
    }
}
#-----------------------------------------------------------[Main]------------------------------------------------------------
Function Main {
    Param ()
    Begin {
        Write-Verbose "Function: $($MyInvocation.MyCommand)"
        Write-Verbose 'Starting'
        $StopWatch = [System.diagnostics.stopwatch]::StartNew()
        Script_Information
    }
    Process {
        Try {
            #code goes here
        }
        Catch {
            Write-Error $PSItem
        }
    }
    End {
        If ($?) {
            Write-Verbose 'Completed Successfully.'
            $StopWatch.Stop()
            Write-Verbose "Elapsed Seconds $($StopWatch.Elapsed.TotalSeconds)"
        }
    }
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Call main
if($NoLog){
    Main *>&1
}Else{
    if ($False -eq $(test-path -PathType Container -path $LogDirectory)){
        Write-Verbose "Attempting to create log directory"
        try {
            New-Item -ItemType Directory -Force -Path $LogDirectory
        }
        catch {
            Write-Error $PSItem -ErrorAction Stop
        }
    }
    Main *>&1 | Tee-Object $ScriptLog
}
