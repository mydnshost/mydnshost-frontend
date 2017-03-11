<?php
	class SiteRoutes {

		public function addRoutes($router, $displayEngine, $api) {
			$router->get('/', function() use ($displayEngine) {
				$displayEngine->display('index.tpl');
			});

			$router->get('/(assets/.*)', function ($asset) use ($displayEngine) {
				$file = $displayEngine->getFile($asset);
				if ($file !== FALSE) {
					header('Content-Type: ' . get_mime_type($file));
					echo file_get_contents($file);
				} else {
					header('HTTP/1.1 404 Not Found');
					$displayEngine->display('404.tpl');
				}
			});

			$router->set404(function() use ($displayEngine) {
				header('HTTP/1.1 404 Not Found');
				$displayEngine->display('404.tpl');
			});
		}
	}
