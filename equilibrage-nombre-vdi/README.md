Ce script permet de rééquilibrer le nombre de VM sur des serveurs esxi.

Il a été utilisé dans le cadre de serveurs ayant leur stockage en localhost, supprimant les VDI une fois déconnectée et les créant sur un autre esxi déterminé par un cycle round-robin.

Le script reçoit trois paramètres, l'adresse IP ou nom du serveur vCenter à joindre, le nom et le mot de passe qui permettront de s'y connecter.

On convertit le mot de passe donné en SecureString. Cela permet de crypter le mot de passe avec les informations de l'ordinateur et de l'utilisateur.
Cette nouvelle chaine de caractère ne peut être utilisée que par la machine et l'utilisateur qui l'a générée.

Le script se connecte ensuite au vCenter avec les informations de connexion fournies.

On déclare une fonction qui récupère les objets de type VDI en parcourant les esxi.

On en déclare une qui va équilibrer la charge de VDI sur les serveurs si le delta des VDI entre l'esxi en comptant le plus et celui en comptant le moins excède 20%.
Ce nombre est récupéré par la fonction Get-VDIcount créée précédemment.
On détermine les esxi qui en compte le plus et le moins et sur lesquelles les opérations seront effectuées.
On sélectionne les VDI inutilisés à déplacer.
On récupère les informations de chacune des VDI à déplacer et on les réutilise pour les créer sur l'esxi comptant le moins de VDI.

Une fois les fonctions exécutées, on se déconnecte du vCenter.

