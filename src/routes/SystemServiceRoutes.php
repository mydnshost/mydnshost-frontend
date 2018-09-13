<?php
	class SystemServiceRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			if ($displayEngine->hasPermission(['system_service_mgmt'])) {
				$router->get('/system/services', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/services')->setTitle('System :: Services');

					$services = $api->api('/system/service/list');
					$displayEngine->setVar('services', $services);

					$displayEngine->display('system/service_list.tpl');
				});


				$router->get('/system/services/([^/]+)', function($service) use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/services')->setTitle('System :: Service :: ' . $service);

					$displayEngine->setVar('service', $service);
					$displayEngine->display('system/service.tpl');
				});

				$router->get('/system/services/([^/]+)/logs', function($service) use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/services')->setTitle('System :: Service :: ' . $service . ' :: Logs');

					$displayEngine->setVar('service', $service);

					$logs = $api->api('/system/service/' . $service . '/logs');
					$displayEngine->setVar('logs', $logs);

					$displayEngine->display('system/service_logs.tpl');
				});

			}

		}
	}
