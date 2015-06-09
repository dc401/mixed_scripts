#20150603 dc - quick and dirty SID duplicate finder in AD
#dchow[AT]xtecsystems.com

#usage run AD_DupSIDFinder.ps1 -o MyPathOrFileName.csv

Try
	{
		Import-Module ActiveDirectory -ErrorAction Stop
	}
Catch
	{ 
		Write-Host "Install RSAT tools"; Break
	}
	
param([string$o])
Write-Host "Writing to $o"

$hostsArr = Get-ADComputer -Filter * -Properties sid | select name,sid
$hostsArr | Group-Object -Property Name -NoElement | Export-Csv $o -notype -encoding "ascii"
