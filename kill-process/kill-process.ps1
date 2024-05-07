param(
    [Parameter(Mandatory=$true)]
    [int]$pid
)

# Essaye de kill le processus
try {
    $process = Get-Process -Id $pid
    $process | Stop-Process -Force
    Write-Host "Processus avec PID $pid a été kill avec succès."
} catch {
    # Gére les erreurs
    Write-Host "Erreur: $_"
}
