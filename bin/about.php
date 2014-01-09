<?php

/**
 * Displays application metadata.
 * <ul>
 * <li>List of developers</li>
 * <li>Ackowledgements and grant support</li>
 * <li>Third party software</li>
 * <li>Disclaimer</li>
 * </ul>
 *
 * @see MiscFunctions
 * @see edu.stanford.covertlab.networkpainter.data.AboutData
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

require('head.php');

$credits = "<ul class=\"top\">".
	join("\n", 
		array_map(
			create_function('$x', 
				'return "<li>".$x["foreName"]." ".$x["lastName"].", ".$x["position"]."<br/><a href=\"".$x["email"]."\">".$x["email"]."</a></li>";'), 
			$aboutData['developers'])).
	"</ul>";

$thirdPartySoftware  = "<table cellpadding=\"0\" cellspacing=\"0\" width=\"70%\"><tr><td><ul>\n";
for($i = 0; $i < ceil(count($aboutData['thirdPartySoftware']) / 3); $i++) {
	$thirdPartySoftware.= "<li><a href=\"".$aboutData['thirdPartySoftware'][$i]['url']."\">".$aboutData['thirdPartySoftware'][$i]['software']."</a></li>\n";
}
$thirdPartySoftware .= "</ul></td><td><ul>\n";
for($i = ceil(count($aboutData['thirdPartySoftware']) / 3); $i < ceil(count($aboutData['thirdPartySoftware'])*2/3); $i++) {
	$thirdPartySoftware.= "<li><a href=\"".$aboutData['thirdPartySoftware'][$i]['url']."\">".$aboutData['thirdPartySoftware'][$i]['software']."</a></li>\n";
}
$thirdPartySoftware .= "</ul></td><td><ul>\n";
for($i = ceil(count($aboutData['thirdPartySoftware'])*2 / 3); $i < count($aboutData['thirdPartySoftware']); $i++) {
	$thirdPartySoftware.= "<li><a href=\"".$aboutData['thirdPartySoftware'][$i]['url']."\">".$aboutData['thirdPartySoftware'][$i]['software']."</a></li>\n";
}
$thirdPartySoftware .= "</ul></td></tr></table>\n";

$disclaimer = str_replace(array('<contact/>', '<applicationName/>'), array($contact, $aboutData['applicationName']), $aboutData['disclaimer']);
$acknowledgements = str_replace(array('<contact/>', '<applicationName/>'), array($contact, $aboutData['applicationName']), $aboutData['acknowledgements']);

echo <<<HTML
  <div class="wrap page">
      <h2>About <span class="red">$applicationName</span></h2>

      <a name="credits"/>
      <h3>Credits <span class="red">& Contact Info</span></h3>
      <p>$applicationName was developed by the <a href="http://covertlab.stanford.edu">Covert Lab</a> at <a href="http://www.stanford.edu">Stanford University</a>. Please contact us with any questions or comments.</p>
	  <p style="padding-top:5px;">$credits</p>
      <p/>

      <a name="acknowledgements"/>
      <h3>Acknowledgements <span class="red">& Grant Support</span></h3>
      <p>$acknowledgements</p>
      <p/>

      <a name="software"/>
      <h3>Third Party Source <span class="red">Used in this Release</span></h3>
      <p>$thirdPartySoftware</p>
      <p/>

      <a name="disclaimer"/>
      <h3>Disclaimer</h3>
      <p>$disclaimer</p>
  </div>
HTML;

require('foot.php');
?>