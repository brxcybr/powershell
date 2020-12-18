<#
.SYSNOPSIS
This script deploys Splunk Forwarders and Sysmon to a list of targets provided as
a text file on the desktop, targets.txt.

.DESCRIPTION
This script deploys Splunk Forwarders and Sysmon to a list of targets provided as
a text file on the desktop, targets.txt. The source files must be in a directory
on the desktop labeled "Software" with nested "Splunk" and "Sysmon" folders. This
script could be used to deploy any other agents to Windows devices
with a few modifications. The scripts also moves an inputs.conf file to the target.

.NOTES
Author: brx.cybr@gmail.com
Last Updated: 2/28/2020
#>


$targets = Get-Content -Path $HOME\Desktop\targets.txt
$softwarefolders = Get-ChildItem $HOME\Desktop\Software -Directory

foreach( $target in $targets){
    foreach( $sw in $softwarefolders )
    { 
        Copy-Item -Path $sw.Fullname -Destination \\$target\c$\Windows\Temp -Credential $cred -Force -Recurse; 
        Copy-Item -Path "$HOME\Desktop\inputs.conf" -Destination "\\$target\c$\Windows\Temp\Splunk" -Credential $cred -Force 
    }
    Invoke-Command -ComputerName $target -Credential $cred -ScriptBlock {
        C:\Windows\Temp\Sysmon\sysmon64.exe -accepteula -i C:\Windows\Temp\Sysmon\sysmonconfig-export.xml; 
        msiexec.exe /i C:\Windows\Temp\Splunk\splunkforwarder-8.0.0-1357bef0a7f6-x64-release.msi AGREETOLICENSE=1 RECEIVING_INDEXER="10.10.1.110:9997" DEPLOYMENT_SERVER="10.10.1.110:8089" LAUNCHSPLUNK=1 SERVICESTARTTYPE=auto SPLUNKPASSWORD=Team_Cinco123!@# /l*vx C:\Windows\Temp\Splunk\INSTALL_Splunk.log /qn;
        sleep 60;
        New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force;
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force;
        get-content C:\Windows\Temp\Splunk\inputs.conf | add-content "c:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf"; 
        C:\"Program Files"\SplunkUniversalForwarder\bin\splunk restart;
        Remove-Item -Path "c:\Windows\Temp\Splunk" -Recurse -Force; Remove-Item -Path "c:\Windows\Temp\Sysmon" -Recurse -Force}
 
}

