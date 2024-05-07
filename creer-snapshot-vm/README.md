Ce script permet de créer un snapshot pour la VM cible sur un hyperviseur VMWARE.

On donne en paramètres le nom ou adresse du vCenter, le nom de la VM, le nom du snapshot que l'on souhaite créé, la descritpion pour ce même snapshot.
Dans le cas où aucun nom et description ne sont fournis pour le snapshot, des informations par défaut seront fournies.

On charge les modules VMware PowerCLI nécessaires. Si les modules ne peuvent pas être chargés, le script s'arrête avec un message d'erreur.

On établit une connexion avec le serveur VCenter spécifié. En cas d'échec de la connexion, un message d'erreur est affiché et le script s'arrête.

On crée un snapshot de la machine virtuelle spécifiée. Si il en existe déjà un avec le même nom, le script s'arrête et signale que le problème. Sinon, il crée le snapshot et affiche ses détails.

On se déconnecte du vCenter.
