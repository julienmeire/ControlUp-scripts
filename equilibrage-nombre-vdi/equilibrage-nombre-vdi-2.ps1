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

# Fonction pour rééquilibrer les VM en fonction de la charge RAM
function Rebalance-VMs {
    $ramUsage = Get-RAMUsage
    $max = $ramUsage.Values | Measure-Object -Maximum
    $min = $ramUsage.Values | Measure-Object -Minimum
    $diff = $max.Maximum - $min.Minimum

    if ($diff -gt 25) { # Seuil de différence de pourcentage pour le rééquilibrage
        $hostMostRAMUsed = $ramUsage.GetEnumerator() | Where-Object {$_.Value -eq $max.Maximum} | Select-Object -First 1
        $hostLeastRAMUsed = $ramUsage.GetEnumerator() | Where-Object {$_.Value -eq $min.Minimum} | Select-Object -First 1

        $leastRAMHostDatastore = Get-Datastore -VMHost $hostLeastRAMUsed.Name | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1

        # Sélection des VM à déplacer
        $vmsToMove = Get-VM -Location $hostMostRAMUsed.Name | Where-Object {
            $_.PowerState -eq "PoweredOff"
        } | Select-Object -First [int]($diff / 5) 
        
        foreach ($vm in $vmsToMove) {
            $vmName = $vm.Name
            $vmConfig = Get-VM $vm | Select-Object -Property DiskGB, MemoryGB, NumCpu, NetworkName, GuestId
            Move-VM -VM $vm -Destination $hostLeastRAMUsed.Name -Datastore $leastRAMHostDatastore.Name -Confirm:$false
        }
    }
}

Connect-VCenter
Rebalance-VMs

# Déconnexion
Disconnect-VIServer -Server $serverAddress -Confirm:$false
