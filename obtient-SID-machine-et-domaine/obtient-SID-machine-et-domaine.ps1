#obtient le SID de l'ordinateur
function Get-ComputerSID {
    $computerSID = (Get-WmiObject Win32_ComputerSystemProduct).SID
    return $computerSID
}

#obtient le SID de l'objet de domaine Active Directory
function Get-DomainSID {
    $domainSID = (Get-ADDomain).DomainSID
    return $domainSID
}

# Appel des fonctions et affichage des résultats
$computerSID = Get-ComputerSID
$domainSID = Get-DomainSID

Write-Host "SID de l'ordinateur: $computerSID"
Write-Host "SID de l'objet de domaine utilisé parl'Active Directory: $domainSID"
