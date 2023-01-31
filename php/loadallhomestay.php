<?php
	error_reporting(0);
	include_once("dbconnect.php");
	$search  = $_GET["search"];
	$results_per_page = 2;
	$pageno = (int)$_GET['pageno'];
	$page_first_result = ($pageno - 1) * $results_per_page;
	
	if ($search =="all"){
			$sqlloadhomestay = "SELECT * FROM tbl_homestay ORDER BY homestay_date DESC";
	}else{
		$sqlloadhomestay = "SELECT * FROM tbl_homestay WHERE homestay_name LIKE '%$search%' ORDER BY homestay_date DESC";
	}
	
	$result = $conn->query($sqlloadhomestay);
	$number_of_result = $result->num_rows;
	$number_of_page = ceil($number_of_result / $results_per_page);
	$sqlloadhomestay = $sqlloadhomestay . " LIMIT $page_first_result , $results_per_page";
	$result = $conn->query($sqlloadhomestay);
	
	if ($result->num_rows > 0) {
		$homestayarray["homestay"] = array();
		while ($row = $result->fetch_assoc()) {
			$homestaylist = array();
			$homestaylist['homestay_id'] = $row['homestay_id'];
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
		$response = array('status' => 'success', 'numofpage'=>"$number_of_page",'numberofresult'=>"$number_of_result",'data' => $homestayarray);
    sendJsonResponse($response);
		}else{
		$response = array('status' => 'failed','numofpage'=>"$number_of_page", 'numberofresult'=>"$number_of_result",'data' => null);
    sendJsonResponse($response);
	}
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
	}