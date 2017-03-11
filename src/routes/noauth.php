<?php
	class NoAuthRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/login', function() use ($displayEngine) {
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
					die();
				} else {
					$displayEngine->flash('error', 'Login Error', 'There was an error with the details provided.');

					header('Location: ' . $displayEngine->getURL('/login'));
				}
			});
		}
	}
