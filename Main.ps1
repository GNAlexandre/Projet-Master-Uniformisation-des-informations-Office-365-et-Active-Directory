#Importation le module Import
Import-Module $PSScriptRoot\Connect.ps1
Import-Module $PSScriptRoot\Import.ps1
Import-Module $PSScriptRoot\Sync.ps1
Import-Module $PSScriptRoot\Log.ps1



### Début Initialisation Module Log ###

#Appel de la fonction Create-LogFile
$logFilePath = Create-LogFile -logDirectory "C:\tmp\Logs" -logFileName "Log"

#Appel de la fonction Initialize-Log
Initialize-Log -logFilePath $logFilePath

#Appel de la fonction Write-Log
Write-Log -logFilePath $logFilePath -message "Début du programme"

### Fin Initialisation Module Log ###





### Début Initialisation Module Import ###

#Appel de la fonction ImporterFichierConfiguration
$NomDomaine, $NomFichier, $LoginOffice365, $PasswordOffice365 = ImporterFichierConfiguration -CheminFichier (DemanderNomFichierConfiguration)

#Appel de la fonction InitialiserAzureAD
InitialiserAzureAD -LoginOffice365 $LoginOffice365 -PasswordOffice365 $PasswordOffice365

#Appel de la fonction InitialiserMsolService
InitialiserMsolService -LoginOffice365 $LoginOffice365 -PasswordOffice365 $PasswordOffice365

#Appel de la fonction InitialiserImportExcel
InitialiserImportExcel

#Appel de la fonction InitialiserActiveDirectory
InitialiserActiveDirectory

### Fin Initialisation Module Import ###





### Début Initialisation Module Import ###

#Appel de la fonction ImporterFichierCSV
$csv = ImporterFichierCSV -NomFichier $NomFichier

#Appel de la fonction ParcourirFichierCSV
$ListeUtilisateurs = ParcourirFichierCSV

Write-Host "--- Liste des utilisateurs ---"

#Appel de la fonction ParcourirListeUtilisateurs
ParcourirListeUtilisateurs -ListeUtilisateurs $ListeUtilisateurs

### Fin Initialisation Module Import ###









#Fonction menu de sélection
function Menu {
    param (
        [Parameter(Mandatory = $true)]
        [array]$ListeUtilisateurs
    )
    Write-Host "--- Menu de selection ---"
    Write-Host "1. Lancer le programme pour tous les utilisateurs"
    Write-Host "2. Selectionner plusieurs utilisateurs a traiter"
    Write-Host "3. Selectionner un utilisateur a traiter"
    Write-Host "4. Modifier les informations d'un utilisateur"
    Write-Host "5. Supprimer un utilisateur de la liste"
    Write-Host "6. Afficher la liste des utilisateurs"
    Write-Host "7. Verifier la concordance des informations"
    Write-Host "8. Quitter"
    Write-Host "--- Fin du menu de selection ---"
    $choix = Read-Host "Entrez votre choix"

    switch ($choix) {
        1 {
            ProgrammeDeSynchronisation -ListeUtilisateurs $ListeUtilisateurs
            Menu -ListeUtilisateurs $ListeUtilisateurs 
        }
        2 {
            #Entrer les numeros des utilisateurs
            $numeros = Read-Host "Entrez les numeros des utilisateurs separes par des virgules"
            $numeros = $numeros -split ","
            $users = @()
            foreach ($numero in $numeros) {
                $user = $ListeUtilisateurs | Where-Object { $_.UserNbr -eq $numero }
                $users += $user
            }
            ParcourirListeUtilisateurs -ListeUtilisateurs $users

            #Demander si les utilisateurs sélectionnés sont corrects
            $choix = Read-Host "Voulez-vous traiter ces utilisateurs ? (O/N)"
            if ($choix -eq "O") {
                ProgrammeDeSynchronisation -ListeUtilisateurs $users
            }
            Menu -ListeUtilisateurs $ListeUtilisateurs
        }
        3 {
            #Entrer le numero de l'utilisateur
            $numero = Read-Host "Entrez le numero de l'utilisateur"

            #Parcours la liste des utilisateurs et renvoi l'utilisateur ayant UserNbr = $numero
            $user = $ListeUtilisateurs | Where-Object { $_.UserNbr -eq $numero }
            ParcourirListeUtilisateurs -ListeUtilisateurs $user

            #Demander si l'utilisateur veut traiter cet utilisateur
            $choix = Read-Host "Voulez-vous traiter cet utilisateur ? (O/N)"
            if ($choix -eq "O") {
                ProgrammeDeSynchronisation -ListeUtilisateurs $user
            }
            Menu -ListeUtilisateurs $ListeUtilisateurs
        }
        4 {
            #Entrer le numero de l'utilisateur
            $numero = Read-Host "Entrez le numero de l'utilisateur"

            #Parcours la liste des utilisateurs et renvoi l'utilisateur ayant UserNbr = $numero
            $user = $ListeUtilisateurs | Where-Object { $_.UserNbr -eq $numero }
            ParcourirListeUtilisateurs -ListeUtilisateurs $user

            #Demander si l'utilisateur veut modifier cet utilisateur
            $choix = Read-Host "Voulez-vous modifier cet utilisateur ? (O/N)"
            if ($choix -eq "O") {
                #Entrer les nouvelles informations
                $UserNameBis = Read-Host "Entrez le nouveau UserName"
                if ($UserNameBis -ne "") {
                    $user.UserName = $UserNameBis
                }
                $UserPrincipalNameBis = Read-Host "Entrez le nouveau UserPrincipalName"
                if ($UserPrincipalNameBis -ne "") {
                    $user.UserPrincipalName = $UserPrincipalNameBis
                }
                $ProxyAddressesBis = Read-Host "Entrez le nouveau ProxyAddresses"
                if ($ProxyAddressesBis -ne "") {
                    $user.ProxyAddresses = $ProxyAddressesBis
                }
                $MailBis = Read-Host "Entrez le nouveau Mail"
                if ($MailBis -ne "") {
                    $user.Mail = $MailBis
                }

            }

            Menu -ListeUtilisateurs $ListeUtilisateurs
        }

        5 {
            #Entrer le numero de l'utilisateur
            $numero = Read-Host "Entrez le numero de l'utilisateur"

            #Parcours la liste des utilisateurs et renvoi l'utilisateur ayant UserNbr = $numero
            $user = $ListeUtilisateurs | Where-Object { $_.UserNbr -eq $numero }
            ParcourirListeUtilisateurs -ListeUtilisateurs $user

            #Demander si l'utilisateur veut supprimer cet utilisateur
            $choix = Read-Host "Voulez-vous supprimer cet utilisateur ? (O/N)"
            if ($choix -eq "O") {
                $ListeUtilisateurs = $ListeUtilisateurs | Where-Object { $_.UserNbr -ne $numero }
            }
            Menu -ListeUtilisateurs $ListeUtilisateurs
        }
        6 {
            ParcourirListeUtilisateurs -ListeUtilisateurs $ListeUtilisateurs
            Menu -ListeUtilisateurs $ListeUtilisateurs
        }
        7 {
            $cpt = 0
            foreach ($user in $ListeUtilisateurs) {
                
                $temp = VerifierConcordance -user $user

                #Afficher les utilisateurs qui ne sont pas concordants
                if ($temp -eq $false) {
                    Write-Host "Les informations de l'utilisateur $($user.UserName) n'est pas concordant"
                    Write-Host "---------------------------------"
                    $cpt++

                }

            }
            if ($cpt -eq 0) {
                Write-Host "Toutes les informations sont concordantes"
            }
            else {
                Write-Host "Il y a $cpt utilisateur(s) dont les informations ne sont pas concordantes"
            }
            Write-Host "---------------------------------"

            Menu -ListeUtilisateurs $ListeUtilisateurs
        }

        8 {
            Write-Host "Fin du programme"
            try {
                #Déconnexion de AzureAD
                Disconnect-AzureAD
                #Déconnexion de MSOnline
                Disconnect-MsolService
            }
            catch {
                Write-Host "Erreur lors de la déconnexion des services"
                Write-Log -logFilePath $logFilePath -message "Erreur lors de la déconnexion des services : $_"
            }
            
        }
        default {
            Write-Host "Choix invalide"
            Menu -ListeUtilisateurs $ListeUtilisateurs
        }
    }
}




#Appel de la fonction Menu
Menu -ListeUtilisateurs $ListeUtilisateurs


#Activer syncro AzureAD
#Set-MsolDirSyncEnabled -EnableDirSync $true -Force

#Permet de forcer la synchro AD vers Azure
#Start-ADSyncSyncCycle -PolicyType Delta