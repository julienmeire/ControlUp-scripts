Ce script permet de surveiller l'utilisation du CPU par un processus et de définir un seuil. 
Une fois ce seuil atteint par le processus, on réduit sa priorité pour lui allouer moins de ressources du CPU.

Le script reçoit en paramètre le pid du processus et un seuil qui servira de limite à ne pas dépasser.

On crée une boucle qui surveille continuellement le processus.

On récupère ses informations grâce à son pid.

On vérifie qu'il ne dépasse pas le seuil et si c'est le cas on diminue sa priorité.
