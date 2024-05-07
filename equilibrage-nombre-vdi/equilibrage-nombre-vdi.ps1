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

# Fonction pour obtenir le nombre de VDI par ESXi
function Get-VDICounts {
    $esxiHosts = Get-VMHost
    $vdiCounts = @{}
    foreach ($esxi in $esxiHosts) {
        $vdiCount = (Get-VM -Location $esxi | Where-Object { $_.Name -like "*VDI*" }).Count
        $vdiCounts[$esxi.Name] = $vdiCount
    }
    return $vdiCounts
}

# Fonction pour rééquilibrer les VDI
function Rebalance-VDIs {
    $vdiCounts = Get-VDICounts
    $max = $vdiCounts.Values | Measure-Object -Maximum
    $min = $vdiCounts.Values | Measure-Object -Minimum
    $diff = $max.Maximum - $min.Minimum

    if ($diff / $min.Minimum -gt 0.2) {
        $hostMostVDIs = $vdiCounts.GetEnumerator() | Where-Object {$_.Value -eq $max.Maximum} | Select-Object -First 1
        $hostLeastVDIs = $vdiCounts.GetEnumerator() | Where-Object {$_.Value -eq $min.Minimum} | Select-Object -First 1

        $leastVDIHostDatastore = Get-Datastore -VMHost $hostLeastVDIs.Name | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1

        # Sélection des VDI inutilisées à déplacer
        $vdisToMove = Get-VM -Location $hostMostVDIs.Name | Where-Object {
            $_.Name -like "*VDI*" -and $_.PowerState -eq "PoweredOff"
        } | Select-Object -First [int]($diff * 0.5)

        foreach ($vdi in $vdisToMove) {
            $vdiName = $vdi.Name
            $vmConfig = Get-VM $vdi | Select-Object -Property DiskGB, MemoryGB, NumCpu, NetworkName, GuestId
            Remove-VM -VM $vdi -DeletePermanently:$true -Confirm:$false
            # Création de la nouvelle VM sur l'hôte et datastore avec le moins de VDI
            New-VM -Name $vdiName -VMHost $hostLeastVDIs.Name -Datastore $leastVDIHostDatastore.Name -DiskGB $vmConfig.DiskGB -MemoryGB $vmConfig.MemoryGB -NumCpu $vmConfig.NumCpu -NetworkName $vmConfig.NetworkName -GuestId $vmConfig.GuestId -CD -Confirm:$false
        }
    }
}

Connect-VCenter
Rebalance-VDIs

# Déconnexion
Disconnect-VIServer -Server $serverAddress -Confirm:$false
