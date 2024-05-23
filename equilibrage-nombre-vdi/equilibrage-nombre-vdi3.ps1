$vCenter = "fqdn"
$user = "tonuser"
$password = "mdpici!"

try {
    $connection = Connect-VIServer -Server $vCenter -User $user -Password $password -ErrorAction Stop
    Write-Host "Connecte avec succes au vCenter: $vCenter"
} catch {
    Write-Error "Erreur lors de la connexion au vCenter: $_"
    exit
}

# Récupérer les informations des ESXi dans le cluster "HA et DRS" et exclure l'esxi 004
$clusterName = "Cluster HA & DRS"
try {
    $cluster = Get-Cluster -Name $clusterName -ErrorAction Stop
    $hosts = Get-VMHost -Location $cluster -ErrorAction Stop | Where-Object { $_.Name -ne 'nexis-esxi-004.wavre.nexis.be' }
    Write-Host "Informations recuperees pour le cluster: $clusterName"
} catch {
    Write-Error "Erreur lors de la recuperation des informations du cluster: $_"
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit
}

# Calculer la moyenne des charges de CPU sur tous les ESXi et identifier les hôtes au-dessus de la moyenne
$hostCpuLoads = @{}
$totalCpuUsage = 0
$hostCount = 0

foreach ($vmhost in $hosts) {
    try {
        # Récupérer tous les échantillons disponibles pour les dernières 5 minutes
        $cpuUsages = Get-Stat -Entity $vmhost -Stat cpu.usage.average -Start (Get-Date).AddMinutes(-5) -Finish (Get-Date) -ErrorAction Stop

        # Calculer la moyenne des valeurs de CPU usage
        $cpuUsageTotal = 0
        $countSamples = 0
        foreach ($sample in $cpuUsages) {
            $cpuUsageTotal += $sample.Value
            $countSamples++
        }

        if ($countSamples -gt 0) {
            $cpuUsageAverage = $cpuUsageTotal / $countSamples
            $hostCpuLoads.Add($vmhost.Name, $cpuUsageAverage)
            $totalCpuUsage += $cpuUsageAverage
            $hostCount++
        }
    } catch {
        Write-Error "Erreur lors de la recuperation de la moyenne de la charge CPU pour $($vmhost.Name): $_"
    }
}

if ($hostCount -gt 0) {
    $averageCpuUsage = $totalCpuUsage / $hostCount
    Write-Host "Moyenne des charges CPU pour tous les ESXi : $averageCpuUsage%"
    
    # Identifier les hôtes avec une charge CPU supérieure à la moyenne
    foreach ($hostName in $hostCpuLoads.Keys) {
        if ($hostCpuLoads[$hostName] -gt $averageCpuUsage) {
            Write-Host "$hostName a une charge CPU superieure à la moyenne : $($hostCpuLoads[$hostName])%"
        }
    }
} else {
    Write-Error "Aucune moyenne de charge CPU recuperee, arret du script."
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit
}

# Trouver l'ESXi avec la charge CPU la plus faible
$minLoadHost = $hostCpuLoads.GetEnumerator() | Sort-Object Value | Select-Object -First 1
Write-Host "L'ESXi avec la plus petite charge : $($minLoadHost.Name), avec une charge de : $($minLoadHost.Value)%"

# Identifier les hôtes ayant une charge CPU supérieure à la moyenne
$highLoadHosts = $hostCpuLoads.Keys | Where-Object { $hostCpuLoads[$_] -gt ($averageCpuUsage * 1.03)}

foreach ($vmhost in $highLoadHosts) {
    Write-Host "esxi au dessus de la moyenne : $vmhost"
}

function Get-VMCpuUsage {
    param (
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]$VM
    )
    try {
        # Récupérer les statistiques de CPU pour les dernières 24 heures
        $cpuStats = Get-Stat -Entity $VM -Stat cpu.usage.average -Start (Get-Date).AddMinutes(-5) -Finish (Get-Date) -MaxSamples 1 -ErrorAction Stop
        if ($cpuStats) {
            $cpuUsage = ($cpuStats | Measure-Object -Property Value -Average).Average
            return $cpuUsage
        } else {
            Write-Error "Aucune donnee de statistique CPU trouvee pour la VM: $($VM.Name)"
            return $null
        }
    } catch {
        Write-Error "Erreur lors de la recuperation des statistiques CPU pour la VM: $($VM.Name), $_"
        return $null
    }
}

foreach ($hostName in $highLoadHosts) {
    # Récupérer les VMs à migrer de cet hôte
    $vmsToMigrate = Get-VM -Location $hostName | Where-Object { $_.Name -like "Nexis-XD-T*" }
    foreach ($vm in $vmsToMigrate) {
        Write-Host "VM a migrer de l'hote $hostName : $($vm.Name)"
    }


    # Vérification si aucune VM n'a été trouvée pour cet hôte
    if ($vmsToMigrate.Count -eq 0) {
        Write-Host "Aucune VM correspondant aux criteres n a ete trouvee sur l'hôte $hostName."
    }

    $hostCpuCapacity = $hostCpuLoads[$hostName]

      
        foreach ($vm in $vmsToMigrate) {
            $vmCpuUsage = Get-VMCpuUsage -VM $vm
            $vmCpuShare = [math]::Round(($vmCpuUsage / $hostCpuCapacity), 3)
                
            Write-Host "La VM : $($vm.Name) consomme : $vmCpuShare% de l'hote $hostName"
                
            if ($minLoadHost) {
                Move-VM -VM $vm -Destination $($minLoadHost.Name)
                Write-Host "Migrating $($vm.Name) from $hostName to $($minLoadHost.Name)"
                $vmsToMigrate = $vmsToMigrate | Where-Object { $_.Id -ne $vm.Id }
                # Mettre à jour les charges estimées
                $hostCpuLoads[$hostName] -= $vmCpuUsage
                $hostCpuLoads[$minLoadHost] += $vmCpuUsage
            } else {
                Write-Host "Aucun hote disponible pour la migration"
            }
        }
    }
