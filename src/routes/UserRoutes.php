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
						$result = $api->setUserInfo($_POST);

						if (array_key_exists('error', $result)) {
							if (!array_key_exists('errorData', $result)) {
								$result['errorData'] = 'Unspecified error. (Email address already in use?)';
							}
							$displayEngine->flash('error', '', 'There was an error updating your profile data: ' . $result['errorData']);
						} else {
							if (in_array($_POST['domain_defaultpage'], ['records', 'details'])) {
								$api->setCustomData('uk.co.mydnshost.www/domain/defaultpage', $_POST['domain_defaultpage']);
								session::set('domain/defaultpage', $_POST['domain_defaultpage']);
							}

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
				}

				$displayEngine->setVar('twofactordevices', $api->get2FADevices());

				$displayEngine->setVar('domain_defaultpage', session::get('domain/defaultpage'));
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
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error adding the new API Key: ' . $apiresult['errorData']];
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
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error removing the device: ' . $apiresult['errorData']];
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

				$apiresult = $api->create2FAKey(['description' => (isset($_POST['description']) ? $_POST['description'] : 'New 2FA Key: ' . date('Y-m-d H:i:s'))]);
				$result = ['unknown', 'unknown'];

				if (array_key_exists('error', $apiresult)) {
					if (!array_key_exists('errorData', $apiresult)) {
						$apiresult['errorData'] = 'Unspecified error.';
					}
					$result = ['error', 'There was an error adding the new 2FA Key: ' . $apiresult['errorData']];
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
					$result = ['error', 'There was an error verifying the key: ' . $apiresult['error']];
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
