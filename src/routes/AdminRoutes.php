<?php
	class AdminRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->before('GET|POST', '/admin/.*', function() use ($api, $displayEngine) {
				$displayEngine->setVar('nosidebar', true);
				$api->domainAdmin();
			});

			if ($displayEngine->hasPermission(['manage_domains'])) {
				$router->get('/admin/domains', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/admin/domains')->setTitle('Admin :: Domains');

					$domains = $api->domainAdmin()->getDomains();

					if (isset($domains)) {
						array_walk($domains, function (&$domainData, $domain) {
							$rdns = getARPA($domain);
							if ($rdns !== FALSE) {
								$domainData['subtitle'] = 'RDNS: '. $rdns;
							} else if (idn_to_ascii($domain) != $domain) {
								$domainData['subtitle'] = idn_to_ascii($domain);
							}
						});

						$displayEngine->setVar('domains', $domains);
					}
					$displayEngine->setVar('domain_defaultpage', session::get('domain/defaultpage'));
					$displayEngine->display('admin/domains.tpl');
				});

				$router->mount('/admin', function() use ($router, $displayEngine, $api) {
					(new AdminDomainRoutes())->addRoutes($router, $displayEngine, $api);
				});
			}

			if ($displayEngine->hasPermission(['manage_users'])) {
				$router->get('/admin/users', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/admin/users')->setTitle('Admin :: Users');

					$users = $api->getUsers();

					$validPermissions = $displayEngine->setVar('validPermissions', $api->getSystemDataValue('validPermissions'));

					if (isset($users['response'])) {
						$displayEngine->setVar('users', $users['response']);
					}
					$displayEngine->display('admin/users.tpl');
				});

				$router->post('/admin/users/action/(.*)/(.*)', function($action, $userid) use ($displayEngine, $api) {
					$setUserData = [];
					$result = NULL;

					if ($action == 'promote') {
						$setUserData['admin'] = 'true';
					} else if ($action == 'demote') {
						$setUserData['admin'] = 'false';
					} else if ($action == 'suspendreason') {
						$setUserData['disabledreason'] = array_key_exists('extra', $_POST) ? $_POST['extra'] : '';
					} else if ($action == 'suspend') {
						$setUserData['disabled'] = 'true';
					} else if ($action == 'unsuspend') {
						$setUserData['disabled'] = 'false';
					} else if ($action == 'setPermission') {
						$setUserData['permissions'] = array_key_exists('permissions', $_POST) ? $_POST['permissions'] : [];
					} else if ($action == 'resendwelcome') {
						$result = $api->resendWelcome($userid);
					}

					if ($result === NULL && !empty($setUserData)) {
						$result = $api->setUserInfo($setUserData, $userid);
					}

					header('Content-Type: application/json');
					echo json_encode($result);
				});

				$router->post('/admin/users/delete/(.*)', function($userid) use ($displayEngine, $api) {
					$result = $api->deleteUser($userid);

					header('Content-Type: application/json');
					echo json_encode($result);
				});

				$router->post('/admin/users/create', function() use ($displayEngine, $api) {
					$canUpdate = true;

					$manualPassword = !isset($_POST['registerUser']) || $_POST['registerUser'] != 'registerUserAuto';
					unset($_POST['registerUser']);

					$fields = ['email' => 'You must specify an email address for the user',
					           'realname' => 'You must specify a name for the user',
					          ];

					if ($manualPassword) {
						$fields['password'] = 'You must specify a password for the user';
						$fields['confirmpassword'] = 'You must confirm the password for the user';
					}

					foreach ($fields as $field => $error) {
						if (!array_key_exists($field, $_POST) || empty($_POST[$field])) {
							$canUpdate = false;
							$displayEngine->flash('error', '', 'There was an error creating the user: ' . $error);
							break;
						}
					}

					if ($manualPassword) {
						$pass = isset($_POST['password']) ? $_POST['password'] : NULL;
						$confirmpass = isset($_POST['confirmpassword']) ? $_POST['confirmpassword'] : NULL;

						if ($canUpdate && $pass != $confirmpass) {
							$canUpdate = false;
							$displayEngine->flash('error', '', 'There was an error creating the user: Passwords do not match.');
							return;
						}
					}

					if ($canUpdate) {
						if (!$manualPassword) {
							$_POST['sendWelcome'] = true;
						}
						$result = $api->createUser($_POST);

						if (array_key_exists('error', $result)) {
							$errorData = $result['error'];
							if (array_key_exists('errorData', $result)) {
								$errorData .= ' => ' . $result['errorData'];
							} else {
								$result['errorData'] = 'Unspecified error. (Email address already in use?)';
							}
							$displayEngine->flash('error', '', 'There was an error creating the user: ' . $result['errorData']);
						} else {
							$displayEngine->flash('success', '', 'New user has been created');
						}
					}

					header('Location: ' . $displayEngine->getURL('/admin/users'));
					return;
				});
			}

			if ($displayEngine->hasPermission(['system_stats'])) {
				$router->get('/admin/stats$', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/admin/stats')->setTitle('Admin :: Statistics');
					$displayEngine->display('admin/stats.tpl');
				});

				$router->get('/admin/stats/(.*).json', function($stat) use ($displayEngine, $api) {
					header('Content-Type: application/json');

					// TODO: Reformat into data-table array.
					$stats = $api->getSystemStats($stat, ['type' => 'derivative']);

					$options = [
					            'hAxis' => ['title' => 'Time', 'titleTextStyle' => ['color' => '#333']],
					            'vAxis' => ['title' => 'Queries', 'minValue' => 0],
					            'isStacked' => true,
					           ];

					echo json_encode(['stats' => $stats, 'options' => $options, 'graphType' => 'area']);
				});
			}

			if ($displayEngine->hasPermission(['impersonate_users'])) {
				$router->get('/impersonate/user/(.*)', function($impersonate) use ($displayEngine, $api) {
					$api->impersonate($impersonate, 'id');
					$result = $api->getUserData();

					if (isset($result['user']['email'])) {
						if ($result['user']['email'] == session::getCurrentUser()['user']['email']) {
							$displayEngine->flash('error', '', 'You can not impersonate yourself.');
							header('Location: ' . $displayEngine->getURL('/admin/users'));
							return;
						} else {
							session::clear(['logindata', 'DisplayEngine::Flash', 'csrftoken']);
							session::set('impersonate', $impersonate);

							$displayEngine->flash('info', '', 'Impersonating: ' . $result['user']['realname'] . ' (' . $result['user']['email'] . ')');
						}
					} else {
						$displayEngine->flash('error', '', 'Impersonation failed: ' . print_r($result, true));
					}

					header('Location: ' . $displayEngine->getURL('/'));
					return;
				});
			}
		}
	}
