<?php
	class AdminDomainRoutes extends DomainRoutes {
		public function setAccessVars($displayEngine, $domainData) {
			parent::setAccessVars($displayEngine, $domainData);

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

			$displayEngine->getTwig()->addFunction(new Twig_Function('canChangeAccess', function($email) { return true; }));
		}
	}

	class DomainRoutes {

		public function setSubtitle($displayEngine, $domainData) {
			$rdns = getARPA($domainData['domain']);
			if ($rdns !== FALSE) {
				$displayEngine->setVar('subtitle', $rdns);
			} else if (idn_to_ascii($domainData['domain']) != $domainData['domain']) {
				$displayEngine->setVar('subtitle', idn_to_ascii($domainData['domain']));
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

			$displayEngine->getTwig()->addFunction(new Twig_Function('canChangeAccess', function($email) { return $email != session::getCurrentUser()['user']['email']; }));
		}

		public function addRoutes($router, $displayEngine, $api) {

			$router->get('/domains', function() use ($router, $displayEngine, $api) {
				$this->setVars($displayEngine);
				$this->setPageID($displayEngine, '/domains/')->setTitle('Domains');

				$domains = $api->getDomains();
				$allDomains = [];
				foreach ($domains as $domain => $access) {
					$domainData = ['domain' => $domain, 'access' => $access];
					$rdns = getARPA($domain);
					if ($rdns !== FALSE) {
						$domainData['subtitle'] = 'RDNS: '. $rdns;
					} else if (idn_to_ascii($domain) != $domain) {
						$domainData['subtitle'] = idn_to_ascii($domain);
					}

					$allDomains[] = $domainData;
				}
				$displayEngine->setVar('domains', $allDomains);
				$displayEngine->setVar('domain_defaultpage', session::get('domain/defaultpage'));
				$displayEngine->display('alldomains.tpl');
			});

			$router->get('/domains/create', function() use ($router, $displayEngine, $api) {
				$this->setVars($displayEngine);
				$this->setPageID($displayEngine, '/admin/domains/')->setTitle('Add Domain');
				$displayEngine->display('createdomain.tpl');
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
							$errorData .= ' => ' . $result['errorData'];
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

			$router->match('GET|POST', '/domain/([^/]+)', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain);

				if ($domainData !== NULL) {
					// Change SOA Stuff.
					if ($router->getRequestMethod() == "POST" && isset($_POST['changetype']) && $_POST['changetype'] == 'soa') {

						$data = ['disabled' => false, 'SOA' => []];
						if (isset($_POST['disabled'])) {
							$data['disabled'] = $_POST['disabled'];
						}
						if (isset($_POST['defaultttl'])) {
							$data['defaultttl'] = $_POST['defaultttl'];
						}
						if (isset($_POST['soa'])) {
							$data['SOA'] = $_POST['soa'];
						}

						$result = $api->setDomainData($domain, $data);

						if (array_key_exists('error', $result)) {
							$displayEngine->flash('error', '', 'There was an error with the soa data provided.');
						} else {
							$displayEngine->flash('success', '', 'Your changes have been saved.');

							header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain));
							return;
						}
					} else if ($router->getRequestMethod() == "POST" && isset($_POST['changetype']) && $_POST['changetype'] == 'access') {
						$edited = isset($_POST['access']) ? $_POST['access'] : [];
						$new = isset($_POST['newAccess']) ? $_POST['newAccess'] : [];

						// Try to submit, to see if we have any errors.
						$data = ['access' => []];
						foreach ($edited as $id => $access) {
							$data['access'][$id] = $access['level'];
						}
						foreach ($new as $access) {
							$data['access'][$access['who']] = $access['level'];
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

					$domains = session::get('domains');
					if (isset($domains[$domainData['domain']])) {
						$domainData['access'] = $domains[$domainData['domain']];
					}
					$displayEngine->setVar('domain', $domainData);
					$this->setAccessVars($displayEngine, $domainData);
					$this->setSubtitle($displayEngine, $domainData);

					$displayEngine->setVar('domainaccess', $api->getDomainAccess($domain));

					$displayEngine->setVar('domainkeys', $api->getDomainKeys($domain));

					$displayEngine->setVar('domainhooks', $api->getDomainHooks($domain));

					$displayEngine->display('domain.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('unknown_domain.tpl');
				}
			});

			$router->post('/domain/([^/]+)/addkey(\.json)?', function($domain, $json = NULL) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$apiresult = $api->createDomainKey($domain, ['description' => (isset($_POST['description']) ? $_POST['description'] : 'New Domain Key: ' . date('Y-m-d H:i:s'))]);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error adding the new Domain Key: ' . $apiresult['errorData']];
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
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error editing the key: ' . $apiresult['errorData']];
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
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error removing the key: ' . $apiresult['errorData']];
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
				$apiresult = $api->createDomainHook($domain, $_POST);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error adding the new Domain Hook: ' . $apiresult['errorData']];
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
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error editing the hook: ' . $apiresult['errorData']];
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
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error removing the hook: ' . $apiresult['errorData']];
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
							foreach ($result['errorData'] as $id => $error) {
								if (array_key_exists($id, $errorMap)) {
									list($rtype, $rid) = $errorMap[$id];

									if (startsWith($error, 'Unable to validate record:')) {
										$error = explode(':', $error, 2);
										$error = trim(isset($error[1]) ? $error[1] : $error[0]);
									}

									$submitted[$rtype][$rid]['errorData'] = $error;
								}
							}
							$displayEngine->flash('error', '', 'There was some errors with some of the submitted records. None of the changes have been saved. Please fix the problems and then try again.');
						} else {
							$displayEngine->flash('success', '', 'Your changes have been saved.');

							header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain . '/records'));
							return;
						}

						$records = $api->getDomainRecords($domain);
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
						$records = $api->getDomainRecords($domain);
					}

					$domains = session::get('domains');
					if (isset($domains[$domainData['domain']])) {
						$domainData['access'] = $domains[$domainData['domain']];
					}
					$displayEngine->setVar('domain', $domainData);
					$this->setAccessVars($displayEngine, $domainData);
					$this->setSubtitle($displayEngine, $domainData);
					$displayEngine->setVar('records', $records);

					$displayEngine->display('domain_records.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('unknown_domain.tpl');
				}
			});

			$router->match('GET', '/domain/([^/]+)/export', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setAccessVars($displayEngine, $domainData);
				$this->setSubtitle($displayEngine, $domainData);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Export');

				if ($domainData !== NULL) {
					$zone = $api->exportZone($domain);

					$displayEngine->setVar('domain', $domainData);
					$displayEngine->setVar('zone', $zone);

					$displayEngine->display('export_domain.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('unknown_domain.tpl');
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
					$displayEngine->display('unknown_domain.tpl');
				}
			});


			$router->match('GET|POST', '/domain/([^/]+)/import', function($domain) use ($router, $displayEngine, $api) {
				$domain = urldecode($domain);
				$this->setVars($displayEngine);

				$domainData = $api->getDomainData($domain);
				$this->setAccessVars($displayEngine, $domainData);
				$this->setSubtitle($displayEngine, $domainData);
				$this->setPageID($displayEngine, '/domain/' . $domain)->setTitle('Domain :: ' . $domain . ' :: Import');

				if ($domainData !== NULL) {
					$displayEngine->setVar('domain', $domainData);
					$zone = '';
					if ($router->getRequestMethod() == "POST") {
						$zone = isset($_POST['zone']) ? $_POST['zone'] : '';
						$result = $api->importZone($domain, $zone);

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
					$displayEngine->display('import_domain.tpl');
				} else {
					$displayEngine->setVar('unknowndomain', $domain);
					$displayEngine->display('unknown_domain.tpl');
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
				$displayEngine->flash('success', '', 'Domain ' . $domain . ' has been synced.');
				header('Location: ' . $this->getURL($displayEngine, '/domain/' . $domain ));
				return;
			});
		}
	}
