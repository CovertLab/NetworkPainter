<?php

/**
 * Displays flash application to user. Passes user id and session id as flashvars.
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @author Harendra Guturu, hguturu@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

$networkid = $_GET['networkID'];
$experimentid = $_GET['experimentID'];

echo <<< HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>NetworkPainter</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	
	<script src="js/swfobject.js" type="text/javascript"></script>
	<script type="text/javascript">
		var flashvars = { 
			networkid:'$networkid',
			experimentid:'$experimentid'};
		var params = {
			menu: "false",
			scale: "noScale",
			bgcolor: "#FFFFFF",
			allowFullScreen: "true"
		};
		swfobject.embedSWF("NetworkPainter.swf", "altContent", "100%", "100%", "10.0.0", "expressInstall.swf", flashvars, params);
		
		window.onbeforeunload = logoff;
		window.onunload = endSession;

		var loggingOff=false;
		function logoff() { 
			if(!loggingOff) 
                return 'Are you sure you want to exit NetworkPainter?';
		}
		
		function endSession() {
			window.location='login.php?cmd=logoff';
		}
	</script>
	<style>
		html, body { height:100%; }
		body { margin:0;padding:0;}
	</style>
</head>
<body>
	<div id="altContent">
		<h1>NetworkPainter</h1>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img 
			src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" 
			alt="Get Adobe Flash player" /></a></p>
	</div>
</body>
</html>
HTML;

?>