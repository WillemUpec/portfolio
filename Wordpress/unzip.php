<?php
@set_time_limit(0);
@ini_set('max_execution_time', 0);
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
