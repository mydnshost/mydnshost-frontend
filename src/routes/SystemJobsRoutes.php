<?php
	class SystemJobsRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			if ($displayEngine->hasPermission(['system_job_mgmt'])) {
				$router->get('/system/jobs', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/jobs')->setTitle('System :: Jobs');

					$filter = isset($_REQUEST['filter']) ? $_REQUEST['filter'] : [];

					$jobs = $api->api('/system/jobs/list?' . http_build_query(['filter' => $filter]));
					$displayEngine->setVar('jobs', isset($jobs['response']) ? $jobs['response'] : []);

					$displayEngine->display('system/job_list.tpl');
				});


				$router->get('/system/jobs/([0-9]+)', function($job) use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/jobs')->setTitle('System :: Jobs :: ' . $job);

					$displayEngine->setVar('jobid', $job);
					$jobinfo = $api->api('/system/jobs/' . $job);
					$displayEngine->setVar('job', isset($jobinfo['response']) ? $jobinfo['response'] : []);

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
