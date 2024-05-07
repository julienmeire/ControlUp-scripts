try {
    # Récupérer les volumes avec des lettres de lecteur
    $volumes = Get-Volume | Where-Object { $_.DriveLetter }
    
    if (-not $volumes) {
        Write-Error "Aucun volume avec lettre de lecteur n'a été trouvé."
        return
    }

    # Parcourir chaque volume et afficher les détails
    foreach ($volume in $volumes) {
        try {
            # Calculer l'espace utilisé (en Go)
            $usedSpace = [math]::Round(($volume.Size - $volume.SizeRemaining) / 1GB, 2)
            # Espace disponible (en Go)
            $freeSpace = [math]::Round($volume.SizeRemaining / 1GB, 2)
            # Espace total (en Go)
            $totalSpace = [math]::Round($volume.Size / 1GB, 2)

            # Afficher les informations
            Write-Output "Lettre de lecteur: $($volume.DriveLetter):"
            Write-Output "Espace Total: $totalSpace Go"
            Write-Output "Espace Utilisé: $usedSpace Go"
            Write-Output "Espace Libre: $freeSpace Go"
            
            if ($freeSpace -gt 10) {
                Write-Output "Possible d'expandre la partition."
            }

        } catch {
            Write-Error "Erreur lors du traitement du volume $($volume.DriveLetter): $_"
        }
    }
} catch {
    Write-Error "Erreur lors de l'accès aux volumes: $_"
}
