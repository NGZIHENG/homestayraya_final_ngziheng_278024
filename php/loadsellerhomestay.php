<?php
	error_reporting(0);
	if (!isset($_GET['userid'])) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	$userid = $_GET['userid'];
	include_once("dbconnect.php");
	$sqlloadhomestay = "SELECT * FROM tbl_homestay WHERE user_id = '$userid'";
	$result = $conn->query($sqlloadhomestay);
	if ($result->num_rows > 0) {
		$homestayarray["homestay"] = array();
		while ($row = $result->fetch_assoc()) {
			$homestaylist = array();
			$homestaylist['product_id'] = $row['homestay_id'];
			$homestaylist['user_id'] = $row['user_id'];
			$homestaylist['homestay_name'] = $row['homestay_name'];
			$homestaylist['homestay_desc'] = $row['homestay_desc'];
			$homestaylist['homestay_price'] = $row['homestay_price'];
			$homestaylist['bedroom_qty'] = $row['bedroom_qty'];
			$homestaylist['guest_qty'] = $row['guest_qty'];
			$homestaylist['homestay_state'] = $row['homestay_state'];
			$homestaylist['homestay_local'] = $row['homestay_local'];
			$homestaylist['homestay_lat'] = $row['homestay_lat'];
			$homestaylist['homestay_lng'] = $row['homestay_lng'];
			$homestaylist['homestay_date'] = $row['homestay_date'];
			array_push($homestayarray["homestay"],$homestaylist);
		}
		$response = array('status' => 'success', 'data' => $homestayarray);
    sendJsonResponse($response);
		}else{
		$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
	}
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
	}