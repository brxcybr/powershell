<#
.SYNOPSIS
This script removes Splunk forwarders and Sysmon from a list of targets provided
as a text file on the desktop, targets.txt. This script could be used to remove 
other agents from Windows devices with a few modifications.

.DESCRIPTION
This script removes Splunk forwarders and Sysmon from a list of targets provided
as a text file on the desktop, targets.txt. This script is designed to undo the
actions taken by the Deploy-Agents.ps1 script. This script could be used to 
remove other agents from Windows devices with a few modifications. 
#>

$targets = Get-Content -Path $HOME\Desktop\targets.txt

foreach( $target in $targets){
    Invoke-Command -ComputerName $target -Credential $cred -ScriptBlock {
        set-location 'C:\Program Files\SplunkUniversalForwarder\bin'
        .\splunk stop;
        sleep 15;
        set-location c:\;
        msiexec /x splunkforwarder-8.0.0-1357bef0a7f6-x64-release.msi REMOVE_FROM_GROUPS=1;
        sleep 30;
        remove-item -Recurse 'C:\Program Files\SplunkUniversalForwarder'
        net stop sysmon;
        net stop sysmondrv;
        del c:\windows\sysmon.exe;
        del c:\windows\sysmondrv.sys;
        reg delete HKLM\SYSTEM\CurrentControlSet\Services\SysmonDrv /f;
        reg delete HKLM\SYSTEM\CurrentControlSet\Services\Sysmon /f;
        }
}