# Chemin vers le dossier temporaire de l'utilisateur
$UserTempFolder = [System.IO.Path]::GetTempPath()

# Vérifie l'existence du dossier avant de tenter de supprimer les fichiers
if (Test-Path -Path $UserTempFolder) {
    # Suppression de tous les fichiers dans le dossier temporaire, y compris les fichiers cachés
    Get-ChildItem -Path $UserTempFolder -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

    # Nettoyage des éventuels dossiers vides après la suppression des fichiers
    Get-ChildItem -Path $UserTempFolder -Recurse | Where-Object { $_.PSIsContainer -and @(Get-ChildItem -Path $_.FullName -Recurse -Force).Count -eq 0 } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
} else {
    Write-Output "Le dossier temporaire n'existe pas ou a été déplacé."
}
