
#Créer une fonction qui génère un fichier log_date_heure tout en vérifiant s'il existe déjà ou non
function Create-LogFile {
    param (
        [string]$logDirectory,
        [string]$logFileName
    )

    # Créer le répertoire s'il n'existe pas
    if (-not (Test-Path -Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory | Out-Null
    }

    # Générer le nom de fichier avec la date et l'heure
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFilePath = Join-Path -Path $logDirectory -ChildPath "$logFileName_$timestamp.txt"

    # Créer le fichier log
    New-Item -ItemType File -Path $logFilePath | Out-Null

    Write-Host "Chemin du fichier log généré : $logFilePath"
    return $logFilePath
}

function Write-Log {
    param (
        [string]$logFilePath,
        [string]$message
    )

    if (-not (Test-Path -Path $logFilePath)) {
        throw "Le fichier de log spécifié n'existe pas ou le chemin est invalide : $logFilePath"
    }

    # Écrire le message dans le fichier log
    Add-Content -Path $logFilePath -Value $message
}

# Créer une fonction pour initialiser le fichier log
function Initialize-Log {
    param (
        [string]$logFilePath
    )

    # Écrire l'en-tête dans le fichier log
    $header = "Log file created on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Log -logFilePath $logFilePath -message $header
}



