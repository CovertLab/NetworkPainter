<?php

/**
 * Displays gallery of networks.
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/30/2009
 */

require('engines/MiscFunctions.php');
require('engines/UserManager.php');
require('configuration.php');

//parameters
$networkID = $_GET['networkID'];

//database connection
$db_connection = databaseConnect($config['mysql']);

//header
require('head.php');

//page content
$networks = runQuery($db_connection, 
	"SELECT * ".
	"from networks ".
	"join permissions on permissions.networkid = networks.id ".
	"join users on permissions.userid = users.id ".
	"where networks.publicstatus='Yes' && permissions.permissions = 'o' ".
	"order by networks.name");

echo "	  <div class=\"wrap\">\n";
echo "      <h2>$applicationName <span class=\"red\">Gallery</span></h2>\n";

echo "      <ul>\n";
foreach ($networks as $network) {
	extract($network);
	echo "      <li><a href=\"#$networkid\">$name</a></li>\n";
}
echo "      </ul>\n";

foreach ($networks as $network) {
	extract($network);
	$description = str_replace("\r", "<br/>", $description);
	$creation = date('F j, Y', strtotime($creation));
	$lastsave = date('F j, Y', strtotime($lastsave));
	$imageWidth = 750;
	$imageHeight = floor($height * $imageWidth / $width);
	
	echo <<<HTML
	<div style="margin-top:10px; margin-bottom:10px;">
		<a name="$networkid"></a>
		<h3><a href="view.php?networkID=$networkid" style="text-decoration:none">$name</a></h3>
		<p>$description</p>
		<div style="margin-top:10px; margin-bottom:10px;">
			<a href="view.php?networkID=$networkid"><img src="preview.php?networkID=$networkid&width=$imageWidth&height=$imageHeight" style="border:1px #aaa solid"/></a>
		</div>
		<div style="margin-top:20px;">
			<div class="col">
				<p>
				Investigator: <a href="mailto:$email">$firstname $lastname</a>, $organization<br/>
				Created: $creation<br/>
				Last modified: $lastsave
				</p>
			</div>
			<div class="col last" style="text-align:right;">
				<a href="login.php?networkID=$networkid">View in $applicationName</a>
			</div>
		</div>
	</div>
	<div style="clear:both;"></div>
HTML;
}
echo "	  </div>\n";

//footer
require('foot.php');
