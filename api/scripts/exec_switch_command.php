<?php

include "root.php";
require_once "resources/require.php";
//require_once "resources/check_auth.php";
/*if (permission_exists('exec_command_line') || permission_exists('exec_php_command') || permission_exists('exec_switch')) {
	//access granted
}
else {
	echo "access denied";
	exit;
}*/



//get the html values and set them as variables
		
	$switch_cmd = trim($_REQUEST["switch_cmd"]);
	
//show the header
	require_once "resources/header.php";


	//fs cmd

	$fp = event_socket_create($_SESSION['event_socket_ip_address'], $_SESSION['event_socket_port'], $_SESSION['event_socket_password']);
	if ($fp) {
		$switch_result = event_socket_request($fp, 'api '.$switch_cmd);
		//$switch_result = eval($switch_cmd);
		echo $switch_result;
	} else {
		echo "fp is null";
	}

?>
