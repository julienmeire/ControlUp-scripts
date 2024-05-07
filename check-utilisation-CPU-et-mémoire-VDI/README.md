Ce script est utilisé pour surveiller et rapporter l'utilisation du processeur (CPU) et de la mémoire des VDI dans un environnement utilisant ControlUp.

On commence par importer le module ControlUp qui sera nécessaire à l'exécution de commandes spécifiques qui iront chercher les informations des VDI.

On crée un tableau qui nous servira à stocker les données des VDI.

On récupère le taux d'utilisation du CPU et de la mémoire pour chaque VDI.

On enregistre ces informations en tant que nouvel objet dans le tableau.

On affiche le tableau et son contenu dans la console.

On enregistre le tableau dans un fichier VDIUsageReport.csv et confirme via un message le bon déroulement de l'enregistrement.
