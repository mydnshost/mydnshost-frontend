<?php
	class AuthedRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/logout', function() use ($displayEngine) {
				$displayEngine->flash('success', 'Success!', 'You have been logged out.');

				session::clear();
				session::setCurrentUser(null);

				header('Location: ' . $displayEngine->getURL('/'));
				return;
			});


			$router->get('/login', function() use ($displayEngine) {
				$displayEngine->flash('warning', 'Login failed', 'You are already logged in.');
				header('Location: ' . $displayEngine->getURL('/'));
				return;
			});

			$router->post('/login', function() use ($displayEngine) {
				$displayEngine->flash('warning', 'Login failed', 'You are already logged in.');
				header('Location: ' . $displayEngine->getURL('/'));
				return;
			});

			$router->get('/impersonate/cancel', function() use ($displayEngine, $api) {
				$person = session::getCurrentUser();
				$displayEngine->flash('info', '', 'You are no longer impersonating: ' . $person['user']['realname'] . ' (' . $person['user']['email'] . ')');

				session::clear(['logindata', 'DisplayEngine::Flash', 'csrftoken']);

				header('Location: ' . $displayEngine->getURL('/admin/users'));
				return;
			});

			$router->post('/checkauth', function() use ($router, $displayEngine, $api) {
				$pass = $_POST['pass'];
				$key = isset($_POST['key']) ? $_POST['key'] : NULL;

				$user = session::getCurrentUser();
				if (isset($user['user'])) {
					$testApi = clone $api;
					$testApi->setAuthUserPass($user['user']['email'], $pass, $key);
					$result = $testApi->validAuth();

					if (!$result && $key === NULL) {
						$last = $testApi->getLastResponse();
						$err = isset($last['errorData'][0]) ? $last['errorData'][0] : (isset($last['errorData']) ? $last['errorData']: '');

						if ($err == '2FA key required.') {
							$result = true;
						}
					}

					if ($result) {
						session::set('lastAuthTime', time());
						$displayEngine->flash('success', '', 'You have successfully re-authenticated.');
					} else {
						session::remove('lastAuthTime');
						$displayEngine->flash('error', 'Incorrect password', 'You provided the wrong password.');
					}
				} else {
					session::remove('lastAuthTime');
					$displayEngine->flash('error', 'Invalid session type.', 'You can not re-authenticate this session.');
				}

				$redirect = isset($_POST['redirect']) ? $_POST['redirect'] : '/';
				header('Location: ' . $displayEngine->getURL($redirect));
				return;
			});

			$router->post('/unauth', function() use ($router, $displayEngine, $api) {
				session::remove('lastAuthTime');
				$displayEngine->flash('success', '', 'You have now de-authenticated.');
				$redirect = isset($_POST['redirect']) ? $_POST['redirect'] : '/';
				header('Location: ' . $displayEngine->getURL($redirect));
				return;
			});

		}
	}
