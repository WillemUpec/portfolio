<?php
$zip = new ZipArchive;
if ($zip->open('wordpress.zip') === TRUE) {
    $zip->extractTo('./');
    $zip->close();
    unlink('wordpress.zip');
    echo 'SUCCESS';
} else {
    echo 'ERROR';
}
unlink('unzip.php');
?>
