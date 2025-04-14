Import-Module $PSScriptRoot\Log.ps1

#Initialisation Variable Global
$ListeUtilisateurs = @()

#Récupère la variable $logFilePath dans Main.ps1
$logFilePath = $script:logFilePath


#Fonction Recursif pour Demander puis essayer d'importer le fichier CSV
function ImporterFichierCSV {
    param (
        [Parameter(Mandatory = $true)]
        [string]$NomFichier
    )

    #Essaie d'importer le fichier CSV
    try {
        $csv = Import-Csv -Path $NomFichier -Delimiter ";"
    }
    catch {
        Write-Log -logFilePath $logFilePath -message "Erreur lors de l'importation du fichier CSV : $_"
        Write-Host "Erreur lors de l'importation du fichier CSV : $_"
        Write-Host "Verifiez le chemin du fichier"
        ImporterFichierCSV
    }
    
    return $csv
}

function ParcourirFichierCSV {
    $ListeUtilisateurs = @()
    $Compteur = 0

    #Parcourir le fichier CSV et ajouter les utilisateurs à la liste
    foreach ($user in $csv) {
        $Utilisateur = New-Object PSObject -Property @{
            UserNbr           = $Compteur
            UserName          = $user.UserAD
            UserPrincipalName = $user.UserAD + "@" + $NomDomaine
            ProxyAddresses    = "SMTP:" + $user.UserAD + "@" + $NomDomaine
            Mail              = $user.UserAD + "@" + $NomDomaine
            MFA               = $user.MFA
        }
        $Compteur++
        $ListeUtilisateurs += $Utilisateur

    
        #Affiche barre de progression
        #Write-Progress -Activity "Traitement des utilisateurs" -Status "Traitement de l'utilisateur $($user.UserAD)" -PercentComplete (($csv.IndexOf($user) / $csv.Count) * 100)


    }

    return $ListeUtilisateurs
}

function ParcourirListeUtilisateurs {
    param (
        [Parameter(Mandatory = $true)]
        [array]$ListeUtilisateurs
    )

    #Parcourir la liste des utilisateurs
    foreach ($user in $ListeUtilisateurs) {
        Write-Host "---------------------------------"
        Write-Host "Numero de l'utilisateur : $($user.UserNbr)"
        Write-Host "Nom de l'utilisateur : $($user.UserName)"
        Write-Host "UserPrincipalName : $($user.UserPrincipalName)"
        Write-Host "ProxyAddresses : $($user.ProxyAddresses)"
        Write-Host "Mail : $($user.Mail)"
        
    }
}







