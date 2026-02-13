<?php
	class SystemJobsRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			if ($displayEngine->hasPermission(['system_job_mgmt'])) {
				$router->get('/system/jobs', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/jobs')->setTitle('System :: Jobs');

					$filter = isset($_REQUEST['filter']) ? $_REQUEST['filter'] : [];
					$page = isset($_REQUEST['page']) ? max(1, intval($_REQUEST['page'])) : 1;

					$params = ['filter' => $filter, 'page' => $page];
					$result = $api->api('/system/jobs/list?' . http_build_query($params));
					$data = isset($result['response']) ? $result['response'] : [];

					$displayEngine->setVar('jobs', isset($data['jobs']) ? $data['jobs'] : []);
					$displayEngine->setVar('pagination', isset($data['pagination']) ? $data['pagination'] : ['page' => 1, 'totalPages' => 1, 'total' => 0]);
					$displayEngine->setVar('filter', $filter);

					$displayEngine->display('system/job_list.tpl');
				});


				$router->get('/system/jobs/([0-9]+)', function($job) use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/jobs')->setTitle('System :: Jobs :: ' . $job);

					$displayEngine->setVar('jobid', $job);
					$jobinfo = $api->api('/system/jobs/' . $job);
					$jobdata = isset($jobinfo['response']) ? $jobinfo['response'] : [];

					// Pretty-print the JSON payload for display.
					if (isset($jobdata['data'])) {
						$decoded = json_decode($jobdata['data'], true);
						if ($decoded !== null) {
							$jobdata['data_formatted'] = json_encode($decoded, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
						} else {
							$jobdata['data_formatted'] = $jobdata['data'];
						}
					}

					$displayEngine->setVar('job', $jobdata);

					$displayEngine->display('system/job.tpl');
				});

				$router->get('/system/jobs/([0-9]+)/logs', function($job) use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/jobs')->setTitle('System :: Jobs :: ' . $job . ' :: Logs');

					$displayEngine->setVar('jobid', $job);

					$logs = $api->api('/system/jobs/' . $job . '/logs');
					$displayEngine->setVar('logs', isset($logs['response']) ? $logs['response'] : []);

					$displayEngine->display('system/job_logs.tpl');
				});

				$router->get('/system/jobs/([0-9]+)/repeat', function($job) use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/jobs')->setTitle('System :: Jobs :: ' . $job . ' :: Repeat');

					$result = $api->api('/system/jobs/' . $job . '/repeat');

					$displayEngine->setVar('result', isset($result['response']) ? $result['response'] : []);
					$displayEngine->setVar('error', isset($result['error']) ? $result['error'] : []);

					$displayEngine->display('system/job_repeat.tpl');
				});

			}

		}
	}
