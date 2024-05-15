Ce script permet d'obtenir le SID d'une machine et le SID de l'objet attribué par l'Active Directory pour cette machine.

Pour utiliser ce script, il faut que la machine ait RSAT (Remote Server Administration Tools) installé. Sans cela, impossible d'utiliser les commandes AD dans PowerShell.

Le SID d'une machine est ce qui permet son authentification dans un environnement Windows. Cet SID est généré lors de l'installation de Windows.

Le SID d'une machine par un AD est ce qui permet de l'authentifier auprès de ce dernier.

La première fonction va chercher le SID de la machine.

La deuxième s'occupe de chercher le SID donné par l'AD.

On affiche ensuite ces deux résultats.
