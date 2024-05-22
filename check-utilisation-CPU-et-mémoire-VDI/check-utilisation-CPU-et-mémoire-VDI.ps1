Import-Module -Name ControlUp

# Récupére les informations des VDI
$VDIList = Get-CUComputer

# Crée un tableau pour stocker les données
$results = @()

foreach ($VDI in $VDIList) {
    # Récupérer l'utilisation du CPU et de la mémoire pour chaque VDI
    $cpuUsage = Get-CUCpuUsage -ComputerName $VDI.Name
    $memoryUsage = Get-CUMemoryUsage -ComputerName $VDI.Name

    # Créer un objet personnalisé pour chaque VDI avec ses données
    $result = New-Object PSObject -Property @{
        VDIName = $VDI.Name
        CPUUsage = $cpuUsage.PercentProcessorTime
        MemoryUsage = $memoryUsage.PercentUsedMemory
    }

    # Ajoute l'objet au tableau
    $results += $result
}

# Affiche les résultats dans la console
$results | Format-Table -AutoSize

try {
    # Tente d'enregistrer les résultats dans un fichier CSV
    $results | Export-Csv -Path "C:\Users\jme\Downloads\PhysicalMachineUsageReport.csv" -NoTypeInformation
    Write-Host "Les donnees ont ete enregistrees dans 'C:\Users\jme\Downloads\PhysicalMachineUsageReport.csv'"
} catch {
    # Affiche un message d'erreur si l'enregistrement échoue
    Write-Host "Erreur lors de l'enregistrement des donnees : $_"
}
