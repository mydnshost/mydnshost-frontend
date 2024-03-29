<?php
	class UserRoutes {

		public function checkAuthTimeOrError($displayEngine, $json = NULL, $seconds = 900) {
			if (session::checkAuthTime($seconds)) { return TRUE; }

			if ($json !== NULL) {
				header('Content-Type: application/json');
				echo json_encode(['error' => 'You must reauthenticate to make changes to keys.']);
			} else {
				$displayEngine->flash('error', '', 'You must reauthenticate to make changes to keys.');
				header('Location: ' . $displayEngine->getURL('/profile'));
			}

			return;
		}

		public function addRoutes($router, $displayEngine, $api) {
			$myUser = session::getCurrentUser();
			if (!isset($myUser['user'])) { return; }

			$router->match('GET|POST', '/profile', function() use ($router, $displayEngine, $api) {
				$displayEngine->setPageID('/profile')->setTitle('Profile');

				if ($router->getRequestMethod() == "POST" && isset($_POST['changetype']) && $_POST['changetype'] == 'profile') {
					$canUpdate = true;
					if (isset($_POST['password']) || isset($_POST['confirmpassword'])) {
						$pass = isset($_POST['password']) ? $_POST['password'] : NULL;
						$confirmpass = isset($_POST['confirmpassword']) ? $_POST['confirmpassword'] : NULL;

						if ($pass != $confirmpass) {
							$canUpdate = false;
							$displayEngine->flash('error', '', 'There was an error updating your profile data: Passwords do not match.');
						}

						if (empty($pass)) {
							unset($_POST['password']);
							unset($_POST['confirmpassword']);
						}
					}

					if ($canUpdate) {
						unset($_POST['customdata']);

						if (isset($_POST['domain_defaultpage']) && in_array($_POST['domain_defaultpage'], ['records', 'details'])) {
							$_POST['customdata']['uk.co.mydnshost.www/domain/defaultpage'] = $_POST['domain_defaultpage'];
						}

						if (isset($_POST['sidebar_layout']) && in_array($_POST['sidebar_layout'], ['access', 'labels'])) {
							$_POST['customdata']['uk.co.mydnshost.www/sidebar/layout'] = $_POST['sidebar_layout'];
						}

						$knownThemes = getThemeInformation();
						if (isset($_POST['sitetheme']) && in_array($_POST['sitetheme'], array_keys($knownThemes))) {
							$_POST['customdata']['uk.co.mydnshost.www/sitetheme'] = $_POST['sitetheme'];
						}

						$result = $api->setUserInfo($_POST);

						if (array_key_exists('error', $result)) {
							if (!array_key_exists('errorData', $result)) {
								$displayEngine->flash('error', '', 'There was an error updating your profile data: ' . $result['error']);
							} else {
								$result['errorData'] = ['Unspecified error. (Email address already in use?)'];
								$displayEngine->flash('error', '', 'There was an error updating your profile data: ' . implode(', ', $result['errorData']));
							}
						} else {
							$displayEngine->flash('success', '', 'Your changes have been saved.');

							header('Location: ' . $displayEngine->getURL('/profile'));
							return;
						}
					}
				}

				if (session::checkAuthTime()) {
					$keys = $api->getAPIKeys();
					$displayEngine->setVar('apikeys', $keys);

					$keys = $api->get2FAKeys();

					if (session::exists('new2fakey')) {
						$newkey = session::get('new2fakey');
						session::remove('new2fakey');

						$keys[$newkey['id']] = $newkey;
					}

					$displayEngine->setVar('twofactorkeys', $keys);

					$displayEngine->setVar('twofactordevices', $api->get2FADevices());
					$displayEngine->setVar('twoFactorKeyTypes', $api->getSystemDataValue('2faKeyTypes'));
				}

				$displayEngine->setVar('candelete', $api->getSystemDataValue('selfDelete'));

				$displayEngine->setVar('domain_defaultpage', session::get('domain/defaultpage'));
				$displayEngine->setVar('sidebar_layout', session::get('sidebar/layout'));
				$displayEngine->display('profile.tpl');
			});

			$router->match('GET', '/profile/stats(\.json)?', function($json = NULL) use ($router, $displayEngine, $api) {
				$displayEngine->setPageID('/profile')->setTitle('Profile :: Statistics');

				if ($json !== NULL) {
					header('Content-Type: application/json');

					// TODO: Reformat into data-table array.
					$stats = $api->getUserStats('domains', ['type' => 'derivative']);

					$options = ['title' => 'Queries-per-domain',
					            'hAxis' => ['title' => 'Time', 'titleTextStyle' => ['color' => '#333']],
					            'vAxis' => ['title' => 'Queries', 'minValue' => 0],
					            'isStacked' => false,
					           ];

					echo json_encode(['stats' => $stats, 'options' => $options, 'graphType' => 'area']);
					return;
				} else {
					$displayEngine->display('profile_stats.tpl');
				}
			});


			$router->post('/profile/addkey(\.json)?', function($json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$apiresult = $api->createAPIKey(['description' => (isset($_POST['description']) ? $_POST['description'] : 'New API Key: ' . date('Y-m-d H:i:s'))]);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error adding the new API Key: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$returnedkeys = array_keys($apiresult['response']);
					$newkey = array_shift($returnedkeys);
					$result = ['success', 'New API Key Added: ' . $newkey];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});

			$router->post('/profile/editkey/([^/]+)(\.json)?', function($key, $json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$data = isset($_POST['key'][$key]) ? $_POST['key'][$key] : [];
				$apiresult = $api->updateAPIKey($key, $data);
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
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});

			$router->post('/profile/deletekey/([^/]+)(\.json)?', function($key, $json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$apiresult = $api->deleteAPIKey($key);
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
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});

			$router->post('/profile/delete2fadevice/([^/]+)(\.json)?', function($device, $json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$apiresult = $api->delete2FADevice($device);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error removing the device: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$result = ['success', 'Device removed.'];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});

			$router->post('/profile/add2fakey(\.json)?', function($json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$data = [];
				$data['description'] = (isset($_POST['description']) ? $_POST['description'] : 'New 2FA Key: ' . date('Y-m-d H:i:s'));

				$data['type'] = isset($_POST['type']) ? strtolower($_POST['type']) : 'rfc6238';
				if ($data['type'] == 'onetime') {
					$data['type'] = 'plain';
					$data['onetime'] = true;
				}

				foreach (['secret', 'countrycode', 'phone'] as $extra) {
					if (isset($_POST[$extra]) && !empty($_POST[$extra])) {
						$data[$extra] = $_POST[$extra];
					}
				}

				$apiresult = $api->create2FAKey($data);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = $apiresult['error'];
					}
					$result = ['error', 'There was an error adding the new 2FA Key: ' . (is_array($apiresult['errorData']) ? implode(' // ', $apiresult['errorData']) : $apiresult['errorData'])];
				} else {
					$newkey = $apiresult['response'];
					$result = ['success', 'New 2FA Key Added: ' . $newkey['description'] . ' - key must be verified before use.'];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					if (isset($result[2])) {
						echo json_encode([$result[0] => [$result[1], $result[2]]]);
					} else {
						echo json_encode([$result[0] => $result[1]]);
					}
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});

			$router->post('/profile/edit2fakey/([^/]+)(\.json)?', function($key, $json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$data = isset($_POST['key'][$key]) ? $_POST['key'][$key] : [];
				$apiresult = $api->update2FAKey($key, $data);
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
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});

			$router->post('/profile/delete2fakey/([^/]+)(\.json)?', function($key, $json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$apiresult = $api->delete2FAKey($key);
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
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});


			$router->post('/profile/verify2fakey/([^/]+)(\.json)?', function($key, $json = NULL) use ($router, $displayEngine, $api) {
				if (!$this->checkAuthTimeOrError($displayEngine, $json)) { return; }

				$code = isset($_POST['code']) ? $_POST['code'] : null;
				$apiresult = $api->verify2FAKey($key, $code);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					$result = ['error', 'There was an error verifying the key: ' . (is_array($apiresult['errorData']) ? implode("\n", $apiresult['errorData']) : $apiresult['errorData'])];
				} else if (array_key_exists('info', $apiresult)) {
					$result = ['info', $apiresult['info']];
				} else {
					$result = ['success', 'Key verified.'];
				}

				if ($json !== NULL) {
					header('Content-Type: application/json');
					echo json_encode([$result[0] => $result[1]]);
					return;
				} else {
					$displayEngine->flash($result[0], '', $result[1]);
					header('Location: ' . $displayEngine->getURL('/profile'));
					return;
				}
			});
		}
	}
