Param (
    [string]$DriveLetter
)

#gère les exceptions et erreurs
Function Out-CUConsole {
    Param (
        [Parameter(Mandatory=$false)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [switch]$Warning,
        [Parameter(Mandatory=$false)]
        [switch]$Stop,
        [Parameter(Mandatory=$false)]
        $Exception
    )

    if ($Exception) {
        Write-Warning "$Message`n$($Exception.Message)"
        Throw $Exception
    } elseif ($Stop) {
        Write-Warning $Message
        Throw $Message
    } elseif ($Warning) {
        Write-Warning $Message
    } else {
        Write-Output $Message
    }
}

#récupère la partition correspondante à la lettre drive fournie en paramètre et calcule la place disponible
try {
    $Partition = Get-Partition -DriveLetter $DriveLetter -ErrorAction Stop
    $Disk = $Partition | Get-Disk
    $SupportedSize = Get-PartitionSupportedSize -DiskNumber $Disk.Number -PartitionNumber $Partition.PartitionNumber -ErrorAction Stop
    $FreeSpace = $SupportedSize.SizeMax - $Partition.Size

	#s'il y a de la place disponible, on agrandit la partition pour occuper toute la place disque disponible 
    if ($FreeSpace -gt 0) {
        Resize-Partition -DiskNumber $Disk.Number -PartitionNumber $Partition.PartitionNumber -Size $SupportedSize.SizeMax
        Out-CUConsole -Message "La partition a été agrandie pour occuper tout l'espace disque restant"
    } else {
        Out-CUConsole -Message "Pas de place disponible pour agrandir la partition" -Warning
    }
} catch {
    Out-CUConsole -Message "Echec lors de l'opération: " -Exception $_
}
