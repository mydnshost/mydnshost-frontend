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
	if (isset($config['redis']) && !empty($config['redis'])) {
		ini_set('session.save_handler', 'redis');
		ini_set('session.save_path', 'tcp://' . $config['redis'] . ':' . $config['redisPort'] . '/?prefix=' . urlencode($config['redisSessionPrefix'] . ':'));
	}
	session::init();

	// Storage array
	$storage = [];

	// API to interact with backend
	$api = new MyDNSHostAPI($config['api']);
	$impersonating = false;
	if (session::exists('logindata')) {
		$logindata = session::get('logindata');
		$api->setAuth($logindata);

		if ($logindata['type'] == 'jwt') {
			// If our token expires within the next 15 minutes, then get a
			// new one.
			$expired = (time() + 15 * 60) >= $logindata['expires'];

			if ($expired) {
				$jwttoken = $api->getJWTToken();
				if ($jwttoken == NULL) {
					// Token has very very expired, abort.
				} else {
					$tokenData = parseJWT($jwttoken);
					session::set('logindata', ['type' => 'jwt', 'token' => $jwttoken, 'expires' => $tokenData['exp']]);
				}
			}
		}

		if (session::exists('impersonate')) {
			$api->impersonate(session::get('impersonate'), 'id');

			$impersonating = true;
			$displayEngine->setVar('impersonating', $impersonating);
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

		$defaultPage = isset($userdata['user']['customdata']['uk.co.mydnshost.www/domain/defaultpage']) ? $userdata['user']['customdata']['uk.co.mydnshost.www/domain/defaultpage'] : '';
		session::set('domain/defaultpage', empty($defaultPage) ? 'details' : $defaultPage);

		$sidebarLayout = isset($userdata['user']['customdata']['uk.co.mydnshost.www/sidebar/layout']) ? $userdata['user']['customdata']['uk.co.mydnshost.www/sidebar/layout'] : '';
		session::set('sidebar/layout', empty($sidebarLayout) ? 'access' : $sidebarLayout);

		$sitetheme = isset($userdata['user']['customdata']['uk.co.mydnshost.www/sitetheme']) ? $userdata['user']['customdata']['uk.co.mydnshost.www/sitetheme'] : '';
		if (isset($_REQUEST['__THEME'])) {
			$sitetheme = $_REQUEST['__THEME'];
		}

		$knownThemes = getThemeInformation()['themes'];

		// Resolve theme aliases
		if (!isset($knownThemes[$sitetheme])) {
			foreach ($knownThemes as $key => $theme) {
				if (isset($theme['aliases']) && in_array($sitetheme, $theme['aliases'], true)) {
					$sitetheme = $key;
					break;
				}
			}
		}

		// Fall back to default theme if still unknown
		if (!isset($knownThemes[$sitetheme])) { $sitetheme = array_key_first(array_filter($knownThemes, fn($t) => !empty($t['default']))); }

		session::set('sitetheme', $sitetheme);
		session::set('sitethemedata', isset($knownThemes[$sitetheme]) ? $knownThemes[$sitetheme] : []);

		$domains = [];
		$domains = $api->getDomains(['type' => 'userdata', 'key' => 'uk.co.mydnshost.www/domain/label', 'extra' => true]);
		session::set('domains', $domains);

		$requireTerms = false;
		if (isset($userdata['user']['acceptterms']) && !parseBool($userdata['user']['acceptterms'])) {
			if ($impersonating) {
				$displayEngine->displayBanner('warning', 'Terms of Service', 'This user has not accepted the terms of service.');
			} else {
				$requireTerms = true;
			}
		}

		(new AuthedRoutes())->addRoutes($router, $displayEngine, $api);
		(new RestrictedUserRoutes())->addRoutes($router, $displayEngine, $api);

		if ($requireTerms) {
			$displayEngine->setRestrictedMode(true);
			(new TermsRoutes())->addRoutes($router, $displayEngine, $api);
		} else {
			(new DomainRoutes())->addRoutes($router, $displayEngine, $api);
			(new UserRoutes())->addRoutes($router, $displayEngine, $api);
			(new AdminRoutes())->addRoutes($router, $displayEngine, $api);
			(new SystemServiceRoutes())->addRoutes($router, $displayEngine, $api);
			(new SystemJobsRoutes())->addRoutes($router, $displayEngine, $api);
		}
	} else {
		$hadLoginDetails = session::exists('logindata');
		$wanted = getWantedPage($displayEngine, $_SERVER['REQUEST_URI']);
		session::clear(['DisplayEngine::Flash', 'wantedPage', 'lastlogin', '2fa_push', 'logindata', 'csrftoken']);

		if ($hadLoginDetails && $wanted !== FALSE) {
			setWantedPage($displayEngine, $_SERVER['REQUEST_URI']);
			$displayEngine->flash('info', 'Session timeout', 'Your login session has timed out, or there was a problem with the API. Please try logging in again.');

			header('Location: ' . $displayEngine->getURL('/login'));
			die();
		}

		(new NotAuthedRoutes())->addRoutes($router, $displayEngine, $api);
	}

	// Add config routes.
	addConfigRoutes($router, $displayEngine, $api, $userdata);

	// Check CSRF Tokens.
	$router->before('POST', '(.*)', function($page) {
		// If we are trying to login, don't care about a CSRF Token that we may
		// think we still have.
		if ($page == 'login') { return; }

		// Pre-Login, we don't have a CSRF Token assigned.
		if (!session::exists('csrftoken')) { return; }

		if (!array_key_exists('csrftoken', $_POST) || empty($_POST['csrftoken']) || $_POST['csrftoken'] != session::get('csrftoken')) {
			header('HTTP/1.1 403 Forbidden');
			die('Invalid CSRF Token.');
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
