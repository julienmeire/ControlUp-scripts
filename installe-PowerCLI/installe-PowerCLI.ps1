# Vérifie et met à jour PowerShellGet
Write-Host "Vérification et mise à jour de PowerShellGet..."
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PowerShellGet -Force
Import-Module -Name PowerShellGet -Force

# Installe VMware PowerCLI pour tous les utilisateurs
Write-Host "Installation de VMware PowerCLI..."
Install-Module -Name VMware.PowerCLI -Scope AllUsers -AllowClobber -Force

# Configure VMware PowerCLI
Write-Host "Configuration de VMware PowerCLI..."
$AllUsersProfile = [System.Environment]::GetFolderPath('CommonApplicationData') + "\VMware\PowerCLI\PowerCLIConfiguration.ps1"
$scriptContent = @'
# Désactive le message de bienvenue
Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCEIP $false -Confirm:$false
Set-PowerCLIConfiguration -Scope AllUsers -InvalidCertificateAction Ignore -Confirm:$false
'@
# Vérifie que le dossier existe
$scriptDir = Split-Path -Path $AllUsersProfile -Parent
If (-Not (Test-Path -Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir -Force
}
Set-Content -Path $AllUsersProfile -Value $scriptContent -Force

# Vérifie que l'installation s'est éffectuée correctement
If (Get-Module -ListAvailable -Name VMware.PowerCLI) {
    Write-Host "VMware PowerCLI a été installé avec succès."
} Else {
    Write-Host "L'installation de VMware PowerCLI a échoué."
}

