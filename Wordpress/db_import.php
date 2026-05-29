<?php
$db_host = 'mysql-dulormne.alwaysdata.net';
$db_user = 'dulormne';
$db_pass = 'Kirua777';
$db_name = 'dulormne_wordpress';

$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = file_get_contents('db.sql');
if ($conn->multi_query($sql)) {
    do {
        if ($result = $conn->store_result()) {
            $result->free();
        }
    } while ($conn->next_result());
    unlink('db.sql');
    echo "DB_SUCCESS";
} else {
    echo "DB_ERROR: " . $conn->error;
}
$conn->close();
unlink('db_import.php');
?>
