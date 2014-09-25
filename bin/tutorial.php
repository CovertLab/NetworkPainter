<?php

/**
 * Displays application tutorial.
 *
 * @see edu.stanford.covertlab.networkpainter.data.TutorialData
 * @see MiscFunctions
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

require('head.php');

$tutorialData = parseTutorialData();
if ($_GET['tutorial']) {
	$idx = $_GET['tutorial'];
	extract($tutorialData[$idx - 1]);
	$height = round(616 / 800 * 750);
	$width = 750;
	
	$html = '';
	$html .= "<h2>Tutorial #$idx <span class=\"red\">$title</span></h3>\n";
	$html .= "<p>$description</p>\n";
    $html .= "<p><i>Note: some features have changed since this video tutorial was recorded in 2010.</i></p>\n";
	$html .= "<div style=\"border:1px #aaa solid; width:750px; margin-top:10px; margin-bottom:10px;\">\n";
    $html .= "  <object width=\"$width\" height=\"$height\">\n";
	$html .= "    <param name=\"movie\" value=\"../tutorials/$url\"></param>\n";
	$html .= "    <param name=\"menu\" value=\"false\"></param>\n";
	$html .= "    <param name=\"play\" value=\"true\"></param>\n";
	$html .= "    <param name=\"loop\" value=\"false\"></param>\n";
	$html .= "    <embed src=\"../tutorials/$url\" width=\"$width\" height=\"$height\" type=\"application/x-shockwave-flash\" play=\"true\" loop=\"false\"></embed>\n"; 
	$html .= "  </object>\n";
	$html .= "</div>\n";
	$html .= "<div style=\"float:left; width:375px;\">Download: ";
	if (file_exists("../tutorials/tutorial_0$idx.pdf")) {
		$html .= "  <a href=\"../tutorials/tutorial_0$idx.pdf\">slides</a> | ";
	}
	$html .= "  <a href=\"../tutorials/tutorial_0$idx.swf\">video</a>";
	$html .= "</div>\n";
	$html .= "<div style=\"float:left; width:375px; text-align:right\">Last updated: ".date('M j, Y', filemtime("../tutorials/tutorial_0$idx.swf"))."</div>\n";
	$html .= "<div style=\"clear:both;\"></div>\n";
}else{
	$html = formatTutorialData($tutorialData, array('<contact/>', '<applicationName/>'), array($contact, $applicationName));
}

echo <<<HTML
  <div class="wrap page">
    $html
  </div>
HTML;

require('foot.php');
?>

