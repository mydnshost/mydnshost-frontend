<?php

	class DisplayEngine {
		private $twig;
		private $directories = [];
		private $basepath;

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
			$twig->addFunction(new Twig_Function('flash', function() { $this->displayFlash(); }));

			$this->twig = $twig;
		}

		public function getURL($path) {
			return sprintf('%s/%s', rtrim($this->basepath, '/'), ltrim($path, '/'));
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

		public function display($template) {
			$this->twig->display('header.tpl');
			$this->twig->display($template);
			$this->twig->display('footer.tpl');
		}

		public function displayRaw($template) {
			$this->twig->display($template);
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
	}
