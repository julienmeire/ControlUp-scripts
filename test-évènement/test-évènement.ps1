param(
    [string]$source = "ControlUpAgent",  
    [int]$eventID = 5001,                
    [string]$eventType = "Information", 
    [string]$logName = "Application",  
    [string]$message = "Ceci est un test d'événement généré par ControlUp Agent." 
)

# Convertit le type d'événement en type Enum approprié
$eventLogType = [System.Diagnostics.EventLogEntryType]::Information
switch ($eventType) {
    "Information" { $eventLogType = [System.Diagnostics.EventLogEntryType]::Information }
    "Warning"     { $eventLogType = [System.Diagnostics.EventLogEntryType]::Warning }
    "Error"       { $eventLogType = [System.Diagnostics.EventLogEntryType]::Error }
}

# Vérifie si la source de l'événement existe déjà, sinon la crée
if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
    [System.Diagnostics.EventLog]::CreateEventSource($source, $logName)
}

# Écriture de l'événement dans le journal
try {
    Write-EventLog -LogName $logName -Source $source -EventId $eventID -EntryType $eventLogType -Message $message
    Write-Host "Événement ajouté avec succès."
} catch {
    Write-Host "Erreur lors de l'ajout de l'événement : $_"
}
