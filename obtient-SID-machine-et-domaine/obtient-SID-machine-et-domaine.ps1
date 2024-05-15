function Get-ComputerSID {
    try {
        $computerSID = (Get-WmiObject Win32_ComputerSystemProduct).IdentifyingNumber
        if (-not $computerSID) {
            throw "SID de l'ordinateur non trouve"
        }
        return $computerSID
    } catch {
        Write-Host "Erreur lors de la recuperation du SID de l'ordinateur : $_"
    }
}

function Get-DomainSID {
    try {
        # Tente d'importer le module Active Directory
        Import-Module ActiveDirectory -ErrorAction Stop
        $domainSID = (Get-ADDomain).DomainSID
        if (-not $domainSID) {
            throw "SID de domaine non trouve"
        }
        return $domainSID
    } catch {
        Write-Host "Erreur lors de la recuperation du SID de domaine : $_"
    }
}

# Appel des fonctions et affichage des résultats
$computerSID = Get-ComputerSID
$domainSID = Get-DomainSID

Write-Host "SID de l'ordinateur: $computerSID"
Write-Host "SID de l'objet de domaine utilise par l'Active Directory: $domainSID"
