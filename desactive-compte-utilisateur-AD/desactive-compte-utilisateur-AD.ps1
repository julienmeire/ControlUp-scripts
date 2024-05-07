$ErrorActionPreference = "Stop"

# Vérifier si le module ActiveDirectory est chargé, sinon essayer de l'importer
If ((Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue) -eq $null) {
    Try {
        Import-Module ActiveDirectory
    } Catch {
        Write-Error "Impossible de charger le module ActiveDirectory" -ErrorAction Continue
        Write-Error $Error[1] -ErrorAction Continue
        Exit 1
    }
}

# Vérifie si un argument est passé au script
If ($args.Count -eq 0) {
    Write-Error "No username provided. Usage: script.ps1 'DOMAIN\username'"
    Exit 1
}

# Tentative de désactivation du compte utilisateur
Try {
    $username = $args[0].split("\")[1]
    $user = Get-ADUser -Identity $username -ErrorAction Stop
    Disable-ADAccount -Identity $user

    # Confirmation que le compte a été désactivé
    $disabledStatus = Get-ADUser -Identity $username -Properties Enabled | Select-Object -ExpandProperty Enabled
    If ($disabledStatus -eq $false) {
        Write-Host "le compte de l'utilisateur $username a parfaitement été désactivé."
    } Else {
        Write-Error "Impossible de désactiver le compte $username."
        Exit 1
    }
} Catch {
    Write-Error "Error occurred: $_"
    Exit 1
}
