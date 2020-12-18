function Get-TypedURLs{
<#
.SYNOPSIS
This function pulls TypedUrls data from the registry.

.EXAMPLE
PS> Get-TypedUrls

.EXAMPLE
PS> Get-TypedUrls | Out-Gridview

.EXAMPLE
PS> Get-TypedUrls | Sort-Object "QueryTime" -Descending

.NOTES
Author: brx.cybr@gmail.com
Last Updated: 3/10/2020

#>
$URLkeyProperty = Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Internet Explorer\TypedURLs"
$TimeKeyProperty = Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Internet Explorer\TypedURLsTime"
$URLEntries = $URLkeyProperty | Get-Member -Name "url*"
$data = @()
foreach($URL in $URLEntries){ 
    $timeEntry = $TimeKeyProperty.($URL.Name)
    $hex  = [System.BitConverter]::ToString($TimeEntry) -split '-'
    $timeData = [Convert]::ToInt64($hex[7]+$hex[6]+$hex[5]+$hex[4]+$hex[3]+$hex[2]+$hex[1]+$hex[0],16)
    $data += [PSCustomObject]@{
        "URL" = $($URL.Definition.split("="))[1]
        "QueryTime" = [datetime]::FromFileTime($timeData)
        }
    }
$data
}
Get-TypedURLs | Out-GridView