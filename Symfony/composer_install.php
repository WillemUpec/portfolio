<?php
// composer_install.php - Script PHP pour executer composer install et cache:clear sur Alwaysdata (auto-detectant)
header('Content-Type: text/plain');

// Augmenter le temps limite d'execution car composer install peut prendre du temps
set_time_limit(300);

echo "--- DEBUT DU PROCESSUS COMPOSER & CACHE --- \n";

// Detecter si on est dans le dossier public/ ou a la racine
$rootDir = __DIR__;
if (basename($rootDir) === 'public') {
    $rootDir = dirname($rootDir);
}
chdir($rootDir);
echo "Repertoire de travail : " . getcwd() . "\n";

// Definir le dossier Home pour Composer (requis par Composer pour le cache local)
putenv('COMPOSER_HOME=' . $rootDir . '/var/composer_cache');

$commands = [
    'composer install --no-dev --optimize-autoloader --no-interaction 2>&1',
    'php bin/console cache:clear --env=prod --no-interaction 2>&1'
];

foreach ($commands as $cmd) {
    echo "\n=====================================\n";
    echo "Execution : $cmd\n";
    echo "=====================================\n";
    
    // Ouvrir un processus pour lire le retour en temps reel
    $handle = popen($cmd, 'r');
    if ($handle) {
        while (!feof($handle)) {
            echo fgets($handle);
            flush();
            ob_flush();
        }
        pclose($handle);
    } else {
        echo "Impossible de lancer la commande.\n";
    }
}

// Supprimer le cache temporaire cree pour Composer
if (is_dir($rootDir . '/var/composer_cache')) {
    function rmdir_recursive($dir) {
        foreach (scandir($dir) as $file) {
            if ($file === '.' || $file === '..') continue;
            if (is_dir("$dir/$file")) rmdir_recursive("$dir/$file");
            else unlink("$dir/$file");
        }
        rmdir($dir);
    }
    rmdir_recursive($rootDir . '/var/composer_cache');
}

echo "\n--- PROCESSUS TERMINE --- \n";

// Supprime ce script de deploiement par securite
unlink(__FILE__);
?>
