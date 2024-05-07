Ce script permet d'allumer une vm sous un hyperviseur VMWARE ou HYPER-V.

Il reçoit en paramètre le nom de la vm a allumée.

Il commence par détecter quel sur quel hyperviseur tourne la vm.

En fonction du résultat, il utilise les bonnes commandes pour allumer la vm.

Un message de réussite ou d'échec apparaît une fois l'opération finie.


**la deuxième version du script est un essai pour obtenir un script compatible avec le plus d'hyperviseur possible,
Mais que le script fonctionne avec KVM, il faut d'exécuter PowerShell sur un système Linux avec le module virsh disponible ou sous Windows avec un accès SSH à un serveur Linux où virsh est installé. 

L'utilisation du module XenServer nécessite qu'on ait installé un module PowerShell compatible pour Citrix XenServer. Il n'est pas officiel, il faut en trouver un créer par la communauté ou le faire soi-même.
