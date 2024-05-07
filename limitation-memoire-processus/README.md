Ce script permet de limiter l'usage de la mémoire à un certain processus.
Il nécessite d'utiliser PowerShell en mode administrateur.

Ce script permet de limiter l'usage de la mémoire à un certain processus.
Il nécessite d'utiliser PowerShell en mode administrateur.

On convertir la taille de la part de mémoire en octets, les fonctions API Windows nécessitent une taille spécifiée comme tel.

On récupère le processus par son Pid.

Pour accéder aux API Windows, on utilise Add-Type pour définir une classe statique "NativeMethods" contenant une méthode SetProcessWorkingSize. Cette méthode est importée de kernel32.dll (une bibliothèque standard Windows).

On appelle l'API et on tente de limiter la taille mémoire accordée au processus.

Un message de confirmation apparaît sur l'opération est un succès. Dans le cas contraire, un message d'erreur apparaît.
