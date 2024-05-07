param (
    [string]$server,
    [string]$username,
    [string]$password,
    [string]$nomSnapshotCorrect
)

# Assurer que les paramètres nécessaires sont fournis
if (-not $server -or -not $username -or -not $password -or -not $nomSnapshotCorrect) {
    Write-Error "Veuillez fournir tous les paramètres nécessaires : server, username, password, nomSnapshotCorrect"
    exit
}

# Se connecter au serveur Horizon
try {
    Import-Module VMware.VimAutomation.Core
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
    Connect-VIServer -Server $server -Credential $credential
} catch {
    Write-Error "Erreur lors de la connexion au serveur VMware : $_"
    exit
}

# Récupérer les machines virtuelles
$vms = Get-VM

# Vérifier chaque machine virtuelle pour le snapshot
foreach ($vm in $vms) {
    $snapshots = Get-Snapshot -VM $vm
    $snapshotIncorrect = $snapshots | Where-Object { $_.Name -ne $nomSnapshotCorrect }

    if ($snapshotIncorrect) {
        Write-Host "La VM $($vm.Name) tourne avec un mauvais snapshot : $($snapshotIncorrect.Name)"
    }
}

# Se déconnecter du serveur
Disconnect-VIServer -Server $server -Confirm:$false
