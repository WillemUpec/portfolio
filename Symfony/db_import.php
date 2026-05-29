<?php
// db_import.php - Script d'importation SQL pour Alwaysdata (auto-detectant)
header('Content-Type: text/plain');

$dbHost = 'mysql-dulormne.alwaysdata.net';
$dbName = 'dulormne_defigithub';
$dbUser = 'dulormne';
$dbPass = 'Kirua777';

$sqlFile = 'db.sql';
if (!file_exists($sqlFile)) {
    $sqlFile = '../db.sql';
}

if (!file_exists($sqlFile)) {
    die("Erreur : Le fichier SQL $sqlFile est introuvable sur le serveur.\n");
}

try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Connexion reussie a MySQL.\nImportation de la base de donnees...\n";
    
    $sql = file_get_contents($sqlFile);
    
    $pdo->exec("SET FOREIGN_KEY_CHECKS = 0;");
    $pdo->exec($sql);
    $pdo->exec("SET FOREIGN_KEY_CHECKS = 1;");
    
    echo "Succes : La base de donnees a ete importee avec succes !\n";
    unlink($sqlFile); // Supprime le fichier SQL après import
} catch (PDOException $e) {
    die("Erreur lors de l'importation de la base de donnees : " . $e->getMessage() . "\n");
}
?>
