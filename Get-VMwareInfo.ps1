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
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
  <html><head><title>$($Header)</title>
      <META http-equiv=Content-Type content='text/html; charset=windows-1252'>
      <style type="text/css">
      
      TABLE 		{
        TABLE-LAYOUT: fixed; 
        FONT-SIZE: 100%; 
        WIDTH: 100%
    }
    *           {
        margin:0
    }
    
    .dspcont 	{
    
        BORDER-RIGHT: #bbbbbb 1px solid;
        BORDER-TOP: #bbbbbb 1px solid;
        PADDING-LEFT: 0px;
        FONT-SIZE: 8pt;
        MARGIN-BOTTOM: -1px;
        PADDING-BOTTOM: 5px;
        MARGIN-LEFT: 0px;
        BORDER-LEFT: #bbbbbb 1px solid;
        WIDTH: 95%;
        COLOR: #717074;
        MARGIN-RIGHT: 0px;
        PADDING-TOP: 4px;
        BORDER-BOTTOM: #bbbbbb 1px solid;
        FONT-FAMILY: Tahoma;
        POSITION: relative;
        BACKGROUND-COLOR: #f9f9f9
    }
    
    .filler 	{
        BORDER-RIGHT: medium none; 
        BORDER-TOP: medium none; 
        DISPLAY: block; 
        BACKGROUND: none transparent scroll repeat 0% 0%; 
        MARGIN-BOTTOM: -1px; 
        FONT: 100%/8px Tahoma; 
        MARGIN-LEFT: 43px; 
        BORDER-LEFT: medium none; 
        COLOR: #ffffff; 
        MARGIN-RIGHT: 0px; 
        PADDING-TOP: 4px; 
        BORDER-BOTTOM: medium none; 
        POSITION: relative
    }
    
    .pageholder	{
        margin: 0px auto;
    }
    
    .dsp
    {
        BORDER-RIGHT: #bbbbbb 1px solid;
        PADDING-RIGHT: 0px;
        BORDER-TOP: #bbbbbb 1px solid;
        DISPLAY: block;
        PADDING-LEFT: 0px;
        FONT-WEIGHT: bold;
        FONT-SIZE: 12pt;
        MARGIN-BOTTOM: -1px;
        MARGIN-LEFT: 0px;
        BORDER-LEFT: #bbbbbb 1px solid;
        COLOR: #FFFFFF;
        MARGIN-RIGHT: 0px;
        PADDING-TOP: 4px;
        BORDER-BOTTOM: #bbbbbb 1px solid;
        FONT-FAMILY: Tahoma;
        POSITION: relative;
        HEIGHT: 2.25em;
        WIDTH: 95%;
        TEXT-INDENT: 10px;
    }
    
    .dsphead0	{
        BACKGROUND-COLOR: #387c2c;
    }
    
    .dsphead1	{
        
        BACKGROUND-COLOR: #003d79;
    }
    
    .dspcomments 	{
        BACKGROUND-COLOR:#FFFFE1;
        COLOR: #000000;
        FONT-STYLE: ITALIC;
        FONT-WEIGHT: normal;
        FONT-SIZE: 8pt;
    }
    
    td 				{
        VERTICAL-ALIGN: TOP; 
        FONT-FAMILY: Tahoma
    }
    
    th 				{
        VERTICAL-ALIGN: TOP; 
        COLOR: #003d70; 
        TEXT-ALIGN: left
    }
    
    BODY 			{
        margin-left: 4pt;
        margin-right: 4pt;
        margin-top: 6pt;
    } 
    .MainTitle		{
        font-family:Arial, Helvetica, sans-serif;
        font-size:20pt;
        font-weight:bolder;
    }
    .SubTitle		{
        font-family:Arial, Helvetica, sans-serif;
        font-size:10pt;
        font-weight:bold;
    }
    .Created		{
        font-family:Arial, Helvetica, sans-serif;
        font-size:10px;
        font-weight:normal;
        margin-top: 20px;
        margin-bottom:5px;
    }
    .links			{	font:Arial, Helvetica, sans-serif;
        font-size:10px;
        FONT-STYLE: ITALIC;
    }

      </style>
    </head>
    <body>
  <div class="MainTitle">$($Header)</div>
        <hr size="8" color="#387c2c" width="95%">
        <div class="SubTitle">VMware Info v$($sScriptVersion) generated on $($ENV:Computername)</div>
        <br/>
        <div class="Created">Report created on $(Get-Date)</div>
"@
Return $Report
  }

Function Get-CustomHTMLClose{
$Report = @"
  </div>
  </body>
  </html>
"@
Return $Report
}

Function Get-CustomHeader0 ($Title){
  $Report = @"
      <div class="pageholder">		
      <h1 class="dsp dsphead0">$($Title)</h1>
      <div class="filler"></div>
"@
Return $Report
}

Function Get-CustomHeader0Close{
$Report = @"
</div>
"@
Return $Report
}

Function Get-CustomHeader ($Title, $cmnt){
$Report = @"
  <h2 class="dsp dsphead1">$($Title)</h2>
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
  <div class="filler"></div>
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
    <th width='50%'><b>$($Heading)</b></font></th>
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


#Close HTML Report
$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

#Save the report and open in default browser
$FileName = ".\" + $sVIServer + "VMwareInfo_" + $Date.Month + "-" + $Date.Day + "-" + $Date.Year + ".htm"
$MyReport | Out-File -Encoding ascii -FilePath $FileName
Invoke-Item $FileName

#Stop Logging
Stop-Log -LogPath $sLogFile