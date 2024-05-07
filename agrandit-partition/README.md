Ce script permet d'utiliser tout l'espace disque disponible pour agrandir une partition.

Il est prévu de fonctionner avec le script "recupere-informations-partitions-disque.ps1" qui nous donne les informations sur la place utilisé et libre des partitions et du disque.

Ce script prend en paramètre la lettre du drive pour laquelle la partition doit occuper tout l'espace disque disponible.

On commence par gérer précisément les exceptions et erreurs.

On récupère la partition correspondante à la lettre drive fournie en paramètre et calcule la place disponible.

S'il y a de la place disponible, on agrandit la partition pour occuper toute la place disque disponible.

On renvoie une erreur s'il n'y a pas de place disponible ou si l'opération a échouée.
