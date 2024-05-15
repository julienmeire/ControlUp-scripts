# Script PowerShell avancé pour scanner le matériel et détecter les problèmes

# Vérifie si le script est exécuté avec des privilèges d'administrateur
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Vous devez exécuter ce script en tant qu'administrateur."
    break
}

# Fonction pour vérifier l'état des périphériques
function Check-DeviceStatus {
    $devices = Get-WmiObject Win32_PnPEntity
    foreach ($device in $devices) {
        if ($device.ConfigManagerErrorCode -ne 0) {
            Write-Host "Probleme detecte: $($device.Name) - Code d'erreur: $($device.ConfigManagerErrorCode)" -ForegroundColor Red
        }
    }
}

# Vérifier la santé du disque dur
function Check-DiskHealth {
    $disks = Get-WmiObject Win32_DiskDrive
    foreach ($disk in $disks) {
        $status = $disk.Status
        if ($status -ne "OK") {
            Write-Host "Alerte disque dur: $($disk.Model) - Statut: $status" -ForegroundColor Red
        } else {
            Write-Host "Disque dur en bonne sante: $($disk.Model) - Statut: $status" -ForegroundColor Green
        }
    }
}

# Vérifier la connectivité réseau
function Check-NetworkStatus {
    $networkCards = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true}
    foreach ($card in $networkCards) {
        if ($card.IPAddress -eq $null) {
            Write-Host "Problème reseau detecte sur: $($card.Description)" -ForegroundColor Red
        } else {
            Write-Host "Connexion reseau active sur: $($card.Description)" -ForegroundColor Green
        }
    }
}

# Vérification du CPU et de la mémoire pour les performances
function Check-SystemPerformance {
    $cpuLoad = Get-WmiObject Win32_Processor
    $totalMemory = Get-WmiObject Win32_ComputerSystem
    $availableMemory = Get-WmiObject Win32_OperatingSystem
    $cpuUsage = ($cpuLoad.LoadPercentage)
    $freeMemory = [math]::Round($availableMemory.FreePhysicalMemory / 1MB, 2)
    $totalMem = [math]::Round($totalMemory.TotalPhysicalMemory / 1GB, 2)

    Write-Host "Utilisation du CPU: $cpuUsage%"
    Write-Host "Memoire Totale: $totalMem GB - Memoire Disponible: $freeMemory MB"
}

# Exécution des vérifications
Write-Host "Debut de l'analyse du materiel et detection des problemes..."
Check-DeviceStatus
Check-DiskHealth
Check-NetworkStatus
Check-SystemPerformance
