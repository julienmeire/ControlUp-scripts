Ce script permet de mettre en veille des vm allumées mais inactive depuis un certain temps, mais également de forcer la mise hors tension des vm en état de veille depuis un certain moment.

Ce script nécessite de recevoir en paramètre le nom du serveur, le nom et mot de passe du compte vcenter.

On importe le module VMware PowerCLI

On se connecte au vCenter.

On définit les durées d'inactivités maximales.

On récupère les vm sur l'hôte esxi.

On vérifie l'état des vm et en fonction de cet état et du temps passé sans activité, la vm se met en veille (état suspendu) ou hors tension.

On se déconnecte du vCenter.
