<?php

/**
 * Displays footer for webpages.
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

require('configuration.php');

$lastupdated = date("M j, Y", getlastmod());
$now = date("Y");

echo <<<HTML
  <div id="footer">
    <p class="right">Design: <a href="http://www.solucija.com/" title="Information Architecture and Web Design">Luka Cvrk</a></p>
    <p class="left">&copy; 2007-$now Covert Lab, Stanford University<br/>$contact<br/>Last updated $lastupdated</p>
  </div>
</body>
HTML;
?>
</body>
</html>