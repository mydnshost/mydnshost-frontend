<?php
	class AuthedRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/logout', function() use ($displayEngine) {
				$displayEngine->flash('success', 'Success!', 'You have been logged out.');

				session::clear();
				session::setCurrentUser(null);

				header('Location: ' . $displayEngine->getURL('/'));
			});
		}
	}
