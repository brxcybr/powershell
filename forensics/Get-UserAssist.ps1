function Get-UserAssist {
<#
.SYNOPSIS
This function pulls UserAssist data from the registry.

.EXAMPLE
PS> Get-UserAssist

.EXAMPLE
PS> Get-UserAssist | Out-Gridview

.EXAMPLE
PS> Get-UserAssist | Sort-Object "FileName" -Unique | Sort-Object "LastExecution" -Descending | Out-GridView

Sort UserAssist Keys by last execution time.

.EXAMPLE
PS> Get-UserAssist | Sort-Object "FileName" -Unique | Sort-Object "FocusCount" -Descending | Out-GridView

Sort UserAssist Keys by number of times executed.

.EXAMPLE
PS> Get-UserAssist | Sort-Object "FileName" -Unique | Sort-Object "FocusTime" -Descending | Out-GridView

Sort UserAssist Keys by most time spent using the application.

.EXAMPLE
PS> Get-UserAssist | Sort-Object "FileName" -Unique | Sort-Object "UA_focusTime" -Descending | Out-GridView

Sort UserAssist Keys by most time spent using the application.

.NOTES
Author: brx.cybr@gmail.com
Last Updated: 3/10/2020

#>

Function Invoke-RotDecode([string]$str, $n)
{
$value=""
For ($index= 0;$index -lt $str.length;$index++){
$ch= [byte][char]($str.substring($index,1))
if ($ch-ge 97 -and $ch -le 109){$ch=$ch+ $n}
else {
if ($ch-ge 110 -and $ch -le 122){$ch=$ch- $n}
else {
if ($ch-ge 65 -and $ch -le 77){$ch=$ch+ $n}
else {
if ($ch-gt 78 -and $ch -le 90){$ch=$ch -$n}
}
}
}
$value=$value+ [char]$ch
}
Return $value
}

$regPath = "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\"
$regKeyNames = "{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}","{F4E57C4B-2036-45F0-A9AB-443BCFE33D9F}"
$data = @()
foreach ($keyName in $regKeyNames){
	$keyPath = $regPath + $keyName + "\Count"
    $keyProperty = Get-ItemProperty -Path $keyPath
    $Entries = $keyProperty | get-member -MemberType NoteProperty | ? {$_.Name -notmatch "\bPS\w+\b"} | select -ExpandProperty name
    foreach( $key in $Entries){ 
        $decoded_UAName = Invoke-RotDecode $key 13
        $value = $keyProperty.$key
        $hex  = [System.BitConverter]::ToString($value) -split '-'
        $version = [Convert]::ToInt32($hex[3]+$hex[2]+$hex[1]+$hex[0],16)
        $counter = [Convert]::ToInt32($hex[7]+$hex[6]+$hex[5]+$hex[4],16)
        $focusCount = [Convert]::ToInt32($hex[11]+$hex[10]+$hex[9]+$hex[8],16)
        $focusTime = [Convert]::ToInt32($hex[15]+$hex[14]+$hex[13]+$hex[12],16)
        $LastExecution = [Convert]::ToInt64($hex[67]+$hex[66]+$hex[65]+$hex[64]+$hex[63]+$hex[62]+$hex[61]+$hex[60],16)
        if($keyName -eq $regKeyNames[0]){$ExecutionType = "Executable"}
        if($keyName -eq $regKeyNames[1]){$ExecutionType = "Shortcut"}
        
        if($LastExecution -gt 0){
            $data += [PSCustomObject]@{
                "FileName" = $decoded_UAName
                "ExecutionType" = $ExecutionType
                "Version" = $version
                "Counter" = $counter
                "FocusCount" = $focusCount
                "FocusTime" = $focusTime
                "LastExecution" = [datetime]::FromFileTime($LastExecution)
            }
        }
    }
    
    $data

    }
    

}
Get-UserAssist | Sort-Object "FileName" -Unique | Sort-Object "LastExecution" -Descending | Out-GridView