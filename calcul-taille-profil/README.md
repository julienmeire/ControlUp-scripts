Ce script permet de récupérer les profils utilisateurs sur une machine et calcul la taille de chaque profil.
Pensé pour être utilisé sur un XenApp.

On récupère les profils utilisateurs que ne sont pas des comptes spéciaux.

Pour chaque profil, on calcule la taille totale des fichiers en parcourant récursivement chaque répertoire.

On affiche les informations (SID du profil, chemin du profil et la taille totale du profil en MB) pour chaque profil utilisateur, triés par la taille totale des fichiers de manière décroissante.
