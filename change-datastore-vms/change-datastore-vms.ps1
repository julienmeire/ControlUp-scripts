param (
    [string]$strHypervisorPlatform,
    [string]$strVCenter,
    [string]$strVMName,
    [string]$strDatastore
)

# Gère les messages et les erreurs
function Feedback {
    Param (
        [string]$Message,
        $Exception = $null,
        [switch]$Oops = $false
    )

    if (!$Oops) {
        Write-Host $Message -ForegroundColor 'Green'
    } else {
        $Host.UI.WriteErrorLine($Message)
        if ($Exception) {
            $Host.UI.WriteErrorLine("erreur rencontrée:`n$Exception")
        }
        Exit 1
    }
}

# Vérifie le support de l'hyperviseur
function Test-HypervisorPlatform {
    if ($strHypervisorPlatform -ne 'VMWare') {
        Feedback "VMWARE est le seul hyperviseur compatible, votre hyperviseur est $strHypervisorPlatform" -Oops
    }
}

# Importe les modules nécessaires
function Load-VMwareModules {
    $components = @('VimAutomation.Core')
    foreach ($component in $components) {
        try {
            Import-Module -Name VMware.$component
        } catch {
            Add-PSSnapin -Name VMware -ErrorAction Stop
        }
    }
}

# Connexion au serveur VCenter
function Connect-VCenterServer {
    try {
        $global:defaultVIServer = Connect-VIServer -Server $strVCenter -WarningAction SilentlyContinue -Force
    } catch {
        Feedback "Could not connect to VCenter server $strVCenter" -Exception $_ -Oops
    }
}

# Déconnexion du serveur VCenter
function Disconnect-VCenterServer {
    Disconnect-VIServer -Server $defaultVIServer -Confirm:$false -ErrorAction SilentlyContinue
}

# Opérations sur la VM
function Manage-VM {
    $objVM = Get-VM -Name $strVMName -Server $defaultVIServer -ErrorAction Stop
    $objVMHDDs = Get-HardDisk -VM $objVM -Server $defaultVIServer

    $objDatastore = Get-Datastore -Name $strDatastore -Server $defaultVIServer -ErrorAction Stop
    Move-VM -VM $objVM -Datastore $objDatastore -Confirm:$false

    $objVMHDDs = Get-HardDisk -VM $objVM -Server $defaultVIServer
    foreach ($hdd in $objVMHDDs) {
        Feedback "$($hdd.Name) file: $($hdd.Filename)"
    }
}

if ($args.Count -ne 4) {
    Feedback "le nombre de paramètres est incorrect, référez-vous à la description du script" -Oops
}

Test-HypervisorPlatform
Load-VMwareModules
Connect-VCenterServer
Manage-VM
Disconnect-VCenterServer
