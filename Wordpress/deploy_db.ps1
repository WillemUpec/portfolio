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

# Upload corrected files
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\wordpress\db.sql" "/www/TD1/wordpress/db.sql"
Upload-FtpFile "C:\Users\fegur\OneDrive\Images\Portofolio\Wordpress\db_import.php" "/www/TD1/wordpress/db_import.php"

# Trigger DB import
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
