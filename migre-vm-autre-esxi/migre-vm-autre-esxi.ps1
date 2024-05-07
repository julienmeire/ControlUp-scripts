param(
    [string]$vmName,      
    [string]$sourceEsxi,              
    [string]$destinationEsxi,       
    [string]$vCenter,                 
    [string]$username,                 
    [string]$password                  

# Importe le module VMware PowerCLI
Import-Module VMware.PowerCLI

# Configure les options de connexion pour éviter les avertissements de certificat
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connexion au vCenter
Connect-VIServer -Server $vCenter -User $username -Password $password

# Récupére l'objet VM
$vm = Get-VM -Name $vmName

# Récupére l'objet hôte ESXi de destination
$destinationHost = Get-VMHost -Name $destinationEsxi

# Vérifie si l'objet VM et l'hôte de destination existent
if ($vm -and $destinationHost) {
    # Lancer la migration de la VM vers l'hôte de destination
    Move-VM -VM $vm -Destination $destinationHost
    Write-Output "La VM '$vmName' a été migrée vers l'hôte '$destinationEsxi'."
} else {
    Write-Output "Erreur : Vérifiez que le nom de la VM et l'hôte de destination sont corrects."
}

# Déconnexion du vCenter
Disconnect-VIServer -Server $vCenter -Confirm:$false
