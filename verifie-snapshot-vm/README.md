Ce script permet de vérifier si une machine tourne avec un mauvais snapshot.

Le script prend en paramètre le nom du serveur vCenter, le nom d'utilisateur et mot de passe pour la connexion au vCenter, et le nom du snapshot qu'on souhaite vérifier.

On charge le module PowerCLI nécessaire pour les commandes VMware.

On se connecte au serveur VMware Horizon.

On récupère la liste des machines virtuelles du serveur.

On obtient les snapshots pour une machine virtuelle donnée.

On filtre les snapshots pour ne trouver que ceux qui ne correspondent pas au nom correct.

On affiche une information à l'écran si une VM est trouvée avec un snapshot incorrect.

On se déconnecte du serveur.
