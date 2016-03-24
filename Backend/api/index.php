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
	// caretaker/patients
	$RH->F("caretaker", "patients", function() {
		return DataAccess::careGet(@$_GET['authcode'], "patients");
	});

	$RH->D("caretaker", "patient");

	// caretaker/patient/new
	$RH->F("caretaker/patient", "new", function() {
		$params = array();
		$params['name'] = @$_POST['name'];
		$params['usability'] = @$_POST['usability'];

		return DataAccess::carePOST(@$_GET['authcode'], "createPatient", $params);
	});

	$RH->D("caretaker/patient", $WC);

	// caretaker/patient/{pid}/relink
	$RH->F("caretaker/patient/$WC", "relink", function($trace) {
		$pid = $trace[2];
		return DataAccess::capaGET(@$_GET['authcode'], $pid, "relink");
	});
	// caretaker/patient/{pid}/share
	$RH->F("caretaker/patient/$WC", "share", function($trace) {
		$pid = $trace[2];
		return DataAccess::capaGET(@$_GET['authcode'], $pid, "share");
	});


	$RH->D("", "patient");
	// patient/link
	$RH->F("patient", "link", function() {
		$lcode = @$_POST['lcode'];
		return DataAccess::patiLINK($lcode);
	});

	try {
		$response = $RH->call($user_request);

		switch ($response->getType()) {
			case 'JSON':
				header('Content-Type: application/json');
				echo json_encode($response->toArray());
				break;
			
			default:
				throw new Exception();
				break;
		}
	} catch(Exception $e) {
		notFound();
	}

?>
