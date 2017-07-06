<?php 
/*
 * Barrick Trip Data Retriever V 1.0
 * Kevin James Hunt 2017
 * kevinjameshunt@gmail.com
 * http://www.kevinjameshunt.com
 *
 *
 */

	require("dbinfo.php");
	
	date_default_timezone_set("Canada/Toronto");
	$message = "Failure";

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

	// Join the two tables using the routeID
	$querySql = "SELECT * FROM (SELECT td.`timestamp`, td.`driverID`, td.`routeID`, td.`tripID`, td.`loadTons`, td.`score`, rd.`routeName`, rd.`startLocLon`, rd.`startLocLat`, rd.`endLocLon`, rd.`endLocLat` FROM `tripData` AS td LEFT JOIN `routeData` AS rd ON `td`.`routeID` = `rd`.`routeID`) AS tr WHERE tr.`driverID` = '" . $driverID . "'  ORDER BY tr.`timestamp`";
	$show = mysql_query($querySql,$con) or die (mysql_error());
	
	$string = "{\"tripData\": [";
	
	// Loop through each row
	while ($row = mysql_fetch_array($show) ) {
		
		//get data from row
		$timestamp = $row["timestamp"];
		$driverID = $row["driverID"];
		$tripID = $row["tripID"];
		$routeID = $row["routeID"]; 
		$loadTons = $row["loadTons"];
		$score = $row["score"];
		$startLocLon = $row["startLocLon"];
		$startLocLat = $row["startLocLat"];
		$endLocLon = $row["endLocLon"];
		$endLocLat = $row["endLocLat"];
		$routeName = $row["routeName"];
		
		// Create movementData element
		$string = $string . "{\"timestamp\":\"" . $timestamp ."\",";
		$string = $string .  "\"driverID\":\"". $driverID ."\",";
		$string = $string .  "\"routeID\":\"". $routeID ."\",";
		$string = $string .  "\"tripID\":\"". $tripID ."\",";
		$string = $string .  "\"loadTons\":\"". $loadTons ."\",";
		$string = $string .  "\"score\":\"". $score ."\",";
		$string = $string .  "\"startLocLon\":\"". $startLocLon ."\",";
		$string = $string .  "\"startLocLat\":\"". $startLocLat ."\",";
		$string = $string .  "\"endLocLon\":\"". $endLocLon ."\",";
		$string = $string .  "\"endLocLat\":\"". $endLocLat ."\",";
		$string = $string .  "\"routeName\":\"". $routeName ."\"},";
	}
	
	if (substr($string, -1, 1) == ',') {
		$string = substr($string, 0, -1);
	}
	
	$string = $string . "]}";
	
	echo $string;
	
	// close the connection
	mysql_close($con);
	
?>	