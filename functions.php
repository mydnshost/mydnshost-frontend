<?php

	function getEnvOrDefault($var, $default) {
		$result = getEnv($var);
		return $result === FALSE ? $default : $result;
	}

	require_once(dirname(__FILE__) . '/config.php');

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
