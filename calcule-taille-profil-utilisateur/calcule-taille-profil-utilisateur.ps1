# Définit le chemin du profil utilisateur
$userProfilePath = $env:USERPROFILE

# Obtient tous les fichiers et sous-dossiers récursivement
$items = Get-ChildItem -Path $userProfilePath -Recurse

# Calcule la taille totale des fichiers
$totalSize = ($items | Where-Object { !$_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum

# Convertit la taille en MB
$totalSizeMB = [Math]::Round($totalSize / 1MB, 2)

# Affiche la taille totale
Write-Output "La taille totale des fichiers est de $totalSizeMB MB"

# Crée une liste pour stocker les informations des dossiers
$folderSizes = @()

# Calcule la taille pour chaque sous-dossier et stocke les dans la liste
foreach ($folder in ($items | Where-Object { $_.PSIsContainer })) {
    $folderSize = (Get-ChildItem -Path $folder.FullName -Recurse | Where-Object { !$_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum
    $folderSizeMB = [Math]::Round($folderSize / 1MB, 2)
    $folderSizes += New-Object PSObject -Property @{
        Name = $folder.FullName
        SizeMB = $folderSizeMB
    }
}

# Trie les dossiers par taille en ordre décroissant et prendre les 15 premiers
$topFolders = $folderSizes | Sort-Object -Property SizeMB -Descending | Select-Object -First 15

# Affiche la taille des 15 dossiers les plus lourds
Write-Output "Top 15 des dossiers les plus lourds :"
foreach ($folder in $topFolders) {
    Write-Output "$($folder.Name): $($folder.SizeMB) MB"
}
