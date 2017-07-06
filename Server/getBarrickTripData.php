<?php 
/*
 * Barrick Motion Data Retriever V 1.0
 * Kevin James Hunt 2017
 * kevinjameshunt@gmail.com
 * http://www.kevinjameshunt.com
 *
 *
 */

	require("dbinfo.php");
	
	date_default_timezone_set("Canada/Toronto");
	$message = "Failure";

	$routeID = $_POST['routeID'];
	$tripID = $_POST['tripID'];

	// connect to the database
	$con = mysql_connect(localhost, $username, $password);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}

	mysql_select_db($database,$con);
	
	/// Get location data from database, create JSON response and return it
	/// =============================

	$querySql = "SELECT * FROM movementData WHERE routeID = '" . $routeID . "' AND tripID = '" . $tripID . "'";
	$show = mysql_query($querySql,$con) or die (mysql_error());
	
	$string = "{\"movementData\": [";
	
	// Loop through each row
	while ($row = mysql_fetch_array($show) ) {
		
		//get data from row
		$timestamp = $row["timestamp"];
		$driverID = $row["driverID"];
		$violation = $row["violation"]; 
		$longitude = $row["longitude"];
		$latitude = $row["latitude"];
		$accX = $row["accX"];
		$accY = $row["accY"];
		$accZ = $row["accZ"];
		$gyroX = $row["gyroX"];
		$gyroY = $row["gyroY"];
		$gyroZ = $row["gyroZ"];

		// Create movementData element
		$string = $string . "{\"timestamp\":\"" . $timestamp ."\",";
		$string = $string .  "\"driverID\":\"". $driverID ."\",";
		$string = $string .  "\"routeID\":\"". $routeID ."\",";
		$string = $string .  "\"tripID\":\"". $tripID ."\",";
		$string = $string .  "\"violation\":\"". $violation ."\",";
		$string = $string .  "\"longitude\":\"". $longitude ."\",";
		$string = $string .  "\"latitude\":\"". $latitude ."\",";
		$string = $string .  "\"accX\":\"". $accX ."\",";
		$string = $string .  "\"accY\":\"". $accY ."\",";
		$string = $string .  "\"accZ\":\"". $accZ ."\",";
		$string = $string .  "\"gyroX\":\"". $gyroX ."\",";
		$string = $string .  "\"gyroY\":\"". $gyroY ."\",";
		$string = $string .  "\"gyroZ\":\"". $gyroZ ."\"},";
	}
	
	if (substr($string, -1, 1) == ',') {
		$string = substr($string, 0, -1);
	}
	
	$string = $string . "]}";
	
	echo $string;
	
	// close the connection
	mysql_close($con);
	
?>	