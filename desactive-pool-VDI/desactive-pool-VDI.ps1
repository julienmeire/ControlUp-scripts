[CmdletBinding()]
Param(
    [string]$strHVPoolName,
    [string]$strHVConnectionServerFQDN,
    [bool]$enable = $false,
    [bool]$doProvisioning = $false
)

#définit le mode de verbosité, la gestion des erreurs et l'affichage des progressions
$VerbosePreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

#gère les messages d'erreurs 
function Out-CUConsole {
    Param (
        [string]$Message,
        [switch]$Warning,
        [switch]$Stop,
        $Exception
    )
    if ($Exception) {
        Write-Warning "$Message`n$($Exception.CategoryInfo.Category)`nRéférez vous au tableau pour vous renseignez sur l'erreur."
        Throw $Exception
    }
    elseif ($Stop) {
        Write-Warning "Tout ne s'est pas passé comme prévu,`n$Message"
        Throw $Message
    }
    elseif ($Warning) {
        Write-Warning $Message
    }
    else {
        Write-Output $Message
    }
}

#se connecte au serveur Horizon
function Connect-HorizonConnectionServer {
    param(
        [string]$HVConnectionServerFQDN
    )
    try {
        # Demander les informations d'identification à l'utilisateur
        $CredsHorizon = Get-Credential -Message "Renseigner vos identifiants Horizon"
        
        # Tenter de se connecter au serveur Horizon en utilisant les informations d'identification fournies
        $objHVConnectionServer = Connect-HVServer -Server $HVConnectionServerFQDN -Credential $CredsHorizon
        return $objHVConnectionServer
    }
    catch {
        Out-CUConsole -Message 'Impossible de se connecter au serveur Horizon.' -Exception $_
    }
}


#cherche le pool mentionné en paramètre
function Get-HVDesktopPool {
    param (
        [string]$HVPoolName,
        [VMware.VimAutomation.HorizonView.Impl.V1.ViewObjectImpl]$HVConnectionServer
    )
    try {
        $queryService = New-Object VMware.Hv.QueryServiceService
        $defn = New-Object VMware.Hv.QueryDefinition
        $defn.queryEntityType = 'DesktopSummaryView'
        $defn.Filter = New-Object VMware.Hv.QueryFilterEquals -property @{ 'memberName' = 'desktopSummaryData.displayName'; 'value' = $HVPoolName }
        $queryResults = ($queryService.queryService_create($HVConnectionServer.extensionData, $defn)).results
        $queryService.QueryService_DeleteAll($HVConnectionServer.extensionData)
        if (!$queryResults) {
            Out-CUConsole -Message "Pool VDI introuvable" -Stop
            exit
        }
        return $queryResults
    }
    catch {
        Out-CUConsole -Message 'Echec lors de la récupération du pool VDI.' -Exception $_
        exit
    }
}

#modifie l'état du pool
function Set-PoolEnablement {
    param (
        [object]$HVPool,
        [VMware.VimAutomation.HorizonView.Impl.V1.ViewObjectImpl]$HVConnectionServer,
        [bool]$Enable,
        [string]$Operation,
        [string]$ProvisioningText
    )
    try {
        $poolname = $HVPool.DesktopSummaryData.name
        $desktopservice = new-object VMware.Hv.desktopService
        $desktophelper = $desktopservice.read($HVConnectionServer.extensionData, $HVPool.id)
        $doUpdate = $false

        if (-Not [string]::IsNullOrEmpty($ProvisioningText)) {
            $desktophelper.getAutomatedDesktopDataHelper().getVirtualCenterProvisioningSettingsHelper().setEnableProvisioning($Enable)
            $doUpdate = $true
        }
        else {
            $desktophelper.getDesktopSettingsHelper().setEnabled($Enable)
            $doUpdate = $true
        }
        if ($doUpdate) {
            $desktopservice.update($HVConnectionServer.extensionData, $desktophelper)
            Out-CUConsole -Message "$($Operation) avec succès $ProvisioningText `"$poolname`"."
        }
    }
    catch {
        Out-CUConsole -Message "Echec de l'opération $($Operation) pour le pool `"$poolname`"$ProvisioningText." -Exception $_
    }
}

#exécution des fonctions
try {
    Load-VMwareModules -Components @('VimAutomation.HorizonView')
    $CredsHorizon = Get-CUStoredCredential -System 'HorizonView'
    $objHVConnectionServer = Connect-HorizonConnectionServer -HVConnectionServerFQDN $strHVConnectionServerFQDN
    $objHVPool = Get-HVDesktopPool -HVPoolName $strHvPoolName -HVConnectionServer $objHVConnectionServer
    $actionBase = if ($enable) { 'enabl' } else { 'disabl' }
    Set-PoolEnablement -HVPool $objHVPool -HVConnectionServer $objHVConnectionServer -Enable:($actionBase -ieq 'enabl') -Operation $actionBase.ToLower() -ProvisioningText $($doProvisioning ? ' provisioning' : '')
}
catch {
    throw $_
}
