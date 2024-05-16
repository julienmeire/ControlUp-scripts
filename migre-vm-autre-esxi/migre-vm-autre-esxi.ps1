param(
    [string]$vmName,
    [string]$hoteEsxi,
    [string]$destinationEsxi,
    [string]$vCenter,
    [string]$user,
    [string]$credentials
)

# Importe le module VMware PowerCLI
Import-Module VMware.PowerCLI

# Configure les options de connexion pour éviter les avertissements de certificat
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connexion au vCenter
try {
    $connection = Connect-VIServer -Server $vCenter -User $user -Password $credentials -ErrorAction Stop
    Write-Output "Connexion réussie au vCenter '$vCenter'."
} catch {
    Write-Output "Erreur de connexion au vCenter '$vCenter': $($_.Exception.Message)"
    exit
}

# Récupère l'objet VM
$vm = Get-VM -Name $vmName
if (-not $vm) {
    Write-Output "VM '$vmName' non trouvée. Vérifiez le nom et essayez à nouveau."
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit
}

# Vérifie si l'hôte de destination existe
$destinationHost = Get-VMHost -Name $destinationEsxi
if (-not $destinationHost) {
    Write-Output "Hôte ESXi de destination '$destinationEsxi' non trouvé. Vérifiez le nom et essayez à nouveau."
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit
}

# Verifie que l esxi hote et destination sont differents
    If ($hoteEsxi -eq $destinationEsxi) {
        Write-Output "impossible de migrer sur le meme hote"
    }


# Vérifie si la VM et l'hôte de destination existent pour procéder à la migration
if ($vm -and $destinationHost) {
    try {
        Move-VM -VM $vm -Server $vCenter -Destination $destinationHost -ErrorAction Stop
        Write-Output "La VM '$vmName' a été migrée avec succès vers l'hôte '$destinationEsxi'"
    } catch {
        Write-Output "Erreur lors de la migration de la VM : $($_.Exception.Message)"
    }
} else {
    Write-Output "Échec de la migration : Vérifiez que le nom de la VM et l'hôte de destination sont corrects."
}

# Déconnexion du vCenter
Disconnect-VIServer -Server $vCenter -Confirm:$false
