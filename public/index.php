<?php
	require_once(__DIR__ . '/../vendor/autoload.php');
	require_once(__DIR__ . '/../functions.php');

	// Router for requests
	$router = new \Bramus\Router\Router();

	// Templating engine
	$displayEngine = new DisplayEngine($config);
	$displayEngine->setSiteName($config['sitename']);

	if ($config['securecookies']) {
		ini_set('session.cookie_secure', True);
	}
	ini_set('session.cookie_httponly', True);

	// Session storage
	if (isset($config['memcached']) && !empty($config['memcached'])) {
		ini_set('session.save_handler', 'memcached');
		ini_set('session.save_path', $config['memcached']);
	}
	session::init();

	// Storage array
	$storage = [];

	// API to interact with backend
	$api = new MyDNSHostAPI($config['api']);
	if (session::exists('logindata')) {
		$api->setAuth(session::get('logindata'));

		if (session::exists('impersonate')) {
			$api->impersonate(session::get('impersonate'), 'id');

			$displayEngine->setVar('impersonating', true);
		}
	}

	if (isset($_COOKIE['MYDNSHOST_2FA_SAVED_DEVICE'])) {
		$deviceData = json_decode($_COOKIE['MYDNSHOST_2FA_SAVED_DEVICE'], true);
		if (isset($deviceData['id'])) {
			$api->setDeviceID($deviceData['id']);
		}
		if (isset($deviceData['name'])) {
			$api->setDeviceName($deviceData['name']);
		}
	}

	// Routes that exist all the time.
	(new SiteRoutes())->addRoutes($router, $displayEngine, $api);

	// If we have valid auth details then present a useful session, otherwise
	// present a login-only session.
	$userdata = $api->getUserData();
	if ($userdata !== NULL) {
		session::setCurrentUser($userdata);

		session::set('domains', $api->getDomains());
		$defaultPage = $api->getCustomData('uk.co.mydnshost.www/domain/defaultpage');
		session::set('domain/defaultpage', empty($defaultPage) ? 'details' : $defaultPage);

		(new AuthedRoutes())->addRoutes($router, $displayEngine, $api);
		(new DomainRoutes())->addRoutes($router, $displayEngine, $api);
		(new UserRoutes())->addRoutes($router, $displayEngine, $api);
		(new AdminRoutes())->addRoutes($router, $displayEngine, $api);
	} else {
		$hadLoginDetails = session::exists('logindata');
		session::clear(['DisplayEngine::Flash', 'wantedPage', 'lastlogin']);

		if ($hadLoginDetails) {
			setWantedPage($displayEngine, $_SERVER['REQUEST_URI']);
			$displayEngine->flash('info', 'Session timeout', 'Your login session has timed out. Please log in again.');

			header('Location: ' . $displayEngine->getURL('/login'));
			die();
		}

		(new NotAuthedRoutes())->addRoutes($router, $displayEngine, $api);
	}

	// Check CSRF Tokens.
	$router->before('POST', '.*', function() {
		// Pre-Login, we don't have a CSRF Token assigned.
		if (!session::exists('csrftoken')) { return; }

		if (!array_key_exists('csrftoken', $_POST) || empty($_POST['csrftoken']) || $_POST['csrftoken'] != session::get('csrftoken')) {
			header('HTTP/1.1 403 Forbidden');
			die('Invalid CSRF Token');
		}
	});

	// Check recaptcha.
	$router->before('POST', '.*', function() use ($config) {
		storage::set('recaptcha_state', 'notchecked');

		if (array_key_exists('g-recaptcha-response', $_POST) && !empty($_POST['g-recaptcha-response'])) {
			$recaptcha = new \ReCaptcha\ReCaptcha($config['recaptcha']['secret']);
			$resp = $recaptcha->verify($_POST['g-recaptcha-response']);
			unset($_POST['g-recaptcha-response']);

			if (!$resp->isSuccess()) {
				storage::set('recaptcha_state', 'failed');
			} else {
				storage::set('recaptcha_state', 'passed');
			}
		}
	});

	// Expose some settings
	$displayEngine->setVar('recaptcha', $config['recaptcha']['site']);

	// Begin!
	$router->run();
