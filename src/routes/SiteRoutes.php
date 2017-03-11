<?php
	class SiteRoutes {

		public function addRoutes($router, $displayEngine, $api) {
			$router->get('/', function() use ($displayEngine) {
				if (!session::isLoggedIn()) {
					header('Location: ' . $displayEngine->getURL('/login'));
				} else {
					$displayEngine->setPageID('home')->setTitle('Home')->display('index.tpl');
				}
			});

			$router->get('/(assets/.*)', function ($asset) use ($displayEngine) {
				$file = $displayEngine->getFile($asset);
				if ($file !== FALSE) {
					header('Content-Type: ' . get_mime_type($file));
					echo file_get_contents($file);
				} else {
					header('HTTP/1.1 404 Not Found');
					$displayEngine->setPageID('404')->setTitle('Error 404')->display('404.tpl');
				}
			});

			$router->set404(function() use ($displayEngine) {
				header('HTTP/1.1 404 Not Found');
				$displayEngine->setPageID('404')->setTitle('Error 404')->display('404.tpl');
			});
		}
	}
