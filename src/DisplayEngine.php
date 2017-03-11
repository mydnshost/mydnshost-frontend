<?php

	class DisplayEngine {
		private $twig;
		private $directories = [];
		private $basepath;
		private $vars = [];

		public function __construct($config) {
			$loader = new Twig_Loader_Filesystem();
			$themes = [];
			if (isset($config['theme'])) {
				$themes[] = $config['theme'];
			}
			foreach (array_unique(array_merge($themes, ['default'])) as $theme) {
				$path = $config['dir'] . '/' . $theme;
				$loader->addPath($path);
				$this->directories[] = $path;
			}

			$twig = new Twig_Environment($loader, array(
				'cache' => $config['cache'],
				'auto_reload' => true,
			));

			$this->basepath = dirname($_SERVER['SCRIPT_FILENAME']);
			$this->basepath = preg_replace('#^' . preg_quote($_SERVER['DOCUMENT_ROOT']) . '#', '/', $this->basepath);
			$this->basepath = preg_replace('#^/+#', '/', $this->basepath);

			$twig->addFunction(new Twig_Function('url', function ($path) { return $this->getURL($path); }));
			$twig->addFunction(new Twig_Function('getVar', function ($var) { return $this->getVar($var); }));

			$twig->addFunction(new Twig_Function('flash', function() { $this->displayFlash(); }));
			$twig->addFunction(new Twig_Function('showSidebar', function() { $this->showSidebar(); }));
			$twig->addFunction(new Twig_Function('showHeaderMenu', function() { $this->showHeaderMenu(); }));

			$this->vars = ['sitename' => '', 'pagetitle' => ''];

			$this->twig = $twig;
		}

		public function setSiteName($sitename) {
			$this->vars['sitename'] = $sitename;
			return $this;
		}

		public function setTitle($title) {
			$this->vars['pagetitle'] = $title;
			return $this;
		}

		public function getVar($var) {
			return array_key_exists($var, $this->vars) ? $this->vars[$var] : '';
		}

		public function getURL($path) {
			return sprintf('%s/%s', rtrim($this->basepath, '/'), ltrim($path, '/'));
		}

		public function display($template) {
			$this->twig->display('header.tpl', $this->vars);
			$this->twig->display($template, $this->vars);
			$this->twig->display('footer.tpl', $this->vars);
		}

		public function displayRaw($template) {
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

		public function showSidebar() { ?>
		<ul class="nav nav-pills flex-column">
            <li class="nav-item">
              <a class="nav-link active" href="#">Overview <span class="sr-only">(current)</span></a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Reports</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Analytics</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Export</a>
            </li>
          </ul>

          <ul class="nav nav-pills flex-column">
            <li class="nav-item">
              <a class="nav-link" href="#">Nav item</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Nav item again</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">One more nav</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Another nav item</a>
            </li>
          </ul>

          <ul class="nav nav-pills flex-column">
            <li class="nav-item">
              <a class="nav-link" href="#">Nav item again</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">One more nav</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#">Another nav item</a>
            </li>
          </ul> <?php
		}

		public function showHeaderMenu() { ?>
        <ul class="navbar-nav mr-auto">
          <li class="nav-item active">
            <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">Settings</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">Profile</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">Help</a>
          </li>
          </ul> <?php
		}
	}
