function Get-BAM {
<#
.SYNOPSIS
This function pulls Background Activity Monitor (BAM) data from the registry.

.EXAMPLE
PS> Get-BAM

.EXAMPLE
PS> Get-BAM | Out-Gridview

.EXAMPLE
PS> Get-BAM | Sort-Object "Application","User","LastExecution" -Unique | Sort-Object "User" -Ascending | Out-GridView

Sort Background Activity Monitor Keys by User SID.

.NOTES
Author: brx.cybr@gmail.com
Last Updated: 3/10/2020

#>

$regPath = "Registry::HKLM\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings\"
$regKeyNames = Get-ChildItem -Name $regPath
$data = @()
foreach ($SID in $regKeyNames){
	$keyPath = $regPath + $SID
    $keyProperty = Get-ItemProperty -Path $keyPath
    $Entries = $keyProperty | 
        Get-Member -MemberType NoteProperty | 
        Where-Object {
            $_.Name -notmatch "\bPS\w+\b" `
            -and $_.Name -ne "Version" `
            -and $_.Name -ne "SequenceNumber" 
        } | 
        Select-Object -ExpandProperty Name
    foreach( $key in $Entries){ 
        $value = $keyProperty.$key
        $hex  = [System.BitConverter]::ToString($value) -split '-'
        $LastExecution = [Convert]::ToInt64($hex[7]+$hex[6]+$hex[5]+$hex[4]+$hex[3]+$hex[2]+$hex[1]+$hex[0],16)
        $data += [PSCustomObject]@{
            "Application" = $key
            "User" = $SID
            "LastExecution" = [datetime]::FromFileTime($LastExecution)
            }
        $data
        }
    }
}
Get-BAM | Sort-Object "Application","User","LastExecution" -Unique | Sort-Object "LastExecution" -Descending | Out-GridView