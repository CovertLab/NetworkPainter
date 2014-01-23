<?php

/**
 * Displays main application page. Lists features, requirements, and status updates.
 *
 * @see edu.stanford.covertlab.networkpainter.data.AboutData
 * @see MiscFunctions
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

require('engines/MiscFunctions.php');
require('engines/UserManager.php');
require('configuration.php');

//parameters
$networkID = $_GET['networkID'];
$experimentID = null;

//database connection
$db_connection = databaseConnect($config['mysql']);

//header
require('head.php');

//page content
echo "	  <div class=\"wrap\">\n";
if (is_numeric($networkID)) {
	list($status, $networks) = runQuery($db_connection, 
		"SELECT * ".
		"from networks ".
		"join permissions on permissions.networkid = networks.id ".
		"join users on permissions.userid = users.id ".
		"where networks.id=$networkID && networks.publicstatus='Yes' && permissions.permissions = 'o'", false);
	if ($status == 1 && count($networks) > 0) {
		extract($networks[0]);
		$description = str_replace("\r", "<br/>", $description);
		$creation = date('F j, Y', strtotime($creation));
		$lastsave = date('F j, Y', strtotime($lastsave));		
		
		if (file_exists("pub/$networkID.swf") && file_exists("pub/$networkID.ColorScale.png")){
            $experimentID = 0;
			list($colorScaleWidth, $junk) = getimagesize("pub/$networkID.ColorScale.png");
			$animationWidth = 750 - 10 - $colorScaleWidth;
			$animationHeight = $height / $width * $animationWidth;
			$animationWidthpx = $animationWidth."px";
			$colorScaleWidthpx = $colorScaleWidth."px";
			
			$content = <<<HTML
				<div style="float:left; width:$animationWidthpx">
					<object width="$animationWidth" height="$animationHeight" style="border:1px #aaa solid; margin-top:0px; margin-bottom:20px;">
						<param name="movie" value="pub/$networkID.swf"></param>
						<param name="allowFullScreen" value="true"></param>
						<param name="menu" value="false"></param>
						<embed src="pub/$networkID.swf" width="$animationWidth" height="$animationHeight" type="application/x-shockwave-flash" allowfullscreen="true"></embed> 
					</object>
				</div>
				<div style="float:left; padding-left:10px; width:$colorScaleWidthpx; position:relative; top:-4px;">
					<img src="pub/$networkID.ColorScale.png"/>
				</div>
HTML;
		}
		
		$imageWidth = 750;
		$imageHeight = floor($height * $imageWidth / $width);
		
		echo <<<HTML
		<h3>$name</h3>
		<p>$description</p>
		<div style="margin-top:10px; margin-bottom:10px;">
			<img src="preview.php?networkID=$networkID&width=$imageWidth&height=$imageHeight" style="border:1px #aaa solid"/>
		</div>
		$content
		<div style="margin-top:20px;">
			<div class="col">
				<p>
				Investigator: <a href="mailto:$email">$firstname $lastname</a>, $organization<br/>
				Created: $creation<br/>
				Last modified: $lastsave
				</p>
			</div>
			<div class="col last" style="text-align:right;">
				<a href="login.php?networkID=$networkID&experimentID=$experimentID">View in $applicationName</a>
			</div>
		</div>
HTML;
	}
}
if (!is_numeric($networkID) || count($networks) == 0) {
	echo "<p>Network not found.</p>\n";
}
echo "	  </div>\n";

//footer
require('foot.php');
?>