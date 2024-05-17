param (
  [string]$vCenter,
  [string]$user,
  [string]$password
)

try {
    $connection = Connect-VIServer -Server $vCenter -User $user -Password $password -ErrorAction Stop
    Write-Host "Connecté avec succès à vCenter: $vCenter"
} catch {
    Write-Error "Erreur lors de la connexion à vCenter: $_"
    exit
}

# Récupérer les informations des ESXi dans le cluster "HA et DRS" et exclure le serveur spécifique
$clusterName = "Cluster HA & DRS"
try {
    $cluster = Get-Cluster -Name $clusterName -ErrorAction Stop
    $hosts = Get-VMHost -Location $cluster -ErrorAction Stop | Where-Object { $_.Name -ne 'nexis-esxi-004.wavre.nexis.be' }
    Write-Host "Informations récupérées pour le cluster: $clusterName"
} catch {
    Write-Error "Erreur lors de la récupération des informations du cluster: $_"
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit
}

# Calculer la charge moyenne de CPU sur tous les ESXi
$hostCpuLoads = @{}
foreach ($host in $hosts) {
    try {
        $cpuUsage = (Get-Stat -Entity $host -Stat cpu.usage.average -Realtime -MaxSamples 1 -ErrorAction Stop).Value
        $hostCpuLoads.Add($host.Name, $cpuUsage)
        Write-Host "Charge CPU actuelle pour $($host.Name): $cpuUsage%"
    } catch {
        Write-Error "Erreur lors de la récupération de la charge CPU pour $($host.Name): $_"
    }
}

if ($hostCpuLoads.Count -eq 0) {
    Write-Error "Aucune charge CPU récupérée, arrêt du script."
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit
}

$averageCpuLoad = ($hostCpuLoads.Values | Measure-Object -Average).Average
Write-Host "Charge moyenne de CPU dans le cluster: $averageCpuLoad%"

# Identifier et migrer uniquement les 5 premières VDI de chaque hôte
foreach ($host in $hosts) {
    $hostLoad = $hostCpuLoads[$host.Name]
    if ($hostLoad -gt $averageCpuLoad) {
        $vms = Get-VM -Location $host | Where-Object { $_.Name -match 'NEXIS-XD-T\d{2}' } | Select-Object -First 5
        foreach ($vm in $vms) {
            $targetHost = $hosts | Where-Object { $hostCpuLoads[$_.Name] -lt $averageCpuLoad } | Sort-Object { $hostCpuLoads[$_.Name] } | Select-Object -First 1
            try {
                Move-VM -VM $vm -Destination $targetHost -ErrorAction Stop
                Write-Host "VM $($vm.Name) migrée de $($host.Name) à $($targetHost.Name)"
                # Mise à jour des charges CPU après migration
                
            } catch {
                Write-Error "Erreur lors de la migration de la VM $($vm.Name) vers $($targetHost.Name): $_"
            }
        }
    }
}

# Déconnexion de vCenter
Disconnect-VIServer -Server $vCenter -Confirm:$false
Write-Host "Déconnecté de vCenter."
