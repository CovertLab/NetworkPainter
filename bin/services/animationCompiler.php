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

//save data as temporary file
file_put_contents('../../src/edu/stanford/covertlab/networkpainter/viewer/data/Network.json', $network);
file_put_contents('../../src/edu/stanford/covertlab/networkpainter/viewer/data/Experiment.json', $experiment);
file_put_contents('tmp/tmp.ColorScale.svg', $colorScale);

//compile flash
$cmd = <<<CMD
mxmlc
	-target-player=10.0.0
	-compiler.source-path+=../../src
	-compiler.library-path+=../../lib
	-default-background-color=16777215
	-default-frame-rate=30
	-default-size=$diagramWidth,$diagramHeight
	-debug=false
	-incremental=true
	-benchmark=false
	-use-network=false
	-default-script-limits=1000,60
	-o tmp/tmpViewer.swf
	../../src/edu/stanford/covertlab/networkpainter/Viewer.mxml
CMD;
$cmd = str_replace("\r\n\t", " ", $cmd);
$result = `$cmd 2>&1`;

//rasterize svg
$result = `inkscape tmp/tmp.ColorScale.svg --export-png=tmp/tmp.ColorScale.png`;

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

//combine in zip archive
$zip = new ZipArchive;
$zip->open('tmp/tmp.zip', ZIPARCHIVE::OVERWRITE);
$zip->addFromString("index.html", $html);
$zip->addFile('tmp/tmpViewer.swf', "network.swf");
$zip->addFile('tmp/tmp.ColorScale.png', "colorScale.png");
$zip->addFile('../js/swfobject.js', "swfobject.js");
$zip->addFile('../expressInstall.swf', "expressInstall.swf");
$zip->close();

//return zip archive
header("location: tmp/tmp.zip");

?>