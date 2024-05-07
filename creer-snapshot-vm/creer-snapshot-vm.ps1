# Définit l'action en cas d'erreur 
$ErrorActionPreference = 'Stop'

# Définit les variables selon les paramètres reçus
$params = @{
    VCenter = $args[0]
    VMName = $args[1]
    SnapshotName = if ($args[2]) { $args[2] } else { "ControlUpSnapshot-" + (Get-Date -Format "yyyyMMddHHmm") }
    SnapshotDescription = if ($args[3]) { $args[3] } else { "Snapshot créé à partir d'un script ControlUp" }
}

# Donne des informations sur l'erreur rencontré et sort du script
function Feedback($Message, $Exception = $null, $ExitOnError = $false) {
    if ($Exception) {
        $Host.UI.WriteErrorLine("$Message`détails sur l erreur rencontrée: $Exception")
        if ($ExitOnError) { Exit 1 }
    } else {
        Write-Host $Message -ForegroundColor Green
    }
}

# S'assure que les modules VMWARE PowerCli soient disponibles
function Load-VMWareModules {
    try {
        Import-Module -Name VMware.VimAutomation.Core -ErrorAction Stop
    } catch {
        Feedback "Le module VMWARE PowerCLI est introuvable" $_ $true
    }
}

# Se connecte au vCenter
function Connect-VCenter($VCenter) {
    try {
        $serverSession = Connect-VIServer -Server $VCenter -ErrorAction Stop
        return $serverSession
    } catch {
        Feedback "Impossible de se connecter au vCenter $VCenter" $_ $true
    }
}

# Crée un snapshot pour la VM
function Create-Snapshot($VMName, $SnapshotName, $SnapshotDescription, $serverSession) {
    try {
        $existingSnapshot = Get-Snapshot -VM $VMName -Name $SnapshotName -Server $serverSession -ErrorAction SilentlyContinue
        if ($existingSnapshot) {
            Feedback "Un snapshot $SnapshotName existe déjà pour $VMName" $null $true
        } else {
            New-Snapshot -VM $VMName -Name $SnapshotName -Description $SnapshotDescription -Server $serverSession | Select-Object Name, Description, Created, SizeMB
        }
    } catch {
        Feedback "Impossible de créer un snapshot pour $VMName." $_ $true
    }
}

# Se déconnecte de vCenter
function Disconnect-VCenter($serverSession) {
    Disconnect-VIServer -Server $serverSession -Confirm:$false -ErrorAction SilentlyContinue
}

Load-VMWareModules
$session = Connect-VCenter $params.VCenter
Create-Snapshot $params.VMName $params.SnapshotName $params.SnapshotDescription $session
Disconnect-VCenter $session
