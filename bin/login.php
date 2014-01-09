<?php

/**
 * Web form for logging in users.
 *
 * @see UserManager
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @author Harendra Guturu, hguturu@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

if (array_key_exists("cmd", $_GET)) $cmd = $_GET['cmd'];
else $cmd = "start";
switch ($cmd) {
case '':
case 'start':
	start();
	break;
case 'login':
	login();
	break;
case 'logoff':
	logoff();
	break;
case 'register_start':
	register_start();
	break;
case 'register_save':
	register_save();
	break;
}

///////////////////////////////////
// login
///////////////////////////////////

function start($email = '', $error = '') {
    $error = 'NetworkPainter is temporarily unavailable while we are improving the software. Please check back soon. '. $error;
    
	if ($error != '') $error = "<p class=\"error\">$error</p>";
	require('head.php');
	echo "<div class=\"wrap page\">"; 

	echo "<div style=\"width:395px; float:left;\">\n";
	echo "    <h3 style=\"margin-bottom:12px;\">Standalone <span class=\"red\">Version</span></h3>"; 
    echo "    <p>$error</p>";
    echo "    <form method=\"POST\" action=\"?cmd=login&networkID=".$_GET['networkID']."&experimentID=".$_GET['experimentID']."\">";
	echo "    <table width=\"100\">";	
	echo "      <tr>";
    echo "        <td colspan=\"2\"><b>1. Login | <a href=\"?cmd=register_start\">Register</a></b></td>";
    echo "      </tr>";
    echo "      <tr>";
    echo "        <td>Email</td>";
	echo "        <td style=\"padding-left:10px;width:200px;\"><input type=\"text\" name=\"email\" style=\"width:323px;\" value=\"$email\"/></td>";
    echo "      </tr>";
    echo "      <tr>";
    echo "        <td>Password</td>";
	echo "        <td style=\"padding-left:10px;width:200px;\"><input type=\"password\" name=\"password\" style=\"width:323px;\" /></td>";
    echo "      </tr>";
    echo "      <tr>";
	echo "        <td colspan=\"2\" style=\"text-align:right\"><button type=\"submit\"><div><span>Login</span></div></button></td>";
	echo "      </tr>";
    echo "    </table>";
	echo "    </form>";
    echo "    <table width=\"100%\" style=\"padding-top:10px\">";	
    echo "    <form method=\"POST\" action=\"?cmd=login&guest=1&networkID=".$_GET['networkID']."&experimentID=".$_GET['experimentID']."\">";
    echo "      <tr>";
    echo "        <td><b>2. Use as guest</b></td>";
    echo "      </tr>";
	echo "      <tr>";
	echo "        <td><i>No registration required</i></td>";
	echo "        <td style=\"text-align:right;\"><button type=\"submit\" style=\"position:relative; top:-10px;\"><div><span>Login</span></div></button></td>";
	echo "      </tr>";
	echo "    </table>";
	echo "    </form>\n";
	echo "</div>\n";
	
	echo "<div style=\"width:120px; float:left; padding:0px; padding-top:30px; text-align:center; font-size:20px; font-weight:bold;\">\n";
	echo "<span class=\"red\">Or</span>";
	echo "</div>\n";
	
	echo "<div style=\"width:235px; float:left;\">\n";
	echo "    <h3 style=\"margin-bottom:12px;\">Cytobank <span class=\"red\">Version</span></h3>"; 	
	echo "    <p>Login at <a href=\"http://www.cytobank.org\">Cytobank</a>.</p>";
	echo "</div>\n";
	
	echo "<div style=\"clear:both; padding-bottom:20px;\">\n";
	
	echo "</div>";
	require('foot.php');
}

function login(){
	require_once('engines/MiscFunctions.php');
	require_once('engines/UserManager.php');
	require('configuration.php');
	session_start();

	//bypass auth for guest account
	if ($_GET['guest'] == '1') {
		$_SESSION['IS_GUEST'] = true;
		$_SESSION['USER_ID'] = 0;
		$_SESSION['SESSION_ID'] = session_id();
		require('NetworkPainter.php');
		return;
	}
	
	$email = $_POST['email'];
    $password = $_POST['password'];
    
    $db_connection = databaseConnect($config['mysql']);		
    $userDatabase = new UserManager($config, $db_connection);
    $UserId = $userDatabase-> loginUser($email, $password);
    if (false !== $UserId){
        $_SESSION['IS_GUEST'] = false;
        $_SESSION['USER_ID'] = $UserId;
        $_SESSION['SESSION_ID'] = session_id();
        require('NetworkPainter.php');
    }else{
        start($email, 'There is no user with that email and password.');
    }
}


///////////////////////////////////
//logoff
///////////////////////////////////
function logoff() {
	session_start();
	session_destroy();
	require('head.php');
	echo "<div class=\"wrap page\">";
	echo "    <h3>Exit</h3>";
	echo "    <p>Thank you for using NetworkPainter.</p>";
	echo "</div>";
	require('foot.php');
}

function register_start(){
    require_once('engines/MiscFunctions.php');
	require_once('engines/UserManager.php');
	require('configuration.php');
    
    //display form
    register_show_form();
}

function register_save(){
    require_once('engines/MiscFunctions.php');
	require_once('engines/UserManager.php');
	require('configuration.php');
    
    //get submitted info
    $FirstName = $_POST['FirstName'];
	$LastName = $_POST['LastName'];	
	$PrincipalInvestigator = $_POST['PrincipalInvestigator'];
    $Organization = $_POST['Organization'];
    $Email = $_POST['Email'];
    $Password = $_POST['Password'];
    
    //error check
    $errorMsg = '';
    if ($FirstName == '') $errorMsg .= 'Please provide your first name. ';
	if ($LastName == '') $errorMsg .= 'Please provide your last name. ';	
    if ($Email == '') $errorMsg .= 'Please provide an email address. ';
    if ($Password == '') $errorMsg .= 'Please provide a password. ';
    
    //restart form if errors
	if ($errorMsg) return register_show_form($errorMsg, $FirstName, $LastName, $PrincipalInvestigator, $Organization, $Email, '');
    
    //create new user
    $db_connection = databaseConnect($config['mysql']);
    $userDatabase = new UserManager($config, $db_connection);
	if($errorMsg = $userDatabase->createUserAccount($FirstName, $LastName, $PrincipalInvestigator, $Organization, $Email, $Password) === true) return start($Email, 'Thanks for registering. Please login to begin using the software.');
    return register_show_form($errorMsg, $FirstName, $LastName, $PrincipalInvestigator, $Organization, $Email, '');
}

function register_show_form($error = '', $FirstName = '', $LastName = '', $PrincipalInvestigator = '', $Organization = '', $Email = '', $Password = ''){
	if ($error != '') $error = "<p class=\"error\">$error</p>";    
	
    require('head.php');
	
    echo "<div class=\"wrap page\">";
	echo "    <h3>Registration</h3>";
	echo "    $error";
	echo "    <p><form method=\"POST\" action=\"?cmd=register_save&networkID=".$_GET['networkID']."&experimentID=".$_GET['experimentID']."\">";
	echo "    <table style=\"padding-top:5px;\">";
	echo "      <tr><td>First Name</td>               <td style=\"padding-left:10px;width:200px;\"><input name=\"FirstName\" type=\"text\" value=\"$FirstName\"/></td></tr>";
	echo "      <tr><td>Last Name</td>                <td style=\"padding-left:10px;width:200px;\"><input name=\"LastName\" type=\"text\" value=\"$LastName\"/></td></tr>";
	echo "      <tr><td>Principal Investigator</td>  <td style=\"padding-left:10px;width:200px;\"><input name=\"PrincipalInvestigator\" type=\"text\" value=\"$PrincipalInvestigator\"/></td></tr>";
    echo "      <tr><td>Organization</td>            <td style=\"padding-left:10px;width:200px;\"><input name=\"Organization\" type=\"text\" value=\"$Organization\"/></td></tr>";
    echo "      <tr><td>Email</td>                   <td style=\"padding-left:10px;width:200px;\"><input name=\"Email\" type=\"text\" value=\"$Email\"/></td></tr>";
    echo "      <tr><td>Password</td>                   <td style=\"padding-left:10px;width:200px;\"><input name=\"Password\" type=\"password\" value=\"$Password\"/></td></tr>";
	echo "      <tr><td style=\"text-align:right;padding-top:5px;padding-bottom:5px;\" colspan=\"2\"><button type=\"submit\"><div><span>Register</span></div></button></td></tr>";
	echo "    </table>";
	echo "    </form></p>";
	echo "</div>";
	
    require('foot.php');
}

?>