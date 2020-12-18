function Get-USBHistory{
<#
.SYNOPSIS
This function gathers USBSTOR data from the registry, including properties and metadata.

.EXAMPLE
PS> Get-USBHistory

.EXAMPLE
PS> Get-USBHistory | Select-Object FriendlyName,Address,Capabilities,HardwareID

.EXAMPLE
PS> Get-USBHistory | Select-Object FriendlyName,Address,Capabilities,HardwareID,ClassGUID | Out-Gridview

.NOTES
Author: brx.cybr@gmail.com
Created: 3/6/2020
Last Updated: 3/9/2020

#>
$regPath = "Registry::HKLM\SYSTEM\ControlSet001\Enum\USBSTOR\"
$regKeyNames = gci -Name $regPath
$data = @()
foreach ($key in $regKeyNames){
	$keyPath = $regPath + $key
    $subkeyNames = gci -Name $keyPath
    foreach ($subkey in $subkeyNames){
        $subkeyPath = $keyPath + "\" + $subkey
        $subkeyProperty = Get-ItemProperty -Path $subkeyPath
        $data += $subkeyProperty
        }
    }
    $data
}
Get-USBHistory