<?php
	class NotAuthedRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/login', function() use ($displayEngine) {
				$displayEngine->setTitle('login');
				$displayEngine->setPageID('login');
				$displayEngine->display('login.tpl');
			});

			$router->get('/2fa', function() use ($displayEngine) {
				$displayEngine->setTitle('2fa');
				$displayEngine->setPageID('2fa');
				$displayEngine->display('2fa.tpl');
			});

			$router->post('/login', function() use ($displayEngine, $api) {
				if (isset($_POST['2fakey']) && session::exists('lastlogin')) {
					$lastAttempt = session::get('lastlogin');
					session::remove('lastlogin');

					$user = $lastAttempt['user'];
					$pass = $lastAttempt['pass'];

					$key = $_POST['2fakey'];
				} else {
					$user = $_POST['user'];
					$pass = $_POST['pass'];
					$key = '';
				}

				$api->setAuthUserPass($user, $pass, $key);
				$sessionID = $api->getSessionID();

				if ($sessionID !== NULL) {
					$displayEngine->flash('success', 'Success!', 'You are now logged in.');

					session::set('logindata', ['type' => 'session', 'sessionid' => $sessionID]);
					session::set('csrftoken', genUUID());

					if (session::exists('wantedPage')) {
						header('Location: ' . $displayEngine->getURL(session::get('wantedPage')));
						session::remove('wantedPage');
					} else {
						header('Location: ' . $displayEngine->getURL('/'));
					}
					return;
				} else {
					$lr = $api->getLastResponse();

					session::setCurrentUser(null);
					if (isset($lr['login_error']) && $lr['login_error'] == '2fa_required') {
						session::set('lastlogin', $_POST);
						header('Location: ' . $displayEngine->getURL('/2fa'));
					} else {
						if (isset($lr['errorData'])) {
							$displayEngine->flash('error', 'Login Error', 'There was an error with the details provided: ' . $lr['errorData']);
						} else {
							$displayEngine->flash('error', 'Login Error', 'There was an error with the details provided.');
						}

						session::clear(['DisplayEngine::Flash', 'wantedPage']);
						header('Location: ' . $displayEngine->getURL('/login'));
					}

					return;
				}
			});
		}
	}
