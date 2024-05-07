Ce script permet de récupérer les snapshots d'une vm et d'en afficher les informations.

Il reçoit en paramètre le nom du serveur vCenter, le nom et mot de passe pour la connexion au serveur, ainsi que le nom de la vm a inspectée.

On importe le module VMware PowerCLI.

On configure les options PowerCLI pour éviter les avertissements de sécurité.

On se connecte au vCenter.

On récupère le ou les snapshots de la vm spécifiée.

On vérifie s'il existe des snapshots et on affiche les informations s'il y en a.

On se déconnecte du vCenter.
