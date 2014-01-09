<?php

/**
 * Ends PHP session started at login.
 *
 * @see login
 *
 * @author Harendra Guturu, hguturu@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

session_start();
session_destroy();
?>