# Script PowerShell pour se connecter à AzureAD et MSOnline, et importer un fichier Excel
# Ce script nécessite les modules AzureAD, MSOnline et ImportExcel
# Ce script est conçu pour être exécuté sur un système Windows avec PowerShell et possèdant un Active Directory local
# Assurez-vous d'avoir les autorisations nécessaires pour exécuter ce script et d'avoir installé les modules requis


Import-Module $PSScriptRoot\Log.ps1
#Récupère la variable $logFilePath dans Main.ps1
$logFilePath = $script:logFilePath

#Ouverture du fichier de Configuration.txt pour récupérer les informations comme suit : 
function ImporterFichierConfiguration {
    param (
        [string]$CheminFichier
    )
    #Write-Host "Le chemin du fichier de configuration est : $CheminFichier"
    $config = Get-Content $CheminFichier

    $NomDomaine = $config[0].Split("=")[1].Trim()
    $NomFichier = $config[1].Split("=")[1].Trim()
    $LoginOffice365 = $config[2].Split("=")[1].Trim()
    $PasswordOffice365 = $config[3].Split("=")[1].Trim()

    return $NomDomaine, $NomFichier, $LoginOffice365, $PasswordOffice365
}





function InitialiserAzureAD {
    param (
        [string]$LoginOffice365,
        [string]$PasswordOffice365
    )

    #Initialisation du Module AzureAD
    Write-Host "### Initialisation du Module AzureAD ###"

    # Détection du module AzureAD
    if (-not (Get-Module -Name AzureAD -ListAvailable)) {
        Write-Host "Le module AzureAD n'est pas installe"
        Write-Host "Installation du module AzureAD"
        Install-Module -Name AzureAD -Force -AllowClobber
        Write-Host "Module AzureAD installe"
    }
    else {
        Write-Host "Le module AzureAD est deja installe"
    }

    # Importation du module AzureAD
    Import-Module AzureAD

    # Connect to Azure AD avec les identifiants Office365
    $SecurePassword = ConvertTo-SecureString $PasswordOffice365 -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($LoginOffice365, $SecurePassword)

    try {
        Connect-AzureAD -Credential $Credential
        Write-Host "Connexion a AzureAD reussie"
    }
    catch {
        Write-Host "Erreur lors de la connexion a AzureAD"
        Write-Log -logFilePath $logFilePath -message "Erreur lors de la connexion a AzureAD : $_"
    }

    # Retour à la ligne
    Write-Host "---------------------------------"
}





function InitialiserMsolService {
    param (
        [string]$LoginOffice365,
        [string]$PasswordOffice365
    )

    # Initialisation du Module MsolService
    Write-Host "### Initialisation du Module MsolService ###"

    if (-not (Get-Module -Name MSOnline -ListAvailable)) {
        Write-Host "Le module MSOnline n'est pas installe"
        Write-Host "Installation du module MSOnline"
        Install-Module -Name MSOnline -Force -AllowClobber
        Write-Host "Module MSOnline installe"
    }
    else {
        Write-Host "Le module MSOnline est deja installe"
    }

    # Importation du module MSOnline
    Import-Module MSOnline

    # Connexion au service MSOnline
    $SecurePassword = ConvertTo-SecureString $PasswordOffice365 -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($LoginOffice365, $SecurePassword)

    try {
        Connect-MsolService -Credential $Credential
        Write-Host "Connexion au service MSOnline reussie"
    }
    catch {
        Write-Host "Erreur lors de la connexion au service MSOnline"
        Write-Log -logFilePath $logFilePath -message "Erreur lors de la connexion au service MSOnline : $_"
    }

    # Initialisation du Module MsolService terminé
    Write-Host "### Initialisation du Module MsolService termine ###"

    # Retour à la ligne
    Write-Host "---------------------------------"
}








function InitialiserImportExcel {
    #Import du module ImportExcel
    Write-Host "### Initialisation du Module ImportExcel ###"

    #Détection du module ImportExcel
    if (-not (Get-Module -Name ImportExcel -ListAvailable)) {
        Write-Host "Le module ImportExcel n'est pas installe"
        Write-Host "Installation du module ImportExcel"
        Install-Module -Name ImportExcel -Force -AllowClobber
        Write-Host "Module ImportExcel installe"
    }
    else {
        Write-Host "Le module ImportExcel est deja installe"
    }

    #Importation du module ImportExcel
    Import-Module ImportExcel

    #Initialisation du Module ImportExcel terminé
    Write-Host "### Initialisation du Module ImportExcel termine ###"

    Write-Host "---------------------------------"
}








function InitialiserActiveDirectory {
    # Initialisation du Module ActiveDirectory
    Write-Host "### Initialisation du Module ActiveDirectory ###"

    # Détection du module ActiveDirectory
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Host "Le module ActiveDirectory n'est pas installe"
        Write-Host "Installation du module ActiveDirectory"
        Install-Module -Name ActiveDirectory -Force -AllowClobber
        Write-Host "Module ActiveDirectory installe"
    }
    else {
        Write-Host "Le module ActiveDirectory est deja installe"
    }

    # Importation du module ActiveDirectory
    Import-Module ActiveDirectory

    # Initialisation du Module ActiveDirectory terminé
    Write-Host "### Initialisation du Module ActiveDirectory termine ###"

    Write-Host "---------------------------------"
}







#Fonction demande entrer le nom du fichier de configuration
function DemanderNomFichierConfiguration {
    $NomFichier = Read-Host "Entrez le nom du fichier de configuration (ex: Configuration.txt)"
    if (-not $NomFichier.EndsWith(".txt")) {
        $NomFichier += ".txt"
    }
    $NomFichier = "$PSScriptRoot\$NomFichier"
    #Write-Host "Le nom du fichier de configuration est : $NomFichier"
    
    # Vérification de l'existence du fichier
    if (-not (Test-Path $NomFichier)) {
        Write-Host "Le fichier de configuration n'existe pas. Veuillez entrer un nom valide."
        return DemanderNomFichierConfiguration
    }
    
    return $NomFichier
}

