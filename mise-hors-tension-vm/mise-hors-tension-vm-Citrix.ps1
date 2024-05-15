param(
    [string]$server,
    [string]$user,
    [string]$password
)

# Importe le module Citrix XenDesktop Admin
if (-not (Get-Module -ListAvailable -Name Citrix.XenDesktop.Admin)) {
    Install-Module -Name Citrix.XenDesktop.Admin -Scope CurrentUser -AllowClobber -Force
}

# Tentative de connexion à Citrix Delivery Controller
try {
    $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($user, (ConvertTo-SecureString -String $password -AsPlainText -Force))
    $connection = New-XDAuthentication -AdminAddress $server -Credential $credentials -ErrorAction Stop
} catch {
    Write-Error "Erreur lors de la connexion au Citrix Delivery Controller: $_"
    exit
}

# Définis les durées d'inactivité maximales
$tempsVeilleMax = New-TimeSpan -Minutes 20
$tempsInactiviteMax = New-TimeSpan -Minutes 15

# Récupère toutes les sessions sur le Delivery Controller
try {
    $sessions = Get-BrokerSession -MaxRecordCount 1000 -ErrorAction Stop
} catch {
    Write-Error "Erreur lors de la recuperation des sessions: $_"
    Remove-XDAuthentication -AdminAddress $server
    exit
}

foreach ($session in $sessions) {
    try {
        $desktop = Get-BrokerDesktop -SessionKey $session.SessionKey -ErrorAction Stop
        # Vérifie si la session est inactive
        if ($desktop.SessionState -eq "Disconnected") {
            $tempsVeille = [DateTime]::Now - $session.DisconnectTime

            if ($tempsVeille -ge $tempsVeilleMax) {
                Stop-BrokerSession -SessionKey $session.SessionKey -Force -ErrorAction Stop
                Write-Host "La session $($session.SessionKey) a été forcée à se terminer car elle était inactive depuis plus de 20 minutes."
            }
        }
        # Vérifie si la session est active mais inutilisée
        elseif ($desktop.SessionState -eq "Active") {
            $lastInputTime = $session.LastInputTime
            $tempsInactivite = [DateTime]::Now - $lastInputTime

            if ($tempsInactivite -ge $tempsInactiviteMax) {
                Disconnect-BrokerSession -SessionKey $session.SessionKey -Force -ErrorAction Stop
                Write-Host "La session $($session.SessionKey) a été déconnectée car aucune activité n'a été détectée depuis plus de 15 minutes."
            }
        }
    } catch {
        Write-Warning "Une erreur est survenue lors du traitement de la session $($session.SessionKey): $_"
    }
}

# Déconnecte-toi du serveur
Remove-XDAuthentication -AdminAddress $server
