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

Write-Host "Creating remote directory /www/TD1/wordpress/..."
try {
    Run-FtpCommand "MKD" "/www/TD1/wordpress/"
    Write-Host "Directory created successfully."
} catch {
    Write-Host "Directory already exists or error: $_"
}

Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\wordpress.zip" "/www/TD1/wordpress/wordpress.zip"
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\unzip.php" "/www/TD1/wordpress/unzip.php"
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\db_import.php" "/www/TD1/wordpress/db_import.php"
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\wp-config-alwaysdata.php" "/www/TD1/wordpress/wp-config.php"

Write-Host "Extracting files on the server..."
$unzipUri = "https://dulormne.alwaysdata.net/td/wordpress/unzip.php"
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
    $res = $webClient.DownloadString($unzipUri)
    Write-Host "Unzip response: $res"
} catch {
    Write-Host "Unzip trigger completed: $_"
}

Write-Host "Importing database on the server..."
$importUri = "https://dulormne.alwaysdata.net/td/wordpress/db_import.php"
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
    $res = $webClient.DownloadString($importUri)
    Write-Host "DB Import response: $res"
} catch {
    Write-Host "DB Import trigger completed: $_"
}

Write-Host "Deployment process finished."
