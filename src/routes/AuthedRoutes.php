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
				$person = session::get('impersonate');
				$displayEngine->flash('info', '', 'You are no longer impersonating: ' . $person);

				session::clear(['logindata', 'DisplayEngine::Flash']);

				header('Location: ' . $displayEngine->getURL('/admin/users'));
				return;
			});
		}
	}
