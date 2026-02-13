<?php

	use ReallySimpleJWT\Parse as JWTParse;
	use ReallySimpleJWT\Jwt as JWTToken;
	use ReallySimpleJWT\Decode as JWTDecode;

	function getEnvOrDefault($var, $default) {
		$result = getEnv($var);
		return $result === FALSE ? $default : $result;
	}

	require_once(dirname(__FILE__) . '/config.php');

	if (!function_exists('addConfigRoutes')) {
		function addConfigRoutes($router, $displayEngine, $api, $userdata) { }
	}

	function recursiveFindFiles($dir) {
		if (!file_exists($dir)) { return; }

		$it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS));
		foreach($it as $file) {
			if (pathinfo($file, PATHINFO_EXTENSION) == "php") {
				yield $file;
			}
		}
	}

	function getBootstrapVersions() {
		return [
			'5.1' => [
				'css' => [
					['url' => 'https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.1.3/css/bootstrap.min.css', 'integrity' => 'sha512-GQGU0fMMi238uA+a/bdWJfpUGKUkBdgfFdgBm72SUQ6BeyWjoY/ton0tEjH+OSH9iP4Dfh+7HM0I9f5eR0L/4w=='],
				],
				'js' => [
					['url' => 'https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.10.2/umd/popper.min.js', 'integrity' => 'sha512-nnzkI2u2Dy6HMnzMIkh7CPd1KX445z38XIu4jG1jGw7x5tSL3VBjE44dY4ihMU1ijAQV930SPM12cCFrB18sVw=='],
					['url' => 'https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.1.3/js/bootstrap.min.js', 'integrity' => 'sha512-OvBgP9A2JBgiRad/mM36mkzXSXaJE9BEIENnVEmeZdITvwT09xnxLtT4twkCa8m/loMbPHsvPl0T8lRGVBwjlQ=='],
				],
			],
			'5.3' => [
				'css' => [
					['url' => 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css', 'integrity' => 'sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ'],
				],
				'js' => [
					['url' => 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js', 'integrity' => 'sha384-zYPOMqeu1DAVkHiLqWBUTcbYfZ8osu1Nd6Z89ify25QV9guujx43ITvfi12/QExE'],
					['url' => 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.min.js', 'integrity' => 'sha384-Y4oOpwW3duJdCWv5ly8SCFYWqFDsfob/3GkgExXKV4idmbt98QcxXYs9UoXAB7BZ'],
				],
			],
			'5.3.8' => [
				'css' => [
					['url' => 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css', 'integrity' => 'sha256-2FMn2Zx6PuH5tdBQDRNwrOo60ts5wWPC9R8jK67b3t4='],
				],
				'js' => [
					['url' => 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js', 'integrity' => 'sha384-zYPOMqeu1DAVkHiLqWBUTcbYfZ8osu1Nd6Z89ify25QV9guujx43ITvfi12/QExE'],
					['url' => 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.min.js', 'integrity' => 'sha256-ew8UiV1pJH/YjpOEBInP1HxVvT/SfrCmwSoUzF9JIgc='],
				],
			],
		];
	}

	function getThemeInformation() {
		$bs = getBootstrapVersions();

		$groups = [
			'light' => 'Light Mode Themes',
			'dark' => 'Dark Mode Themes',
		];

		$themes = [];

		$themes['light'] = ['name' => "Normal Theme (Light)", 'bstheme' => 'light', 'bsversion' => '5.3.8', 'extracss' => 'bs53light', 'default' => true, 'aliases' => ['normal', 'bs53light'], 'groups' => ['light']];
		$themes['dark'] = ['name' => "Normal Theme (Dark)", 'bstheme' => 'dark', 'bsversion' => '5.3.8', 'extracss' => 'bs53dark', 'aliases' => ['bs53dark'], 'groups' => ['dark']];

		$themes['night'] = [
			'name' => "Bootstrap 5.1 Night", 'bstheme' => '', 'bsversion' => '5.1', 'extracss' => 'night', 'deprecated' => true, 'groups' => ['dark'],
			'externalcss' => [
				['url' => 'https://cdn.jsdelivr.net/npm/bootstrap-dark-5@1.1.3/dist/css/bootstrap-night.min.css'],
			],
		];

		$themes['cyborg'] = [
			'name' => "Cyborg", 'bstheme' => '', 'bsversion' => '5.3.8', 'extracss' => 'cyborg', 'groups' => ['dark'],
			'bscss' => [
				['url' => 'https://cdn.jsdelivr.net/npm/bootswatch@5.3.8/dist/cyborg/bootstrap.min.css', 'integrity' => 'sha256-fa5a59VNtFFUgRkGARsgqJWkITHAdbWQINAtZfTjpRM='],
			],
		];

		// Resolve bootstrap version assets into each theme
		foreach ($themes as &$theme) {
			$version = $theme['bsversion'];
			if (!isset($theme['bscss'])) {
				$theme['bscss'] = $bs[$version]['css'];
			}
			$theme['bsjs'] = $bs[$version]['js'];
		}

		return ['groups' => $groups, 'themes' => $themes];
	}

	function get_mime_type($file) {
		$mime_types = [];
		$mime_types['css'] = 'text/css';
		$mime_types['scss'] = 'text/css';
		$mime_types['js'] = 'application/javascript';
		$mime_types['woff'] = 'application/x-font-woff';

		$bits = explode('.', $file);
		$ext = strtolower(array_pop($bits));
		if (array_key_exists($ext, $mime_types)) {
            return $mime_types[$ext];
        } else {
        	return mime_content_type($file);
        }
	}

	function startsWith($haystack, $needle) {
		$length = strlen($needle);
		return (substr($haystack, 0, $length) === $needle);
	}

	function endsWith($haystack, $needle) {
		$length = strlen($needle);
		if ($length == 0) {
			return true;
		}

		return (substr($haystack, -$length) === $needle);
	}

	function parseBool($input) {
		$in = strtolower($input);
		return ($in === true || $in == 'true' || $in == '1' || $in == 'on' || $in == 'yes');
	}

	function getARPA($domain) {
		if (preg_match('/.*\.ip6\.arpa$/', $domain)) {
			$mainptr = substr($domain, 0, strlen($domain) - 9);
			$pieces = array_reverse(explode('.', $mainptr));
			$hex = implode('', $pieces);
			$repeat = 4 - (strlen($hex) % 4);
			if ($repeat == '4') { $repeat = 0; }
			if ($repeat < 0) { $repeat = 0; }
			$rdns = rtrim(chunk_split($hex, '4', ':'), ':') . str_repeat('0', $repeat) . '::';
			$rdns = inet_ntop(inet_pton($rdns)) . '/' . (count($pieces) * 4);

			return $rdns;
		} else if (preg_match('/.*\.in-addr\.arpa$/', $domain)) {
			$mainptr = substr($domain, 0, strlen($domain) - 13);
			$pieces = array_reverse(explode('.', $mainptr));
			$dom = implode('.', $pieces);
			$repeat = 4 - count($pieces);
			if ($repeat < 0) { $repeat = 0; }
			$rdns = $dom . str_repeat('.0', $repeat) . '/' . (count($pieces) * 8);

			return $rdns;
		}

		return FALSE;
	}

	function getFullARPAIP($domain) {
		if (preg_match('/.*\.ip6\.arpa$/', $domain)) {
			$mainptr = substr($domain, 0, strlen($domain) - 9);
			$pieces = array_reverse(explode('.', $mainptr));
			$hex = implode('', $pieces);
			$repeat = 4 - (strlen($hex) % 4);
			if ($repeat == '4') { $repeat = 0; }
			if ($repeat < 0) { $repeat = 0; }
			$rdns = rtrim(chunk_split($hex, '4', ':'), ':') . str_repeat('0', $repeat);

			return inet_ntop(inet_pton($rdns));
		} else if (preg_match('/.*\.in-addr\.arpa$/', $domain)) {
			$mainptr = substr($domain, 0, strlen($domain) - 13);
			$pieces = array_reverse(explode('.', $mainptr));
			$dom = implode('.', array_slice($pieces, 0, 3));
			$repeat = 3 - count($pieces);
			if ($repeat < 0) { $repeat = 0; }
			$rdns = $dom . str_repeat('.0', $repeat) . '.' . $pieces[count($pieces) - 1];

			return $rdns;
		}

		return FALSE;
	}

	function genUUID() {
		return sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
	}

	function getWantedPage($displayEngine, $page) {
		$wanted = $page;
		$wanted = preg_replace('#^' . preg_quote($displayEngine->getBasePath()) . '#', '/', $wanted);
		$wanted = preg_replace('#^/+#', '/', $wanted);

		if (preg_match('#^/?(admin|domains?|user|profile|impersonate|system)/?#', $wanted)) {
			return $wanted;
		}

		return FALSE;
	}

	function setWantedPage($displayEngine, $page) {
		$wanted = getWantedPage($displayEngine, $page);

		if ($wanted !== FALSE) {
			session::set('wantedPage', $wanted);
		}
	}

	function systemGetTermsText() {
		global $config;
		return $config['register']['termsText'];
	}

	function parseJWT($token, $secret = '') {
		try {
			$jwttoken = new JWTToken($token, $secret);
			$parse = new JWTParse($jwttoken, new JWTDecode());

			if (!empty($secret)) {
				if (!JWTToken::validate($token, $secret)) { throw new Exception('Fail.'); }
			}

			$parsed = $parse->parse();
			if ($parsed != null) {
				return $parsed->getPayload();
			}
		} catch (Exception $ex) { }

		return [];
	}

	function do_idn_to_ascii($domain) {
		return idn_to_ascii($domain, IDNA_DEFAULT, INTL_IDNA_VARIANT_UTS46);
	}

	function do_idn_to_utf8($domain) {
		return idn_to_utf8($domain, IDNA_DEFAULT, INTL_IDNA_VARIANT_UTS46);
	}
