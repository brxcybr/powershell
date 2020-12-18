Function Invoke-RotDecode([string]$str, $n){
<#
.SYNOPSIS
This function decodes Rot13 text data.

.EXAMPLE
PS> Invoke-RotDecode $data 13

Rot 13 decode of encoded text object.

.NOTES
Author: brx.cybr@gmail.com
Created: 3/6/2020
Last Updated: 3/10/2020

#>
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
