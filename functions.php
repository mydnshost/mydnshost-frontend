<?php

	use ReallySimpleJWT\Parse as JWTParse;
	use ReallySimpleJWT\Jwt as JWTToken;
	use ReallySimpleJWT\Validate as JWTValidate;
	use ReallySimpleJWT\Encode as JWTEncode;

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

	function get_mime_type($file) {
		$mime_types = [];
		$mime_types['css'] = 'text/css';
		$mime_types['js'] = 'application/javascript';

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
			$rdns = rtrim(chunk_split($hex, '4', ':'), ':') . str_repeat('0', $repeat) . '::/' . (count($pieces) * 4);

			return $rdns;
		} else if (preg_match('/.*\.in-addr\.arpa$/', $domain)) {
			$mainptr = substr($domain, 0, strlen($domain) - 13);
			$pieces = array_reverse(explode('.', $mainptr));
			$dom = implode('.', $pieces);
			$repeat = 4 - count($pieces);
			$rdns = $dom . str_repeat('.0', $repeat) . '/' . (count($pieces) * 8);

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
			$token = new JWTToken($token, $secret);
			$parse = new JWTParse($token, new JWTValidate(), new JWTEncode());

			if (!empty($secret)) {
				$parse = $parse->validate();
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
