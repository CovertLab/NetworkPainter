<?php

/**
 * Displays application help.
 *
 * @see edu.stanford.covertlab.networkpainter.data.HelpData
 * @see MiscFunctions
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

require('head.php');

$helpData = parseHelpData();
$html = formatHelpData($helpData,array('<contact/>','<applicationName/>'),array($contact,$applicationName));

echo <<< HTML
  <style>
      p {text-align:justify;}
	  page p,page ul {
		line-height: 1.3em;
	  }
	  page ul,page ol {
		margin-top:-6px;
	  }
	  page ul ul, page ol ol {
		margin-top:-2px;
		margin-bottom:-4px;
	  }
  </style>
  <div class="wrap page">
    $html
  </div>
HTML;

require('foot.php');


?>