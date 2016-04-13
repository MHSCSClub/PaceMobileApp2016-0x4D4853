<?php

	require_once("secret.class.php");
	require_once("signal.class.php");
	require_once("exception.class.php");
	require_once("nodeAPI.class.php");

	/*
		Database interface
		
		Public interface:

		Return value is ALWAYS an object of type ISignal

		caretaker:
		careREGISTER: registers a new caretaker
		careLOGIN: caretaker login
		careGET: standard caretaker GET request
		carePOST: standard caretaker POST request
		capaGET: caretaker accessing patient data (checks relation)
		capaPOST: caretaker creating patient data (checks relation)

		patient:
		patiLINK: links caretaker and patient
		patiGET: standard patient GET request
		patiPOST: standard patient POST request

	*/

	class DataAccess
	{

		private static $ip = "localhost";
		private static $dbName = "pace2016";

		const T_PATI = 0;
		const T_CARE = 1;

		/*
			Public interface
		*/

		//Caretaker

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

		public static function careGET($authcode, $funcname) {
			return self::run(function() use ($authcode, $funcname) {
				$realfunc = "DataAccess::GET_CARE_$funcname";
				$db = self::getConnection();
				$userid = DataAccess::authSetup($db, $authcode, self::T_CARE);

				return call_user_func($realfunc, $db, $userid);
			});
		}

		public static function carePOST($authcode, $funcname, $params) {
			return self::run(function() use ($authcode, $funcname, $params) {
				$realfunc = "DataAccess::POST_CARE_$funcname";
				$db = self::getConnection();
				$userid = DataAccess::authSetup($db, $authcode, self::T_CARE);

				return call_user_func($realfunc, $db, $userid, $params);
			});
		}

		public static function capaGET($authcode, $pid, $funcname) {
			return self::run(function() use ($authcode, $pid, $funcname) {
				$realfunc = "DataAccess::GET_CAPA_$funcname";
				$db = self::getConnection();
				$cid = DataAccess::authSetup($db, $authcode, self::T_CARE);
				$pid = self::checkRelation($db, $cid, $pid);

				return call_user_func($realfunc, $db, $cid, $pid);
			});
		}

		public static function capaPOST($authcode, $pid, $funcname, $params) {
			return self::run(function() use ($authcode, $pid, $funcname, $params) {
				$realfunc = "DataAccess::POST_CAPA_$funcname";
				$db = self::getConnection();
				$cid = DataAccess::authSetup($db, $authcode, self::T_CARE);
				$pid = self::checkRelation($db, $cid, $pid);

				return call_user_func($realfunc, $db, $cid, $pid, $params);
			});
		}

		//Patient

		public static function patiLINK($lcode) {
			return self::run(function() use ($lcode) {
				return DataAccess::PATI_link($lcode);
			});
		}

		public static function patiGET($authcode, $funcname) {
			return self::run(function() use ($authcode, $funcname) {
				$realfunc = "DataAccess::GET_PATI_$funcname";
				$db = self::getConnection();
				$userid = DataAccess::authSetup($db, $authcode, self::T_PATI);

				return call_user_func($realfunc, $db, $userid);
			});
		}

		public static function patiPOST($authcode, $funcname, $params) {
			return self::run(function() use ($authcode, $funcname, $params) {
				$realfunc = "DataAccess::POST_PATI_$funcname";
				$db = self::getConnection();
				$userid = DataAccess::authSetup($db, $authcode, self::T_PATI);

				return call_user_func($realfunc, $db, $userid, $params);
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
			} catch(IMGException $e) {
				return Signal::imgError()->setMessage($e->getMessage());
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

		private static function authSetup($db, $authcode, $type) {
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

			if($userinfo['usertype'] != $type)
				throw new AuthException();

			//Update authcode expiration
			self::updateAuthExpiration($db, $userid);
			return $userid;
		}

		private static function checkRelation($db, $cid, $pid) {
			//Get userid from auth
			$stmt = $db->prepare("SELECT pid FROM relation WHERE cid=? AND pid=?");
			$stmt->bind_param("ii", $cid, $pid);
			$stmt->execute();
			$res = $stmt->get_result();
			$stmt->close();

			if($res->num_rows != 1)
				throw new Exception("Invalid patient id");

			return $res->fetch_assoc()['pid'];
		}

		private static function getIdFromUsername($db, $username) {
			$db = self::getConnection();
			$stmt = $db->prepare("SELECT cid FROM caretakers WHERE username=?");
			$stmt->bind_param('s', $username);
			$stmt->execute();
			$res = $stmt->get_result();
			$stmt->close();

			if($res->num_rows != 1) {
				throw new Exception("Invalid caretaker id");
			}
			return $res->fetch_assoc()['cid'];
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
			$res = $db->query("SELECT LAST_INSERT_ID()");
			$cid = $res->fetch_assoc()['LAST_INSERT_ID()'];

			$stmt = $db->prepare('INSERT INTO caretakers VALUES (?, ?, ?, ?)');
			$stmt->bind_param('isss', $cid, $username, $hshpass, $salt);
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
			$stmt = $db->prepare('SELECT lid, cid, pid FROM link WHERE lcode=? AND open=1');
			$stmt->bind_param('s', $lcode);
			$stmt->execute();
			$res = $stmt->get_result();
			$stmt->close();

			//Link code error
			if($res->num_rows != 1)
				throw new Exception("Invalid link code error");

			$res = $res->fetch_assoc();
			$lid = $res['lid'];
			$cid = $res['cid'];
			$pid = $res['pid'];

			//Update relation
			$db->query("UPDATE relation SET active=1 WHERE cid=$cid AND pid=$pid");

			//Update link
			$db->query("UPDATE link SET open=0 WHERE lid=$lid");

			//Return authcode
			$random = openssl_random_pseudo_bytes(64);
			$authcode = self::hash($random);
			$db->query("INSERT INTO auth VALUES (null, $pid, '$authcode', NOW() )");
			self::updateAuthExpiration($db, $pid);

			//Return success with data
			$data = array("authcode" => $authcode);
			return Signal::success()->setData($data);
		}

		//Caretaker auxillary actions

		private static function GET_CARE_verify($db, $cid) {
			//If userid exists, it means that authcode is valid already
			return Signal::success();
		}

		private static function GET_CARE_info($db, $cid) {
			//Username
			$res = $db->query("SELECT username FROM caretakers WHERE cid=$cid");
			$username = $res->fetch_assoc()["username"];

			//Data
			$data = array("username" => $username);
			return Signal::success()->setData($data);
		}

		//Patient auxillary actions

		private static function GET_PATI_info($db, $pid) {
			$res = $db->query("SELECT name, usability FROM patients WHERE pid=$pid");
			$ret = $res->fetch_assoc();
			$ret['medstatus'] = self::medStatus($db, $pid);
			return Signal::success()->setData($res->fetch_assoc());
		}

		//Register Device

		private static function registerDevice($db, $userid, $uiud) {
			$stmt = $db->prepare('INSERT INTO devices VALUES (null, ?, ?) ON DUPLICATE KEY UPDATE uiud=?');
			$stmt->bind_param('iss', $userid, $uiud, $uiud);
			$stmt->execute();
			$stmt->close();
		}

		private static function POST_CARE_registerDevice($db, $cid, $params) {
			if(is_null($params['uiud']) || strlen($params['uiud']) != 64)
				throw new Exception("Invalid POST data");

			self::registerDevice($db, $cid, $params['uiud']);
			return Signal::success();
		}

		private static function POST_PATI_registerDevice($db, $pid, $params) {
			if(is_null($params['uiud']) || strlen($params['uiud']) != 64)
				throw new Exception("Invalid POST data");

			self::registerDevice($db, $pid, $params['uiud']);
			return Signal::success();
		}

		//Caretaker Patient Interaction 

		private static function GET_CARE_patients($db, $cid) {
			$res = $db->query("SELECT relation.pid, name, active FROM relation INNER JOIN patients ON patients.pid = relation.pid WHERE cid=$cid");

			return self::formatArrayResults($res);
		}

		private static function POST_CARE_createPatient($db, $cid, $params) {
			if(is_null($params['name']) || is_null($params['usability']))
				throw new Exception("Invalid POST data");

			//Patient info
			$name = $params['name'];
			$usability = $params['usability'];

			//Create patient
			$db->query('INSERT INTO users VALUES (null, 0)');
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
			$data = array("pid" => $pid, "lcode" => $lcode);
			return Signal::success()->setData($data);
		}

		private static function GET_CAPA_info($db, $cid, $pid) {
			return self::GET_PATI_info($db, $pid);
		}

		private static function GET_CAPA_relink($db, $cid, $pid) {
			$data = array();
			//Look for existing open link
			$res = $db->query("SELECT lcode FROM link WHERE cid=$cid AND pid=$pid AND open=1");
			if($res->num_rows == 1) {
				$data['lcode'] = $res->fetch_assoc()['lcode'];
				return Signal::success()->setData($data);
			}

			//Create link
			$random = openssl_random_pseudo_bytes(6);
			$lcode = base64_encode($random);

			$db->query("INSERT INTO link VALUES (null, $cid, $pid, '$lcode', 1)");
			$data['lcode'] = $lcode;
			return Signal::success()->setData($data);
		}

		private static function GET_CAPA_share($db, $cid, $pid) {
			$username = $params['username'];
			$ncid = self::getIdFromUsername($username);

			//Create relation
			$db->query("INSERT INTO relation VALUES (null, $cid, $pid, 1)");
			return Signal::success();
		}

		//Medication

		private static function validateMedid($db, $pid, $medid) {
			$stmt = $db->prepare("SELECT medid FROM medication WHERE medid=? AND pid=$pid");
			$stmt->bind_param('i', $medid);
			$stmt->execute();
			$res = $stmt->get_result();

			if($res->num_rows != 1)
				throw new Exception("Invalid medid");
			return $res->fetch_assoc()['medid'];
		}

		//Caretaker

		private static function POST_CAPA_createMedication($db, $cid, $pid, $params) {
			if(is_null($params['name']) || is_null($params['dosage']) || is_null($params['remain']))
				throw new Exception("Invalid POST data");
			$stmt = $db->prepare("INSERT INTO medication VALUES (null, $pid, ?, ?, ?, ?, ?)");
			$stmt->bind_param('siiss', $params['name'], $params['dosage'], $params['remain'], $params['pic'], $params['info']);
			$stmt->execute();
			$stmt->close();

			$res = $db->query("SELECT LAST_INSERT_ID()");
			$medid = $res->fetch_assoc()['LAST_INSERT_ID()'];

			return Signal::success()->setData(array("medid" => $medid));
		}

		private static function POST_CAPA_modifyMedication($db, $cid, $pid, $params) {
			$medid = self::validateMedid($db, $pid, $params['medid']);
			$stmt = $db->prepare("UPDATE medication SET name=COALESCE(?, name), dosage=COALESCE(?, dosage),".
									"remain=COALESCE(?, remain), pic=COALESCE(?, pic), info=COALESCE(?, info) WHERE medid=$medid");
			$stmt->bind_param('siiss', $params['name'], $params['dosage'], $params['remain'], $params['pic'], $params['info']);
			$stmt->execute();
			$stmt->close();

			return Signal::success();
		}

		private static function GET_CAPA_listMedication($db, $cid, $pid) {
			return self::GET_PATI_listMedication($db, $pid);
		}

		private static function POST_CAPA_getMedication($db, $cid, $pid, $params) {
			return self::POST_PATI_getMedication($db, $pid, $params);
		}

		//Patient

		private static function packagePatient($db, $pid) {
			$res = $db->query("SELECT uiud, name, patients.pid FROM patients INNER JOIN devices ON patients.pid=devices.userid WHERE patients.pid=$pid");
			$package = array('patient' => $res->fetch_assoc());
			return $package;
		}

		private static function medStatus($db, $pid) {
			$res = $db->query("SELECT msid FROM schedule inner join medsche on schedule.schid=medsche.schid " . 
								"WHERE TIME(take) < CURTIME() AND (CURDATE()<>DATE(taken) OR taken IS NULL) AND pid=2");

			return ($res->num_rows == 0);
		}

		private static function POST_PATI_takeMedication($db, $pid, $params) {
			$schid = self::validateSchid($db, $pid, $params['schid']);
			$medid = self::validateMedid($db, $pid, $params['medid']);

			$res = $db->query("SELECT msid FROM medsche WHERE medid=$medid AND schid=$schid");
			if($res->num_rows != 1)
				throw new Exception("Invalid medid");
				
			$db->query("UPDATE medsche SET taken=NOW() WHERE schid=$schid AND medid=$medid");
			$db->query("UPDATE medication SET remain=remain-dosage WHERE medid=$medid");

			//Send a success notification if all medication has been taken on time
			$res = $db->query("SELECT msid FROM medsche WHERE (CURDATE()<>DATE(taken) OR taken IS NULL) AND schid=$schid");
			if($res->num_rows == 0) {
				//All medication has been taken

				$package = self::packagePatient($db, $pid);
				$package['schid'] = $schid;

				$res = $db->query("SELECT cid FROM relation WHERE pid=$pid");
				$cid = $res->fetch_assoc()['cid'];
				$package = array_merge($package, self::packageCaretaker($db, $cid));

				$res = NodeAPI::POST("schedule/$schid/take", $package);
				if($res->isError())
					throw new Exception($res->getMessage());
			}
			return Signal::success();
		}

		private static function GET_PATI_listMedication($db, $pid) {
			$res = $db->query("SELECT medid, name, dosage, remain, info FROM medication WHERE pid=$pid");
			return self::formatArrayResults($res);
		}

		private static function POST_PATI_getMedication($db, $pid, $params) {
			try {
				$medid = self::validateMedid($db, $pid, $params['medid']);
			} catch(Exception $e) {
				throw new IMGException($e->getMessage());
			}
			
			$res = $db->query("SELECT pic FROM medication WHERE medid=$medid AND pid=$pid");
			$imgdata = $res->fetch_assoc()['pic'];

			if(is_null($imgdata))
				throw new IMGException("No image");
			return Signal::success()->setType("IMG")->setData($imgdata);
		}

		//Schedule

		private static function validateSchid($db, $pid, $schid) {
			$stmt = $db->prepare("SELECT schid FROM schedule WHERE schid=? AND pid=$pid");
			$stmt->bind_param('i', $schid);
			$stmt->execute();
			$res = $stmt->get_result();

			if($res->num_rows != 1)
				throw new IMGException("Invalid schid");
			return $res->fetch_assoc()['schid'];
		}

		//Caretaker

		private static function packageCaretaker($db, $cid) {
			$res = $db->query("SELECT uiud FROM devices WHERE userid=$cid");
			$package = array('caretaker' => $res->fetch_assoc());
			return $package;
		}

		private static function POST_CAPA_createSchedule($db, $cid, $pid, $params) {
			if(is_null($params['hours']) || is_null($params['minutes']) || is_null($params['medication']))
				throw new Exception("Invalid POST data");

			$date = new DateTime('2001-09-11');
			$date->setTime($params['hours'], $params['minutes']);
			$date = $date->format('Y-m-d H:i:s');

			$stmt = $db->prepare("INSERT IGNORE INTO schedule VALUES (null, $pid, ?)");
			$stmt->bind_param('s', $date);
			$stmt->execute();

			$res = $db->query("SELECT LAST_INSERT_ID()");
			$schid = $res->fetch_assoc()['LAST_INSERT_ID()'];

			if($schid == 0)
				throw new Exception("Time already exists");

			$meds = explode(',', $params['medication']);
			for($i = 0; $i < count($meds); ++$i) {
				$medid = self::validateMedid($db, $pid, $meds[$i]);
				$db->query("INSERT IGNORE INTO medsche VALUES (null, $schid, $medid, null)");
			}

			//Create notification
			$package = array_merge(self::packageCaretaker($db, $cid), self::packagePatient($db, $pid));
			$package['time'] = $date;
			$package['schid'] = $schid;

			$res = NodeAPI::POST('schedule', $package);
			if($res->isError())
				throw new Exception($res->getMessage());

			return Signal::success()->setData(array("schid" => $schid));
		}

		private static function GET_CAPA_listSchedule($db, $cid, $pid) {
			return self::GET_PATI_listSchedule($db, $pid);
		}

		private static function POST_CAPA_detailSchedule($db, $cid, $pid, $params) {
			return self::POST_PATI_detailSchedule($db, $pid, $params);
		}

		private static function POST_CAPA_modifySchedule($db, $cid, $pid, $params) {
			$schid = self::validateSchid($db, $pid, $params['schid']);
			$db->query("DELETE FROM medsche WHERE schid=$schid");
			$meds = explode(',', $params['medication']);
			for($i = 0; $i < count($meds); ++$i) {
				$medid = self::validateMedid($db, $pid, $meds[$i]);
				$db->query("INSERT IGNORE INTO medsche VALUES (null, $schid, $medid, null)");
			}
			return Signal::success();
		}

		private static function POST_CAPA_deleteSchedule($db, $cid, $pid, $params) {
			$schid = self::validateSchid($db, $pid, $params['schid']);
			$db->query("DELETE FROM medsche WHERE schid=$schid");
			$db->query("DELETE FROM schedule WHERE schid=$schid");

			//Delete from notifications
			$res = NodeAPI::DELETE("schedule/$schid");
			if($res->isError())
				throw new Exception($res->getMessage());
			return Signal::success();
		}

		//Patient

		private static function GET_PATI_listSchedule($db, $pid) {
			$res = $db->query("SELECT schid, HOUR(take) AS hours, MINUTE(take) AS minutes FROM schedule WHERE pid=$pid");
			return self::formatArrayResults($res);
		}

		private static function POST_PATI_detailSchedule($db, $pid, $params) {
			$schid = self::validateSchid($db, $pid, $params['schid']);
			$res = $db->query("SELECT medid, taken FROM medsche WHERE schid=$schid");
			return self::formatArrayResults($res);
		}
	}

?>