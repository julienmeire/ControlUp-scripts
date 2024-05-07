Ce script permet de calculer la taille d'un profil utilisateur et calculant la somme du poids des dossiers et fichiers du profil utilisateur.

On récupère le chemin d'accès du profil utilisateur en utilisant la variable d'environnement correspondante.

On calcule la taille de l'intégralité des fichiers et on convertit cette valeur en Mb.

On crée une liste qui nous permettra de stocker les informations des fichiers.

On ajoute à cette liste le nom et la taille de chaque dossier.

On les trie par ordre décroissant et on ne garde que les 15 premiers.

On affiche le nom et la taille de ces 15 dossiers.
