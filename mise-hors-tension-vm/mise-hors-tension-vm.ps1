param(
    [string]$server,
    [string]$user,
    [string]$password
)

# Importe le module VMware PowerCLI
if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
    Install-Module -Name VMware.PowerCLI -Scope CurrentUser -AllowClobber -Force
}

# Tentative de connexion à l'hôte ESXi
try {
    $connection = Connect-VIServer -Server $server -User $user -Password $password -ErrorAction Stop
} catch {
    Write-Error "Erreur lors de la connexion à l'hôte ESXi: $_"
    exit
}

# Définis les durées d'inactivité maximales
$tempsVeilleMax = New-TimeSpan -Minutes 20
$tempsInactiviteMax = New-TimeSpan -Minutes 15

# Récupère toutes les VMs sur l'hôte ESXi
try {
    $vms = Get-VM -ErrorAction Stop
} catch {
    Write-Error "Erreur lors de la récupération des VMs: $_"
    Disconnect-VIServer -Server $server -Confirm:$false
    exit
}

foreach ($vm in $vms) {
    try {
        # Vérifie si la VM est en état suspendu
        if ($vm.PowerState -eq "Suspended") {
            $info = Get-VMQuestion -VM $vm
            $tempsVeille = [DateTime]::Now - $info.CreatedTime

            if ($tempsVeille -ge $tempsVeilleMax) {
                Stop-VM -VM $vm -Kill -Confirm:$false -ErrorAction Stop
                Write-Host "La VM $($vm.Name) a été forcée à s'arrêter car elle était en veille depuis plus de 20 minutes."
            }
        }
        # Vérifie si la VM est allumée mais inactive
        elseif ($vm.PowerState -eq "PoweredOn") {
            $stats = Get-Stat -Entity $vm -Stat "cpu.usage.average" -MaxSamples 1 -Realtime -ErrorAction SilentlyContinue
            if ($stats.Value -eq 0) {
                $lastActiveTime = $stats.Timestamp
                $tempsInactivite = [DateTime]::Now - $lastActiveTime

                if ($tempsInactivite -ge $tempsInactiviteMax) {
                    Suspend-VM -VM $vm -Confirm:$false -ErrorAction Stop
                    Write-Host "La VM $($vm.Name) a été mise en veille car aucune activité n'a été détectée depuis plus de 15 minutes."
                }
            }
        }
    } catch {
        Write-Warning "Une erreur est survenue lors du traitement de la VM $($vm.Name): $_"
    }
}

# Déconnecte-toi du serveur
Disconnect-VIServer -Server $server -Confirm:$false
