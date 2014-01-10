<?php

/**
 * Displays links to source code, instructions for installation.
 *
 * @see MiscFunctions
 * @see edu.stanford.covertlab.networkpainter.data.AboutData
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

require('head.php');

$license = '<p>'.str_replace("\r\n\r\n","</p>\n<p>",file_get_contents('../license.txt'))."</p>\n";

echo <<<HTML
  <div class="wrap page">
    <div>
      <h2>$applicationName <span class="red">Source Code</span></h2>
	  
	  <a name="download"/>
      <h3>Download</h3>
	  $applicationName is distributed under the <a href="#license">MIT license</a>. The source code is freely available at <a href="http://github.com/CovertLab/NetworkPainter">Github</a>.
	  
	  <a name="installation"/>
      <h3>Installation</h3>
	  Installation instructions are available <a href="https://github.com/CovertLab/NetworkPainter/blob/master/installation.md">here</a>.
	  
	  <a name="documentation"/>
	  <h3>Documentation</h3>
	  <table class="documentation" cellspacing="0" cellpadding="0">
	  <tr><td style="padding-right:40px;"><img src="../docs/uml/application.png"/></td><td><img src="../docs/uml/diagram.png"/></td></tr>
	  <tr><td style="padding-right:40px;">Application</td><td>Diagram</td></tr>
	  <tr><td colspan="2" style="padding-top:50px;"><img src="../docs/uml/db_schema.png"/></td></tr>
	  <tr><td colspan="2"">Database Schema</td></tr>
	  </table>
	  
	  <p>See <a href="../docs">online documentation</a> for more information.</p>
	  
	  <a name="license"/>
      <h3>License</h3>
      <p>$license</p>
      <p/>     
    </div>
  </div>
HTML;

require('foot.php');
?>