<?php
	class NotAuthedRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/login', function() use ($displayEngine) {
				$displayEngine->setPageID('login');
				$displayEngine->displayRaw('login.tpl');
			});

			$router->post('/login', function() use ($displayEngine, $api) {
				$user = $_POST['user'];
				$pass = $_POST['pass'];

				$api->setAuthUserPass($user, $pass);
				$sessionID = $api->getSessionID();

				if ($sessionID !== NULL) {
					$displayEngine->flash('success', 'Success!', 'You are now logged in.');

					session::set('logindata', ['type' => 'session', 'sessionid' => $sessionID]);
					header('Location: ' . $displayEngine->getURL('/'));
					return;
				} else {
					$displayEngine->flash('error', 'Login Error', 'There was an error with the details provided.');

					session::setCurrentUser(null);
					header('Location: ' . $displayEngine->getURL('/login'));
					return;
				}
			});
		}
	}
