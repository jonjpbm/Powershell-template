<#
.SYNOPSIS
  <Overview of script>
  Run a command across of the Viero instances
.DESCRIPTION
  <Brief description of script>
  The intent of this script is to be able to run a desired command across all of the Viero Database servers
.PARAMETER Servers
  <Brief description of parameter input required. Repeat this attribute if required>
  Pass one or more Viero Servers
.PARAMETER ServerFile
  <Brief description of parameter input required. Repeat this attribute if required>
  Pass a file with a list of Viero Servers
.INPUTS
  <Inputs if any, otherwise state None>
  None
.OUTPUTS
  <Outputs if any, otherwise state None>
  None
.NOTES
  Version:        1.0
  Author:         Jon Duarte
  Creation Date:  Fri Mar 15 12:25:16 CDT 2019
  Purpose/Change: Initial script development
.EXAMPLE
  <Example explanation goes here>
  Run it with no parameters runs the script across all markets

  <Example goes here. Repeat this attribute for more than one example>
  .\Run-commandAllVieroParallel.ps1

  <Example explanation goes here>
  Passing one or more individual servers

  <Example goes here. Repeat this attribute for more than one example>
  .\Run-commandAllVieroParallel.ps1 -Servers vrsanatx01,vrnewyny01

  <Example explanation goes here>
  Passing a file with a list of viero servers in it

  <Example goes here. Repeat this attribute for more than one example>
  .\Run-commandAllVieroParallel.ps1 -ServerFile .list.txt
#>
#---------------------------------------------------------[Script Parameters]------------------------------------------------------
[CmdletBinding()]
Param (
  #Script parameters go here
  [Parameter(mandatory=$false)] [string[]]$Servers
  ,[Parameter(mandatory=$false)] [string]$ServerFile
  ,[Parameter(mandatory=$false)] [switch]$RunningLog
)
#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Import Modules & Snap-ins
Import-Module dbatools
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
Function psjob_cleanup{
  Param()
  Write-output "Attempting to clean up the jobs"
  Get-RSJob | Remove-RSJob
}
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
        #Do some checks

        #Initialize Variables
        ##Make sure either a file or Server(s) were passed but not both
        if  ( (-$false -eq $([string]::IsNullOrEmpty($ServerFile))) -and (-$false -eq $([string]::IsNullOrEmpty($Servers)))){ #Both parameters where passed.
            Write-Error "Both a file of Servers and Servers as parameters were passed. It should be only one or the other" -ErrorAction Stop
        }

        #Check for file passed and then put it in an array
        if( $False -eq $([string]::IsNullOrWhitespace($ServerFile)) ){
          #put contents of file into array
          $ListOfServers = Get-Content $ServerFile
        }

        if($Servers){ #If a single or multipe Servers were passed
          Write-Output "One or more Servers were passed at the command line"
          $ListOfServers = $Servers
        }elseif( $False -eq $([string]::IsNullOrWhitespace($ServerFile))){ #If a file with the list of Servers were passed
          Write-Output "A file with a list of Servers were passed"
          $ListOfServers = Get-Content $ServerFile
        }else{ #If no instance is specifed than assume all of the viero servers
          Write-Output "No specific Servers where passed. Using all of the Viero Database Servers"
          Try{
            $Query = @'
                SELECT
                    [ServerName]
                FROM [ESB].[dbo].[Server] WITH (NOLOCK)
                where IsActive = 1
                and  [ServerName] not in ('SGIIS08')
'@
            $instance = 'RPSFSQLAGL'
            $ListOfServers=Invoke-DbaQuery -SqlInstance $instance -Query $Query | Select-Object -ExpandProperty servername
          }Catch{
            Write-error $PSItem -ErrorAction Stop
          }
        }

        $ScriptBlock = {
          Param($S)
          #Here is where the code would need to be modified depending on the command you want run
          Try{
            Write-Output "$S`:Code Goes Here"
          }Catch{
            Write-Error $PSItem -ErrorAction Stop
          }
        }

        Try{
          $ListOfServers | Start-RSJob -ScriptBlock $ScriptBlock -ArgumentList $Server | Out-Null
        }Catch{
          Write-error $PSItem -ErrorAction Stop
        }

        Write-output "Waiting for jobs to finish"
        Get-rsjob | wait-rsjob -ShowProgress | Out-Null

        $FailedJobs=Get-RSjob | Where-Object {$_.State -eq 'Failed' -or ($_.HasErrors -eq $True)}

        if($FailedJobs){
            Write-Output "Failed Jobs:"
            $FailedJobs | Format-Table -AutoSize
            Write-Output "Failed Job Output:"
            $FailedJobs | Get-rsjob | Receive-rsjob
            Write-Output "Successfull Jobs:"
            $AllObjects= Get-rsjob | Where-Object {$_.State -eq 'Completed' -and ($_.HasErrors -eq $False)} | Receive-rsjob
        }Else{
            Write-output "No Failed jobs were detected"
            $AllObjects= Get-rsjob | Receive-rsjob
        }

        $AllObjects | Format-Table -AutoSize

        #Clean up Jobs
        psjob_cleanup
    }
    Catch {
      psjob_cleanup
      Write-Error $PSItem
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
#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Script Execution goes here
Main *>&1 | Tee-Object $ScriptLog
