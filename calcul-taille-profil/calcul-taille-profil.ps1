# Affichage des informations système
Write-Output "System: $($env:COMPUTERNAME)"
Write-Output "Date/Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Récupération des profils utilisateur avec des SID spécifiques et calcul de leur taille totale
$AllUserProfiles = Get-CimInstance Win32_UserProfile |
    Where-Object { $_.SID -like 'S-1-5-21-*' -and $_.Special -eq $false } |
    Select-Object LocalPath, SID, @{
        Name="TotalSize"
        Expression={
            (Get-ChildItem $_.LocalPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        }
    }

# Tri des profils par taille décroissante
$SortedProfiles = $AllUserProfiles | Sort-Object TotalSize -Descending

# Affichage des résultats
$SortedProfiles | ForEach-Object {
    $userSize = if ($_.TotalSize) { "{0:N2} MB" -f ($_.TotalSize / 1MB) } else { "0 MB" }
    Write-Output "Profile SID: $($_.SID), Path: $($_.LocalPath), Total Size: $userSize"
}

Write-Output "Tâche exécutée"
