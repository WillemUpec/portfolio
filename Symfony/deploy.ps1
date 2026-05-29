# deploy.ps1 - Script de deploiement automatique pour Symfony sur Alwaysdata (Super-Robust Version)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ftpHost = "ftp-dulormne.alwaysdata.net"
$ftpUser = "dulormne"
$ftpPass = "Kirua777"

$remoteDirLower = "/www/aquasite"
$remoteDirUpper = "/www/Aquasite"

$sourcePath = "C:\Users\fegur\Downloads\AquaSite-main\AquaSite-main"
$symfonyDir = "C:\Users\fegur\OneDrive\Images\Portofolio\Symfony"
$zipPath = "$symfonyDir\project.zip"
$dbSqlPath = "$symfonyDir\db.sql"

# --- ETAPE 1 : Exporter la base de donnees locale ---
Write-Host "Exportation de la base de donnees locale..." -ForegroundColor Cyan
try {
    docker exec aquasite_mysql mysqldump -uroot -proot guestbook > $dbSqlPath
    Write-Host "Base de donnees exportee avec succes !" -ForegroundColor Green
} catch {
    Write-Warning "Erreur lors de l'exportation. Assurez-vous que Docker est lance."
}

# --- ETAPE 2 : Creer l'archive zip sans les dossiers lourds (vendor, var, etc.) ---
Write-Host "Preparation de l'archive de code (excluant vendor, var, etc.)..." -ForegroundColor Cyan
$stagingPath = "$sourcePath`_staging"
if (Test-Path $stagingPath) { Remove-Item -Path $stagingPath -Recurse -Force }
New-Item -ItemType Directory -Path $stagingPath | Out-Null

# Utiliser Robocopy pour copier les fichiers de maniere ultra-robuste et sans verrouillage
robocopy "$sourcePath" "$stagingPath" /E /XD vendor var .git node_modules db_data mysql_data /R:0 /W:0 | Out-Null

# Utiliser la classe .NET ZipFile pour une compression rapide et fiable sans bug de verrouillage
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Add-Type -AssemblyName "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::CreateFromDirectory($stagingPath, $zipPath)

# Nettoyer le dossier temporaire
Remove-Item -Path $stagingPath -Recurse -Force
Write-Host "Archive de code creee avec succes : $zipPath" -ForegroundColor Green

# --- FONCTIONS FTP ---
function Upload-FtpFile($localPath, $remotePath) {
    Write-Host "Televersement de $localPath vers $remotePath..." -ForegroundColor Yellow
    $uri = "ftp://$ftpHost$remotePath"
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.Method = "STOR"
    $request.UsePassive = $true
    $request.UseBinary = $true
    $request.EnableSsl = $true
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    
    $bytes = [System.IO.File]::ReadAllBytes($localPath)
    $request.ContentLength = $bytes.Length
    $stream = $request.GetRequestStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
    
    $response = $request.GetResponse()
    Write-Host "Televersement reussi: $($response.StatusDescription)" -ForegroundColor Green
    $response.Close()
}

function Create-FtpDirectory($remotePath) {
    Write-Host "Creation du repertoire distant $remotePath..." -ForegroundColor Yellow
    $uri = "ftp://$ftpHost$remotePath"
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.Method = "MKD"
    $request.UsePassive = $true
    $request.EnableSsl = $true
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    try {
        $response = $request.GetResponse()
        Write-Host "Repertoire cree avec succes !" -ForegroundColor Green
        $response.Close()
    } catch {
        Write-Host "Le repertoire existe deja ou n'a pas pu etre cree."
    }
}

# --- ETAPE 3 : Televersement par FTP ---
Write-Host "Connexion FTP et televersement..." -ForegroundColor Cyan
try {
    # Creer les dossiers (minuscule et majuscule)
    Create-FtpDirectory "$remoteDirLower"
    Create-FtpDirectory "$remoteDirLower/public"
    Create-FtpDirectory "$remoteDirUpper"
    Create-FtpDirectory "$remoteDirUpper/public"
    
    # Televerser les fichiers de base dans les deux dossiers
    Upload-FtpFile "$zipPath" "$remoteDirLower/project.zip"
    Upload-FtpFile "$zipPath" "$remoteDirUpper/project.zip"
    
    Upload-FtpFile "$dbSqlPath" "$remoteDirLower/db.sql"
    Upload-FtpFile "$dbSqlPath" "$remoteDirUpper/db.sql"
    
    Upload-FtpFile "$symfonyDir/.env.alwaysdata" "$remoteDirLower/.env.local"
    Upload-FtpFile "$symfonyDir/.env.alwaysdata" "$remoteDirUpper/.env.local"
    
    # Televerser les helpers PHP
    Upload-FtpFile "$symfonyDir/unzip.php" "$remoteDirLower/unzip.php"
    Upload-FtpFile "$symfonyDir/unzip.php" "$remoteDirLower/public/unzip.php"
    Upload-FtpFile "$symfonyDir/unzip.php" "$remoteDirUpper/unzip.php"
    Upload-FtpFile "$symfonyDir/unzip.php" "$remoteDirUpper/public/unzip.php"
    
    Upload-FtpFile "$symfonyDir/db_import.php" "$remoteDirLower/db_import.php"
    Upload-FtpFile "$symfonyDir/db_import.php" "$remoteDirLower/public/db_import.php"
    Upload-FtpFile "$symfonyDir/db_import.php" "$remoteDirUpper/db_import.php"
    Upload-FtpFile "$symfonyDir/db_import.php" "$remoteDirUpper/public/db_import.php"
    
    Upload-FtpFile "$symfonyDir/composer_install.php" "$remoteDirLower/composer_install.php"
    Upload-FtpFile "$symfonyDir/composer_install.php" "$remoteDirLower/public/composer_install.php"
    Upload-FtpFile "$symfonyDir/composer_install.php" "$remoteDirUpper/composer_install.php"
    Upload-FtpFile "$symfonyDir/composer_install.php" "$remoteDirUpper/public/composer_install.php"
} catch {
    Write-Error "Erreur lors du televersement FTP : $_"
    exit
}

# --- ETAPE 4 : Extraction, Importation et Installation Composer a distance ---
Write-Host "Extraction des fichiers sur le serveur Alwaysdata..." -ForegroundColor Cyan
$unzipUri = "https://dulormne.alwaysdata.net/Aquasite/unzip.php"
try {
    $res = curl.exe -s -m 300 $unzipUri
    Write-Host "Reponse serveur (Unzip) : $res" -ForegroundColor Green
} catch {
    Write-Warning "Erreur ou timeout lors du desarchivage : $_"
}

Write-Host "Importation de la base de donnees a distance..." -ForegroundColor Cyan
$importUri = "https://dulormne.alwaysdata.net/Aquasite/db_import.php"
try {
    $res = curl.exe -s -m 300 $importUri
    Write-Host "Reponse serveur (DB Import) : $res" -ForegroundColor Green
} catch {
    Write-Warning "Erreur ou timeout lors de l'importation SQL : $_"
}

Write-Host "Execution automatique de 'composer install' et vidage du cache Symfony sur Alwaysdata..." -ForegroundColor Cyan
Write-Host "Veuillez patienter (cela peut prendre 1 a 2 minutes)..." -ForegroundColor Yellow
$composerUri = "https://dulormne.alwaysdata.net/Aquasite/composer_install.php"
try {
    $res = curl.exe -s -m 300 $composerUri
    Write-Host "Reponse serveur (Composer & Cache) :`n$res" -ForegroundColor Green
} catch {
    Write-Warning "Erreur ou timeout lors de l'execution Composer : $_"
}

# Suppression locale de l'archive temporaire
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Write-Host "Deploiement complet de AquaSite reussi avec succes !" -ForegroundColor Green
Write-Host "Votre application est en ligne sur : https://dulormne.alwaysdata.net/Aquasite/" -ForegroundColor Cyan
