<?php

	class DisplayEngine {
		private $twig;
		private $directories = [];
		private $basepath;
		private $vars = [];
		private $pageID = '';

		public function __construct($config) {
			$loader = new Twig_Loader_Filesystem();
			$themes = [];
			if (isset($config['theme'])) {
				$themes = is_array($config['theme']) ? $config['theme'] : [$config['theme']];
			}
			foreach (array_unique(array_merge($themes, ['default'])) as $theme) {
				$path = $config['dir'] . '/' . $theme;
				if (file_exists($path)) {
					$loader->addPath($path);
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
			$twig->addFunction(new Twig_Function('getVar', function ($var) { return $this->getVar($var); }));

			$twig->addFunction(new Twig_Function('flash', function() { $this->displayFlash(); }));
			$twig->addFunction(new Twig_Function('showSidebar', function() { $this->showSidebar(); }));
			$twig->addFunction(new Twig_Function('showHeaderMenu', function() { $this->showHeaderMenu(); }));

			$twig->addFilter(new Twig_Filter('gravatar', function($input, $size = 20, $default = '') {
				return '//www.gravatar.com/avatar/' . md5(strtolower($input)) . '.jpg?s=' . $size . '&d=' . $default;
			}));

			$twig->addFilter(new Twig_Filter('yesno', function($input) {
				return parseBool($input) ? "Yes" : "No";
			}));

			$this->vars = ['sitename' => '', 'pagetitle' => ''];

			$this->twig = $twig;
		}

		public function setPageID($pageID) {
			$this->pageID = $pageID;
			return $this;
		}


		public function setSiteName($sitename) {
			$this->vars['sitename'] = $sitename;
			return $this;
		}

		public function setTitle($title) {
			$this->vars['pagetitle'] = $title;
			return $this;
		}

		public function setVar($var, $value) {
			$this->vars[$var] = $value;
			return $this;
		}

		public function getVar($var) {
			return array_key_exists($var, $this->vars) ? $this->vars[$var] : '';
		}

		public function getURL($path) {
			return sprintf('%s/%s', rtrim($this->basepath, '/'), ltrim($path, '/'));
		}

		public function setExtraVars() {
			if (session::isLoggedIn()) {
				$user = session::getCurrentUser();
				$this->setVar('user', $user);
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
		}

		public function showSidebar() {
			$menu = [];
			$sections = [];

			if (session::exists('domains')) {
				$domains = session::get('domains');
				foreach ($domains as $domain => $access) {
					$sections[$access][] = ['link' => $this->getURL('/domain/' . $domain), 'title' => $domain, 'dataValue' => $domain, 'active' => ($this->pageID == '/domain/' . $domain)];
				}

				foreach (['owner', 'admin', 'write', 'read'] as $section) {
					if (array_key_exists($section, $sections)) {
						$menu[] = array_merge([['title' => 'Access level: ' . ucfirst($section)]], $sections[$section]);
					}
				}
			}

			$this->twig->display('sidebar_menu.tpl', ['menu' => $menu]);
		}

		public function showHeaderMenu() {
			$menu = [];

			/* $menu[] = ['link' => '#', 'title' => 'Home', 'active' => true];
			$menu[] = ['link' => '#', 'title' => 'Settings'];
			$menu[] = ['link' => '#', 'title' => 'Profile'];
			$menu[] = ['link' => '#', 'title' => 'Help']; */

			$this->twig->display('header_menu.tpl', ['menu' => $menu]);
		}
	}
