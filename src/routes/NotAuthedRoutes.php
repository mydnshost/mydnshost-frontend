<?php
	class NotAuthedRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/login', function() use ($displayEngine) {
				$displayEngine->setPageID('login');
				$displayEngine->display('login.tpl');
			});

			$router->post('/login', function() use ($displayEngine, $api) {
				$user = $_POST['user'];
				$pass = $_POST['pass'];
				$key = $_POST['2fakey'];

				$api->setAuthUserPass($user, $pass, $key);
				$sessionID = $api->getSessionID();

				if ($sessionID !== NULL) {
					$displayEngine->flash('success', 'Success!', 'You are now logged in.');

					session::set('logindata', ['type' => 'session', 'sessionid' => $sessionID]);
					session::set('csrftoken', genUUID());
					header('Location: ' . $displayEngine->getURL('/'));
					return;
				} else {
					$lr = $api->getLastResponse();

					if (isset($lr['errorData'])) {
						$displayEngine->flash('error', 'Login Error', 'There was an error with the details provided: ' . $lr['errorData']);
					} else {
						$displayEngine->flash('error', 'Login Error', 'There was an error with the details provided.');
					}

					session::setCurrentUser(null);
					session::clear(['DisplayEngine::Flash']);
					header('Location: ' . $displayEngine->getURL('/login'));
					return;
				}
			});
		}
	}
