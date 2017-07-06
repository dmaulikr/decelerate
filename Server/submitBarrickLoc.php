<?php 
/*
 * Barrick Motion Data Sender V 1.0
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

	$driverID = $decoded_params['driverID'];
	$routeID = $decoded_params['routeID'];
	$tripID = $decoded_params['tripID'];
	$violation = $decoded_params['violation'];
	$longitude = $decoded_params['longitude'];
	$latitude = $decoded_params['latitude'];
	$accX = $decoded_params['accX'];
	$accY = $decoded_params['accY'];
	$accZ = $decoded_params['accZ'];
	$gyroX = $decoded_params['gyroX'];
	$gyroY = $decoded_params['gyroY'];
	$gyroZ = $decoded_params['gyroZ'];

	// connect to the database
	$con = mysql_connect(localhost, $username, $password);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}
	mysql_select_db($database,$con);
	
	// prepare query to insert data into database
	$querySql = "INSERT INTO movementData (driverID, routeID, tripID, longitude, latitude, accX, accY, accZ, gyroX, gyroY, gyroZ, violation)";
	$querySql .= " VALUES (";
	$querySql .= "'" . $driverID . "',";
	$querySql .= "'" . $routeID . "',";
	$querySql .= "'" . $tripID . "',";
	$querySql .= "'" . $longitude . "',";
	$querySql .= "'" . $latitude . "',";
	$querySql .= "'" . $accX . "',";
	$querySql .= "'" . $accY . "',";
	$querySql .= "'" . $accZ . "',";
	$querySql .= "'" . $gyroX . "',";
	$querySql .= "'" . $gyroY . "',";
	$querySql .= "'" . $gyroZ . "',";
	$querySql .= "'" . $violation . "')";
		
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