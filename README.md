# Automating-ZVR-vCenter-Alarms
Automate SMTP based notifications for Zerto com.zerto.events within vCenter

# Getting Started
Instructions on how to utilize this automation example can be found on the following blog: https://www.zerto.com/scripting-apis/automating-zerto-virtual-replication-vcenter-alarms/

# Prerequisites 
Environment Requirements: 
- PowerShell 5.0 
- VMware PowerCLI 6.0+ 
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
