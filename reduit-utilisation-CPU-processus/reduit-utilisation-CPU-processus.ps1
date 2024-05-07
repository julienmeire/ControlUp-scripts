param(
    [int]$pid,  
    [int]$cpuThreshold = 20  
)

# Fonction pour baisser la priorité du processus
function Adjust-ProcessPriority {
    param($process)
    try {
        $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
        Write-Host "Priorité réduite pour le processus PID $($process.Id)."
    } catch {
        Write-Host "Erreur lors de l'ajustement de la priorité: $_"
    }
}

# Boucle pour surveiller continuellement le processus
while ($true) {
    try {
        $process = Get-Process -Id $pid -ErrorAction Stop
        $cpuUsage = (Get-Counter "\Process($($process.ProcessName))\% Processor Time").CounterSamples.CookedValue
        Write-Host "Utilisation du CPU par le processus PID $pid: $cpuUsage%"

        # Vérifier si l'utilisation du CPU dépasse le seuil
        if ($cpuUsage -gt $cpuThreshold) {
            Write-Host "Utilisation du CPU supérieure à $cpuThreshold% pour le processus PID $pid."
            Adjust-ProcessPriority -process $process
        }
    } catch {
        Write-Host "Erreur lors de la récupération des informations du processus ou processus introuvable: $_"
    }
    # Attendre 5 secondes avant de vérifier à nouveau
    Start-Sleep -Seconds 5
}
