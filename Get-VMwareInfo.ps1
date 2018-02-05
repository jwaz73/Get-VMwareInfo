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
  [Parameter(Mandatory=$true)] [string] $sVIServer 
)

#[Initialization]==================================================================================

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#[Declarations]====================================================================================

#Script Version
$sScriptVersion = 'Beta 0.1'

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
      $oCred = Get-Credential -Message 'Enter credentials to connect to vCenter Server or vSphere Host'
      $script:oVIServer = Connect-VIServer -Server $VMServer -Credential $oCred
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

Function Get-CustomHTML{
  Param(
    [Parameter(Mandatory=$true)] [string] $Header
  )
$Report = @"
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>$($Header)</title>
    <link rel="stylesheet" type="text/css" href="Includes/report_style.css">
  </head>
  <body>
    <div class="header">
      <img class="logo" src="Includes/vmw_logo_white.png" alt="">
      <div class="maintitle">$($Header)</div>
    </div>
    <div class="subtitle">VMware Information Report v$($sScriptVersion) generated on $(Get-Date)</div>
"@
Return $Report
}

Function Get-CustomHTMLClose{
$Report = @"
  </body>
</html>
"@
Return $Report
}

Function Get-CustomHeader0 ($Title){
  $Report = @"
    <div class="dsp dsphead0">$($Title)</div>
"@
Return $Report
}

Function Get-CustomHeader ($Title, $cmnt){
$Report = @"
    <div class="dsp dsphead1">$($Title)</div>
"@
If ($Comments) {
  $Report += @"
  <div class="dsp dspcomments">$($cmnt)</div>
"@
}
$Report += @"
  <div class="dspcont">
"@
Return $Report
}
  
Function Get-CustomHeaderClose{
$Report = @"
  </div>
"@
Return $Report
}

Function Get-HTMLTable {
	param([array]$Content)
	$HTMLTable = $Content | ConvertTo-Html
	$HTMLTable = $HTMLTable -replace '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">', ""
	$HTMLTable = $HTMLTable -replace '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"  "http://www.w3.org/TR/html4/strict.dtd">', ""
	$HTMLTable = $HTMLTable -replace '<html xmlns="http://www.w3.org/1999/xhtml">', ""
	$HTMLTable = $HTMLTable -replace '<html>', ""
	$HTMLTable = $HTMLTable -replace '<head>', ""
	$HTMLTable = $HTMLTable -replace '<title>HTML TABLE</title>', ""
	$HTMLTable = $HTMLTable -replace '</head><body>', ""
	$HTMLTable = $HTMLTable -replace '</body></html>', ""
	$HTMLTable = $HTMLTable -replace '&lt;', "<"
	$HTMLTable = $HTMLTable -replace '&gt;', ">"
	Return $HTMLTable
}

Function Get-HTMLDetail ($Heading, $Detail){
$Report = @"
<TABLE>
  <tr>
    <th width='50%'>$($Heading)</th>
    <td width='50%'>$($Detail)</td>
  </tr>
</TABLE>
"@
Return $Report
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

#[Script Execution]================================================================================
$Date = Get-Date
#Start Logging
Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Connect to vCenter or ESXi host
Connect-VMwareServer -VMServer $sVIServer

#Initialize HTML Report
$MyReport = Get-CustomHTML -Header "VMware Information Report"
$MyReport += Get-CustomHeader0 $oVIServer.Name

#Collect License Details
$LicInfo = @()
$SvcInstance = Get-View ServiceInstance
$LicManager = Get-View $SvcInstance.Content.LicenseManager
ForEach ($License in ($LicManager | Select-Object -ExpandProperty Licenses | Where-Object {$_.Name -ne "Product Evaluation"})){
  $LicDetails = "" | Select-Object vCenter, Name, Used, Total, ExpirationDate, Information
  $LicDetails.vCenter = ([uri]$LicManager.Client.ServiceUrl).Host
  $LicDetails.Name = $License.Name
  $LicDetails.Used = $License.Used
  $LicDetails.Total = $License.Total
  $LicDetails.ExpirationDate = $License.Properties | Where-Object {$_.key -eq "expirationDate"} | Select-Object -ExpandProperty Value
  $LicDetails.Information = $License.Labels | Select-Object -ExpandProperty Value
  $LicInfo += $LicDetails
}

$MyReport += Get-CustomHeader "VMware Licensing Details"
$MyReport += Get-HTMLTable $LicInfo
$MyReport += Get-CustomHeaderClose

#Collect ESXi Host Details
$HostInfo = @()
$VMHosts = Get-VMHost
ForEach ($VMHost in $VMHosts){
  $HostDetails = "" | Select-Object Name,Manufacturer,Model,Memory,CPUSockets,CPUCores,CPUModel,CPUFrequency,ESXiVersion,LicenseEdition
  $HostDetails.Name = $VMHost.Name
  $HostDetails.Manufacturer = $VMHost.ExtensionData.Summary.Hardware.Vendor
  $HostDetails.Model = $VMHost.ExtensionData.Summary.Hardware.Model
  $HostDetails.Memory = $VMHost.ExtensionData.Summary.Hardware.MemorySize/1gb
  $HostDetails.CPUSockets = $VMHost.ExtensionData.Hardware.CpuInfo.NumCpuPackages
  $HostDetails.CPUCores = $VMHost.ExtensionData.Hardware.CpuInfo.NumCpuCores
  $HostDetails.CPUModel = $VMHost.ExtensionData.Summary.Hardware.CPUModel
  $HostDetails.CPUFrequency = $VMHost.ExtensionData.Summary.Hardware.CpuMhz/1000
  $HostDetails.ESXiVersion = $VMHost.ExtensionData.Config.Product.FullName
  $lam = Get-View LicenseAssignmentManager
  $HostDetails.LicenseEdition = ($lam.QueryAssignedLicenses($VMHost.ExtensionData.MoRef.Value)).AssignedLicense.Name
  $HostInfo += $HostDetails
}

$MyReport += Get-CustomHeader "vSphere Host Details"
$MyReport += Get-HTMLTable $HostInfo
$MyReport += Get-CustomHeaderClose

#Close HTML Report
$MyReport += Get-CustomHTMLClose

#Save the report and open in default browser
$FileName = ".\" + $sVIServer + "VMwareInfo_" + $Date.Month + "-" + $Date.Day + "-" + $Date.Year + ".htm"
$MyReport | Out-File -Encoding ascii -FilePath $FileName
Invoke-Item $FileName

#Stop Logging
Stop-Log -LogPath $sLogFile