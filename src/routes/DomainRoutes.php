<?php
	class DomainRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/domain/([^/]+)', function($domain) use ($displayEngine, $api) {
				$data = $api->getDomainData($domain);
				$displayEngine->setPageID('/domain/' . $domain)->setTitle('Domain :: ' . $domain);

				if ($data !== NULL) {
					$domains = session::get('domains');
					if (isset($domains[$domain])) {
						$data['access'] = $domains[$domain];
					}
					$displayEngine->setVar('domain', $data);

					$displayEngine->setVar('domainaccess', $api->getDomainAccess($domain));

					$displayEngine->display('domain.tpl');
				} else {
					$displayEngine->display('unknown_domain.tpl');
				}
			});

			$router->get('/domain/([^/]+)/records', function($domain) use ($displayEngine, $api) {
				$data = $api->getDomainData($domain);
				$records = $api->getDomainRecords($domain);
				$displayEngine->setPageID('/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Records');

				if ($records !== NULL) {
					$domains = session::get('domains');
					if (isset($domains[$domain])) {
						$data['access'] = $domains[$domain];
					}
					$displayEngine->setVar('domain', $data);
					$displayEngine->setVar('records', $records);

					$displayEngine->display('domain_records.tpl');
				} else {
					$displayEngine->display('unknown_domain.tpl');
				}
			});
		}
	}
