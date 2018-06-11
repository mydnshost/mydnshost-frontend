<?php

	class DisplayEngine {
		private $twig;
		private $directories = [];
		private $basepath;
		private $vars = [];
		private $pageID = '';
		private $customSidebar = FALSE;
		private $restrictedMode = FALSE;
		private $banners = [];

		public function __construct($siteconfig) {
			$config = $siteconfig['templates'];

			$loader = new Twig_Loader_Filesystem();
			$themes = [];
			if (isset($config['theme'])) {
				$themes = is_array($config['theme']) ? $config['theme'] : [$config['theme']];
			}
			foreach (array_unique(array_merge($themes, ['default'])) as $theme) {
				$path = $config['dir'] . '/' . $theme;
				if (file_exists($path)) {
					$loader->addPath($path, $theme);
					$loader->addPath($path, '__main__');
					$this->directories[] = $path;
				}
			}

			$twig = new Twig_Environment($loader, array(
				'cache' => $config['cache'],
				'auto_reload' => true,
				'debug' => true,
				'autoescape' => 'html',
			));

			$twig->addExtension(new Twig_Extension_Debug());

			$this->basepath = dirname($_SERVER['SCRIPT_FILENAME']) . '/';
			$this->basepath = preg_replace('#^' . preg_quote($_SERVER['DOCUMENT_ROOT']) . '#', '/', $this->basepath);
			$this->basepath = preg_replace('#^/+#', '/', $this->basepath);

			$twig->addFunction(new Twig_Function('url', function ($path) { return $this->getURL($path); }));
			$twig->addFunction(new Twig_Function('apiurl', function ($path) use ($siteconfig) { return sprintf('%s/%s', rtrim($siteconfig['api_public'], '/'), ltrim($path, '/')); }));
			$twig->addFunction(new Twig_Function('getVar', function ($var) { return $this->getVar($var); }));
			$twig->addFunction(new Twig_Function('hasPermission', function($permissions) { return $this->hasPermission($permissions); }));

			$twig->addFunction(new Twig_Function('flash', function() { $this->displayFlash(); }));
			$twig->addFunction(new Twig_Function('showSidebar', function() { $this->showSidebar(); }));
			$twig->addFunction(new Twig_Function('showHeaderMenu', function() { $this->showHeaderMenu(); }));
			$twig->addFunction(new Twig_Function('getARPA', function($domain) { return getARPA($domain); }));

			$twig->addFilter(new Twig_Filter('getARPA', function($domain) {
				return getARPA($domain);
			}));

			$twig->addFilter(new Twig_Filter('gravatar', function($input, $size = 20, $default = '') {
				return '//www.gravatar.com/avatar/' . md5(strtolower($input)) . '.jpg?s=' . $size . '&d=' . $default;
			}));

			$twig->addFilter(new Twig_Filter('yesno', function($input) {
				return parseBool($input) ? "Yes" : "No";
			}));

			$twig->addFilter(new Twig_Filter('date', function($input) {
				return date('r', $input);
			}));

			$twig->addFilter(new Twig_Filter('get2FAQRCode', function($input) {
				$ga = new PHPGangsta_GoogleAuthenticator();
				$user = session::getCurrentUser();
				return $ga->getQRCodeGoogleUrl($this->getVar('sitename') . ' ' . $user['user']['email'], $input);
			}));

			$this->vars = ['sitename' => '', 'pagetitle' => ''];

			$this->twig = $twig;
		}

		public function getTwig() {
			return $this->twig;
		}

		public function setPageID($pageID) {
			$this->pageID = $pageID;
			return $this;
		}

		public function setSiteName($sitename) {
			$this->vars['sitename'] = $sitename;
			return $this;
		}

		public function setRestrictedMode($mode) {
			$this->restrictedMode = $mode;
			return $this;
		}

		public function getRestrictedMode() {
			return $this->restrictedMode;
		}

		public function setTitle($title) {
			$this->vars['pagetitle'] = $title;
			return $this;
		}

		public function setSidebar($vars) {
			$this->customSidebar = $vars;
			return $this;
		}

		public function setVar($var, $value) {
			$this->vars[$var] = $value;
			return $this;
		}

		public function getVar($var) {
			return array_key_exists($var, $this->vars) ? $this->vars[$var] : '';
		}

		public function getBasePath() {
			return rtrim($this->basepath, '/');
		}

		public function getURL($path) {
			$path = sprintf('%s/%s', $this->getBasePath(), ltrim($path, '/'));

			return $path;
		}

		public function hasPermission($permissions) {
			if (session::isLoggedIn()) {
				$user = session::getCurrentUser();

				if (!is_array($permissions)) { $permissions = [$permissions]; }

				foreach ($permissions as $permission) {
					if (!array_key_exists($permission, $user['access']) || !parseBool($user['access'][$permission])) {
						return false;
					}
				}
				return true;
			}

			return false;
		}

		public function setExtraVars() {
			if (session::isLoggedIn()) {
				$user = session::getCurrentUser();
				if (isset($user['user'])) {
					$this->setVar('user', $user['user']);
				}
				if (isset($user['domainkey'])) {
					$this->setVar('domainkey', $user['domainkey']);
				}
				$this->setVar('useraccess', $user['access']);
				$this->setVar('csrftoken', session::get('csrftoken'));
			}
		}

		public function display($template) {
			$this->setExtraVars();

			$this->twig->display('header.tpl', $this->vars);
			$this->twig->display($template, $this->vars);
			$this->twig->display('footer.tpl', $this->vars);
		}

		public function displayRaw($template) {
			$this->setExtraVars();

			$this->twig->display($template, $this->vars);
		}

		public function getFile($file) {
			$file = str_replace('../', '', $file);

			foreach ($this->directories as $dir) {
				$path = $dir . '/' . $file;
				if (file_exists($path)) {
					return $path;
				}
			}

			return FALSE;
		}

		public function displayBanner($type, $title, $message) {
			if ($type == 'error') { $type = 'danger'; }

			$this->banners[] = ['type' => $type, 'title' => $title, 'message' => $message];
		}

		public function flash($type, $title, $message) {
			if ($type == 'error') { $type = 'danger'; }

			session::append('DisplayEngine::Flash', ['type' => $type, 'title' => $title, 'message' => $message]);
		}

		public function displayFlash() {
			if (session::exists('DisplayEngine::Flash')) {
				$messages = session::get('DisplayEngine::Flash');
				foreach ($messages as $flash) {
					$this->twig->display('flash_message.tpl', $flash);
				}
				session::remove('DisplayEngine::Flash');
			}

			foreach ($this->banners as $flash) {
				$this->twig->display('flash_message.tpl', $flash);
			}
		}

		public function showSidebar() {
			$vars = [];

			if (!$this->getRestrictedMode()) {

				if ($this->customSidebar !== FALSE) {
					$vars = $this->customSidebar;
				} else {
					$menu = [];
					$sections = [];

					if (session::exists('domains') && !startsWith($this->pageID, '/admin')) {
						$vars['title'] = 'Domains List';
						$vars['showsearch'] = true;

						if ($this->hasPermission(['domains_create'])) {
							$section = [];
							$section[] = ['title' => 'Extra'];
							$section[] = ['title' => 'My Domains', 'link' => $this->getURL('/domains'),];
							$section[] = ['title' => 'Add Domain', 'button' => 'primary', 'action' => 'addUserDomain', 'link' => $this->getURL('/domains/create'),];

							$menu[] = $section;
						}

						$domains = session::get('domains');
						foreach ($domains as $domain => $access) {
							$item = array();
							$item['link'] = $this->getURL('/domain/' . $domain);
							if (session::get('domain/defaultpage') == 'records') {
								$item['link'] .= '/records';
							}
							$item['title'] = $domain;
							$item['active'] = ($this->pageID == '/domain/' . $domain);

							$dataValue = [$domain];

							$rdns = getARPA($domain);
							if ($rdns !== FALSE) {
								$dataValue[] = $rdns;
								$dataValue[] = 'rdns';

								$item['hover'] = 'RDNS: ' . $rdns;
							} else if (idn_to_ascii($domain) != $domain) {
								$dataValue[] = idn_to_ascii($domain);
								$item['hover'] = idn_to_ascii($domain);
							}

							$item['dataValue'] = implode(' ', $dataValue);

							$sections[$access][] = $item;
						}

						foreach (['owner', 'admin', 'write', 'read'] as $section) {
							if (array_key_exists($section, $sections)) {
								$menu[] = array_merge([['title' => 'Access level: ' . ucfirst($section)]], $sections[$section]);
							}
						}
					}

					$vars['menu'] = $menu;
				}
			}

			$this->twig->display('sidebar_menu.tpl', $vars);
		}

		public function showHeaderMenu() {
			$menu = [];

			if (!$this->getRestrictedMode()) {
				if ($this->hasPermission(['manage_users'])) {
					$menu[] = ['link' => $this->getURL('/admin/users'), 'title' => 'Manage Users', 'active' => ($this->pageID == '/admin/users')];
				}
				if ($this->hasPermission(['manage_domains'])) {
					$menu[] = ['link' => $this->getURL('/admin/domains'), 'title' => 'Manage Domains', 'active' => ($this->pageID == '/admin/domains')];
				}
				if ($this->hasPermission(['system_stats'])) {
					$menu[] = ['link' => $this->getURL('/admin/stats'), 'title' => 'System Statistics', 'active' => ($this->pageID == '/admin/stats')];
				}

				if (count($menu) > 0) {
					$public = ['link' => $this->getURL('/'), 'title' => 'Public', 'active' => (!startsWith($this->pageID, '/admin'))];
					array_unshift($menu, $public);
				}
			}

			$this->twig->display('header_menu.tpl', ['menu' => $menu]);
		}
	}
