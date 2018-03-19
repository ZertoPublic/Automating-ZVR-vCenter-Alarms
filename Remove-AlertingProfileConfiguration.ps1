#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
   This script removes the com.zerto.event alarms that were previously configured within vCenter by the AlertingProfile script. This script requires the CSV file that was created by the Alert
   profile script (reports.csv) to import that CSV and remove the specific Zerto alarm definitions that were configured. 
   
.DESCRIPTION
   Detailed explanation of script
.EXAMPLE
   Examples of script execution
.VERSION 
   This script has been tested on ZVR 5.0 and higher
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
$ConfiguredAlertExport = "enterImportAlertCSV"

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
# Importing the CSV of Alert Profile to configure com.zerto.event Alerts
#------------------------------------------------------------------------------#
$ConfiguredAlertCSVImport = Import-Csv $ConfiguredAlertExport

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

ForEach ($Alert in $ConfiguredAlertCSVImport ){
#Setting Variables from import CSV
$AlertName = $Alert.AlarmName

# Delete Trigger to remove any prior configuration;
Get-AlarmDefinition -Name $AlertName | Get-AlarmAction | Remove-AlarmAction -Confirm:$false
Get-AlarmDefinition -Name $AlertName | Get-AlarmAction | Remove-AlarmActionTrigger -Confirm:$false 
#End of per Alert operations below
}
#End of per Alert operations above

# Writing end of script 
#------------------------------------------------------------------------------#
Write-Host "Alarms successfully removed" 
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#Disconnect from vCenter
#------------------------------------------------------------------------------#
Disconnect-VIServer -Server $vCenter -Force:$true -Confirm:$false