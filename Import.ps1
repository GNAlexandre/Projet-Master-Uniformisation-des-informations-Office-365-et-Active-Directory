Import-Module $PSScriptRoot\Log.ps1

#Initialisation Variable Global
$ListeUtilisateurs = @()

#Récupère la variable $logFilePath dans Main.ps1
$logFilePath = $script:logFilePath


# Fonction pour importer un fichier CSV et parcourir son contenu
function ImporterEtParcourirFichierCSV {
    param (
        [Parameter(Mandatory = $true)]
        [string]$NomFichier,
        [Parameter(Mandatory = $true)]
        [string]$NomDomaine
    )

    # Initialisation de la liste des utilisateurs
    $ListeUtilisateurs = @()
    $Compteur = 0

    # Essaie d'importer le fichier CSV
    try {
        $csv = Import-Csv -Path $NomFichier -Delimiter ";"
    }
    catch {
        # Log et affichage de l'erreur en cas d'échec
        Write-Log -logFilePath $logFilePath -message "Erreur lors de l'importation du fichier CSV : $_"
        Write-Host "Erreur lors de l'importation du fichier CSV : $_"
        Write-Host "Vérifiez le chemin du fichier"
        return $null
    }

    # Parcourir le fichier CSV et ajouter les utilisateurs à la liste
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
    }

    # Retourne la liste des utilisateurs
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







