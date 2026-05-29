<?php
header('Content-Type: text/plain; charset=utf-8');

echo "--- PHP ENCODING INFO ---\n";
echo "default_charset: " . ini_get('default_charset') . "\n";
echo "mbstring.internal_encoding: " . ini_get('mbstring.internal_encoding') . "\n";

$wpConfigPath = __DIR__ . '/wp-config.php';
if (file_exists($wpConfigPath)) {
    echo "\n--- wp-config.php FOUND ---\n";
    $content = file_get_contents($wpConfigPath);
    
    // Let's find DB_CHARSET and DB_COLLATE
    if (preg_match("/define\(\s*['\"]DB_CHARSET['\"]\s*,\s*['\"](.*?)['\"]\s*\)/", $content, $m)) {
        echo "DB_CHARSET defined as: " . $m[1] . "\n";
    } else {
        echo "DB_CHARSET NOT FOUND in wp-config.php\n";
    }
    
    if (preg_match("/define\(\s*['\"]DB_COLLATE['\"]\s*,\s*['\"](.*?)['\"]\s*\)/", $content, $m)) {
        echo "DB_COLLATE defined as: " . $m[1] . "\n";
    } else {
        echo "DB_COLLATE NOT FOUND in wp-config.php\n";
    }
} else {
    echo "\nwp-config.php NOT FOUND at $wpConfigPath\n";
}

echo "\n--- DATABASE TABLES COLLATION ---\n";
$host = 'mysql-dulormne.alwaysdata.net';
$db   = 'dulormne_wordpress';
$user = 'dulormne';
$pass = 'Kirua777';
$charset = 'utf8mb4';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=$charset", $user, $pass);
    $stmt = $pdo->query("SHOW TABLE STATUS");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "Table: " . $row['Name'] . " | Collation: " . $row['Collation'] . "\n";
    }
} catch (\Exception $e) {
    echo "DB Error: " . $e->getMessage() . "\n";
}
?>
