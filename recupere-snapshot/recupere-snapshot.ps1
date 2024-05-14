param (
    [Parameter(Mandatory=$true)]
    [string]$vcServer,

    [Parameter(Mandatory=$true)]
    [string]$vcUser,

    [Parameter(Mandatory=$true)]
    [string]$vcPassword,

    [Parameter(Mandatory=$true)]
    [string]$vmName
)

# Importe le module VMware PowerCLI
Import-Module VMware.PowerCLI

# Configure les options PowerCLI pour éviter les avertissements de sécurité
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Se connecte à vCenter
Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPassword

# Récupére les snapshots de la VM
$snapshots = Get-VM -Name $vmName | Get-Snapshot

# Vérifie s'il existe des snapshots et afficher les informations
if ($snapshots) {
    Write-Host "Snapshots trouvés pour la VM $vmName :"
    foreach ($snap in $snapshots) {
        Write-Host "Snapshot: $($snap.Name) - Créé le: $($snap.Created)"
    }
} else {
    Write-Host "Aucun snapshot trouvé pour la VM $vmName."
}

# Déconnexion du serveur vCenter
Disconnect-VIServer -Server $vcServer -Confirm:$false
