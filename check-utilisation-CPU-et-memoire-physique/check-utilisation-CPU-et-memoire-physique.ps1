# Récupère le nom de la machine hôte automatiquement
$ComputerName = $env:COMPUTERNAME

# Utilise Get-WmiObject pour récupérer les informations CPU et mémoire
$cpuUsage = (Get-WmiObject Win32_Processor).LoadPercentage
$memoryUsage = Get-WmiObject Win32_OperatingSystem | ForEach-Object {
    "{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) * 100) / $_.TotalVisibleMemorySize)
}

# Crée un tableau pour stocker les données
$results = @()

# Créer un objet personnalisé pour la machine avec ses données
$result = New-Object PSObject -Property @{
    ComputerName = $ComputerName
    CPUUsage = $cpuUsage
    MemoryUsage = $memoryUsage
}

# Ajoute l'objet au tableau
$results += $result

# Affiche les résultats dans la console
$results | Format-Table -AutoSize

try {
    # Tente d'enregistrer les résultats dans un fichier CSV
    $results | Export-Csv -Path "C:\Users\jme\Downloads\PhysicalMachineUsageReport.csv" -NoTypeInformation
    Write-Host "Les données ont été enregistrées dans 'C:\Users\jme\Downloads\PhysicalMachineUsageReport.csv'"
} catch {
    # Affiche un message d'erreur si l'enregistrement échoue
    Write-Host "Erreur lors de l'enregistrement des données : $_"
}
