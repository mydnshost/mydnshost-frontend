<?php
	require_once(__DIR__ . '/../vendor/autoload.php');
	require_once(__DIR__ . '/../functions.php');

	// Router for requests
	$router = new \Bramus\Router\Router();

	// Templating engine
	$displayEngine = new DisplayEngine($config['templates']);
	$displayEngine->setSiteName($config['sitename']);

	// API to interact with backend
	$api = new MyDNSHostAPI($config['api']);
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
		session::set('domains', $api->getDomains());

		(new AuthedRoutes())->addRoutes($router, $displayEngine, $api);
		(new DomainRoutes())->addRoutes($router, $displayEngine, $api);
		(new UserRoutes())->addRoutes($router, $displayEngine, $api);
	} else {
		$wasLoggedIn = session::isLoggedIn();
		session::clear();
		if ($wasLoggedIn) {
			$displayEngine->flash('warning', 'Session timeout', 'Your login session has timed out. Please log in again.');

			header('Location: ' . $displayEngine->getURL('/login'));
			die();
		}

		(new NotAuthedRoutes())->addRoutes($router, $displayEngine, $api);
	}

	// Begin!
	$router->run();
