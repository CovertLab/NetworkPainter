<?php

/**
 * Displays header for webpages.
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

require('configuration.php');
require_once('engines/MiscFunctions.php');

$aboutData = parseAboutData();
$applicationName = $aboutData['applicationName'];
$contact = "<a href=\"mailto:".$aboutData['email']."\">".$aboutData['email']."</a>";
$description = str_replace(array('<contact/>', '<applicationName/>'), array($contact, $applicationName), $aboutData['description']);
$keywords = join(", ", $aboutData['keywords']);

$file = array_shift(explode(".", array_pop(explode("/", $_SERVER["SCRIPT_NAME"]))));
$menu = "<div id=\"menu\">";
$menu .= "
      <ul>
        <li class=\"top".($file=="login" ? " active":"")."\"><a href=\"login.php\">login</a></li>
      </ul>
";
$menu .= "
      <ul>
        <li class=\"top".($file=="index" ? " active":"")."\"><a href=\"features.php\">features</a></li>
      </ul>
";
$menu .= "
      <ul>
        <li class=\"top".($file=="gallery" ? " active":"")."\"><a href=\"gallery.php\">gallery</a></li>
      </ul>
";
$menu .= "
      <ul>
        <li class=\"top".($file=="tutorial" ? " active":"")."\"><a href=\"tutorial.php\">tutorial</a></li>
      </ul>
";
$menu.="
      <ul>
        <li class=\"top".($file=="help" ? " active":"")."\"><a href=\"help.php\">help</a></li>
      </ul>
";
$menu.="
      <ul>
        <li class=\"top".($file=="source" ? " active":"")."\"><a href=\"source.php\">source</a></li>
      </ul>
";
$menu.="
      <ul>
        <li class=\"top".($file=="about" ? " active":"")."\"><a href=\"about.php\">about</a></li>
      </ul>
";
$menu.="    </div>";

global $redirect;
if($redirect!='') $redirect="<meta http-equiv=\"REFRESH\" content=\"5;url=$redirect\"/>";
echo <<<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <title>$applicationName</title>
  <meta name="description" content="$description" />
  <meta name="keywords" content="$keywords" />
  $redirect
  <link rel="stylesheet" type="text/css" href="css/main.css"/>
</head>
<body>
  <script type="text/javascript" src="js/wz_tooltip.js"></script>
  <script type="text/javascript" src="js/tip_balloon.js"></script>
  <div id="header">
    <h1><a href=".">$applicationName</a></h1>
    $menu
  </div>
  <div id="teaser">
    <div class="wrap">
      <div id="image"></div>
      <div class="box">
        <p style="text-align:justify;margin-top:-10px;">$description</p>
      </div>
    </div>
  </div>

  <div id="bar">
    <div class="wrap">
      <span class="step"><span class="stepNum">1</span> Network Biology</span>
      <span class="step"><span class="stepNum">2</span> Visualization & Analysis</span>
      <span class="step"><span class="stepNum">3</span> Collaboration & Open Access</span>
    </div>
  </div>
HTML;
?>