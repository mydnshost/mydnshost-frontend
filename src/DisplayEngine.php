<?php

	use Twig\Loader\FilesystemLoader as TwigFilesystemLoader;
	use Twig\Environment as TwigEnvironment;
	use Twig\Extension\DebugExtension as TwigDebugExtension;
	use Twig\TwigFunction;
	use Twig\TwigFilter;

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

			$loader = new TwigFilesystemLoader();
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

			$twig = new TwigEnvironment($loader, array(
				'cache' => $config['cache'],
				'auto_reload' => true,
				'debug' => true,
				'autoescape' => 'html',
			));

			$twig->addExtension(new TwigDebugExtension());

			$this->basepath = dirname($_SERVER['SCRIPT_FILENAME']) . '/';
			$this->basepath = preg_replace('#^' . preg_quote($_SERVER['DOCUMENT_ROOT']) . '#', '/', $this->basepath);
			$this->basepath = preg_replace('#^/+#', '/', $this->basepath);

			$twig->addFunction(new TwigFunction('url', function ($path) { return $this->getURL($path); }));
			$twig->addFunction(new TwigFunction('apiurl', function ($path) use ($siteconfig) { return sprintf('%s/%s', rtrim($siteconfig['api_public'], '/'), ltrim($path, '/')); }));
			$twig->addFunction(new TwigFunction('getVar', function ($var) { return $this->getVar($var); }));
			$twig->addFunction(new TwigFunction('hasPermission', function($permissions) { return $this->hasPermission($permissions); }));

			$twig->addFunction(new TwigFunction('startsWith', function($haystack, $needle) { return startsWith($haystack, $needle); }));
			$twig->addFunction(new TwigFunction('endsWith', function($haystack, $needle) { return endsWith($haystack, $needle); }));
			$twig->addFunction(new TwigFunction('parseBool', function($input) { return parseBool($input); }));

			$twig->addFunction(new TwigFunction('flash', function() { $this->displayFlash(); }));
			$twig->addFunction(new TwigFunction('showSidebar', function() { $this->showSidebar(); }));
			$twig->addFunction(new TwigFunction('showHeaderMenu', function() { $this->showHeaderMenu(); }));
			$twig->addFunction(new TwigFunction('getARPA', function($domain) { return getARPA($domain); }));
			$twig->addFunction(new TwigFunction('getThemeInformation', function() { return getThemeInformation(); }));

			$twig->addFilter(new TwigFilter('getARPA', function($domain) {
				return getARPA($domain);
			}));

			$twig->addFilter(new TwigFilter('gravatar', function($input, $size = 20, $default = '') {
				if ($input != 'none') { $input = md5(strtolower($input)); }

				if ($default == '') {
					if ($input == 'none') { $default = 'mp'; }
					else { $default = 'retro'; }
				}
				return '//www.gravatar.com/avatar/' . $input . '.jpg?s=' . $size . '&d=' . $default;
			}));

			$twig->addFilter(new TwigFilter('yesno', function($input) {
				return parseBool($input) ? "Yes" : "No";
			}));

			$twig->addFilter(new TwigFilter('date', function($input) {
				return date('r', $input);
			}));

			$twig->addFilter(new TwigFilter('getRFC6238QRCode', function($input) {
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
				$this->setVar('userdomains', session::get('domains'));
				$this->setVar('csrftoken', session::get('csrftoken'));
				$this->setVar('sitetheme', session::get('sitetheme'));
				$this->setVar('sitethemedata', session::get('sitethemedata'));
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

			$postProcessor = static::getPostProcessor($template, $this->getFile($template));

			if ($postProcessor == FALSE) {
				$this->twig->display($template, $this->vars);
			} else {
				$template = $this->twig->load($template);
				$parsedTemplate = $template->render($this->vars);
				echo call_user_func_array($postProcessor, [$parsedTemplate]);
			}
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

						$section = [];
						$section[] = ['title' => 'Extra'];
						$section[] = ['title' => 'My Domains', 'link' => $this->getURL('/domains'),];
						$section[] = ['title' => 'Find Records', 'link' => $this->getURL('domains/findRecords'),];
						if ($this->hasPermission(['domains_create'])) {
							$section[] = ['title' => 'Add Domain', 'button' => 'primary', 'action' => 'addUserDomain', 'link' => $this->getURL('/domains/create'),];
						}
						$menu[] = $section;

						$labelNames = ['' => 'Unlabelled'];

						$domains = session::get('domains');
						$sidebarLayout = session::get('sidebar/layout');
						foreach ($domains as $domain => $data) {
							$label = ($sidebarLayout == 'labels') ? $data['userdata'] : $data['access'];

							$item = array();
							$item['link'] = $this->getURL('/domain/' . $domain);
							if (session::get('domain/defaultpage') == 'records') {
								$item['link'] .= '/records';
							}
							$item['title'] = $domain;
							$item['active'] = ($this->pageID == '/domain/' . $domain);
							$item['badge'] = ['classes' => ['verificationstate', 'state-' . $data['verification']['state']],
							                  'value' => '?',
							                  'title' => 'Verification state: ' . $data['verification']['state'] . ' as of ' . date('r', $data['verification']['time']),
							                 ];
							if ($data['verification']['state'] == 'valid') {
								$item['badge']['value'] = '✓';
							} else if ($data['verification']['state'] == 'invalid') {
								$item['badge']['value'] = 'X';
							} else {
								$item['badge']['value'] = '?';
							}
							$dataValue = [$domain];

							$rdns = getARPA($domain);
							if ($rdns !== FALSE) {
								$dataValue[] = $rdns;
								$dataValue[] = 'rdns';

								$item['hover'] = 'RDNS: ' . $rdns;
							} else if (do_idn_to_ascii($domain) != $domain) {
								$dataValue[] = do_idn_to_ascii($domain);
								$item['hover'] = do_idn_to_ascii($domain);
							}

							$item['dataValue'] = implode(' ', $dataValue);

							if (!isset($labelNames[strtolower($label)])) { $labelNames[strtolower($label)] = $label; }
							$sections[strtolower($label)][] = $item;
						}

						if (session::get('sidebar/layout') == 'labels') {
							$labels = array_keys($sections);
							sort($labels);
							foreach ($labels as $label) {
								$menu[] = array_merge([['title' => $labelNames[strtolower($label)]]], $sections[$label]);
							}
						} else {
							foreach (['owner', 'admin', 'write', 'read'] as $section) {
								if (array_key_exists($section, $sections)) {
									$menu[] = array_merge([['title' => 'Access level: ' . ucfirst($section)]], $sections[$section]);
								}
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
				if ($this->hasPermission(['manage_articles'])) {
					$menu[] = ['link' => $this->getURL('/admin/articles'), 'title' => 'Manage Articles', 'active' => ($this->pageID == '/admin/aticles')];
				}
				if ($this->hasPermission(['manage_blocks'])) {
					$menu[] = ['link' => $this->getURL('/admin/blockregexes'), 'title' => 'Manage Blocks', 'active' => ($this->pageID == '/admin/blockregexes')];
				}
				if ($this->hasPermission(['system_stats'])) {
					$menu[] = ['link' => $this->getURL('/admin/stats'), 'title' => 'System Statistics', 'active' => ($this->pageID == '/admin/stats')];
				}
				if ($this->hasPermission(['system_service_mgmt'])) {
					$menu[] = ['link' => $this->getURL('/system/services'), 'title' => 'System Services', 'active' => ($this->pageID == '/system/services')];
				}
				if ($this->hasPermission(['system_job_mgmt'])) {
					$menu[] = ['link' => $this->getURL('/system/jobs'), 'title' => 'Job Status', 'active' => ($this->pageID == '/system/jobs')];
				}

				if (count($menu) > 0) {
					$public = ['link' => $this->getURL('/'), 'title' => 'Public', 'active' => (!startsWith($this->pageID, '/admin'))];
					array_unshift($menu, $public);
				}
			}

			$this->twig->display('header_menu.tpl', ['menu' => $menu]);
		}

		public static function getPostProcessor($template, $file = '') {
			// TODO: This shouldn't really end up being used in production.
			$postProcessor['scss'] = function ($raw) use ($template, $file) {
				try {
					$compiler = new \ScssPhp\ScssPhp\Compiler();
					// $compiler->setOutputStyle(\ScssPhp\ScssPhp\OutputStyle::COMPRESSED);

					if ($file != '') {
						$compiler->setImportPaths(dirname($file));
						// Doesn't seem to work nicely :(
						// $compiler->setSourceMap(\ScssPhp\ScssPhp\Compiler::SOURCE_MAP_INLINE);
					}
					return $compiler->compileString($raw)->getCss();
				} catch (\Throwable $ex) {
					return $raw;
				}
			};

			$bits = explode('.', $template);
			$ext = strtolower(array_pop($bits));
			if (array_key_exists($ext, $postProcessor)) {
				return $postProcessor[$ext];
			} else {
				return FALSE;
			}
		}
	}
