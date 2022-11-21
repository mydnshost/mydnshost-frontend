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
							} else if (do_idn_to_ascii($domain) != $domain) {
								$domainData['subtitle'] = do_idn_to_ascii($domain);
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


				$router->get('/admin/users/create', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/admin/users')->setTitle('Admin :: Users :: Add');
					$displayEngine->display('admin/createuser.tpl');
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
								$errorData .= ' => ' . implode($result['errorData'], ', ');
							} else {
								$errorData .= 'Unspecified error.';
							}
							$displayEngine->flash('error', '', 'There was an error creating the user: ' . $errorData);
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


			if ($displayEngine->hasPermission(['manage_articles'])) {
				$router->get('/admin/articles', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/admin/articles')->setTitle('Admin :: Articles');

					$articles = $api->getAllArticles();
					$displayEngine->setVar('articles', $articles);
					$displayEngine->setVar('time', time());

					$displayEngine->display('admin/articles.tpl');
				});

				$router->get('/admin/articles/(create|[0-9]+)', function($articleid) use ($displayEngine, $api) {
					$error = false;

					if ($articleid == 'create') {
						$displayEngine->setPageID('/admin/articles')->setTitle('Admin :: Articles :: Create');
						$displayEngine->setVar('create', true);
					} else {
						$displayEngine->setPageID('/admin/articles')->setTitle('Admin :: Articles :: ' . $articleid);
						$article = $api->getArticle($articleid);
						if (isset($article['id'])) {
							$displayEngine->setVar('article', $article);
						} else {
							$error = true;
						}
					}

					$displayEngine->setVar('time', time());

					if ($error) {
						$displayEngine->flash('error', '', 'No such article ID: ' . $articleid);
						header('Location: ' . $displayEngine->getURL('/admin/articles'));
					} else {
						$displayEngine->display('admin/article.tpl');
					}
				});

				$router->post('/admin/articles/(create|[0-9]+)', function($articleid) use ($displayEngine, $api) {
					$fields = ['title' => 'You must specify a title.',
					           'content' => 'You must specify content.',
					           'visiblefrom' => 'You must specify visible from.',
					           'visibleuntil' => 'You must specify visible until.',
					          ];

					$canUpdate = true;

					$create = ($articleid == 'create');

					foreach ($fields as $field => $error) {
						if (!array_key_exists($field, $_POST) || ($_POST[$field] != "0" && empty($_POST[$field]))) {
							$canUpdate = false;
							$displayEngine->flash('error', '', 'There was an error updating the article: ' . $error);
							break;
						}
					}

					if ($canUpdate) {
						$result = ($create ? $api->createArticle($_POST) : $api->updateArticle($articleid, $_POST));

						if (array_key_exists('error', $result)) {
							$errorData = $result['error'];
							if (array_key_exists('errorData', $result)) {
								$errorData .= ' => ' . is_array($result['errorData']) ? implode(' / ', $result['errorData']) : $result['errorData'];
							}
							if ($create) {
								$displayEngine->flash('error', '', 'There was an error creating the article: ' . $errorData);
							} else {
								$displayEngine->flash('error', '', 'There was an error updating the article: ' . $errorData);
							}
						} else {
							if ($create) {
								$displayEngine->flash('success', '', 'New article has been created');
							} else {
								$displayEngine->flash('success', '', 'Article has been updated');
							}
							header('Location: ' . $displayEngine->getURL('/admin/articles'));
							return;
						}
					}

					header('Location: ' . $displayEngine->getURL('/admin/articles'));
					return;
				});

				$router->post('/admin/articles/([0-9]+)/delete', function($articleid) use ($displayEngine, $api) {
					$result = $api->deleteArticle($articleid);

					header('Content-Type: application/json');
					echo json_encode($result);
				});
			}


			if ($displayEngine->hasPermission(['manage_blocks'])) {
				$router->get('/admin/blockregexes', function() use ($displayEngine, $api) {
					$displayEngine->setPageID('/admin/blockregexes')->setTitle('Admin :: BlockRegexes');

					$blockregexes = $api->getAllBlockRegexes();
					$displayEngine->setVar('blockregexes', $blockregexes);
					$displayEngine->setVar('time', time());

					$displayEngine->display('admin/blockregexes.tpl');
				});

				$router->get('/admin/blockregexes/(create|[0-9]+)', function($blockregexid) use ($displayEngine, $api) {
					$error = false;

					if ($blockregexid == 'create') {
						$displayEngine->setPageID('/admin/blockregexes')->setTitle('Admin :: BlockRegexes :: Create');
						$displayEngine->setVar('create', true);
					} else {
						$displayEngine->setPageID('/admin/blockregexes')->setTitle('Admin :: BlockRegexes :: ' . $blockregexid);
						$blockregex = $api->getBlockRegex($blockregexid);
						if (isset($blockregex['id'])) {
							$displayEngine->setVar('blockregex', $blockregex);
						} else {
							$error = true;
						}
					}

					$displayEngine->setVar('time', time());

					if ($error) {
						$displayEngine->flash('error', '', 'No such blockregex ID: ' . $blockregexid);
						header('Location: ' . $displayEngine->getURL('/admin/blockregexes'));
					} else {
						$displayEngine->display('admin/blockregex.tpl');
					}
				});

				$router->post('/admin/blockregexes/(create|[0-9]+)', function($blockregexid) use ($displayEngine, $api) {
					$fields = ['regex' => 'You must specify a regex.',
					          ];

					$canUpdate = true;

					$create = ($blockregexid == 'create');

					// Boolean fields are not send if not ticked.
					foreach (['signup_email', 'signup_name', 'domain_name'] as $field) {
						if (!array_key_exists($field, $_POST) || empty($_POST[$field])) {
							$_POST[$field] = false;
						} else {
							$_POST[$field] = true;
						}
					}

					foreach ($fields as $field => $error) {
						if (!array_key_exists($field, $_POST) || ($_POST[$field] != "0" && empty($_POST[$field]))) {
							$canUpdate = false;
							$displayEngine->flash('error', '', 'There was an error updating the blockregex: ' . $error);
							break;
						}
					}

					if ($canUpdate) {
						$result = ($create ? $api->createBlockRegex($_POST) : $api->updateBlockRegex($blockregexid, $_POST));

						if (array_key_exists('error', $result)) {
							$errorData = $result['error'];
							if (array_key_exists('errorData', $result)) {
								$errorData .= ' => ' . is_array($result['errorData']) ? implode(' / ', $result['errorData']) : $result['errorData'];
							}
							if ($create) {
								$displayEngine->flash('error', '', 'There was an error creating the blockregex: ' . $errorData);
							} else {
								$displayEngine->flash('error', '', 'There was an error updating the blockregex: ' . $errorData);
							}
						} else {
							if ($create) {
								$displayEngine->flash('success', '', 'New blockregex has been created');
							} else {
								$displayEngine->flash('success', '', 'BlockRegex has been updated');
							}
							header('Location: ' . $displayEngine->getURL('/admin/blockregexes'));
							return;
						}
					}

					header('Location: ' . $displayEngine->getURL('/admin/blockregexes'));
					return;
				});

				$router->post('/admin/blockregexes/([0-9]+)/delete', function($blockregexid) use ($displayEngine, $api) {
					$result = $api->deleteBlockRegex($blockregexid);

					header('Content-Type: application/json');
					echo json_encode($result);
				});
			}


		}
	}
