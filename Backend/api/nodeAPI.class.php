<?php

	require_once("signal.class.php");

	/*
		NodeAPI: interacting with the backend Node.js server through cURL
		Like DataAccess, this class uses static methods and returns ISignals

	*/

	class NodeAPI
	{
		private static $baseURL = "http://localhost:6969/api/";

		private static function parseResponse($res) {
			if($res['status'] == 'success')
				return Signal::success();
			return Signal::error()->setData($res['message']);
		}

		public static function POST($action, $params) {
			$url = self::$baseURL.$action;
			$params = json_encode($params);

			$curl = curl_init();

			curl_setopt_array($curl, array(
				CURLOPT_RETURNTRANSFER => 1,
				CURLOPT_URL => $url,
				CURLOPT_POST => 1,
				CURLOPT_POSTFIELDS => $params,
				CURLOPT_HTTPHEADER => array(
					'Content-Type: application/json',
					'Content-Length: ' . strlen($params)
				)
			));

			$res = json_decode(curl_exec($curl), True);
			curl_close($curl);

			return self::parseResponse($res);
		}

		public static function DELETE($action) {
			$url = self::$baseURL.$action;

			$curl = curl_init();

			curl_setopt_array($curl, array(
				CURLOPT_RETURNTRANSFER => 1,
				CURLOPT_URL => $url,
				CURLOPT_CUSTOMREQUEST => "DELETE"
			));
			
			$res = json_decode(curl_exec($curl), True);
			curl_close($curl);

			return self::parseResponse($res);
		}
	}

?>