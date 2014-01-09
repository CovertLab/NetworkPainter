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
$width = $_GET['width'];
$height = $_GET['height'];

//database connection
$db_connection = databaseConnect($config['mysql']);

//retrieve preview
list($status, $networks) = runQuery($db_connection, 
	"SELECT * ".
	"from networks ".
	"where networks.id=$networkID && networks.publicstatus='Yes'", false);
if ($status == 0 || count($networks) == 0){
	echo "Network not found.";
	exit;
}

//display content
$fid = tmpfile();
$md = stream_get_meta_data($fid);
$tmpName = $md['uri'];
fclose($fid);

file_put_contents($tmpName, $networks[0]['preview']);

list($origWidth, $origHeight) = getimagesize($tmpName);

$ii = imagecreatefrompng($tmpName);
$io = imagecreatetruecolor($width, $height);
imagecopyresampled($io, $ii, 
    0, 0, 0, 0, 
	$width, $height, 
	$origWidth, $origHeight);
imagepng($io, $tmpName);	

header('Content-Type: image/png');
readfile($tmpName);


//unlink($tmpName);