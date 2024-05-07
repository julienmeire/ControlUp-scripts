param (
    [Parameter(Mandatory=$true)]
    [string]$vmName
)

# Détecte l'hyperviseur
if (Get-Command -Name Get-VM -ErrorAction SilentlyContinue) {
    $hypervisor = "Hyper-V"
} elseif (Get-Command -Name Get-VMHost -Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue) {
    $hypervisor = "VMware"
} else {
    Write-Host "Hyperviseur non supporté ou non détecté"
    exit
}

# Allume la VM selon l'hyperviseur
switch ($hypervisor) {
    "Hyper-V" {
        Start-VM -Name $vmName
        if ($?) {
            Write-Host "VM démarrée avec succès sur Hyper-V"
        } else {
            Write-Host "Échec du démarrage de la VM sur Hyper-V"
        }
    }
    "VMware" {
        Connect-VIServer -Server "votreServeurVCenter" -User "votreUser" -Password "votrePassword"
        Start-VM -VM $vmName -Confirm:$false
        if ($?) {
            Write-Host "VM démarrée avec succès sur VMware"
        } else {
            Write-Host "Échec du démarrage de la VM sur VMware"
        }
    }
}
