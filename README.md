# Projet-Master-Uniformisation-des-informations-Office-365-et-Active-Directory

Ce projet a but de créer un programme/outils qui permettra uniformiser et de résoudre les problèmes de conflits entre l’un des principaux Annuaire (Active Directory) et l’un des principaux systèmes de Messagerie (Office 365), tous deux développés par Microsoft. Afin de former un annuaire propre et centralisé pour l’interconnexion des logiciels métiers qui gravite autour de l’environnement de l’entreprise au travers de connexion LDAP.

Attention, pour exécuter ce projet, il est nécessaire de modifier les polices d'exécution de PowerShell afin d'autoriser les scripts non-signés à s'exécuter.
Commande à entrer dans un Shell PowerShell Administrateur : Set-ExecutionPolicy Unrestricted

De plus pour que le script s'exécute sans problème, il est nécessaire de l'exécuter depuis un Serveur Active Directory possédant le connecteur Azure AD de déployer et de posséder des identifiants Administrateur d'un tenant Office 365.
