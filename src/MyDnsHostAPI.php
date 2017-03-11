<?php

	class MyDnsHostAPI {
		private $baseurl = 'https://api.mydnshost.co.uk/';
		private $version = '1.0';
		private $auth = FALSE;

		public function __construct($baseurl) {
			$this->baseurl = $baseurl;
		}

		public function setAuthUserPass($user, $pass) {
			$this->auth = ['type' => 'userpass', 'user' => $user, 'pass' => $pass];
		}

		public function setAuthUserKey($user, $key) {
			$this->auth = ['type' => 'userkey', 'user' => $user, 'key' => $key];
		}

		public function setAuthSession($sessionid) {
			$this->auth = ['type' => 'session', 'sessionid' => $sessionid];
		}

		public function setAuth($auth) {
			$this->auth = $auth;
		}

		public function validAuth() {
			if ($this->auth === FALSE) {
				return FALSE;
			}

			return $this->getUserData() !== NULL;
		}

		public function getUserData() {
			if ($this->auth === FALSE) { return NULL; }

			$result = $this->api('/userdata');
			return isset($result['response']['user']) ? $result['response']['user'] : NULL;
		}

		public function getSessionID() {
			if ($this->auth === FALSE) { return NULL; }

			$result = $this->api('/session');
			return isset($result['response']['session']) ? $result['response']['session'] : NULL;
		}

		private function api($apimethod, $method = 'GET', $data = []) {
			$headers = [];
			$options = [];
			if ($this->auth !== FALSE) {
				if ($this->auth['type'] == 'session') {
					$headers['X-SESSION-ID'] = $this->auth['sessionid'];
				} else if ($this->auth['type'] == 'userkey') {
					$headers['X-API-USER'] = $this->auth['user'];
					$headers['X-API-KEY'] = $this->auth['key'];
				} else if ($this->auth['type'] == 'userpass') {
					$options['auth'] = [$this->auth['user'], $this->auth['pass']];
				}
			}

			if ($method == 'GET') {
				$response = Requests::get($this->getURL($apimethod), $headers, $options);
			} else if ($method == 'POST') {
				$response = Requests::post($this->getURL($apimethod), $headers, $data, $options);
			} else if ($method == 'DELETE') {
				$response = Requests::delete($this->getURL($apimethod), $headers, $options);
			}

			$data = @json_decode($response->body, TRUE);
			if ($data == null) {
				$data = ['error' => 'There was an unknown error.'];
			}

			return $data;
		}

		private function getURL($apimethod) {
			return sprintf('%s/%s/%s', rtrim($this->baseurl, '/'), $this->version, ltrim($apimethod, '/'));
		}
	}
