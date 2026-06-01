<?php
header('Content-Type: text/plain; charset=utf-8');

$host = 'mysql-dulormne.alwaysdata.net';
$db   = 'dulormne_wordpress';
$user = 'dulormne';
$pass = 'Kirua777';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (\PDOException $e) {
     throw new \PDOException($e->getMessage(), (int)$e->getCode());
}

echo "Database connection successful!\n\n";

$tables = ['wp_posts', 'wp_options', 'wp_postmeta', 'wp_comments', 'wp_terms'];

foreach ($tables as $table) {
    echo "========================================\n";
    echo "Scanning table: $table\n";
    echo "========================================\n";
    
    // Get text columns
    try {
        $stmt = $pdo->query("DESCRIBE $table");
    } catch (\PDOException $e) {
        echo "Table does not exist or error: " . $e->getMessage() . "\n\n";
        continue;
    }
    
    $columns = [];
    while ($row = $stmt->fetch()) {
        $type = strtolower($row['Type']);
        if (strpos($type, 'char') !== false || strpos($type, 'text') !== false) {
            $columns[] = $row['Field'];
        }
    }
    
    if (empty($columns)) {
        echo "No text columns found.\n\n";
        continue;
    }
    
    $pk = ($table === 'wp_options') ? 'option_id' : (($table === 'wp_postmeta') ? 'meta_id' : (($table === 'wp_comments') ? 'comment_ID' : (($table === 'wp_terms') ? 'term_id' : 'ID')));
    
    $sql = "SELECT $pk, " . implode(', ', $columns) . " FROM $table";
    $stmt = $pdo->query($sql);
    
    $foundCount = 0;
    while ($row = $stmt->fetch()) {
        $rowDetails = [];
        
        foreach ($columns as $col) {
            $val = $row[$col];
            if (empty($val) || !is_string($val)) continue;
            
            // Search for typical CP850/CP1252 box drawing or multi-byte corruptions
            // E.g. bytes like 0xE2 (226), 0xC3 (195), 0xC2 (194), etc., followed by other bytes
            // Let's inspect the string for sequences:
            // - ├® (\xe2\x94\x9c\xc2\xae)
            // - ├á (\xe2\x94\x9c\xc3\xa1)
            // - ├è (\xe2\x94\x9c\xc3\x88)
            // - ├¿ (\xe2\x94\x9c\xc2\xa8)
            // - ├¬ (\xe2\x94\x9c\xc2\xac)
            // - ├┤ (\xe2\x94\x9c\xc2\xb4)
            // - ├╣ (\xe2\x94\x9c\xe2\x95\xa3)
            // - ┬½ (\xe2\x94\xac\xc2\xbd)
            // - ┬╗ (\xe2\x94\xac\xe2\x95\x97)
            // - ÔÇÖ (\xc3\x94\xc3\x87\xc3\x96)
            // - ÔÇ£ (\xc3\x94\xc3\x87\xc2\xa3)
            // - ÔÇØ (\xc3\x94\xc3\x87\xc3\x98)
            // - ÔÇô (\xc3\x94\xc3\x87\xc3\xb4)
            // - ÔÇö (\xc3\x94\xc3\x87\xc3\xb6)
            
            $suspiciousPatterns = [
                "\xe2\x94\x9c", // ├
                "\xe2\x94\xac", // ┬
                "\xc3\x94\xc3\x87", // ÔÇ
                "├",
                "┬"
            ];
            
            $hasSuspicious = false;
            foreach ($suspiciousPatterns as $pattern) {
                if (strpos($val, $pattern) !== false) {
                    $hasSuspicious = true;
                    break;
                }
            }
            
            if ($hasSuspicious) {
                // Find where the first suspicious pattern starts
                $pos = -1;
                foreach ($suspiciousPatterns as $pattern) {
                    $p = strpos($val, $pattern);
                    if ($p !== false && ($pos === -1 || $p < $pos)) {
                        $pos = $p;
                    }
                }
                
                $start = max(0, $pos - 30);
                $len = min(strlen($val) - $start, 100);
                $snippet = substr($val, $start, $len);
                
                $rowDetails[] = [
                    'column' => $col,
                    'hex' => bin2hex($snippet),
                    'text' => $snippet
                ];
            }
        }
        
        if (!empty($rowDetails)) {
            $foundCount++;
            echo "Row $pk = {$row[$pk]}:\n";
            foreach ($rowDetails as $d) {
                echo "  - Column [{$d['column']}]:\n";
                echo "    Hex:     " . $d['hex'] . "\n";
                echo "    As Text: " . htmlspecialchars($d['text'], ENT_SUBSTITUTE, 'UTF-8') . "\n";
            }
            echo "\n";
        }
    }
    
    echo "Finished scanning $table. Found $foundCount rows with suspicious encodings.\n\n";
}
?>
