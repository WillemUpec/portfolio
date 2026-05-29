<?php
//Begin Really Simple Security session cookie settings
@ini_set('session.cookie_httponly', true);
@ini_set('session.cookie_secure', true);
@ini_set('session.use_only_cookies', true);
//END Really Simple Security cookie settings
//Begin Really Simple Security key
define('RSSSL_KEY', 'PBP7Kz7WQly5yLzRsWslv8b0Y69MVg4RBB5NH8HrJXnTf3SGZkprVvmvzMreoSfD');
//END Really Simple Security key

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'dulormne_wordpress' );

/** Database username */
define( 'DB_USER', 'dulormne' );

/** Database password */
define( 'DB_PASSWORD', 'Kirua777' );

/** Database hostname */
define( 'DB_HOST', 'mysql-dulormne.alwaysdata.net' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

// Surcharges dynamiques d'URL pour le fonctionnement en ligne
define( 'WP_HOME', 'https://dulormne.alwaysdata.net/td' );
define( 'WP_SITEURL', 'https://dulormne.alwaysdata.net/td' );

define( 'AUTH_KEY',         '8d0bbf25c726102af250ffab041be62c910e7149' );
define( 'SECURE_AUTH_KEY',  'ecb681bdc2cfc75bef3dc3dc129103204bf910e2' );
define( 'LOGGED_IN_KEY',    '0b4e7d810c850d6157cef2c2075be29bf69428f7' );
define( 'NONCE_KEY',        'e6c0fbc9de5f7c745ca4096b283be6dc4af2d156' );
define( 'AUTH_SALT',        '86f99bbc56565971bf8305cb43bec3ab19412261' );
define( 'SECURE_AUTH_SALT', 'd78cc7f19002ee4d43a30487521446ddb69549c2' );
define( 'LOGGED_IN_SALT',   '15ff0906b22e00c52c26a1dc3dc6a0b14c94d3b0' );
define( 'NONCE_SALT',       'f834028fa3d1ea692a92ee5839ca6ec5b497d56f' );

$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
	$_SERVER['HTTPS'] = 'on';
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
