<?php

/**
 * Manages users accounts.
 * <ul>
 * <li>Create user account</li> 
 * <li>Login, logoff user</li>
 * <li>Check if there is user account with email and password</li>
 * </ul>
 *
 * @see login
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @author Harendra Guturu, hguturu@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */
class UserManager{

  function __construct($config, $db_connection){
    $this->myConfig = $config;
	$this->myDBConnection = $db_connection;
  }

  function is_registered_email($email){
    $sql = sprintf("CALL getuserwithemail('%s')", $this->myDBConnection->real_escape_string($email));
    return count(runQuery($this->myDBConnection, $sql)) > 0;
  }

  // login
  //if user name doesn't already exist creates new user account and create temporary directory
  function createUserAccount($FirstName, $LastName, $PrincipalInvestigator, $Organization, $Email, $Password){
    $sql = sprintf("CALL getuserwithemail('%s')", $this->myDBConnection->real_escape_string($Email));
    if(count(runQuery($this->myDBConnection, $sql))>0) return 'A user account already exists with that email.';

    $sql = sprintf("CALL newuser('%s', '%s', '%s', '%s', '%s', '%s')", 
        $this->myDBConnection->real_escape_string($FirstName), 
        $this->myDBConnection->real_escape_string($LastName),
        $this->myDBConnection->real_escape_string($PrincipalInvestigator), 
        $this->myDBConnection->real_escape_string($Organization), 
        $this->myDBConnection->real_escape_string($Email), 
        $this->myDBConnection->real_escape_string($Password));
    $newuser = runQuery($this->myDBConnection, $sql);
    if (count($newuser) == 0) return 'Registration error.';

    return true;
  }

  //check if email and password belong to registered user
  //if so, start new session
  function loginUser($email, $password){
    if ($email == '') return false;
	
    $sql = sprintf("CALL getuserwithemailandpassword('%s', '%s')", 
        $this->myDBConnection->real_escape_string($email), 
        $this->myDBConnection->real_escape_string($password));
	$user = runQuery($this->myDBConnection, $sql);
    if (count($user) == 0) return false;

    return $user[0]['id'];
  }

  function logoffUser($UserId){
    return "success";
  }   
}

?>