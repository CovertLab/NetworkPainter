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

//save svg as temporary file
file_put_contents('tmp/tmp.svg', str_replace('\"', '"',$svg));

//rasterize svg (png, ps, eps, pdf)
shell_exec("inkscape tmp/tmp.svg --export-$format=tmp/tmp.$format");

//return rendered file
readfile("tmp/tmp.$format");

?>