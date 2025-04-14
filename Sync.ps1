Import-Module $PSScriptRoot\Log.ps1
#Récupère la variable $logFilePath dans Main.ps1
$logFilePath = $script:logFilePath


Function ProgrammeDeSynchronisation {
    param (
        [Parameter(Mandatory = $true)]
        [array]$ListeUtilisateurs
    )

    foreach ($user in $ListeUtilisateurs) {

        try {
                #Modifier information de l'utilisateur dans l'AD
            Set-ADUser -Identity $user.UserName -Replace @{UserPrincipalName = $user.UserPrincipalName; ProxyAddresses = $user.ProxyAddresses; Mail = $user.Mail }

            #Ajout de l'utilisateur à un groupe
            AjouterUtilisateurGroupe -NomGroupe "GroupeSync_AzureAD" -NomUtilisateur $user.UserName
            
            #Recupération de l'ObjectID dans Azure
            $Azure = Get-AzureADUser -ObjectId $user.UserPrincipalName | Select-Object ObjectId

            #Conversion de l'ObjectGUID en base64
            $UserAD = Get-ADUser -Identity $user.UserName
            $ImmutableId = [System.Convert]::ToBase64String($UserAD.ObjectGUID.tobytearray())
            Write-Host $Azure.ObjectId, $UserAD, $ImmutableId

            #Modification de l'ImmutableID dans Azure
            Set-AzureADUser -ObjectId $Azure.ObjectId -ImmutableId $ImmutableId


            #Correction Bug de Synchro 

            #Copie du contenu de l'objectGUID dans l'attribut msDS-ConsistencyGuid
            #$UserAD = Get-ADUser -Identity $user.UserName
            #$ConsistencyGuid = $UserAD.ObjectGUID
            #Set-ADUser -Identity $user.UserName -Replace @{"msDS-ConsistencyGuid" = $ConsistencyGuid }
            

            #Ajout de la licence Office365
            #try {
            #    Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses "AAAFRANCECARS:AAD_PREMIUM"
            #}
            #catch {
            #    Write-Host "Erreur lors de l'ajout de la licence Office365 à l'utilisateur $($user.UserName)"
            #}



            #Ajout de l'utilisateur au groupe de sécurité
            try {
                if ($user.MFA -eq "OUI") {
                    Add-AzureADGroupMember -ObjectId "ce1697b8-0bda-4082-ad36-09570b83b589" -RefObjectId $Azure.ObjectId
                }
                else {
                    Add-AzureADGroupMember -ObjectId "ac7dc845-b9fa-4e33-972a-1aa02a096085" -RefObjectId $Azure.ObjectId
                }
            }
            catch {
                Write-Host "Erreur lors de l'ajout de l'utilisateur au groupe de sécurité dans Office365 pour l'utilisateur $($user.UserName)"
                Write-Log -logFilePath $logFilePath -message "Erreur lors de l'ajout de l'utilisateur au groupe de sécurité dans Office365 pour l'utilisateur $($user.UserName) : $_"
            }
            

            #Affiche barre de progression
            Write-Progress -Activity "Traitement des utilisateurs" -Status "Traitement de l'utilisateur $($user.UserName)" -PercentComplete (($ListeUtilisateurs.IndexOf($user) / $ListeUtilisateurs.Count) * 100)
        
        }
        catch {
            Write-Host "Erreur lors de la modification de l'utilisateur $($user.UserName) dans l'AD : $_"
            Write-Log -logFilePath $logFilePath -message "Erreur lors de la modification de l'utilisateur $($user.UserName) dans l'AD : $_"
        }
            
    }
}

#Fonction Vérification de concordance des informations
#Cette fonction a pour but de vérifier que les informations dans l'AD et dans AzureAD sont concordantes
function VerifierConcordance {
    param (
        [Parameter(Mandatory = $true)]
        #Prends en paramètre un utilisateur
        [object]$user
    )

    #Vérifie l'existance de l'utilisateur dans l'AD
    try {
        $UserAD = Get-ADUser -Identity $user.UserName
    }
    catch {
        if ($UserAD -eq $null) {
            Write-Host "L'utilisateur $($user.UserName) n'existe pas dans l'AD"
            return $false
        }
    }

    #Vérifie l'existance de l'utilisateur dans Office365
    try {
        $UserAzureAD = Get-AzureADUser -ObjectId $user.UserPrincipalName 
    }
    catch {
        if ($UserAzureAD -eq $null) {
            Write-Host "L'utilisateur $($user.UserName) n'existe pas dans Office365"
            return $false
        }
    }

    return $true
}



#Fonction Ajout d'un Utilisateur à un Groupe AD
function AjouterUtilisateurGroupe {
    param (
        [Parameter(Mandatory = $true)]
        [string]$NomGroupe,
        [Parameter(Mandatory = $true)]
        [string]$NomUtilisateur
    )

    #Ajout de l'utilisateur au groupe
    Add-ADGroupMember -Identity $NomGroupe -Members $NomUtilisateur
}