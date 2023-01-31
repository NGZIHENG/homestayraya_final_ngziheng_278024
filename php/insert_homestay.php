<?php
	if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	include_once("dbconnect.php");
	$userid= $_POST['userid'];
  	$homestayname= $_POST['homestayname'];
	$homestaydesc= $_POST['homestaydesc'];
	$homestayprice= $_POST['homestayprice'];
  	$bedroomqty= $_POST['bedroomqty'];
  	$guestqty= $_POST['guestqty'];
  	$homestaystate= $_POST['homestaystate'];
  	$homestaylocal= $_POST['homestaylocal'];
  	$lat= $_POST['lat'];
  	$lng= $_POST['lng'];
 	$image= $_POST['image'];
	
	$sqlinsert = "INSERT INTO `tbl_homestay`(`user_id`, `homestay_name`, `homestay_desc`, `homestay_price`, `bedroom_qty`, `guest_qty`, `homestay_state`, `homestay_local`, `homestay_lat`, `homestay_lng`) VALUES ('$userid','$homestayname','$homestaydesc',$homestayprice,$bedroomqty,$guestqty,'$homestaystate','$homestaylocal','$lat','$lng')";
	
	try {
		if ($conn->query($sqlinsert) === TRUE) {
			$decoded_string = base64_decode($image);
			$filename = mysqli_insert_id($conn);
			$path = '../assets/homestayimages/'.$filename.'.png';
			file_put_contents($path, $decoded_string);
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}
		else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}
	catch(Exception $e) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}
	$conn->close();
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type= application/json');
    echo json_encode($sentArray);
	}
?>