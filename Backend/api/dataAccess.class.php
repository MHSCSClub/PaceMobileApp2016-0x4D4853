<?php

	require_once("secret.class.php");
	require_once("signal.class.php");
	require_once("exception.class.php");

	/*
		Database interface
		
		Public interface:

		Return value is ALWAYS an object of type ISignal

		register($username, $password): registers users in database

		login($username, $password): logs in + authcode

		authGET($authcode, $function): calls a function, no additional data

		authPOST($authcode, $function, $params): $params is an array

	*/

	class DataAccess
	{

		private static $ip = "localhost";
		private static $dbName = "pace2016";

		/*
			Public interface
		*/

		public static function careREGISTER($username, $password) {
			return self::run(function() use ($username, $password) {
				return DataAccess::CARE_register($username, $password);
			});
		}

		public static function careLOGIN($username, $password) { 
			return self::run(function() use ($username, $password) {
				return DataAccess::CARE_login($username, $password);
			});
		}

		public static function patiLINK($lcode) {
			return self::run(function() use ($lcode) {
				return DataAccess::PATI_link($lcode);
			});
		}

		public static function careGET($authcode, $funcname) {
			return self::run(function() use ($authcode, $funcname) {
				$realfunc = "DataAccess::GET_CARE_$funcname";
				$db = self::getConnection();
				$userinfo = DataAccess::authSetup($db, $authcode);
				if($userinfo['usertype'] != 1)
					throw new AuthException();

				return call_user_func($realfunc, $db, $userinfo['userid']);
			});
		}

		public static function carePOST($authcode, $funcname, $params) {
			return self::run(function() use ($authcode, $funcname, $params) {
				$realfunc = "DataAccess::POST_CARE_$funcname";
				$db = self::getConnection();
				$userinfo = DataAccess::authSetup($db, $authcode);
				if($userinfo['usertype'] != 1)
					throw new AuthException();

				return call_user_func($realfunc, $db, $userinfo['userid'], $params);
			});
		}

		/*
			Private methods

			All functions are ran through the run() method
			This ensures consistent error handling

		*/

		private static function run($function) {
			try {
				return $function();
			} catch(DBConnectException $e) {
				return Signal::dbConnectionError();
			} catch(AuthException $e) {
				return Signal::authError();
			} catch(Exception $e) {
				return Signal::error()->setMessage($e->getMessage());
			}
		}

		private static function getConnection() {
			$db = new mysqli(self::$ip, Secret::$username, Secret::$password, self::$dbName);

			if($db->connect_error)
				throw new DBConnectException();

			return $db;
		}

		private static function hash($value) {
			return hash("sha256", $value);
		}

		private static function hashPass($pass, $salt) {
			return self::hash($pass.$salt);
		}

		/*
			Helper functions that interface with the database
		*/

		private static function authSetup($db, $authcode) {
			//Get userid from auth
			$stmt = $db->prepare("SELECT userid FROM auth WHERE authcode=? AND NOW() < expire");
			$stmt->bind_param('s', $authcode);
			$stmt->execute();
			$res = $stmt->get_result();
			$stmt->close();

			if($res->num_rows != 1)
				throw new AuthException();

			$userid = $res->fetch_assoc()['userid'];
			$userinfo = $db->query("SELECT * FROM users WHERE userid=$userid");
			$userinfo = $userinfo->fetch_assoc();

			//Update authcode expiration
			self::updateAuthExpiration($db, $userid);
			return $userinfo;
		}

		private static function updateAuthExpiration($db, $userid) {
			$db->query("UPDATE auth SET expire=DATE_ADD(NOW(), INTERVAL 1 MONTH) WHERE userid=$userid");
		}

		//Creates a JSON array out of multiple results
		private static function formatArrayResults($res) {
			//Format results
			$rows = array();
			while($r = $res->fetch_assoc()) {
				$rows[] = $r;
			}
			return Signal::success()->setData($rows);
		}

		/*
			All actions
		*/

		//User

		private static function CARE_register($username, $password) {
			$db = self::getConnection();

			//Verify basic UN + Pass checks
			//UN >= 4 chars, Pass >= 8 chars
			if(strlen($username) < 5 || strlen($password) < 8)
				throw new Exception("Parameter length error");

			//Check if user exists
			$stmt = $db->prepare('SELECT cid FROM caretakers WHERE username=?');
			$stmt->bind_param('s', $username);
			$stmt->execute();
			$res = $stmt->get_result();
			if($res->num_rows > 0)
				throw new Exception("Username already taken");
			$stmt->close();

			//Process password: generate salt and hash pwd + salt
			$random = openssl_random_pseudo_bytes(64);
			$salt = self::hash($random);
			$hshpass = self::hashPass($password, $salt);

			//Insert user into database
			$stmt = $db->query('INSERT INTO users VALUES (null, 1)');
			$userid = $db->query("SELECT LAST_INSERT_ID()");

			$stmt = $db->prepare('INSERT INTO caretakers VALUES (?, ?, ?, ?)');
			$stmt->bind_param('isss', $userid, $username, $hshpass, $salt);
			$stmt->execute();
			$stmt->close();
			return Signal::success();
		}

		private static function CARE_login($username, $password) {
			$db = self::getConnection();

			//Fetch salt + check if user exists
			$stmt = $db->prepare('SELECT username, salt FROM caretakers WHERE username=?');
			$stmt->bind_param('s', $username);
			$stmt->execute();
			$res = $stmt->get_result();
			$stmt->close();

			//User found (note same error)
			if($res->num_rows != 1)
				throw new Exception("Invalid credentials error");

			$row = $res->fetch_assoc();
			$username = $row['username']; //username is safe now: no risk of sql injection
			$salt = $row['salt'];

			//Salt password
			$hshpass = self::hashPass($password, $salt); //hshpass also safe, no sql injection in a hash
			$res = $db->query("SELECT cid FROM caretakers WHERE username='$username' AND password='$hshpass'");

			//Authentication
			if($res->num_rows != 1)
				throw new Exception("Invalid credentials error");
			$cid = $res->fetch_assoc()["cid"];

			//Check if user in auth table
			$res = $db->query("SELECT authcode FROM auth WHERE userid=$cid");

			//Generate a random authcode
			$random = openssl_random_pseudo_bytes(64);
			$authcode = self::hash($random);

			if($res->num_rows >= 1) {
				$authcode = $res->fetch_assoc()['authcode'];
			} else {
				//Set temporary expiration date and then update
				$db->query("INSERT INTO auth VALUES (null, $cid, '$authcode', NOW() )");
			}
			self::updateAuthExpiration($db, $cid);

			//Return success with data
			$data = array("authcode" => $authcode);
			return Signal::success()->setData($data);
		}

		private static function PATI_link($lcode) {
			$db = self::getConnection();

			//Fetch link
			$stmt = $db->prepare('SELECT cid, pid FROM link WHERE lcode=? AND open=1');
			$stmt->bind_param('s', $lcode);
			$stmt->execute();
			$res = $stmt->get_result();
			$stmt->close();

			//Link code error
			if($res->num_rows != 1)
				throw new Exception("Invalid link code error");

			$res = $res->fetch_assoc();
			$cid = $res['cid'];
			$pid = $res['pid'];

			//Update relation
			$db->query("UPDATE relation SET active=1 WHERE cid=$cid AND pid=$pid");

			//Return authcode
			$random = openssl_random_pseudo_bytes(64);
			$authcode = self::hash($random);
			$db->query("INSERT INTO auth VALUES (null, $pid, '$authcode', NOW() )");
			self::updateAuthExpiration($db, $pid);

			//Return success with data
			$data = array("authcode" => $authcode);
			return Signal::success()->setData($data);
		}

		private static function GET_CARE_verify($db, $cid) {
			//If userid exists, it means that authcode is valid already
			return Signal::success();
		}

		private static function GET_CARE_info($db, $cid) {
			//Username
			$res = $db->query("SELECT username FROM users WHERE userid=$cid");
			$username = $res->fetch_assoc()["username"];

			//Data
			$data = array("username" => $username);
			return Signal::success()->setData($data);
		}

		private static function POST_CARE_createPatient($db, $cid, $params) {
			if(is_null($params['name']) || is_null($params['usability']))
				throw new Exception("Invalid POST data");

			//Patient info
			$name = $params['name'];
			$usability = $params['usability'];

			//Create patient
			$stmt = $db->query('INSERT INTO users VALUES (null, 0)');
			$res = $db->query("SELECT LAST_INSERT_ID()");
			$pid = $res->fetch_assoc()['LAST_INSERT_ID()']; 

			$stmt = $db->prepare('INSERT INTO patients VALUES (?, ?, ?)');
			$stmt->bind_param('iss', $pid, $name, $usability);
			$stmt->execute();
			$stmt->close();

			//Create relation
			$db->query("INSERT INTO relation VALUES (null, $cid, $pid, 0)");

			$random = openssl_random_pseudo_bytes(6);
			$lcode = base64_encode($random);

			//Create link
			$db->query("INSERT INTO link VALUES (null, $cid, $pid, '$lcode', 1)");
			$data = array("lcode" => $lcode);
			return Signal::success()->setData($data);
		}


	}
?>
