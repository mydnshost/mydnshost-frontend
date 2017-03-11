<?php
	require_once(__DIR__ . '/../vendor/autoload.php');
	require_once(__DIR__ . '/../functions.php');

	// Router for requests
	$router = new \Bramus\Router\Router();

	// Templating engine
	$displayEngine = new DisplayEngine($config['templates']);
	$displayEngine->setSiteName($config['sitename']);

	// API to interact with backend
	$api = new MyDnsHostAPI($config['api']);
	if (session::exists('logindata')) {
		$api->setAuth(session::get('logindata'));
	}

	// Routes that exist all the time.
	(new SiteRoutes())->addRoutes($router, $displayEngine, $api);


	// If we have valid auth details then present a useful session, otherwise
	// present a login-only session.
	$userdata = $api->getUserData();
	if ($userdata !== NULL) {
		session::setCurrentUser($userdata);
		(new AuthRoutes())->addRoutes($router, $displayEngine, $api);
	} else {
		session::clear();
		(new NoAuthRoutes())->addRoutes($router, $displayEngine, $api);
	}

	// Begin!
	$router->run();
