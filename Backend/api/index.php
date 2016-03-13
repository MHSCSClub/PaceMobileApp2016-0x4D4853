<?php
	
	require_once("requestHandler.class.php");
	require_once("signal.class.php");

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
