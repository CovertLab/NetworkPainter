<?php

/**
 * Compiles network with experimental data into "Viewer" (simplified version of the application which 
 * animates network and has a few controls).
 * <ul>
 * <li>Application posts network, experiment, measurement as MXML - formatted text</li>
 * <li>Script saves network, experiment, measurement to temporary files</li>
 * <li>Script compiles Viewer using flex compiler</li>
 * <li>Returns zip file containing Viewer, color scale, and html file for displaying viewer in browser</li>
 * </ul>
 *
 * @see edu.stanford.covertlab.networkpainter.Viewer
 *
 * @author Jonathan Karr
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 2/23/2009
 */
 
//options
extract(array_map('urldecode', $_POST));

//sanitize name
if ($name == "") 
	$name = "NetworkPainter";
	
//temporary files
$tmpFile = tempnam('tmp', 'tmp');

//save data as temporary file
file_put_contents('../../src/edu/stanford/covertlab/networkpainter/viewer/data/Network.json', $network);
file_put_contents('../../src/edu/stanford/covertlab/networkpainter/viewer/data/Experiment.json', $experiment);
file_put_contents("$tmpFile.ColorScale.svg", $colorScale);

//generate html
$colorScaleWidth = ceil($colorScaleWidth);
$widthPx = $diagramWidth.'px';
$heightPx = $diagramHeight.'px';
$colorScaleWidthPx = $colorScaleWidth.'px';
$fullWidthPx = ($colorScaleWidth + 20 + $diagramWidth).'px';
$html = <<< HTML
<html>
<head>
	<title>$name</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />	
	<script type="text/javascript" src="swfobject.js"></script>
	<script type="text/javascript">
	var flashvars = {};
		var params = {
			menu: "false",
			bgcolor: "#FFFFFF",
			allowFullScreen: "true"
		};
		swfobject.embedSWF("network.swf", "altContent", $diagramWidth, $diagramHeight, "10.0.0", "expressInstall.swf", flashvars, params);
	</script>
	<style>
		html, body { height:100%; }
		body { margin:10px;padding:0px;}
	</style>
</head>
<body>
	<div style="margin:0 auto; width:$fullWidthPx;">
		<div style="float:left; width:$widthPx; height:$heightPx; border:1px solid #999999;">
			<div id="altContent">
				<h1>NetworkPainter</h1>
				<p><a href="http://www.adobe.com/go/getflashplayer"><img 
					src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" 
					alt="Get Adobe Flash player" /></a></p>
			</div>
		</div>
		<div style="float:right; width:$colorScaleWidthPx; position:relative; top:-4px;">
			<img src="colorScale.png"/>
		</div>
	</div>
</body>
</html>
HTML;

//rasterize svg
shell_exec("./svgconvert $tmpFile.ColorScale.svg $tmpFile.ColorScale.png");

//compile flash
putenv('PATH='.getenv('PATH').':.:./jre1.8.0_05/bin');
$cmd = <<<CMD
flex_sdk_3.6a/bin/mxmlc
	-target-player=10.0.0
	-compiler.source-path+=../../src
	-compiler.library-path+=../../lib
	-default-background-color=16777215
	-default-frame-rate=30
	-default-size=$diagramWidth,$diagramHeight
	-debug=false
	-incremental=false
	-benchmark=false
	-use-network=false
	-default-script-limits=1000,60
	-o $tmpFile.swf
	../../src/edu/stanford/covertlab/networkpainter/Viewer.mxml
CMD;
$cmd = str_replace("\r\n\t", " ", $cmd);
$log = shell_exec("$cmd 2>&1");

//file_put_contents("$tmpFile.sh", $cmd);
//file_put_contents("$tmpFile.log", $log."\n".getenv('PATH'));

//combine in zip archive
$zip = new ZipArchive;
$zip->open("$tmpFile.zip", ZIPARCHIVE::OVERWRITE);
$zip->addFromString("index.html", $html);
$zip->addFile("$tmpFile.swf", "network.swf");
$zip->addFile("$tmpFile.ColorScale.png", "colorScale.png");
$zip->addFile('../js/swfobject.js', "swfobject.js");
$zip->addFile('../expressInstall.swf', "expressInstall.swf");
$zip->close();

//return zip archive
header("Content-type: application/zip");
header("Content-Disposition: attachment; filename=\"$name.zip\"");
$fp = fopen("$tmpFile.zip", 'r');
fpassthru($fp);
fclose($fp);

//cleanup
unlink("$tmpFile");
unlink("$tmpFile.swf");
unlink("$tmpFile.ColorScale.svg");
unlink("$tmpFile.ColorScale.png");
unlink("$tmpFile.zip");
?>