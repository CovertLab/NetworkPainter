<?php

/**
 * Converts svg input to one of png, ps, eps, pdf using Inkscape.
 *
 * @see http://www.inkscape.org/
 *
 * @author Jonathan Karr
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 2/16/2009
 */
 
//options
$svg = urldecode($_POST['svg']);
$format = urldecode($_POST['format']);

//temporary files
$tmpFile = tempnam('tmp', 'tmp');

//save svg as temporary file
file_put_contents("$tmpFile.svg", str_replace('\"', '"', $svg));

//rasterize svg (png, ps, eps, pdf)
shell_exec("./svgconvert $tmpFile.svg $tmpFile.$format");

//return rendered file
$fp = fopen("$tmpFile.$format", 'r');
fpassthru($fp);
fclose($fp);

//cleanup
unlink("$tmpFile");
unlink("$tmpFile.svg");
unlink("$tmpFile.$format");

?>