<?php
	class SystemServiceRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			if ($displayEngine->hasPermission(['system_service_mgmt'])) {
				$router->get('/system/services', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/services')->setTitle('System :: Services');

					$displayEngine->setVar('services', $api->getSystemServices());

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

					$page = isset($_REQUEST['page']) ? max(1, intval($_REQUEST['page'])) : 1;
					$stream = isset($_REQUEST['stream']) ? $_REQUEST['stream'] : '';
					$search = isset($_REQUEST['search']) ? $_REQUEST['search'] : '';

					$params = ['page' => $page];
					if ($stream !== '') { $params['stream'] = $stream; }
					if ($search !== '') { $params['search'] = $search; }

					$data = $api->getSystemServiceLogs($service, $params);

					$displayEngine->setVar('logs', isset($data['logs']) ? $data['logs'] : []);
					$displayEngine->setVar('pagination', isset($data['pagination']) ? $data['pagination'] : ['page' => 1, 'totalPages' => 1, 'total' => 0]);
					$displayEngine->setVar('filterStream', $stream);
					$displayEngine->setVar('filterSearch', $search);

					$displayEngine->display('system/service_logs.tpl');
				});

			}

		}
	}
