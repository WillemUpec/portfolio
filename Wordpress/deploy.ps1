$ftpHost = "ftp-dulormne.alwaysdata.net"
$ftpUser = "dulormne"
$ftpPass = "Kirua777"

function Upload-FtpFile($localPath, $remotePath) {
    Write-Host "Uploading $localPath to $remotePath..."
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
    Write-Host "Upload complete: $($response.StatusDescription)"
    $response.Close()
}

function Run-FtpCommand($method, $remotePath) {
    $uri = "ftp://$ftpHost$remotePath"
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.Method = $method
    $request.UsePassive = $true
    $request.EnableSsl = $true
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    
    $response = $request.GetResponse()
    $response.Close()
}

Write-Host "Cleaning up old files in /www/TD1/..."
$oldFiles = @(
    "/www/TD1/index.php",
    "/www/TD1/page2.php",
    "/www/TD1/deploy.log",
    "/www/TD1/deploy.ps1",
    "/www/TD1/deploy.sh"
)

foreach ($file in $oldFiles) {
    try {
        Run-FtpCommand "DELE" $file
        Write-Host "Deleted $file"
    } catch {
        Write-Host "Could not delete $file (might not exist): $_"
    }
}

Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\wordpress.zip" "/www/TD1/wordpress.zip"
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\unzip.php" "/www/TD1/unzip.php"
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\db_import.php" "/www/TD1/db_import.php"
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\wp-config-alwaysdata.php" "/www/TD1/wp-config.php"

Write-Host "Extracting files on the server root /www/TD1/..."
$unzipUri = "https://dulormne.alwaysdata.net/td/unzip.php"
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
    $res = $webClient.DownloadString($unzipUri)
    Write-Host "Unzip response: $res"
} catch {
    Write-Host "Unzip trigger completed: $_"
}

Write-Host "Importing database on the server..."
$importUri = "https://dulormne.alwaysdata.net/td/db_import.php"
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
    $res = $webClient.DownloadString($importUri)
    Write-Host "DB Import response: $res"
} catch {
    Write-Host "DB Import trigger completed: $_"
}

Write-Host "Deployment process finished."
