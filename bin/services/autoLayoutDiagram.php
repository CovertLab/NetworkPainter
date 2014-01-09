<?php

/**
 * Compiles dot - formatted graph using GraphViz to plain format. Returns plain format.
 *
 * @see http://www.graphviz.org
 *
 * @author Jonathan Karr 
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 1/27/2009
 */

//url decode dot code, unescape actionscript string
//save dot code to temporary file
file_put_contents('tmp/tmp.dot', str_replace('\"', '"',urldecode($_POST['dotCode'])));

//get layout using GraphViz with options
// - plain format
// - don't scale input
// - invert y axis
echo system('dot tmp/tmp.dot -v1 -y -Tplain');

?>