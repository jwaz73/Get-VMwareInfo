<#
.NOTES
===================================================================================================
Author                      : James Wood
Author email                : woodj@vmware.com
Version                     : 1.0
===================================================================================================
Tested Against Environment:
vCenter Server              : 6.5U1e
PowerCLI Version            : PowerCLI 6.5.1
PowerShell Version          : 5.0, 5.1
===================================================================================================
Changelog:
02/01/2018 ver 1.0 Initial Version
===================================================================================================
Copyright (c) 2018 James Wood

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
===================================================================================================
Acknowledgements:
PSLogging module by Luca Sturlese (http://9to5it.com)

===================================================================================================

.SYNOPSIS
  Creates an HTML report of the basic VMware infrastructure configuration and licensing.

.DESCRIPTION
  Creates an HTML report of the basic VMware infrastructure configuration and licensing.

.PARAMETER <none>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS Server
  Mandatory. The vCenter Server or ESXi Host the script will connect to, in the format of IP address or FQDN.

.INPUTS Credentials
  Mandatory. The user account credentials used to connect to the vCenter Server of ESXi Host.

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\Get-VMwareInfo.log

.OUTPUTS HTML Report
  The report created by the script.

.EXAMPLE
  Run this script from the PowerShell console.
  
  ./Get-VMwareInfo.ps1
      or
  <path to script>/Get-VMwareInfo.ps1
#>

#[Script Parameters]===============================================================================

Param (
  #Script parameters go here
)

#[Initialization]==================================================================================

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#[Declarations]====================================================================================

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = 'C:\Windows\Temp'
$sLogName = 'Get-VMwareInfo.log'
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#[Functions]=======================================================================================

Function Connect-VMwareServer {
  Param ([Parameter(Mandatory=$true)][string]$VMServer)

  Begin {
    Write-LogInfo -LogPath $sLogFile -Message "Connecting to VMware environment [$VMServer]..."
  }

  Process {
    Try {
      $oCred = Get-Credential -Message 'Enter credentials to connect to vSphere Server or Host'
      Connect-VIServer -Server $VMServer -Credential $oCred
    }

    Catch {
      Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
      Break
    }
  }

  End {
    If ($?) {
      Write-LogInfo -LogPath $sLogFile -Message 'Completed Successfully.'
      Write-LogInfo -LogPath $sLogFile -Message ' '
    }
  }
}

<#

Function <FunctionName> {
  Param ()

  Begin {
    Write-LogInfo -LogPath $sLogFile -Message '<description of what is going on>...'
  }

  Process {
    Try {
      <code goes here>
    }

    Catch {
      Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
      Break
    }
  }

  End {
    If ($?) {
      Write-LogInfo -LogPath $sLogFile -Message 'Completed Successfully.'
      Write-LogInfo -LogPath $sLogFile -Message ' '
    }
  }
}

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
$Server = Read-Host 'Specify the vCenter Server or ESXi Host to connect to (IP or FQDN)?'
Connect-VMwareServer -VMServer $Server
#Script Execution goes here
Stop-Log -LogPath $sLogFile