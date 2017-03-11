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
