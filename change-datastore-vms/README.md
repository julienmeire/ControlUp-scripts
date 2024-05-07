Ce script permet de migrer les disques locaux d'une vm vers un datastore.

Ce script reçoit comme paramètres le nom de l'hyperviseur utilisé, le nom du vCenter, le nom de la vm et le nom du datastore.

On gère les messages et les erreurs.

On vérifie le support de l'hyperviseur.

On importe les modules nécessaires.

On se connecte au serveur VCenter.

On récupère les informations de la vm et de ses disques durs.

On migre les disques durs vers le nouveau datastore.

On affiche les informations de localisation actuelles des disques durs.

On se déconnecte du vCenter.
