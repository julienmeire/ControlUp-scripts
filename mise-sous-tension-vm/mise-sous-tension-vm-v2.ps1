param (
    [Parameter(Mandatory=$true)]
    [string]$vmName
)

# choisi la bonne commande en fonction de l'hyperviseur
function Start-VMCommand {
    if (Get-Command -Name Get-VM -Module Hyper-V -ErrorAction SilentlyContinue) {
        Start-VM -Name $vmName
        Check-Status "Hyper-V"
    }
    elseif (Get-Command -Name Get-VMHost -Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue) {
        Connect-VIServer -Server "votreServeurVCenter" -User "votreUser" -Password "votrePassword"
        Start-VM -VM $vmName -Confirm:$false
        Check-Status "VMware"
    }
    elseif (Get-Command -Name virsh -ErrorAction SilentlyContinue) {
        virsh start $vmName
        Check-Status "KVM"
    }
    elseif (Get-Command -Name Get-XenServerVM -Module XenServerPSModule -ErrorAction SilentlyContinue) {
        $session = New-XenServerSession -Server "votreServeurXen" -UserName "votreUser" -Password "votrePassword"
        Start-XenServerVM -VM $vmName -Session $session
        Check-Status "Citrix XenServer"
    }
    else {
        Write-Host "Hyperviseur non supporté ou non détecté"
        exit
    }
}

# Vérifie le statut après tentative de démarrage
function Check-Status($hypervisor) {
    if ($?) {
        Write-Host "VM démarrée avec succès sur $hypervisor"
    } else {
        Write-Host "Échec du démarrage de la VM sur $hypervisor"
    }
}

# Démarre la VM
Start-VMCommand
