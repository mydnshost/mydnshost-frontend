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
						$displayEngine->setVar('domains', $domains);
					}
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

					if (isset($users['response'])) {
						$displayEngine->setVar('users', $users['response']);
					}
					$displayEngine->display('admin/users.tpl');
				});

				$router->post('/admin/users/action/(.*)/(.*)', function($action, $userid) use ($displayEngine, $api) {
					$data = [];

					if ($action == 'promote') {
						$data['admin'] = 'true';
					} else if ($action == 'demote') {
						$data['admin'] = 'false';
					} else if ($action == 'suspend') {
						$data['disabled'] = 'true';
					} else if ($action == 'unsuspend') {
						$data['disabled'] = 'false';
					}

					$result = $api->setUserInfo($data, $userid);

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

					$fields = ['email' => 'You must specify an email address for the user',
					           'realname' => 'You must specify a name for the user',
					           'password' => 'You must specify a password for the user',
					           'confirmpassword' => 'You must confirm the password for the user'
					          ];

					foreach ($fields as $field => $error) {
						if (!array_key_exists($field, $_POST) || empty($_POST[$field])) {
							$canUpdate = false;
							$displayEngine->flash('error', '', 'There was an error creating the user: ' . $error);
							break;
						}
					}

					$pass = isset($_POST['password']) ? $_POST['password'] : NULL;
					$confirmpass = isset($_POST['confirmpassword']) ? $_POST['confirmpassword'] : NULL;

					if ($canUpdate && $pass != $confirmpass) {
						$canUpdate = false;
						$displayEngine->flash('error', '', 'There was an error creating the user: Passwords do not match.');
						return;
					}

					if ($canUpdate) {
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
							session::clear(['logindata', 'DisplayEngine::Flash']);
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
