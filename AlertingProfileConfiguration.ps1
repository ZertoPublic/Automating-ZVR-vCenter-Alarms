#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
   This script will create custom notification emails for ZVR alarms within a vCenter environment. 
   
.DESCRIPTION
   Leveraging Alerting Profile CSVs this script will configure the com.zerto.event alarms within the Alerting Profile with a custom email notification to replace the default vCenter email 
   notification for these alarms. Once complete the script will output a CSV file containing the details of the ZVR alarms that have been modified in vCenter, the action taken when the alarm
   is triggered, and who will be receiving the notification. This output file is also utilized in the Remove-AlertingProfileConfiguration script if the user decides to remove the custom notifcations.
.EXAMPLE
   .\AlertingProfileConfiguration.ps1
.VERSION 
   This script has been tested on ZVR 5.0 and higher.   
.LEGAL
   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
#>
#------------------------------------------------------------------------------#
# Declare variables
#------------------------------------------------------------------------------#
#Examples of variables:
$vCenter = "EntervCenterIP"
$username = "EntervCenterUserName"
$password = "EntervCenterPassword"
$ZVMIP = "EnterZVMIP"
$ZVMPort = "9669"
$AlertProfileCSV = "EnterImportCSVLocation"
$ZvmUrl = "https://" + $ZVMIP + ":" + $ZVMPort
$MonitoringURL = $ZvmUrl + "/zvm#/main/monitoring/alerts"
$report = @()
$ConfiguredAlertExport = "Enter Reports CSV export location"
$UrlIDDetails = "/Help/index.html#context/ErrorsGuide/"
$LogDataDir = "EnterLogDirectoryLocation"

########################################################################################################################
# Nothing to configure below this line - Starting the main function of the script
########################################################################################################################

Write-Host -ForegroundColor Yellow "Informational line denoting start of script GOES HERE." 
Write-Host -ForegroundColor Yellow "   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
"

#------------------------------------------------------------------------------#
#Setting log directory and starting transcript logging
#------------------------------------------------------------------------------#
$CurrentMonth = get-date -Format MM.yy
$CurrentTime = get-date -format hh.mm.ss
$CurrentLogDataDir = $LogDataDir + $CurrentMonth
$CurrentLogDataFile = $LogDataDir + $CurrentMonth + "\AlertingProfileCreationLog-" + $CurrentTime + ".txt"
#Testing path exists, if not creating it
$ExportDataDirTestPath = test-path $CurrentLogDataDir
If($ExportDataDirTestPath -eq $False)
{
New-item -ItemType Directory -Force -Path $CurrentLogDataDir
}
start-transcript -path $CurrentLogDataFile -NoClobber

#------------------------------------------------------------------------------#
# Importing the CSV of Alert Profile to configure com.zerto.event Alerts
#------------------------------------------------------------------------------#
$AlertProfileCSVImport = Import-Csv $AlertProfileCSV

#------------------------------------------------------------------------------#
# Importing PowerCLI snap-in required
#------------------------------------------------------------------------------#
function LoadSnapin{
  param($PSSnapinName)
  if (!(Get-PSSnapin | where {$_.Name   -eq $PSSnapinName})){
    Add-pssnapin -name $PSSnapinName
  }
}
# Loading snapins and modules
LoadSnapin -PSSnapinName   "VMware.VimAutomation.Core"

#------------------------------------------------------------------------------#
# Connect to vCenter Server
#------------------------------------------------------------------------------#
Connect-VIServer -Server $vCenter -Protocol https -User $username -Password $password -WarningAction SilentlyContinue | Out-Null

#------------------------------------------------------------------------------#
# Starting Install Process for each Alert specified in the CSV
#------------------------------------------------------------------------------#
ForEach($Alert in $AlertProfileCSVImport) {
#Setting Variables from import CSV
$AlertName = $Alert.Alert
$EmailTo = $Alert.EmailTo
$EmailCC = $Alert.EmailCC
$EmailDescription = $Alert.EmailDescription
$AlertSeverity = $Alert.Severity
$AlertID = $Alert.AlertID
$AlertID = $AlertID -split ","
$AlertLinks = @()

#Gathering each alert ID if multiple AlertIDs specified in Alert Profile CSV
Foreach ($ID in $AlertID)
{
 $AlertLinks += New-Object psobject -Property @{AlertLink=$ZvmUrl+$UrlIDDetails+$ID} 
}

$AlertLinks = $AlertLinks | select-object -ExpandProperty AlertLink

# Delete Alarm Action to remove any prior configuration
Get-AlarmDefinition -Name $AlertName | Get-AlarmAction | Remove-AlarmAction -Confirm:$false

#Delete previous $EmailBody content
$EmailBody = $null

#Building email body to be configured for New-AlarmAction
$EmailBody += @"

This message is being sent due to the following Zerto alarm within your vCenter being triggered:
{alarmName}
Severity: $AlertSeverity 

For further information about this alarm please review the following description:
{eventDescription}

Additional details in regards to possible causes and steps for resolution can be found at: `

"@
$EmailBody += $AlertLinks.Trim() | foreach {$_ + "`n"}
$EmailBody += "`nYou can also review the information further within the ZVM UI. Navigate to the monitoring tab and then search for the following alert ID:`n"
$EmailBody += $MonitoringUrl
$EmailBody += "`n`nAlertID:`n" 
$EmailBody += $AlertID | foreach {$_ + "`n"}

#Setting Notification emails 
Get-AlarmDefinition -Name $AlertName | New-AlarmAction -Email -To $EmailTo -Cc $EmailCC -Body $EmailBody -Subject $EmailDescription

#Repeat alarm notification every 5 minutes
Get-AlarmDefinition -Name $AlertName | Set-AlarmDefinition -ActionRepeatMinutes 5

# Create Trigger for each Alarm in the import CSV
Get-AlarmDefinition -Name $AlertName | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"
Get-AlarmDefinition -Name $AlertName | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "yellow" -EndStatus "green" 
Get-AlarmDefinition -Name $AlertName | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "red" -EndStatus "yellow"


#Wait 30 seconds between alert configuration task
write-host "Waiting 30 seconds before configuring the next alarm definition"
sleep 30

#End of per Alert operations below
}
#End of per Alert operations above

#------------------------------------------------------------------------------#
# Building export CSV containing the details of vCenter alarm configuration 
#------------------------------------------------------------------------------#
ForEach ($ConfiguredAlert in $AlertProfileCSVImport) {
#Setting Variables from ImportCSV
$ConfiguredAlert = $ConfiguredAlert.Alert

#Gathering Name, Description, ActionType, To, Cc from alerts successfully configured to export to CSV
$alarmdef = Get-AlarmDefinition $ConfiguredAlert | select-object Name, Description
$alarmactions = Get-AlarmDefinition $ConfiguredAlert | Get-AlarmAction | select-object ActionType, {$_.To}, {$_.Cc}

#Building Reporting objects 
$report += New-Object psobject -Property @{AlarmName=$alarmdef.Name;AlarmDescription=$alarmdef.Description;AlarmAction=$alarmactions.ActionType;EmailTo=$alarmactions.{$_.To};EmailCc=$alarmactions.{$_.Cc}}

#End of per Alert operations below
}
#End of per Alert operations above 

#------------------------------------------------------------------------------#
#Output report to CSV file
#------------------------------------------------------------------------------#
$report | export-csv $ConfiguredAlertExport -NoTypeInformation
Write-Host -ForegroundColor Yellow "An output report of the alarms configured has been written to: $ConfiguredAlertExport"

#------------------------------------------------------------------------------#
#Disconnect from vCenter
#------------------------------------------------------------------------------#
Disconnect-VIServer -Server $vCenter -Force:$true -Confirm:$false

#------------------------------------------------------------------------------#
# Stopping Logging
#------------------------------------------------------------------------------#
Stop-Transcript