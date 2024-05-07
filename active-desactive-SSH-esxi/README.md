Ce script permet d'activer ou désactiver le service SSH sur un hôte esxi.

Le script reçoit en paramètres le nom ou adresse du serveur vCenter, le nom d'utilisateur et mot de passe du vCenter, le nom de l'hôte esxi, et l'action à entreprendre.

On charge les commandes PowerCLI nécessaires.

On configure PowerCLI pour ignorer les avertissements de certificat non approuvé.

On utilise les identifiants fournis pour se connecter à votre serveur vCenter.

On cherche le service SSH (TSM-SSH) sur l'hôte spécifié et le démarre ou l'arrête en fonction de l'action spécifiée.

On se déconnecte du serveur vCenter
