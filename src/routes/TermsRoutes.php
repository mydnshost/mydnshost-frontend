<?php
	class TermsRoutes {

		public function addRoutes($router, $displayEngine, $api) {

			$router->match('GET|POST', '/profile/terms', function() use ($router, $displayEngine, $api) {
				$displayEngine->setPageID('/profile/terms')->setTitle('Profile :: Terms of Service');

				if ($router->getRequestMethod() == "POST" && isset($_POST['acceptTerms'])) {
					$result = $api->acceptTerms();

					if (isset($result['response']['acceptterms'])) {
						$displayEngine->flash('success', '', 'You have accepted the terms of service.');

						if (session::exists('wantedPage')) {
							header('Location: ' . $displayEngine->getURL(session::get('wantedPage')));
							session::remove('wantedPage');
						} else {
							header('Location: ' . $displayEngine->getURL('/'));
						}

						return;
					} else if (isset($result['error'])) {
						$displayEngine->flash('error', '', 'There was an error accepting the terms of service: ' . $result['error']);
					} else {
						$displayEngine->flash('error', '', 'There was an unknown error accepting the terms of service.');
					}
				} else if ($router->getRequestMethod() == "POST" && !isset($_POST['acceptTerms'])) {
					$displayEngine->flash('error', '', 'You must accept the terms of service.');
				}

				$displayEngine->setVar('termsText', systemGetTermsText());
				$displayEngine->setVar('termstime', session::getCurrentUser()['user']['termstime']);
				$displayEngine->display('accept_terms.tpl');
			});

		}
	}
