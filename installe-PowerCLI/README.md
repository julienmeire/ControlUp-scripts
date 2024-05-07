Ce script permet d'installer et de configurer le module PowerCLI de VMWARE pour tous les utilisateurs d'une machine.

Il est nécessaire d'être en mode admin pour exécuter le script.

On Vérifie si PowerShellGet est à jour, il est nécessaire pour installer des modules depuis le PowerShell Gallery.

On installe le module VMware PowerCLI en utilisant Install-Module.

On configure le module et ses préférences globales, comme ignorer les certificats non valides et désactiver la participation au programme d'amélioration de l'expérience client (CEIP).

On crée un dossier pour tous les utilisateurs qui contiendra les paramètres de configurations de PowerCLI.

On vérifie que l'installation s'est bien déroulée.
