<?php 
/*
 * PersonDetails location-only Submit V 1.0
 * Kevin James Hunt 2014
 * kevinjameshunt@gmail.com
 * http://www.kevinjameshunt.com
 *
 *
 */

	require("dbinfo.php");
	
	date_default_timezone_set("Canada/Toronto");
	$message = "Failure";

	$driverID = $_POST['driverID'];
	$sensorID = $_POST['sensorID'];
	$longitude = $_POST['longitude'];
	$latitude = $_POST['latitude'];
	$accX = $_POST['accX'];
	$accY = $_POST['accY'];
	$accZ = $_POST['accZ'];
	$gyroX = $_POST['gyroX'];
	$gyroY = $_POST['gyroY'];
	$gyroZ = $_POST['gyroZ'];
	$timestamp = $_POST['timestamp'];

	// connect to the database
	$con = mysql_connect(localhost, $username, $password);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}
	mysql_select_db($database,$con);
	
	// prepare query to insert data into database
	$querySql = "INSERT INTO person (timestamp, driverID, sensorID, longitude, latitude, accX, accY, accZ, gyroX, gyroY, gyroZ)";
	$querySql .= " VALUES (";
	$querySql .= "'" . $timestamp . "',";
	$querySql .= "'" . $driverID . "',";
	$querySql .= "'" . $sensorID . "',";
	$querySql .= "'" . $longitude . "',";
	$querySql .= "'" . $latitude . "',";
	$querySql .= "'" . $accX . "',";
	$querySql .= "'" . $accY . "',";
	$querySql .= "'" . $accZ . "',";
	$querySql .= "'" . $gyroX . "',";
	$querySql .= "'" . $gyroX . "',";
	$querySql .= "'" . $gyroX . "')";
		
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
	
	// Now grab the latest records for both sensors
	
	
	// close the connection
	mysql_close($con);
?>