<?php

	/**
	 * Class to interact with mydnshost api.
	 */
	class MyDNSHostAPI {
		/** Base URL. */
		private $baseurl = 'https://api.mydnshost.co.uk/';
		/** API Version. */
		private $version = '1.0';
		/** Auth Data. */
		private $auth = FALSE;

		/**
		 * Create a new MyDNSHostAPI
		 *
		 * @param $baseurl Base URL to connect to.
		 */
		public function __construct($baseurl) {
			$this->baseurl = $baseurl;
		}

		/**
		 * Auth using a username and password.
		 *
		 * @param $user User to auth with
		 * @param $pass Password to auth with
		 */
		public function setAuthUserPass($user, $pass) {
			$this->auth = ['type' => 'userpass', 'user' => $user, 'pass' => $pass];
		}

		/**
		 * Auth using a username and api key.
		 *
		 * @param $user User to auth with
		 * @param $key Key to auth with
		 */
		public function setAuthUserKey($user, $key) {
			$this->auth = ['type' => 'userkey', 'user' => $user, 'key' => $key];
		}

		/**
		 * Auth using a session ID.
		 *
		 * @param $sessionid ID to auth with
		 */
		public function setAuthSession($sessionid) {
			$this->auth = ['type' => 'session', 'sessionid' => $sessionid];
		}

		/**
		 * Auth using a custom auth method.
		 *
		 * @param $auth Auth data.
		 */
		public function setAuth($auth) {
			$this->auth = $auth;
		}

		/**
		 * Check if we have valid auth details.
		 *
		 * @return True if we can auth successfully.
		 */
		public function validAuth() {
			if ($this->auth === FALSE) {
				return FALSE;
			}

			return $this->getUserData() !== NULL;
		}

		/**
		 * Get information about the user we are authed as
		 *
		 * @return Array of user data or null if we are not authed.
		 */
		public function getUserData() {
			if ($this->auth === FALSE) { return NULL; }

			$result = $this->api('/userdata');
			return isset($result['response']['user']) ? $result['response']['user'] : NULL;
		}

		/**
		 * Get a session ID from the backend
		 *
		 * @return Backend session ID or null if we are not authed.
		 */
		public function getSessionID() {
			if ($this->auth === FALSE) { return NULL; }

			$result = $this->api('/session');
			return isset($result['response']['session']) ? $result['response']['session'] : NULL;
		}

		/**
		 * Get list of our domains.
		 *
		 * @return Array of domains or an empty array.
		 */
		public function getDomains() {
			if ($this->auth === FALSE) { return []; }

			$result = $this->api('/domains');
			return isset($result['response']) ? $result['response'] : [];
		}

		/**
		 * Get domain data for a given domain.
		 *
		 * @return Array of domains or an empty array.
		 */
		public function getDomainData($domain) {
			if ($this->auth === FALSE) { return []; }

			$result = $this->api('/domains/' . $domain);
			return isset($result['response']) ? $result['response'] : [];
		}

		/**
		 * Get domain data for a given domain.
		 *
		 * @return Array of access info or an empty array.
		 */
		public function getDomainAccess($domain) {
			if ($this->auth === FALSE) { return []; }

			$result = $this->api('/domains/' . $domain . '/access');
			return isset($result['response']['access']) ? $result['response']['access'] : [];
		}

		/**
		 * Get domain data for a given domain.
		 *
		 * @return Array of records or an empty array.
		 */
		public function getDomainRecords($domain) {
			if ($this->auth === FALSE) { return []; }

			$result = $this->api('/domains/' . $domain . '/records');
			return isset($result['response']['records']) ? $result['response']['records'] : [];
		}

		/**
		 * Poke the API.
		 *
		 * @param $apimethod API Method to poke
		 * @param $method Request method to access the API with
		 * @param $data (Default: []) Data to send if POST
		 */
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

			$url = sprintf('%s/%s/%s', rtrim($this->baseurl, '/'), $this->version, ltrim($apimethod, '/'));

			try {
				if ($method == 'GET') {
					$response = Requests::get($url, $headers, $options);
				} else if ($method == 'POST') {
					$response = Requests::post($url, $headers, $data, $options);
				} else if ($method == 'DELETE') {
					$response = Requests::delete($url, $headers, $options);
				}

				$data = @json_decode($response->body, TRUE);
			} catch (Requests_Exception $ex) {
				$data = NULL;
			}

			if ($data == NULL) {
				$data = ['error' => 'There was an unknown error.'];
			}

			return $data;
		}
	}
