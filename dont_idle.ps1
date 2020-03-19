Add-Type -AssemblyName system.windows.forms; 
while ($true) 
{[system.windows.forms.sendkeys]::sendwait("{HOME}"); start-sleep -seconds 120
} 