<#
20150911 dc - Compares a list of names fed to known male/female gender names
from two different other lists and does a count and ratio of each

Usage:
GetGenderRatioPS.ps1 -i inPutofNames -m MaleList.txt -f FemaleList.txt

Using multiple Arrays with Switch Statements Ref:
http://serverfault.com/questions/160258/powershell-switch-statement-with-multiple-values
http://powershell.com/cs/blogs/ebookv2/archive/2012/03/06/chapter-7-conditions.aspx#switch

#>

#cli arguments
param([string]$i, [string]$m, [string]$f);

#grab into array
$maleListArr = Get-Content $m.toString();
$femaleListArr = Get-Content $f.toString();
$inputListArr = Get-Content $i.toString();

#zero out the counters
[int]$mCounter = 0;
[int]$fCounter = 0;
[int]$uCounter = 0;

#loop through your own list
ForEach ($x in $inputListArr)
{
    #switch statements (cases) are case insensitive by default
    switch ($x)
        {
            #eval array and stop on first match via break
            { $maleListArr -eq $_ } { [int]$mCounter++ ; break }
            { $femaleListArr -eq $_ } { [int]$fCounter++ ; break }
            default { $uCounter++ ; break }
         }
}

Write-Host "Males: $mCounter";
Write-Host "Females: $fCounter";
Write-Host "Unknown: $uCounter";

#Ratio the counters
$ratio = $mCounter/$fCounter;

Write-Host "M/F Ratio: $ratio";
exit;
