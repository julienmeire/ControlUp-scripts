param(
    [int]$Pid,
    [int]$limitMB
)

$limit = $limitMB * 1MB

# Tente d'obtenir le processus
$process = Get-Process -Id $Pid -ErrorAction Stop

#définit une classe statique pour accéder aux API de Windows et implémente une méthode pour définir la taille de l'ensemble de travail
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class NativeMethods {
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool SetProcessWorkingSize(IntPtr hProcess, IntPtr minSize, IntPtr maxSize, int flags);
}
"@

# Tente de définir la taille maximale de la mémoire accordée au processus
if (-not [NativeMethods]::SetProcessWorkingSize($process.Handle, [IntPtr]::Zero, [IntPtr]$limit, 0x00000001)) {
    throw "Échec pour attribuer au Pid $Pid la taille d'utilisation de la mémoire de $maxWorkingSetMB MB."
}
else{
Write-Host "Le Pid $Pid est limité maintenant limité à $maxWorkingSetMB MB de mémoire."
}
