<?php 
/*
 * Barrick Route Data Receiver V 1.0
 * Kevin James Hunt 2017
 * kevinjameshunt@gmail.com
 * http://www.kevinjameshunt.com
 *
 *
 */

require("dbinfo.php");
	
date_default_timezone_set("Canada/Toronto");
$message = "Failure";
	
function isValidJSON($str) {
   json_decode($str);
   return json_last_error() == JSON_ERROR_NONE;
}

$json_params = file_get_contents("php://input");

if (strlen($json_params) > 0 && isValidJSON($json_params)) {
  	$decoded_params = json_decode($json_params, true);

	$routeID = $decoded_params['routeID'];
	$routeName = $decoded_params['routeName'];
	$startLocLon = $decoded_params['startLocLon'];
	$startLocLat = $decoded_params['startLocLat'];
	$endLocLon = $decoded_params['endLocLon'];
	$endLocLat = $decoded_params['endLocLat'];
	

	// connect to the database
	$con = mysql_connect(localhost, $username, $password);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}
	mysql_select_db($database,$con);
	
	// prepare query to insert data into database
	$querySql = "INSERT INTO routeData (routeID, routeName, startLocLon, startLocLat, endLocLon, endLocLat)";
	$querySql .= " VALUES (";
	$querySql .= "'" . $routeID . "',";
	$querySql .= "'" . $routeName . "',";
	$querySql .= "'" . $startLocLon . "',";
	$querySql .= "'" . $startLocLat . "',";
	$querySql .= "'" . $endLocLon . "',";
	$querySql .= "'" . $endLocLat . "')";
		
	// Execute the query
	if (!mysql_query($querySql,$con))
	{
		// If it fails, we do nothing other than send back a failure message.  The app can handle it from there
		//echo $querySql;
		die('Error: ' . mysql_error());
		$message = "Error";
	} else {
		// If the update is successful, 
		
		// default return value should be Success
		$message = "Success";
	}
	
	// Send this as the response to the transmitter
	echo $message;
	
	// close the connection
	mysql_close($con);
} else {
	echo "Invalid JSON data";
}
?>