# Legal Disclaimer
This script is an example script and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.

# Automating-ZVR-vCenter-Alarms
Automate SMTP based notifications for Zerto com.zerto.events within vCenter

# Getting Started
Instructions on how to utilize this automation example can be found on the following blog: [Zerto Automating Virtual Replication vCenter Alarms](https://www.zerto.com/scripting-apis/automating-zerto-virtual-replication-vcenter-alarms/)

# Prerequisites
Environment Requirements:
- PowerShell 5.0
- [VMware PowerCLI Module installed from the PowerShell Gallery](https://blogs.vmware.com/PowerCLI/2017/04/powercli-install-process-powershell-gallery.html)
- vCenter Server Settings configured for SMTP
- ZVR 5.0 +

Script Requirements:
- Complete Alert Profile CSV
- Configure variables noted in string with "Enter"

# Running Script
Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following:

.\AlertingProfileConfiguration.PS1

# Deployment
After automating the SMTP trigger for the Zerto com.zerto.events alarms within vCenter a CSV will be created containing the specific alarms that were modified. This CSV should be saved and can be used with the Remove-AlertingProfileConfiguration.PS1 if the user would like to un-install the changes.
