Ce script permet de gérer l'état d'une pool VDI dans un environnement Horizon.

Il reçoit en paramètres le nom du pool VDI, le nom complet (FQDN) du serveur Horizon, une valeur booléenne pour activer ou désactiver le pool, et une valeur booléenne pour activer ou désactiver la provision de VDI dans le pool.

On commence par gérer l'affichage des messages et des erreurs dans la console. On affiche des messages normaux, des avertissements, ou on arrête le script en cas d'erreur.

On se connecte au serveur Horizon avec son nom passé en paramètre et un prompt qui demande les credentials de l'utilisateur.

On recherche un pool de bureaux spécifique en utilisant une requête sur le serveur Horizon, en utilisant le service de requête de VMware pour filtrer le pool par nom.

On modifie l'état d'activation d'un pool de bureaux ou de sa provision selon les paramètres $enable et $doProvisioning. On utilise les services API de VMware pour lire et mettre à jour la configuration du pool.
