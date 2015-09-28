Enter file contents here<#
20150910 dc - Recursively copy files specified of the same name.ext from various folders
and then write to a new path renamed for each instance with numerical values incrementing

Be careful we use Get-Content which loads the entire file listing into memory. Hint: If the file list
becomes something like 1 TB; this will be loaded entirely in memory. The alternative is to
modify the listing using a new object to stream the file rather than load all at once.

Usage: recurseCopyDuplicates.ps1 -s SourcePathToSearch -f FileNameToFind.Ext -d DestinationPath

Examples:
Always include the trailing blackslash "\" in your path
recurseCopyDuplicates.ps1 -s 'C:\foo' -f repeatingData.txt -d 'D:\foo bar\'
recurseCopyDuplicates.ps1 -s C:\foo\ -f *.csv -d D:\foobar\

#>

#Add some arguments
param([string]$s , [string]$f, [string]$d)

IF (Test-Path -isvalid $s)
{
	#enumerate where the files; specify a filename; and dump to temp file
	Get-ChildItem -Path $s -Recurse -Force -Include $f | % { echo $_.FullName } | `
	Out-File filelist.tmp -Append;

	#shove into an array
	$fileListArr = Get-Content filelist.tmp;

	#For loop with a counter and less than the total array count
	FOR($index=0; $index -lt $fileListArr.Count; $index++)
		{
			#For some reason basic copies interactive require quotes yet read in from index does not
			#$sourcePath = ('"' + ($fileListArr[$index]) + '"').toString()
			$sourcePath = ($fileListArr[$index]).toString()
			
			#Static way
			$destPath = ($d + "file" + "$index" + ".csv").toString()
			
			#FileName from parameters taken
			#$destPath = ($d + $f + $index)
	
			Copy-Item -path $sourcePath -destination $destPath
			#Write-Host ("file" + "$index" + ".csv")
		}
		
	#Clean up
	rm filelist.tmp;
}

ELSE
{
	Write-Host "Syntax: recurseCopyDuplicates.ps1 -s SourcePathToSearch -f FileNameToFind.Ext -d DestinationPath"
	Write-Host "Always include the trailing blackslash "\" in your paths"
	exit;
}
