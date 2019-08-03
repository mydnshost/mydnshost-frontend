<?php
	// Database Details

	$config['templates']['dir'] = getEnvOrDefault('TEMPLATE_DIR', __DIR__ . '/templates');
	$config['templates']['theme'] = getEnvOrDefault('TEMPLATE_THEME', 'default');
	$config['templates']['cache'] = getEnvOrDefault('TEMPLATE_CACHE', __DIR__ . '/templates_c');

	$config['api'] = getEnvOrDefault('API_URL', 'https://api.mydnshost.co.uk/');
	$config['api_public'] = getEnvOrDefault('API_PUBLICURL', $config['api']);

	$config['sitename'] = getEnvOrDefault('SITE_NAME', 'MyDNSHost');

	// Config for redis.
	//
	// This will be used for sessions instead of memcached if defined
	$config['redis'] = getEnvOrDefault('REDIS_HOST', '');
	$config['redisPort'] = getEnvOrDefault('REDIS_PORT', 6379);
	$config['redisSessionPrefix'] = getEnvOrDefault('REDIS_SESSION_PREFIX', 'MyDNSHost-Web-Session');

	$config['memcached'] = getEnvOrDefault('MEMCACHED', '');

	$config['securecookies'] = getEnvOrDefault('SECURE_COOKIES', false);

	$config['recaptcha']['site'] = getEnvOrDefault('RECAPTCHA_SITE', '');
	$config['recaptcha']['secret'] = getEnvOrDefault('RECAPTCHA_SECRET', '');

	$config['register']['termsText'] = getEnvOrDefault('TERMS_TEXT', 'I agree to the terms of service.');

	if (file_exists(dirname(__FILE__) . '/config.local.php')) {
		include(dirname(__FILE__) . '/config.local.php');
	}
