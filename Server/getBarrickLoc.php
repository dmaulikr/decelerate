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

	$timestamp = $_POST['timestamp'];
	$driverID = $_POST['driverID'];

	// connect to the database
	$con = mysql_connect(localhost, $username, $password);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}

	mysql_select_db($database,$con);
	
	/// Get location data from database, create JSON response and return it
	/// =============================

	$querySql = "SELECT * FROM movementData WHERE timestamp > '" . $timestamp . "' AND driverID = '" . $driverID . "'";
	$show = mysql_query($querySql,$con) or die (mysql_error());
	
	$string = "{\"movementData\": [";
	
	// Loop through each row
	while ($row = mysql_fetch_array($show) ) {
		
		//get data from row
		$timestamp = $row["timestamp"];
		$driverID = $row["driverID"]; 
		$sensorID = $row["sensorID"]; 
		$loadTons = $row["loadTons"]; 
		$longitude = $row["longitude"];
		$latitude = $row["latitude"];
		$accX = $row["accX"];
		$accY = $row["accY"];
		$accZ = $row["accZ"];
		$gyroX = $row["gyroX"];
		$gyroX = $row["gyroY"];
		$gyroX = $row["gyroZ"];
		$magX = $row["magX"];
		$magY = $row["magY"];
		$magZ = $row["magY"];

		// Create movementData element
		$string = $string . "{\"timestamp\":\"" . $timestamp ."\",";
		$string = $string .  "\"driverID\":\"". $driverID ."\",";
		$string = $string .  "\"sensorID\":\"". $sensorID ."\",";
		$string = $string .  "\"loadTons\":\"". $loadTons ."\",";
		$string = $string .  "\"longitude\":\"". $longitude ."\",";
		$string = $string .  "\"latitude\":\"". $latitude ."\",";
		$string = $string .  "\"accX\":\"". $accX ."\",";
		$string = $string .  "\"accY\":\"". $accY ."\",";
		$string = $string .  "\"accZ\":\"". $accZ ."\",";
		$string = $string .  "\"gyroX\":\"". $gyroX ."\",";
		$string = $string .  "\"gyroY\":\"". $gyroY ."\",";
		$string = $string .  "\"gyroZ\":\"". $gyroZ ."\",";
		$string = $string .  "\"magX\":\"". $magX ."\",";
		$string = $string .  "\"magY\":\"". $magY ."\",";
		$string = $string .  "\"magZ\":\"". $magZ ."\"},";
	}
	
	if (substr($string, -1, 1) == ',') {
		$string = substr($string, 0, -1);
	}
	
	$string = $string . "]}";
	
	echo $string;
	
	// close the connection
	mysql_close($con);
	
?>