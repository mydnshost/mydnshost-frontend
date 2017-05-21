<?php
	class SiteRoutes {

		public function addRoutes($router, $displayEngine, $api) {
			$router->get('/', function() use ($displayEngine) {
				if (!session::isLoggedIn()) {
					$displayEngine->setPageID('home')->setTitle('Home')->display('index.tpl');
					return;
				} else {
					$displayEngine->setPageID('home')->setTitle('Home')->display('home.tpl');
				}
			});

			$router->get('/register', function() use ($displayEngine) {
				if (!session::isLoggedIn()) {
					$displayEngine->setPageID('register')->setTitle('Register')->display('register.tpl');
					return;
				} else {
					header('Location: ' . $displayEngine->getURL('/'));
					return;
				}
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

			$router->set404(function() use ($displayEngine) {
				if (session::exists('logindata')) {
					header('HTTP/1.1 404 Not Found');
					$displayEngine->setPageID('404')->setTitle('Error 404')->display('404.tpl');
				} else {
					header('Location: ' . $displayEngine->getURL('/login'));
					return;
				}
			});
		}
	}
