# ControlUp-script
Repository regroupant les scripts PowerShell à utilisé dans ControlUp dans le cadre de mon tfe

Ces script sont utilisés pour collecter des informations ou agir directement sur les VM

Ils sont utilisés avec des triggers et automatisation mais peuvent également être exécutés en passant par la console ControlUp DX ou via ligne de commande PowerShell


## Exemple d'utilisation d'automatisation

Dans la console ControlUp, allez dans l'onglet "Automatisation" et cliquez sur "Scripts"
- Cliquez sur le bouton "Ajouter" pour créer un nouveau script
- Dans l'onglet "Détails du script", donnez un nom et une description au script
- Dans l'onglet "Code du script", collez le code du script
- Dans l'onglet "Arguments", ajoutez les arguments suivants :
- Argument 1 : serveur vCenter 
- Argument 2 : nom d'utilisateur 
- Argument 3 : mot de passe 
- Argument 4 : nom de la banque de données 
- Enregistrez le script

## Exemple d'utilisation des triggers

Dans la console ControlUp, allez dans l'onglet "Automatisation" et cliquez sur "Triggers"
- Cliquez sur le bouton "Ajouter" pour créer un nouveau déclencheur
- Dans l'onglet "Détails du déclencheur", donnez un nom et une description au déclencheur
- Dans l'onglet "Conditions", ajoutez les conditions suivantes :
- Condition 1 : « VM Host » « est l'un des » « <serveur vCenter> »
- Condition 2 : « Le nombre de machines virtuelles » « est supérieur à » « 35 »
- Dans l'onglet "Détails de l'action", sélectionnez "Exécuter un script" comme type d'action.
- Dans l'onglet "Script", précisez le chemin d'accès au script que vous souhaitez exécuter. Vous pouvez utiliser des variables dans le chemin du script pour référencer les données du déclencheur, telles que le nom de l'hôte ESXi ou le nombre de machines virtuelles.
- Dans l'onglet "Paramètres", spécifiez tous les paramètres requis par le script. Vous pouvez utiliser des variables dans les valeurs des paramètres pour référencer les données du déclencheur.
- Enregistrez le trigger


## Différence automatisation et activer un script avec un trigger :
Même effet pour les deux, déclencher un script lors d'un trigger permet de notifier lorsque les conditions ont été réunies.
