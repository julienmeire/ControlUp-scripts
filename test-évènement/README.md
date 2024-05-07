Ce script permet de générer un nouvel évènement dans le journal d'évènements de Windows.

Il est très utile pour tester les capacités et bon fonctionnement des triggers.

Il reçoit par défaut des paramètres mais on peut également lui en donner des spécifiques à savoir, la source de l'évènement, son id, son type, un nom et un message.

L'API de Windows permettant l'inscription d'un nouvel évènement dans le journal, s'attend à un type bien spécifique, on rend le paramètre du type compatible avec l'API.

On vérifie ensuite la source de l'évènement et si elle n'existe pas encore, on la crée.

On essaie d'écrire un nouvel évènement avec nos informations, on attrape les potentiels erreurs et affiche un message d'erreur.
