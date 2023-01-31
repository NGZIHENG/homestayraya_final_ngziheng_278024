<?php

	if(!isset($_POST)){
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
		die();
	}
	
	include_once("dbconnect.php");
	
	$userid= $_POST['userid'];
	$homestayid = $_POST['homestayid'];
  	$homestayname= $_POST['homestayname'];
	$homestaydesc= $_POST['homestaydesc'];
	$homestayprice= $_POST['homestayprice'];
  	$bedroomqty= $_POST['bedroomqty'];
  	$guestqty= $_POST['guestqty'];

$sqlupdate = "UPDATE `tbl_homestay` SET `homestay_name`='$homestayname',`homestay_desc`='$homestaydesc',`homestay_price`='$homestayprice',`bedroom_qty`='$bedroomqty',`guest_qty`='$guestqty' WHERE `homestay_id`='$homestayid' AND `user_id`='$userid'";

try{
		if($conn->query($sqlupdate) === TRUE){
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}
	catch (Exception $e){
		$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
	}
	$conn->close();
	
	function sendJsonResponse($sentArray){
		header('Content-Type: application/json');
		echo json_encode($sentArray);
	}

?>