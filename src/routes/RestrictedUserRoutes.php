<?php
	class RestrictedUserRoutes {

		public function addRoutes($router, $displayEngine, $api) {
			$router->match('GET|POST', '/profile/delete', function() use ($router, $displayEngine, $api) {
				$displayEngine->setPageID('/profile/delete')->setTitle('Profile :: Delete');

				if ($router->getRequestMethod() == "POST" && isset($_POST['confirmCode'])) {
					$confirmCode = $_POST['confirmCode'];
					if (empty($confirmCode)) {
						$displayEngine->flash('error', 'Error!', 'You need to provide the confirm code.');
					} else {
						$twoFactorCode = isset($_POST['2fakey']) ? $_POST['2fakey'] : '';
						$deleteInfo = $api->deleteUserConfirm('self', $confirmCode, $twoFactorCode);

						if (parseBool($deleteInfo['response']['deleted'])) {
							session::clear();
							session::setCurrentUser(null);
							$displayEngine->flash('success', 'Success!', 'Your account has been deleted.');
							header('Location: ' . $displayEngine->getURL('/'));
							return;
						} else if (isset($deleteInfo['error'])) {
							$displayEngine->flash('error', 'Error!', 'There was an error deleting your account: ' . $deleteInfo['error']);
						} else {
							$displayEngine->flash('error', 'Error!', 'There was an unknown error deleting your account.');
						}
					}
				}

				$deleteInfo = $api->deleteUser('self')['response'];
				$displayEngine->setVar('confirmCode', $deleteInfo['confirmCode']);
				$displayEngine->setVar('twofactor', $deleteInfo['twofactor']);

				$displayEngine->display('profile_delete.tpl');
			});
		}
	}
