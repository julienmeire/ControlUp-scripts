$services = Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped' }

foreach ($service in $services) {
    Write-Output "Démarrage du service: $($service.Name)"
    Start-Service $service.Name
    if ((Get-Service -Name $service.Name).Status -eq 'Running') {
        Write-Output "Le service $($service.Name) a été démarré avec succès."
    } else {
        Write-Output "Échec du démarrage du service $($service.Name)."
    }
}
