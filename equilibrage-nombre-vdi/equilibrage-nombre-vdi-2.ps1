param(
    [Parameter(Mandatory=$true)]
    [string]$serverAddress,

    [Parameter(Mandatory=$true)]
    [string]$username,

    [Parameter(Mandatory=$true)]
    [string]$password
)

# Conversion du mot de passe en SecureString
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Connexion à vCenter
function Connect-VCenter {
    Connect-VIServer -Server $serverAddress -Credential $credential
}

# Fonction pour obtenir la charge RAM des ESXi
function Get-RAMUsage {
    $esxiHosts = Get-VMHost
    $ramUsage = @{}
    foreach ($esxi in $esxiHosts) {
        $totalMemoryGB = $esxi.MemoryTotalGB
        $freeMemoryGB = $esxi.MemoryUsageGB
        $usedMemoryPercent = [math]::Round(($freeMemoryGB / $totalMemoryGB) * 100, 2)
        $ramUsage[$esxi.Name] = $usedMemoryPercent
    }
    return $ramUsage
}

# Fonction pour rééquilibrer les VDIs en fonction de la charge RAM
function Rebalance-VDIs {
    $ramUsage = Get-RAMUsage
    $max = $ramUsage.Values | Measure-Object -Maximum
    $min = $ramUsage.Values | Measure-Object -Minimum
    $diff = $max.Maximum - $min.Minimum

    if ($diff -gt 10) { # Seuil de différence de pourcentage pour le rééquilibrage
        $hostMostRAMUsed = $ramUsage.GetEnumerator() | Where-Object {$_.Value -eq $max.Maximum} | Select-Object -First 1
        $hostLeastRAMUsed = $ramUsage.GetEnumerator() | Where-Object {$_.Value -eq $min.Minimum} | Select-Object -First 1

        $leastRAMHostDatastore = Get-Datastore -VMHost $hostLeastRAMUsed.Name | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1

        # Sélection des VDIs à déplacer qui n'ont pas d'utilisateur actif et suivent le format nommé
        $vdisToMove = Get-VM -Location $hostMostRAMUsed.Name | Where-Object {
            $_.Name -match "^NEXIS-XD-T\d{2}$" -and $_.PowerState -eq "PoweredOff"
        } | Select-Object -First [int]($diff / 2) # On déplace un nombre de VDIs basé sur la moitié de la différence de pourcentage

        foreach ($vdi in $vdisToMove) {
            Move-VM -VM $vdi -Destination $hostLeastRAMUsed.Name -Datastore $leastRAMHostDatastore.Name -Confirm:$false
        }
    }
}

Connect-VCenter
Rebalance-VDIs

# Déconnexion
Disconnect-VIServer -Server $serverAddress -Confirm:$false
