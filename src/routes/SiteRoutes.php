<?php
	class SiteRoutes {

		public function addRoutes($router, $displayEngine, $api) {
			$router->get('/', function() use ($displayEngine, $api) {
				if (!session::isLoggedIn()) {
					$displayEngine->setPageID('home')->setTitle('Home')->display('index.tpl');
					return;
				} else if ($displayEngine->getRestrictedMode()) {
					header('Location: ' . $displayEngine->getURL('/profile/terms'));
				} else {
					$displayEngine->setVar('articles', $api->getArticles());
					$displayEngine->setPageID('home')->setTitle('Home')->display('home.tpl');
				}
			});

			$router->match('GET|POST', '/register', function() use ($router, $displayEngine, $api) {
				if (session::isLoggedIn()) {
					$displayEngine->flash('error', '', 'You must be logged out to register a new account.');
					header('Location: ' . $displayEngine->getURL('/'));
					return;
				}

				$registerOpen = $api->getSystemDataValue('registerEnabled');
				if (!$registerOpen) {
					$displayEngine->setPageID('register')->setTitle('Register')->display('register_closed.tpl');
					return;
				}

				$requireTerms = $api->getSystemDataValue('registerRequireTerms');
				$displayEngine->setVar('requireTerms', $requireTerms);
				$displayEngine->setVar('termsText', systemGetTermsText());

				if ($router->getRequestMethod() == "POST") {
					$displayEngine->setVar('posted', $_POST);

					if (storage::get('recaptcha_state', 'unknown') !== 'passed') {
						$displayEngine->flash('error', '', 'Recaptcha failed.');
					} else if (!isset($_POST['inputEmail'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must enter an email address.');
					} else if (!isset($_POST['inputEmail2'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must confirm your email address.');
					} else if (!isset($_POST['inputName'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must enter a real name.');
					} else if ($requireTerms && !isset($_POST['acceptTerms'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must accept the terms of registration.');
					} else if ($_POST['inputEmail'] != $_POST['inputEmail2']) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: The email addresses entered did not match.');
					} else {
						$result = $api->register($_POST['inputEmail'], $_POST['inputName'], isset($_POST['acceptTerms']));

						if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error with the registration data: ' . $result['error']);
						} else {
							$displayEngine->flash('success', '', 'Your registration has been successful, please check your email for further instructions.');

							header('Location: ' . $displayEngine->getURL('/'));
							return;
						}
					}
				}

				$displayEngine->setPageID('register')->setTitle('Register')->display('register.tpl');
				return;
			});

			$router->match('GET|POST', '/register/verify/([^/]+)/([^/]+)', function($user, $code) use ($router, $displayEngine, $api) {
				if (session::isLoggedIn()) {
					$displayEngine->flash('error', '', 'You must be logged out to register a new account.');
					header('Location: ' . $displayEngine->getURL('/'));
					return;
				}

				if ($router->getRequestMethod() == "POST") {

					if (!isset($_POST['inputPassword'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must enter a password.');
					} else if (!isset($_POST['inputPassword2'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must confirm your password.');
					} else if ($_POST['inputPassword'] != $_POST['inputPassword2']) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: The passwords entered did not match.');
					} else {
						$result = $api->registerConfirm($user, $code, $_POST['inputPassword']);

						if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error with the registration data: ' . $result['error']);
						} else {
							if (array_key_exists('success', $result['response'])) {
								$displayEngine->flash('success', '', $result['response']['success']);
								header('Location: ' . $displayEngine->getURL('/login'));
							} else if (array_key_exists('pending', $result['response'])) {
								$displayEngine->flash('warning', '', $result['response']['pending']);
								header('Location: ' . $displayEngine->getURL('/'));
							}

							return;
						}
					}
				}

				$displayEngine->setPageID('register_verify')->setTitle('Registration Verify')->display('register_verify.tpl');
			});

			$router->match('GET|POST', '/forgotpassword', function() use ($router, $displayEngine, $api) {
				if (session::isLoggedIn()) {
					$displayEngine->flash('error', '', 'You must be logged out to request a password reminder.');
					header('Location: ' . $displayEngine->getURL('/'));
					return;
				}

				if ($router->getRequestMethod() == "POST") {
					$displayEngine->setVar('posted', $_POST);

					if (!isset($_POST['inputEmail'])) {
						$displayEngine->flash('error', '', 'There was an error: You must enter an email address.');
					} else {
						$result = $api->forgotpassword($_POST['inputEmail']);

						if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error: ' . $result['error']);
						} else {
							$displayEngine->flash('success', '', 'Your password reset request has been successful, please check your email for further instructions.');

							header('Location: ' . $displayEngine->getURL('/'));
							return;
						}
					}
				}

				$displayEngine->setPageID('forgotpassword')->setTitle('Forgot Password')->display('forgotpassword.tpl');
				return;
			});

			$router->match('GET|POST', '/forgotpassword/confirm/([^/]+)/([^/]+)', function($user, $code) use ($router, $displayEngine, $api) {
				if (session::isLoggedIn()) {
					$displayEngine->flash('error', '', 'You must be logged out to request a password reminder.');
					header('Location: ' . $displayEngine->getURL('/'));
					return;
				}

				if ($router->getRequestMethod() == "POST") {
					if (!isset($_POST['inputPassword'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must enter a password.');
					} else if (!isset($_POST['inputPassword2'])) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: You must confirm your password.');
					} else if ($_POST['inputPassword'] != $_POST['inputPassword2']) {
						$displayEngine->flash('error', '', 'There was an error with the registration data: The passwords entered did not match.');
					} else {
						$result = $api->forgotpasswordConfirm($user, $code, $_POST['inputPassword']);

						if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error: ' . $result['error']);
						} else {
							$displayEngine->flash('success', '', $result['response']['success']);
							header('Location: ' . $displayEngine->getURL('/login'));
							return;
						}
					}
				}

				$displayEngine->setPageID('forgotpassword_verify')->setTitle('Forgot Password Verify')->display('forgotpassword_verify.tpl');
			});

			$router->get('/(assets/.*)', function ($asset) use ($displayEngine) {
				$file = $displayEngine->getFile($asset);
				if ($file !== FALSE) {
					header('Content-Type: ' . get_mime_type($file));
					$displayEngine->displayRaw($asset);
					// echo file_get_contents($file);
				} else {
					header('HTTP/1.1 404 Not Found');
					$displayEngine->setPageID('404')->setTitle('Error 404')->display('404.tpl');
				}
			});

			$router->get('/loginsession/(.*)', function($sessionID) use ($displayEngine) {
				session::clear();
				session::set('logindata', ['type' => 'session', 'sessionid' => $sessionID]);
				header('Location: ' . $displayEngine->getURL('/'));
				return;
			});

			$router->set404(function() use ($displayEngine, $router) {
				if (session::exists('logindata')) {
					if ($displayEngine->getRestrictedMode()) {
						setWantedPage($displayEngine, $_SERVER['REQUEST_URI']);

						header('Location: ' . $displayEngine->getURL('/'));
					} else {
						header('HTTP/1.1 404 Not Found');
						$displayEngine->setPageID('404')->setTitle('Error 404')->display('404.tpl');
					}
				} else {
					setWantedPage($displayEngine, $_SERVER['REQUEST_URI']);

					header('Location: ' . $displayEngine->getURL('/login'));
					return;
				}
			});
		}
	}
