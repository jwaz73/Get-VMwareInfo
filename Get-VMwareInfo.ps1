<#
.NOTES
===================================================================================================
Author                      : James Wood
Author email                : woodj@vmware.com
Version                     : Beta v0.2
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
Multiple functions inspired by Alan Renouf (http://virtu-al.net)
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

.CHANGELOG
  02-05-2015  Completed HTML report and information gathering for licensing and ESXi hosts
  01-15-2018  Development begins

.ToDo
  Check for dependencies
    PSLogging
    VMware.PowerCLI -> Done!
  Check configuration issues
    VM snapshots
    Virtual CD-Rom devices connected
    VMware tools not up to date
  Capacity Summary
    Number of hosts
    Number of CPU's
    Number of VMs
    Powered-off VMs
    Estimate of VM 'slots' available
  Detailed Information
    Cluster Details
      HA Enabled
      Proactive HP Enabled
      DRS Enabled
      DRS Automation Level
      DPM Enabled
      DPM Threshold

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
$sScriptVersion = 'Beta v0.2'

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
      $oCred = Get-Credential -Message 'Enter credentials to connect to vCenter Server.'
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
    <div class="header"></div>
    <div class="subtitle">VMware Information Report $($sScriptVersion) generated on $(Get-Date)</div>
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

Function Test-NuGet {
  Begin {
    Write-LogInfo -LogPath $sLogFile -Message 'Checking for NuGet Package Provider...'
  }

  Process {
    Try {
      $pkg = Get-PackageProvider -ListAvailable | Where-Object {$_.Name -eq "NuGet"}
      if ($pkg) {
        Write-LogInfo -LogPath $sLogFile -Message 'NuGet is already installed.'
      }

      else {
        Write-LogInfo -LogPath $sLogFile -Message 'NuGet not found.  Installing...'
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force
        Write-LogInfo -LogPath $sLogFile -Message 'NuGet Installed Successfully.'
      }
    }

    Catch {
      Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
      Break
    }
  }

  End {
    If ($?) {
      Write-LogInfo -LogPath $sLogFile -Message 'NuGet Validated.'
      Write-LogInfo -LogPath $sLogFile -Message ' '
    }
  }
}

Function Test-PowerCLI {
  Begin {
    Write-LogInfo -LogPath $sLogFile -Message 'Checking for PowerCLI modules...'
  }

  Process {
    Try {
      $pcli = Get-Module -ListAvailable | Where-Object {$_.Name -eq "VMware.PowerCLI"}
      if ($pcli) {
        Write-LogInfo -LogPath $sLogFile -Message 'PowerCLI is already installed.'
      }

      else {
        Write-LogInfo -LogPath $sLogFile -Message 'PowerCLI not found.  Installing...'
        $psGal = Get-PSRepository | Where-Object {$_.Name -eq "PSGallery"}
        if ($psGal.InstallationPolicy -eq "Trusted") {
          Write-LogInfo -LogPath $sLogFile -Message 'PSGallery is trusted.'
        }

        else {
          Write-LogInfo -LogPath $sLogFile -Message 'Setting PSGallery as trusted gallery.'
          Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Confirm $false
        Write-LogInfo -LogPath $sLogFile -Message 'PowerCLI modules successfully installed.'
      }
    }

    Catch {
      Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
      Break
    }
  }

  End {
    If ($?) {
      Write-LogInfo -LogPath $sLogFile -Message 'PowerCLI Validated.'
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

#[Script Execution]================================================================================
$Date = Get-Date
#Start Logging
Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#Test prerequisites
Test-NuGet
Test-PowerCLI

#Connect to vCenter or ESXi host
Connect-VMwareServer -VMServer $sVIServer



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



#Collect ESXi Host Details
$HostInfo = @()
$VMHosts = Get-VMHost
$lam = Get-View LicenseAssignmentManager
ForEach ($VMHost in $VMHosts){
  $HostDetails = "" | Select-Object Cluster,Name,Manufacturer,Model,Memory,Sockets,Cores,"CPU Model","CPU Frequency","ESXi Version","License Edition"
  $HostDetails.Cluster = $VMHost.Parent.Name
  $HostDetails.Name = $VMHost.Name
  $HostDetails.Manufacturer = $VMHost.ExtensionData.Summary.Hardware.Vendor
  $HostDetails.Model = $VMHost.ExtensionData.Summary.Hardware.Model
  $HostDetails.Memory = [string]([math]::Round(($VMHost.ExtensionData.Summary.Hardware.MemorySize)/1gb,2)) + " GB"
  $HostDetails.Sockets = $VMHost.ExtensionData.Hardware.CpuInfo.NumCpuPackages
  $HostDetails.Cores = $VMHost.ExtensionData.Hardware.CpuInfo.NumCpuCores
  $HostDetails."CPU Model" = $VMHost.ExtensionData.Summary.Hardware.CPUModel
  $HostDetails."CPU Frequency" = [string]($VMHost.ExtensionData.Summary.Hardware.CpuMhz/1000) + " GHz"
  $HostDetails."ESXi Version" = $VMHost.ExtensionData.Config.Product.FullName
  $HostDetails."License Edition" = ($lam.QueryAssignedLicenses($VMHost.ExtensionData.MoRef.Value)).AssignedLicense.Name
  $HostInfo += $HostDetails
}



#Initialize HTML Report
$MyReport = Get-CustomHTML -Header "VMware Information Report"
$MyReport += Get-CustomHeader0 $oVIServer.Name

#Add Summary Details

#Add License Details
$MyReport += Get-CustomHeader "VMware Licensing Details"
$MyReport += Get-HTMLTable $LicInfo
$MyReport += Get-CustomHeaderClose

#Add Host Details
$MyReport += Get-CustomHeader "vSphere Host Details"
$MyReport += Get-HTMLTable $HostInfo
$MyReport += Get-CustomHeaderClose

#Add VM Details

#Close HTML Report
$MyReport += Get-CustomHTMLClose

#Save the report and open in default browser
$FileName = ".\" + $sVIServer + "VMwareInfo_" + $Date.Month + "-" + $Date.Day + "-" + $Date.Year + ".htm"
$MyReport | Out-File -Encoding ascii -FilePath $FileName
Invoke-Item $FileName

#Stop Logging
Stop-Log -LogPath $sLogFile