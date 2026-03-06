<?php
	class SystemAuditLogRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			if ($displayEngine->hasPermission(['system_audit_log'])) {
				$router->get('/system/audit', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/audit')->setTitle('System :: Audit Log');

					$filter = isset($_REQUEST['filter']) ? $_REQUEST['filter'] : [];
					$page = isset($_REQUEST['page']) ? max(1, intval($_REQUEST['page'])) : 1;

					$params = ['filter' => $filter, 'page' => $page];
					$data = $api->getAuditLog($params);

					$displayEngine->setVar('entries', isset($data['entries']) ? $data['entries'] : []);
					$displayEngine->setVar('pagination', isset($data['pagination']) ? $data['pagination'] : ['page' => 1, 'totalPages' => 1, 'total' => 0]);
					$displayEngine->setVar('filter', $filter);

					$displayEngine->display('system/audit_log_list.tpl');
				});

				$router->get('/system/audit/([0-9]+)', function($id) use ($displayEngine, $api) {
					$displayEngine->setPageID('/system/audit')->setTitle('System :: Audit Log :: #' . $id);

					$displayEngine->setVar('entryid', $id);
					$entry = $api->getAuditEntry($id) ?? [];

					if (isset($entry['args'])) {
						$decoded = is_string($entry['args']) ? json_decode($entry['args'], true) : $entry['args'];
						if ($decoded !== null) {
							// Recursively decode JSON strings within args
							$expandJson = function($val) use (&$expandJson) {
								if (is_string($val)) {
									$try = json_decode($val, true);
									if ($try !== null && (is_array($try) || is_object($try))) {
										return $expandJson($try);
									}
								} else if (is_array($val)) {
									foreach ($val as $k => $v) {
										$val[$k] = $expandJson($v);
									}
								}
								return $val;
							};
							$expanded = $expandJson($decoded);
							$entry['args_formatted'] = json_encode($expanded, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
						} else {
							$entry['args_formatted'] = is_string($entry['args']) ? $entry['args'] : json_encode($entry['args']);
						}
					}

					$displayEngine->setVar('entry', $entry);

					$displayEngine->display('system/audit_log_entry.tpl');
				});
			}

		}
	}
