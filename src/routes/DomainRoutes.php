<?php
	use Twig\TwigFunction;

	class AdminDomainRoutes extends DomainRoutes {
		public function setAccessVars($displayEngine, $domainData) {
			parent::setAccessVars($displayEngine, $domainData);

			$displayEngine->setVar('has_admin_override', true);

			$displayEngine->setVar('has_domain_owner', true);
			$displayEngine->setVar('has_domain_admin', true);
			$displayEngine->setVar('has_domain_write', true);
			$displayEngine->setVar('has_domain_read', true);

			$displayEngine->setVar('domain_access_level', 'Owner (override)');
		}

		public function getURL($displayEngine, $location) {
			return $displayEngine->getURL('/admin/' . ltrim($location, '/'));
		}

		public function setPageID($displayEngine, $pageid) {
			return $displayEngine->setPageID('/admin/domains');
		}

		public function setVars($displayEngine) {
			$displayEngine->setVar('adminroute', true);
			$displayEngine->setVar('pathprepend', '/admin');

			$displayEngine->getTwig()->addFunction(new TwigFunction('hasHigherAccess', function($level) { return true; }));
		}
	}

	class DomainRoutes {

		public function setSubtitle($displayEngine, $domainData) {
			$rdns = getARPA($domainData['domain']);
			if ($rdns !== FALSE) {
				$displayEngine->setVar('subtitle', $rdns);
				$displayEngine->setVar('rdns', 'true');
			} else if (do_idn_to_ascii($domainData['domain']) != $domainData['domain']) {
				$displayEngine->setVar('subtitle', do_idn_to_ascii($domainData['domain']));
			}
		}

		public function setAccessVars($displayEngine, $domainData) {
			if (!isset($domainData['access'])) { $domainData['access'] = 'none'; }
			$displayEngine->setVar('has_domain_owner', in_array($domainData['access'], ['owner']));
			$displayEngine->setVar('has_domain_admin', in_array($domainData['access'], ['owner', 'admin']));
			$displayEngine->setVar('has_domain_write', in_array($domainData['access'], ['owner', 'admin', 'write']));
			$displayEngine->setVar('has_domain_read', in_array($domainData['access'], ['owner', 'admin', 'write', 'read']));

			$displayEngine->setVar('domain_access_level', $domainData['access']);
		}

		public function getURL($displayEngine, $location) {
			return $displayEngine->getURL($location);
		}

		public function setPageID($displayEngine, $pageid) {
			return $displayEngine->setPageID($pageid);
		}

		public function setVars($displayEngine) {
			$displayEngine->setVar('pathprepend', '');

			$displayEngine->getTwig()->addFunction(new TwigFunction('hasHigherAccess', function($level) use ($displayEngine) {
				$myAccess = $displayEngine->getVar('domain_access_level');
				if ($myAccess == 'owner') {
					return ($level == 'admin' || $level == 'write' || $level == 'read' || $level == 'none');
				} else if ($myAccess == 'admin') {
					return ($level == 'write' || $level == 'read' || $level == 'none');
				} else if ($myAccess == 'write') {
					return ($level == 'read' || $level == 'none');
				} else if ($myAccess == 'read') {
					return ($level == 'none');
				}

				return false;
			}));
		}

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/domains', function() use ($router, $displayEngine, $api) {
				$this->setVars($displayEngine);
				$this->setPageID($displayEngine, '/domains/')->setTitle('Domains');

				$domains = session::get('domains');
				$allDomains = [];
				foreach ($domains as $domain => $data) {
					$domainData = ['domain' => $domain, 'access' => $data['access'], 'verification' => $data['verification']];
					$rdns = getARPA($domain);
					if ($rdns !== FALSE) {
						$domainData['subtitle'] = 'RDNS: '. $rdns;
					} else if (do_idn_to_ascii($domain) != $domain) {
						$domainData['subtitle'] = do_idn_to_ascii($domain);
					}

					$allDomains[] = $domainData;
				}

				$displayEngine->setVar('domains', $allDomains);
				$displayEngine->setVar('domain_defaultpage', session::get('domain/defaultpage'));
				$displayEngine->display('alldomains.tpl');
			});

			$router->get('/domains/create', function() use ($router, $displayEngine, $api) {
				$this->setVars($displayEngine);
				$this->setPageID($displayEngine, '/domains/')->setTitle('Add Domain');
				$displayEngine->display('domain_create.tpl');
			});

			$router->post('/domains/create', function() use ($displayEngine, $api) {
				$this->setVars($displayEngine);
				$canUpdate = true;

				$fields = ['domainname' => 'You must specify a domain name to create'
				          ];

				foreach ($fields as $field => $error) {
					if (!array_key_exists($field, $_POST) || empty($_POST[$field])) {
						$canUpdate = false;
						$displayEngine->flash('error', '', 'There was an error creating the domain: ' . $error);
						break;
					}
				}

				if ($canUpdate) {
					$result = $api->createDomain($_POST['domainname'], isset($_POST['owner']) ? $_POST['owner'] : '');

					if (array_key_exists('error', $result)) {
						$errorData = $result['error'];
						if (array_key_exists('errorData', $result)) {
							$errorData .= ' => ' . is_array($result['errorData']) ? implode(' / ', $result['errorData']) : $result['errorData'];
						}
						$displayEngine->flash('error', '', 'There was an error creating the domain: ' . $errorData);
					} else {
						$displayEngine->flash('success', '', 'New domain ' . $_POST['domainname'] . ' has been created');
						header('Location: ' . $displayEngine->getURL($displayEngine->getVar('pathprepend') . '/domain/' . urlencode($_POST['domainname'])));
						return;
					}
				}

				header('Location: ' . $displayEngine->getURL($displayEngine->getVar('pathprepend') . '/domains'));
				return;
			});

			$router->get('/domains/findRecords', function() use ($router, $displayEngine, $api) {
				$this->setVars($displayEngine);
				$this->setPageID($displayEngine, '/domains/')->setTitle('Domains :: Find Records');

				$displayEngine->display('domains_findrecords.tpl');
			});

			$router->post('/domains/findRecords', function() use ($router, $displayEngine, $api) {
				$this->setVars($displayEngine);
				$this->setPageID($displayEngine, '/domains/')->setTitle('Domains :: Find Records');

				$recordContent = $_POST['recordContent'];

				$domains = $api->getDomains(['search' => true, 'content' => $recordContent]);

				$allDomains = [];
				foreach ($domains as $domain => $data) {
					$domainData = ['domain' => $domain, 'records' => $data['records']];
					$rdns = getARPA($domain);
					if ($rdns !== FALSE) {
						$domainData['subtitle'] = 'RDNS: '. $rdns;
					} else if (do_idn_to_ascii($domain) != $domain) {
						$domainData['subtitle'] = do_idn_to_ascii($domain);
					}

					$allDomains[] = $domainData;
				}

				$displayEngine->setVar('domains', $allDomains);
				$displayEngine->setVar('recordContent', $recordContent);
				$displayEngine->setVar('domain_defaultpage', session::get('domain/defaultpage'));
				$displayEngine->display('domains_findrecords.tpl');
			});

			$router->match('GET|POST', '/domain/([^/]+)', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain);

				if ($domainData !== NULL) {
					// Change SOA Stuff.
					if ($router->getRequestMethod() == "POST" && isset($_POST['changetype']) && $_POST['changetype'] == 'soa') {

						$data = ['disabled' => false, 'SOA' => [], 'aliasof' => ''];
						if (isset($_POST['disabled'])) {
							$data['disabled'] = $_POST['disabled'];
						}
						if (isset($_POST['defaultttl'])) {
							$data['defaultttl'] = $_POST['defaultttl'];
						}
						if (isset($_POST['soa'])) {
							$data['SOA'] = $_POST['soa'];
						}
						if (isset($_POST['aliasof'])) {
							$data['aliasof'] = $_POST['aliasof'];
						}

						if (isset($_POST['custom_label'])) {
							$data['userdata']['uk.co.mydnshost.www/domain/label'] = $_POST['custom_label'];
						}

						if (isset($_POST['custom_notes'])) {
							$data['userdata']['uk.co.mydnshost.www/domain/notes'] = $_POST['custom_notes'];
						}

						$result = $api->setDomainData($domain, $data);

						if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error with the data provided: ' . $result['error']);
						} else {
							$displayEngine->flash('success', '', 'Your changes have been saved.');

							header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain));
							return;
						}
					} else if ($router->getRequestMethod() == "POST" && isset($_POST['changetype']) && $_POST['changetype'] == 'access') {
						// Try to submit, to see if we have any errors.
						$data = ['access' => []];

						if (isset($_POST['removeselfaccess']) && parseBool($_POST['removeselfaccess'])) {
							$user = session::getCurrentUser();
							$data['access'][$user['user']['email']] = 'none';
						} else {
							$edited = isset($_POST['access']) ? $_POST['access'] : [];
							$new = isset($_POST['newAccess']) ? $_POST['newAccess'] : [];

							foreach ($edited as $id => $access) {
								$data['access'][$id] = $access['level'];
							}
							foreach ($new as $access) {
								$data['access'][$access['who']] = $access['level'];
							}
						}

						$result = $api->setDomainAccess($domain, $data);

						if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', ['There was an error: '. $result['error'], 'None of the changes have been saved. Please fix the problems and then try again.']);
						} else {
							$displayEngine->flash('success', '', 'Your changes have been saved.');

							header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain));
							return;
						}

						$displayEngine->setVar('newaccess', $new);
						$displayEngine->setVar('editedaccess', $edited);
					}

					$displayEngine->setVar('domain', $domainData);
					$this->setAccessVars($displayEngine, $domainData);
					$this->setSubtitle($displayEngine, $domainData);

					$da = $api->getDomainAccess($domain);
					$displayEngine->setVar('domainaccess', $da['access']);
					$displayEngine->setVar('userinfo', $da['userinfo']);

					$displayEngine->setVar('domainkeys', $api->getDomainKeys($domain));

					$displayEngine->setVar('domainhooks', $api->getDomainHooks($domain));

					$displayEngine->display('domain.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('domain_unknown.tpl');
				}
			});

			$router->post('/domain/([^/]+)/addkey(\.json)?', function($domain, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$apiresult = $api->createDomainKey($domain, ['description' => (isset($_POST['description']) ? $_POST['description'] : 'New Domain Key: ' . date('Y-m-d H:i:s'))]);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error adding the new Domain Key: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$returnedkeys = array_keys($apiresult['response']);
					$newkey = array_shift($returnedkeys);
					$result = ['success', 'New Domain Key Added: ' . $newkey];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
					return;
				}
			});

			$router->post('/domain/([^/]+)/editkey/([^/]+)(\.json)?', function($domain, $key, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$data = isset($_POST['key'][$key]) ? $_POST['key'][$key] : [];
				$apiresult = $api->updateDomainKey($domain, $key, $data);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error editing the key: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$result = ['success', 'Key edited.'];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
					return;
				}
			});

			$router->post('/domain/([^/]+)/deletekey/([^/]+)(\.json)?', function($domain, $key, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$apiresult = $api->deleteDomainKey($domain, $key);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error removing the key: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$result = ['success', 'Key removed.'];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
					return;
				}
			});

			$router->post('/domain/([^/]+)/addhook(\.json)?', function($domain, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);

				if (isset($_POST['hookurl'])) { $_POST['url'] = $_POST['hookurl']; unset($_POST['hookurl']); }
				if (isset($_POST['hookpassword'])) { $_POST['password'] = $_POST['hookpassword']; unset($_POST['hookpassword']); }

				$apiresult = $api->createDomainHook($domain, $_POST);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error adding the new Domain Hook: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$returnedhooks = array_keys($apiresult['response']);
					$newhook = array_shift($returnedhooks);
					$result = ['success', 'New Domain Hook Added: ' . $apiresult['response'][$newhook]['url']];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
					return;
				}
			});

			$router->post('/domain/([^/]+)/edithook/([^/]+)(\.json)?', function($domain, $hookid, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$data = isset($_POST['hook'][$hookid]) ? $_POST['hook'][$hookid] : [];
				$apiresult = $api->updateDomainHook($domain, $hookid, $data);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error editing the hook: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$result = ['success', 'Hook edited.'];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
					return;
				}
			});

			$router->post('/domain/([^/]+)/deletehook/([^/]+)(\.json)?', function($domain, $hookid, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$apiresult = $api->deleteDomainHook($domain, $hookid);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error removing the hook: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$result = ['success', 'Hook removed.'];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
					return;
				}
			});

			$router->match('GET|POST', '/domain/([^/]+)/records', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Records');

				if ($domainData !== NULL) {
					$records = [];

					// Handle POST first.
					if ($router->getRequestMethod() == "POST") {
						$submitted['edited'] = isset($_POST['record']) ? $_POST['record'] : [];
						$submitted['new'] = isset($_POST['newRecord']) ? $_POST['newRecord'] : [];

						$errorMap = [];

						// Try to submit, to see if we have any errors.
						$data = ['records' => []];
						foreach (['edited', 'new'] as $rtype) {
							foreach ($submitted[$rtype] as $id => $record) {
								if ($rtype == 'edited') {
									$record['id'] = $id;
								}

								$data['records'][] = $record;
								$errorMap[] = [$rtype, $id];
							}
						}

						$result = $api->setDomainRecords($domain, $data);

						if (array_key_exists('errorData', $result)) {
							$otherErrors = [];
							foreach ($result['errorData'] as $id => $error) {
								if (array_key_exists($id, $errorMap)) {
									list($rtype, $rid) = $errorMap[$id];

									if (startsWith($error, 'Unable to validate record:')) {
										$error = explode(':', $error, 2);
										$error = trim(isset($error[1]) ? $error[1] : $error[0]);
									}

									$submitted[$rtype][$rid]['errorData'] = $error;
								} else {
									$otherErrors[$id] = $error;
								}
							}
							$displayEngine->flash('error', '', 'There was some errors with some of the submitted records. None of the changes have been saved. Please fix the problems and then try again.');

							if (!empty($otherErrors)) {
								foreach ($otherErrors as $type => $data) {
									array_unshift($data, $type . ' failure:');
									$displayEngine->flash('error', '', $data);
								}
							}
						} else if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error: ' . $result['error']);
						} else {
							$displayEngine->flash('success', '', 'Your changes have been saved.');

							if (array_key_exists('zonecheck', $result['response'])) {
								$zonecheck = $result['response']['zonecheck'];
								if (!empty($zonecheck)) {
									$displayEngine->flash('info', '', $zonecheck);
								}
							}

							header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain . '/records'));
							return;
						}

						$recordInfo = $api->getDomainRecords($domain);
						$records = $recordInfo['records'];
						foreach ($records as &$record) {
							if (array_key_exists($record['id'], $submitted['edited'])) {
								if (array_key_exists('delete', $submitted['edited'][$record['id']])) {
									$record['deleted'] = true;
								} else {
									$record['edited'] = $submitted['edited'][$record['id']];

									if (array_key_exists('errorData', $submitted['edited'][$record['id']])) {
										$record['errorData'] = $submitted['edited'][$record['id']]['errorData'];
									}
								}
							}
						}

						$displayEngine->setVar('newRecords', $submitted['new']);
					} else {
						$recordInfo = $api->getDomainRecords($domain);
						$records = $recordInfo['records'];
					}

					// Set PTR info if applicable
					$rdns = getARPA($domainData['domain']);
					if ($rdns !== FALSE) {
						// echo '<pre>';
						foreach (array_keys($records) as $rid) {
							if ($records[$rid]['name'] !== '') {
								$rarpa = getFullARPAIP($records[$rid]['name'] . '.' . $domainData['domain']);
								if ($rarpa !== FALSE) {
									$records[$rid]['subtitle'] = $rarpa;
								}
							}
						}
					}

					$displayEngine->setVar('domain', $domainData);
					$this->setAccessVars($displayEngine, $domainData);
					$this->setSubtitle($displayEngine, $domainData);
					$displayEngine->setVar('records', $records);

					$hasNS = false;
					if (isset($recordInfo['hasNS'])) {
						$hasNS = $recordInfo['hasNS'];
					} else {
						// Find by hand if the API doesn't tell us.
						// This won't resolve RRCLONE records, but this shouldn't
						// matter as an API that supports RRCLONE will return
						// a hasNS result.
						foreach ($records as $r) {
							if ($r['type'] == 'NS' && !parseBool($r['disabled']) && $r['name'] === '') {
								$hasNS = true;
								break;
							}
						}
					}
					$displayEngine->setVar('hasNS', $hasNS);

					if (!$hasNS) {
						$defaultNS = [];
						$defaultRecords = $api->getSystemDataValue('defaultRecords');
						if (is_array($defaultRecords)) {
							foreach ($defaultRecords as $r) {
								if ($r['type'] == 'NS' && $r['name'] === '') {
									$defaultNS[] = $r['content'];
								}
							}

							if (!empty($defaultNS)) {
								$displayEngine->setVar('defaultNS', $defaultNS);
							}
						}
					}

					$displayEngine->display('domain_records.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('domain_unknown.tpl');
				}
			});

			$router->match('GET', '/domain/([^/]+)/export', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setAccessVars($displayEngine, $domainData);
				$this->setSubtitle($displayEngine, $domainData);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Export');

				$et = $api->getSystemDataValue('exportTypes', true);
				$displayEngine->setVar('exportTypes', $et['exportTypes']);
				$displayEngine->setVar('descriptions', $et['descriptions']);

				if ($domainData !== NULL) {
					$type = isset($_REQUEST['type']) ? $_REQUEST['type'] : NULL;
					$zone = $api->exportZone($domain, $type);

					$displayEngine->setVar('domain', $domainData);
					if (empty($zone)) {
						$lr = $api->getLastResponse();
						if (isset($lr['error'])) {
							$displayEngine->flash('error', '', 'There was an error exporting the zone: ' . $lr['error']);
						}
					} else {
						$displayEngine->setVar('zone', $zone);
					}

					$displayEngine->display('domain_export.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('domain_unknown.tpl');
				}
			});

			$router->match('GET', '/domain/([^/]+)/stats(\.json)?', function($domain, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setAccessVars($displayEngine, $domainData);
				$this->setSubtitle($displayEngine, $domainData);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Statistics');

				if ($domainData !== NULL) {
					$displayEngine->setVar('domain', $domainData);

					if ($json !== NULL) {
						header('Content-Type: application/json');

						// TODO: Reformat into data-table array.
						$stats = $api->getDomainStats($domain, ['type' => 'derivative']);

						$options = ['title' => 'Domain Queries-per-rrtype',
						            'hAxis' => ['title' => 'Time', 'titleTextStyle' => ['color' => '#333']],
						            'vAxis' => ['title' => 'Queries', 'minValue' => 0],
						            'isStacked' => false,
						           ];

						echo json_encode(['stats' => $stats, 'options' => $options, 'graphType' => 'area']);
						return;
					} else {
						$displayEngine->display('domain_stats.tpl');
					}
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('domain_unknown.tpl');
				}
			});

			$router->match('GET', '/domain/([^/]+)/logs', function($domain, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setAccessVars($displayEngine, $domainData);
				$this->setSubtitle($displayEngine, $domainData);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Logs');

				if ($domainData !== NULL) {
					$displayEngine->setVar('domain', $domainData);
					$displayEngine->setVar('logs', $api->getDomainLogs($domain));

					$displayEngine->display('domain_logs.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('domain_unknown.tpl');
				}
			});


			$router->match('GET|POST', '/domain/([^/]+)/import', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setAccessVars($displayEngine, $domainData);
				$this->setSubtitle($displayEngine, $domainData);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Import');

				$it = $api->getSystemDataValue('importTypes', true);
				$displayEngine->setVar('importTypes', $it['importTypes']);
				$displayEngine->setVar('descriptions', $it['descriptions']);

				if ($domainData !== NULL) {
					$displayEngine->setVar('domain', $domainData);
					$zone = '';
					if ($router->getRequestMethod() == "POST") {
						$zone = isset($_POST['zone']) ? $_POST['zone'] : '';
						$type = isset($_POST['type']) ? $_POST['type'] : NULL;
						$result = $api->importZone($domain, $zone, $type);

						if (array_key_exists('errorData', $result)) {
							$displayEngine->flash('error', '', 'There was an error importing the zone: ' . $result['errorData']);
						} else if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error importing the zone: ' . $result['error']);
						} else {
							$displayEngine->flash('success', '', 'The zone has been imported successfully.');

							header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain . '/records'));
							return;
						}
					}

					$displayEngine->setVar('zone', $zone);
					$displayEngine->setVar('type', $type);
					$displayEngine->display('domain_import.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('domain_unknown.tpl');
				}
			});


			$router->match('POST', '/domain/([^/]+)/delete', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				if (isset($_POST['confirm']) && parseBool($_POST['confirm'])) {
					$result = $api->deleteDomain($domain);

					if (array_key_exists('error', $result)) {
						$displayEngine->flash('error', '', 'There was an error deleting the domain.');
						header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
						return;
					} else {
						$displayEngine->flash('success', '', 'Domain ' . $domain . ' has been deleted.');
						header('Location: ' . $this->getURL($displayEngine, '/domains'));
						return;
					}
				} else {
					header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
					return;
				}
			});


			$router->match('GET', '/domain/([^/]+)/sync', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$api->syncDomain($domain);
				$displayEngine->flash('success', '', 'Domain ' . $domain . ' sync scheduled.');
				header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
				return;
			});

			$router->match('GET', '/domain/([^/]+)/verify', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$api->verifyDomain($domain);
				$displayEngine->flash('success', '', 'Domain ' . $domain . ' verification scheduled.');
				header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
				return;
			});
		}
	}
