<?php
	class SystemJobsRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			if ($displayEngine->hasPermission(['system_job_mgmt'])) {
				$router->get('/system/jobs', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/jobs')->setTitle('System :: Jobs');

					$filter = isset($_REQUEST['filter']) ? $_REQUEST['filter'] : [];
					$page = isset($_REQUEST['page']) ? max(1, intval($_REQUEST['page'])) : 1;

					// Fold filter_data_key/filter_data_value into filter[data][key]=value.
					if (!empty($_REQUEST['filter_data_key']) && isset($_REQUEST['filter_data_value']) && $_REQUEST['filter_data_value'] !== '') {
						if (!isset($filter['data'])) { $filter['data'] = []; }
						$filter['data'][$_REQUEST['filter_data_key']] = $_REQUEST['filter_data_value'];
					}

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

				$router->post('/system/jobs/create', function() use ($displayEngine, $api) {
					$name = isset($_POST['name']) ? trim($_POST['name']) : '';
					$data = isset($_POST['data']) ? trim($_POST['data']) : '';

					if ($name === '') {
						$displayEngine->flash('error', '', 'Job name is required.');
						header('Location: ' . $displayEngine->getURL('/system/jobs'));
						return;
					}

					if ($data === '') {
						$displayEngine->flash('error', '', 'Job payload is required.');
						header('Location: ' . $displayEngine->getURL('/system/jobs'));
						return;
					}

					$decoded = json_decode($data, true);
					if ($decoded === null && $data !== 'null') {
						$displayEngine->flash('error', '', 'Job payload must be valid JSON.');
						header('Location: ' . $displayEngine->getURL('/system/jobs'));
						return;
					}

					$apiData = ['name' => $name, 'data' => $decoded];

					$dependsOn = isset($_POST['dependsOn']) ? intval($_POST['dependsOn']) : 0;
					if ($dependsOn > 0) {
						$apiData['dependsOn'] = $dependsOn;
					}

					$result = $api->api('/system/jobs/create', 'POST', $apiData);

					if (array_key_exists('error', $result)) {
						$displayEngine->flash('error', '', 'Error creating job: ' . $result['error']);
						header('Location: ' . $displayEngine->getURL('/system/jobs'));
					} else {
						$jobid = isset($result['response']['jobid']) ? $result['response']['jobid'] : '';
						$status = isset($result['response']['status']) ? $result['response']['status'] : 'Job scheduled.';
						$displayEngine->flash('success', '', $status . ($jobid ? ' Job ID: ' . $jobid : ''));
						header('Location: ' . $displayEngine->getURL('/system/jobs/' . $jobid));
					}
					return;
				});

			$router->get('/system/jobs/([0-9]+)/logs', function($job) use ($displayEngine) {
					header('Location: ' . $displayEngine->getURL('/system/jobs/' . $job));
					return;
				});

				$router->get('/system/jobs/([0-9]+)/cancel', function($job) use ($displayEngine, $api) {
					$result = $api->api('/system/jobs/' . $job . '/cancel');

					if (array_key_exists('error', $result)) {
						$displayEngine->flash('error', '', 'Error cancelling job: ' . $result['error']);
						header('Location: ' . $displayEngine->getURL('/system/jobs/' . $job));
					} else {
						$displayEngine->flash('success', '', isset($result['response']['status']) ? $result['response']['status'] : 'Job cancelled.');
						header('Location: ' . $displayEngine->getURL('/system/jobs'));
					}
					return;
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
