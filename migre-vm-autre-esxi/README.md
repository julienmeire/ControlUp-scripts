Ce script permet de migrer une vm d'un hôte esxi à un autre.

Il reçoit en paramètre le nom de la vm à migrer, le nom ou adresse de esxi source et destination, le nom ou adresse du vCenter, le nom et mot de passe pour la connexion au vCenter.

On importe le module VMware PowerCLI.

On se connecte au vCenter.

On vérifie que la vm et l'esxi destination existent tous les deux.

On récupère la vm.

On récupère l'esxi sur lequel se fera la migration.

On se déconnecte du vCenter.
