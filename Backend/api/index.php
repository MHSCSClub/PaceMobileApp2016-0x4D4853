<?php
	
	require_once("requestHandler.class.php");
	require_once("signal.class.php");
	require_once("dataAccess.class.php");

	$user_request = @$_GET['request'];

	function notFound() {
		header("HTTP/1.0 404 Not Found");
		echo("<h1> you fucked up!<h1>");
		die();
	}

	//Using RequestHandler class, look in class to find documentation
	$RH = new RequestHandler();
	$WC = $RH->getWildcard();

	$RH->D("", "test");

	// test/*
	$RH->F("test", $WC, function($trace) {
		return Signal::success()->setData($trace[1]);
	});
	// test/get
	$RH->F("test", "get", function() {
		return Signal::success();
	});
	// test/post
	$RH->F("test", "post", function() {
		$foo = $_POST["foo"];
		$ret = NULL;
		
		if(isset($foo)) {
			$data = array("fooback" => $foo);
			return Signal::success()->setData($data);
		} else {
			$ret = Signal::error()->setMessage("foo parameter not set error");
		}

		return $ret;
	});
	// test/schedule
	$RH->F("test", "schedule", function() {
		$url = "http://localhost:6969/api/schedule";

		$date = new DateTime('2001-09-11');
		$date->setTime(14, 10, rand(1, 60));

		$parameters = array();
		$parameters['time'] = $date->format('Y-m-d H:i:s');
		$parameters['medid'] = @$_POST['medid'];
		$parameters['message'] = @$_POST['message'];
		$parameters = json_encode($parameters);

		$curl = curl_init();

		curl_setopt_array($curl, array(
			CURLOPT_RETURNTRANSFER => 1,
			CURLOPT_URL => $url,
			CURLOPT_POST => 1,
			CURLOPT_POSTFIELDS => $parameters,
			CURLOPT_HTTPHEADER => array(
				'Content-Type: application/json',
				'Content-Length: ' . strlen($parameters)
			)
		));

		$res = curl_exec($curl);
		curl_close($curl);
		return Signal::success()->setMessage(array("res" => $res));
	});
	// test/notify
	$RH->F("test", "notify", function() {
		$url = "http://localhost:6969/api/notify";

		$parameters = array();
		$parameters['medid'] = array(1);
		$parameters['uiud'] = @$_POST['uiud'];
		$parameters['message'] = @$_POST['message'];
		$parameters = json_encode($parameters);

		$curl = curl_init();

		curl_setopt_array($curl, array(
			CURLOPT_RETURNTRANSFER => 1,
			CURLOPT_URL => $url,
			CURLOPT_POST => 1,
			CURLOPT_POSTFIELDS => $parameters,
			CURLOPT_HTTPHEADER => array(
				'Content-Type: application/json',
				'Content-Length: ' . strlen($parameters)
			)
		));

		$res = curl_exec($curl);
		curl_close($curl);
		return Signal::success()->setMessage(array("Server response" => $res));

	});

	$RH->D("", "caretaker");

	// caretaker/register
	$RH->F("caretaker", "register", function() {
		$username = @$_POST['username'];
		$password = @$_POST['password'];
		return DataAccess::careREGISTER($username, $password);
	});
	// caretaker/login
	$RH->F("caretaker", "login", function() {
		$username = @$_POST['username'];
		$password = @$_POST['password'];
		return DataAccess::careLOGIN($username, $password);
	});
	// caretaker/verify
	$RH->F("caretaker", "verify", function() {
		return DataAccess::careGet(@$_GET['authcode'], "verify");
	});
	// caretaker/info
	$RH->F("caretaker", "info", function() {
		return DataAccess::careGet(@$_GET['authcode'], "info");
	});
	//caretaker/device
	$RH->F("caretaker", "device", function() {
		$params = array();
		$params['uiud'] = @$_POST['uiud'];

		return DataAccess::carePOST(@$_GET['authcode'], "registerDevice", $params);
	});

	//Patient handling

	$RH->D("caretaker", "patients");
	$RH->D("caretaker/patients", $WC);

	// caretaker/patients
	$RH->F("caretaker", "patients", function() {
		switch ($_SERVER['REQUEST_METHOD']) {
			case 'GET':
				return DataAccess::careGet(@$_GET['authcode'], "patients");
			
			case 'POST':
				$params = array();
				$params['name'] = @$_POST['name'];
				$params['usability'] = @$_POST['usability'];
				return DataAccess::carePOST(@$_GET['authcode'], "createPatient", $params);

		}
		return Signal::error()->setMessage("Invalid request type");
	});
	// caretaker/patients/{pid}/info
	$RH->F("caretaker/patients", "$WC", function($trace) {
		return DataAccess::capaGET(@$_GET['authcode'], $trace[2], "info");
	});
	// caretaker/patients/{pid}/relink
	$RH->F("caretaker/patients/$WC", "relink", function($trace) {
		return DataAccess::capaGET(@$_GET['authcode'], $trace[2], "relink");
	});
	// caretaker/patients/{pid}/share
	$RH->F("caretaker/patients/$WC", "share", function($trace) {
		return DataAccess::capaGET(@$_GET['authcode'], $trace[2], "share");
	});

	//Medication handling

	$RH->D("caretaker/patients/$WC", "medications");
	
	// caretaker/patients/{pid}/medications
	$RH->F("caretaker/patients/$WC", "medications", function($trace) {
		switch ($_SERVER['REQUEST_METHOD']) {
			case 'GET':
				return DataAccess::capaGET(@$_GET['authcode'], $trace[2], "listMedication");
			
			case 'POST':
				$params = array();
				$params['name'] = @$_POST['name'];
				$params['dosage'] = @$_POST['dosage'];
				$params['remain'] = @$_POST['remain'];
				if(isset($_FILES['picture']))
					$params['pic'] = file_get_contents($_FILES['picture']['tmp_name']);
				$params['info'] = @$_POST['info'];
				return DataAccess::capaPOST(@$_GET['authcode'], $trace[2], "createMedication", $params);
	
		}
		return Signal::error()->setMessage("Invalid request type");
		
	});
	// caretaker/patients/{pid}/medication/{medid}
	$RH->F("caretaker/patients/$WC/medications", "$WC", function($trace) {
		$params = array();
		$params['medid'] = $trace[4];
		return DataAccess::capaPOST(@$_GET['authcode'], $trace[2], "getMedication", $params);
	});

	//Schedule handling

	$RH->D("caretaker/patients/$WC", "schedules");

	// caretaker/patients/{pid}/schedules
	$RH->F("caretaker/patients/$WC", "schedules", function($trace) {
		switch ($_SERVER['REQUEST_METHOD']) {
			case 'GET':
				return DataAccess::capaGET(@$_GET['authcode'], $trace[2], "listSchedule");
			
			case 'POST':
				$params = array();
				$params['hours'] = @$_POST['hours'];
				$params['minutes'] = @$_POST['minutes'];
				$params['medication'] = @$_POST['medication'];
				return DataAccess::capaPOST(@$_GET['authcode'], $trace[2], "createSchedule", $params);
		}
		return Signal::error()->setMessage("Invalid request type");
	});

	// caretaker/patients/{pid}/schedules/{schid}
	$RH->F("caretaker/patients/$WC/schedules", "$WC", function($trace) {
		$params = array();
		$params['schid'] = $trace[4];

		switch ($_SERVER['REQUEST_METHOD']) {
			case 'GET':
				return DataAccess::capaPOST(@$_GET['authcode'], $trace[2], "detailSchedule", $params);

			case 'POST':
				$params['medication'] = @$_POST['medication'];
				return DataAccess::capaPOST(@$_GET['authcode'], $trace[2], "modifySchedule", $params);
			
			case 'DELETE':
				return DataAccess::capaPOST(@$_GET['authcode'], $trace[2], "deleteSchedule", $params);
		}
		return Signal::error()->setMessage("Invalid request type");
	});

	$RH->D("", "patient");
	// patient/link
	$RH->F("patient", "link", function() {
		$lcode = @$_POST['lcode'];
		return DataAccess::patiLINK($lcode);
	});
	// patient/device
	$RH->F("patient", "device", function() {
		$params = array();
		$params['uiud'] = @$_POST['uiud'];

		return DataAccess::patiPOST(@$_GET['authcode'], "registerDevice", $params);
	});
	// patient/info
	$RH->F("patient", "info", function() {
		return DataAccess::patiGET(@$_GET['authcode'], "info");
	});

	$RH->D("patient", "medications");

	// patient/medications
	$RH->F("patient", "medications", function() {
		return DataAccess::patiGET(@$_GET['authcode'], "listMedication");
	});
	// patient/medications/{medid}
	$RH->F("patient/medications", "$WC", function($trace) {
		$params = array();
		$params['medid'] = $trace[2];
		return DataAccess::patiPOST(@$_GET['authcode'], "getMedication", $params);
	});

	$RH->D("patient", "schedules");
	$RH->D("patient/schedules", $WC);

	$RH->F("patient", "schedules", function() {
		return DataAccess::patiGET(@$_GET['authcode'], "listSchedule");
	});
	$RH->F("patient/schedules", "$WC", function($trace) {
		$params = array();
		$params['schid'] = $trace[2];
		return DataAccess::patiPOST(@$_GET['authcode'], "detailSchedule", $params);
	});
	$RH->F("patient/schedules/$WC", "take", function($trace) {
		$params = array();
		$params['schid'] = $trace[2];
		$params['medid'] = @$_POST['medid'];
		return DataAccess::patiPOST(@$_GET['authcode'], "takeMedication", $params);
	});

	try {
		$response = $RH->call($user_request);

		switch ($response->getType()) {
			case 'JSON':
				header('Content-Type: application/json');
				echo json_encode($response->toArray());
				break;

			case 'IMG':

				//Return not found in case of error
				if($response->isError())
					notFound();
				ob_clean(); //Prevent stray new lines
				header('Content-Type: image/jpeg');
				echo $response->getData();
				break;
			
			default:
				throw new Exception("Invalid return type");
				break;
		}
	} catch(Exception $e) {
		echo $e->getMessage();
		notFound();
	}

?>
