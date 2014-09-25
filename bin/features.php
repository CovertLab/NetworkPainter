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

require('head.php');

//format about data
$features = "<ul>\n";
foreach($aboutData['features'] as $feature){
	$features .= "<li class=\"features\">".$feature["feature"]." &#151 ".
		str_replace(array('<contact/>', '<applicationName/>'), array($contact, $aboutData['applicationName']), $feature["comment"]).
		"</li>\n";
}
$features .= "</ul>\n";
	
$requirements="<ul><li>".join("</li><li>",array_map(create_function('$x','return $x["requirement"].(array_key_exists("comment",$x) && $x["comment"]!="" ? " -- ".$x["comment"] : "");'),$aboutData['requirements']))."</li></ul>";
$contact_darkgray='<a href="mailto:"'.$aboutData['email'].'">'.$aboutData['email'].'</a>';
$newStuff=str_replace(array('<contact/>','<applicationName/>'),array($contact,$aboutData['applicationName']),$aboutData['newStuff']);
$infoMsg=str_replace(array('<contact/>','<applicationName/>'),array($contact_darkgray,$aboutData['applicationName']),$aboutData['infoMsg']);
 
echo <<<HTML
  <div class="wrap">
    <div class="col">
      <h3>$applicationName <span class="red">Features</span></h3>
      <p>$features</p>
    </div>
    <div class="col last">
      <h3>What's <span class="red">New?</span></h3>
      <p>$newStuff</p>
      <p/>
      <h3>Software <span class="red">Requirements</span></h3>
      <p">$requirements</p>
      <p/>
      <p class="info">$infoMsg</p>
    </div>
  </div>
HTML;

require('foot.php');
?>