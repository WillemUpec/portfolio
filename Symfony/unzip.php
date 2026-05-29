<?php
// unzip.php - Script d'extraction de projet Symfony sur Alwaysdata (Super-Robust Version)
header('Content-Type: text/plain');

$zipFile = 'project.zip';
$extractTo = '.';

if (!file_exists($zipFile)) {
    $zipFile = '../project.zip';
    $extractTo = '../';
}

if (!file_exists($zipFile)) {
    die("Erreur : Le fichier project.zip est introuvable sur le serveur.\n");
}

echo "Debut de l'extraction de $zipFile vers $extractTo...\n";

// Essayer en premier via la commande systeme native 'unzip' de Linux (ultra-rapide et robuste)
$output = [];
$returnVar = 0;
@exec("unzip -o " . escapeshellarg($zipFile) . " -d " . escapeshellarg($extractTo) . " 2>&1", $output, $returnVar);

if ($returnVar === 0 && !empty($output)) {
    echo "Succes : Extraction terminee avec la commande systeme unzip.\n";
    unlink($zipFile);
} else {
    echo "Commande systeme unzip non disponible ou en erreur. Passage a ZipArchive...\n";
    $zip = new ZipArchive;
    if ($zip->open($zipFile) === TRUE) {
        $zip->extractTo($extractTo);
        $zip->close();
        echo "Succes : Extraction terminee avec ZipArchive.\n";
        unlink($zipFile);
    } else {
        echo "Erreur : Impossible d'ouvrir ou d'extraire le fichier zip via ZipArchive.\n";
    }
}
?>
