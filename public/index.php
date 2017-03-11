<?php
	require_once(__DIR__ . '/../vendor/autoload.php');
	require_once(__DIR__ . '/../functions.php');

	$router = new \Bramus\Router\Router();

	$displayEngine = new DisplayEngine($config['templates']);

	$api = new MyDnsHostAPI($config['api']);
	if (session::exists('logindata')) {
		$api->setAuth(session::get('logindata'));
	}

	(new SiteRoutes())->addRoutes($router, $displayEngine, $api);
	if ($api->validAuth()) {
		// TODO: Other routes!
	} else {
		(new NoAuthRoutes())->addRoutes($router, $displayEngine, $api);
	}

	$router->run();
