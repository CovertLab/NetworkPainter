/**
 * MySQL stored procedures for storing, retrieving, updating, and deleting user accounts,
 * networks, and network-experiment associations. Implements user, network security.
 * Supports collaboration through user permissions over networks. Prohibits concurrent editing
 * of networks by "locking".
 * <ul>
 * <li>Create, update user account</li>
 * <li>Get user account by email or id</li>
 * <li>Login, logoff user</li>
 * <li>Get list of allowed networks for a user</li>
 * <li>Get user permissions for a network</li>
 * <li>Grant, remove network permissions to a user</li>
 * <li>Lock, unlock a network</li>
 * <li>Get, save, delete a network - basic properties, axes, biomolecules, edges, compartments, styles, associations, perturbations</li>
 * </ul>
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @author Harendra Guturu, hguturu@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

DELIMITER $$

###############################################################
## Creating / updating user accounts
###############################################################

DROP PROCEDURE IF EXISTS `newuser` $$
CREATE PROCEDURE `newuser` (FirstName varchar(255), LastName varchar(255),
     PrincipalInvestigator varchar(255), Organization varchar(255), Email varchar(255), Password varchar(255))
BEGIN

DECLARE _userid BIGINT;

INSERT INTO `users` (`firstname`, `lastname`, `principalinvestigator`, `organization`, `email`, `password`, `logofferror`)
VALUES (FirstName, LastName, PrincipalInvestigator, Organization, Email, Password, false);

SELECT MAX(id) INTO _userid FROM users;

CALL savenewnetwork(_userid,'', '', 'No',0,0,0xFFD700,0xCDAD00,true,0,0,0,0, 0,0,0,true,true,0,0,true);

SELECT _userid id;

END $$

DROP PROCEDURE IF EXISTS `saveuser` $$
CREATE PROCEDURE `saveuser` (_userid BIGINT, 
     _FirstName varchar(255), _LastName varchar(255),
     _PrincipalInvestigator varchar(255), _Organization varchar(255))
BEGIN

UPDATE users
SET
  firstname = _FirstName,
  lastname = _LastName,
  principalinvestigator = _PrincipalInvestigator,
  organization = _Organization
WHERE users.id = _userid;

CALL getuserwithid(_userid);

END $$

###############################################################
## Function for opening a user account
###############################################################

DROP PROCEDURE IF EXISTS `getuserwithemail` $$
CREATE PROCEDURE `getuserwithemail` (_email VARCHAR(255))
BEGIN

SELECT users.*
FROM users
WHERE users.email=_email;

END $$

DROP PROCEDURE IF EXISTS `getuserwithemailandpassword` $$
CREATE PROCEDURE `getuserwithemailandpassword` (_email VARCHAR(255), _password VARCHAR(255))
BEGIN

SELECT users.*
FROM users
WHERE users.email=_email && users.password = _password;

END $$

DROP PROCEDURE IF EXISTS `getuserwithid` $$
CREATE PROCEDURE `getuserwithid` (_userid BIGINT)
BEGIN

SELECT users.*, permissions.networkid autosaveid
FROM users
JOIN permissions ON permissions.userid=users.id
WHERE users.id=_userid && permissions.permissions='a';

END $$

DROP PROCEDURE IF EXISTS `loginuser` $$
CREATE PROCEDURE `loginuser` (_userid BIGINT)
BEGIN

CALL getuserwithid(_userid);

UPDATE users
SET logofferror=true
WHERE users.id=_userid;

END $$

DROP PROCEDURE IF EXISTS `logoffuser` $$
CREATE PROCEDURE `logoffuser` (_userid BIGINT, _logofferror BOOL)
BEGIN

UPDATE users
SET logofferror = _logofferror
WHERE users.id = _userid;

END $$

###############################################################
## Functions for showing a user networks they are allowed to
## access, granting access
###############################################################

DROP PROCEDURE IF EXISTS `listnetworks` $$
CREATE PROCEDURE `listnetworks`(_email varchar(255))
BEGIN

DECLARE userid BIGINT;

SELECT id INTO userid
FROM users
WHERE users.email = _email;

SELECT
  networks.id,
  networks.name,
  networks.description,
  DATE_FORMAT(networks.creation,'%a %b %d %Y %r') creation,
  DATE_FORMAT(networks.lastsave,'%a %b %d %Y %r') lastsave,
  networks.publicstatus,
  networks.permissions,
  GROUP_CONCAT(DISTINCT CONCAT_WS(' ',owner.firstname,owner.lastname) ORDER BY owner.firstname, owner.lastname SEPARATOR ', ') owner
FROM (
  SElECT networks.*, permissions.permissions
  FROM permissions
  JOIN networks ON permissions.networkid=networks.id
  WHERE permissions.userid=userid &&
    (permissions.permissions!='a' && permissions.permissions!='n')

  UNION

  SELECT networks.*, 'r' AS permissions
  FROM networks
  WHERE networks.publicstatus='Yes' AND
    id NOT IN (
      SElECT networks.id
      FROM permissions
      JOIN networks ON permissions.networkid=networks.id
      WHERE permissions.userid=userid && permissions.permissions!='n')
) AS networks
JOIN permissions ON permissions.networkid=networks.id
JOIN users owner ON permissions.userid=owner.id
WHERE permissions.permissions='o'
GROUP BY networks.id
ORDER BY networks.name;

END $$

DROP PROCEDURE IF EXISTS `getallowednetworks` $$
CREATE PROCEDURE `getallowednetworks`(_userid BIGINT)
BEGIN

SELECT
  networks.id,
  networks.name,
  networks.description,
  DATE_FORMAT(networks.creation,'%a %b %d %Y %r') creation,
  DATE_FORMAT(networks.lastsave,'%a %b %d %Y %r') lastsave,
  networks.publicstatus,
  networks.lockuserid,
  IF(HOUR(TIMEDIFF(NOW(),networks.locktime  ))<1,CONCAT_WS(' ',lockeduser.firstname,lockeduser.lastname),'') lockuser,
  IF(networks.lockuserid!=_userid && HOUR(TIMEDIFF(NOW(),networks.locktime))<1,true,false) locked,
  networks.permissions,
  GROUP_CONCAT(DISTINCT CONCAT_WS(' ',owner.firstname,owner.lastname) ORDER BY owner.firstname, owner.lastname SEPARATOR ', ') owner
FROM (
  SElECT networks.*, permissions.permissions
  FROM permissions
  JOIN networks ON permissions.networkid=networks.id
  WHERE permissions.userid=_userid && permissions.permissions!='n'

  UNION

  SELECT networks.*, 'r' AS permissions
  FROM networks
  WHERE networks.publicstatus='Yes' AND
    id NOT IN (
      SElECT networks.id
      FROM permissions
      JOIN networks ON permissions.networkid=networks.id
      WHERE permissions.userid=_userid && permissions.permissions!='n')
) AS networks
JOIN permissions ON permissions.networkid=networks.id
JOIN users owner ON permissions.userid=owner.id
LEFT JOIN users lockeduser ON networks.lockuserid=lockeduser.id
WHERE permissions.permissions='o'
GROUP BY networks.id
ORDER BY networks.name;

END $$

DROP PROCEDURE IF EXISTS `getuserpermissions` $$
CREATE PROCEDURE `getuserpermissions`(_userid BIGINT)
BEGIN

SELECT * from permissions WHERE permissions.userid=_userid;

END $$

DROP PROCEDURE IF EXISTS `getnetworkpermissions` $$
CREATE PROCEDURE `getnetworkpermissions`(_networkid BIGINT)
BEGIN

SELECT
  users.id userid,
  CONCAT_WS(' ',users.firstname,users.lastname) user,
  IF(permissions.permissions IS NULL,'n',permissions.permissions) permissions
FROM users
LEFT JOIN (
  SELECT *
  FROM permissions
  WHERE permissions.networkid=_networkid
) AS permissions ON permissions.userid=users.id
ORDER BY users.firstname,users.lastname;

END $$

DROP PROCEDURE IF EXISTS `grantnetworkpermissions` $$
CREATE PROCEDURE `grantnetworkpermissions`(_networkid BIGINT, _userid BIGINT, _permissions ENUM('r','w','o','n','a'))
BEGIN

IF _permissions!='n' THEN
  INSERT INTO permissions(networkid,userid,permissions) VALUES(_networkid, _userid, _permissions);
END IF;

END $$

###############################################################
## Functions for network collaboration
###############################################################

DROP PROCEDURE IF EXISTS `updatelastsave` $$
CREATE PROCEDURE `updatelastsave`(_networkid BIGINT)
BEGIN

UPDATE networks SET lastsave=NOW() WHERE networks.id=_networkid;

END $$

DROP PROCEDURE IF EXISTS `clearnetworklock` $$
CREATE PROCEDURE `clearnetworklock` (_networkid BIGINT)
BEGIN

UPDATE networks SET lockuserid=0, locktime=0 WHERE networks.id=_networkid;

END $$

DROP PROCEDURE IF EXISTS `renewnetworklock` $$
CREATE PROCEDURE `renewnetworklock` (userid BIGINT, _networkid BIGINT)
BEGIN

UPDATE networks
SET lockuserid=0,locktime=0
WHERE networks.lockuserid=userid;

UPDATE networks
SET
  lockuserid=userid,
  locktime=NOW()
WHERE networks.id=_networkid;

END $$

###############################################################
## Functions for opening a specific network
###############################################################

DROP PROCEDURE IF EXISTS `getnetwork` $$
CREATE PROCEDURE `getnetwork` (_networkid BIGINT, _userid BIGINT)
BEGIN

SELECT
  networks.id,
  networks.name,
  networks.description,
  DATE_FORMAT(networks.creation, '%a %b %d %Y %r') creation,
  DATE_FORMAT(networks.lastsave, '%a %b %d %Y %r') lastsave,
  networks.publicstatus,
  networks.lockuserid,
  IF(HOUR(TIMEDIFF(NOW(), networks.locktime )) < 1, CONCAT_WS(' ', lockeduser.firstname,lockeduser.lastname), '') lockuser,
  IF(networks.lockuserid!=_userid && HOUR(TIMEDIFF(NOW(),networks.locktime)) < 1, true, false) locked,
  IF(permissions.permissions IS NULL, IF(networks.publicstatus = 'Yes', 'r', 'n'), permissions.permissions) permissions,
  GROUP_CONCAT(DISTINCT CONCAT_WS(' ', owner.firstname,owner.lastname) ORDER BY owner.firstname, owner.lastname SEPARATOR ', ') owner,
  networks.preview,
  networks.width,
  networks.showPores,
  networks.poreFillColor,
  networks.poreStrokeColor,
  networks.height,
  networks.membraneHeight,
  networks.membraneCurvature,
  networks.minCompartmentHeight,
  networks.ranksep,
  networks.nodesep,
  networks.animationFrameRate,
  networks.loopAnimation,
  networks.exportShowBiomoleculeSelectedHandles,
  networks.exportColorBiomoleculesByValue,
  networks.exportAnimationFrameRate,
  networks.exportLoopAnimation
  
FROM networks
LEFT JOIN (SELECT * FROM permissions WHERE userid = _userid) AS permissions ON permissions.networkid = networks.id
LEFT JOIN users lockeduser ON networks.lockuserid = lockeduser.id

JOIN permissions ownerpermissions ON networks.id=ownerpermissions.networkid
JOIN users owner ON ownerpermissions.userid=owner.id

WHERE
  networks.id = _networkid
GROUP BY networks.id;

END $$

DROP PROCEDURE IF EXISTS `getbiomoleculestyles` $$
CREATE PROCEDURE `getbiomoleculestyles` (_networkid BIGINT, userid BIGINT)
BEGIN

SELECT *
FROM biomoleculestyles
WHERE biomoleculestyles.networkid=_networkid
ORDER BY biomoleculestyles.id;

END $$

DROP PROCEDURE IF EXISTS `getcompartments` $$
CREATE PROCEDURE `getcompartments` (_networkid BIGINT, userid BIGINT)
BEGIN

SELECT *
FROM compartments
WHERE compartments.networkid=_networkid
ORDER BY compartments.id;

END $$

DROP PROCEDURE IF EXISTS `getbiomolecules` $$
CREATE PROCEDURE `getbiomolecules` (_networkid BIGINT, userid BIGINT)
BEGIN

SELECT *
FROM biomolecules
WHERE biomolecules.networkid=_networkid
ORDER BY biomolecules.id;

END $$

DROP PROCEDURE IF EXISTS `getedges` $$
CREATE PROCEDURE `getedges` (_networkid BIGINT, userid BIGINT)
BEGIN

SELECT *
FROM edges
WHERE edges.networkid=_networkid
ORDER BY edges.id;

END $$

###############################################################
## Function for creating/saving/updating a network
###############################################################

DROP PROCEDURE IF EXISTS `savenewnetwork` $$
CREATE PROCEDURE `savenewnetwork`(_ownerid BIGINT,
  _name VARCHAR(255), _description TEXT, _publicstatus ENUM('No','Yes'),
  _width int, _height int, _showPores bool,
  _poreFillColor INT, _poreStrokeColor INT,
  _membraneHeight FLOAT, _membraneCurvature FLOAT, _minCompartmentHeight FLOAT,
  _ranksep FLOAT, _nodesep FLOAT,
  _animationFrameRate FLOAT, _loopAnimation TINYINT,
  _exportShowBiomoleculeSelectedHandles BOOL, _exportColorBiomoleculesByValue BOOL,
  _exportAnimationFrameRate FLOAT, _exportLoopAnimation TINYINT,
  _autosave BOOL)
BEGIN

#new network
INSERT INTO `networks` (
  name,description,
  width,height,showPores,
  poreFillColor,poreStrokeColor,
  membraneHeight,membraneCurvature,minCompartmentHeight,
  ranksep,nodesep,
  animationFrameRate, loopAnimation,
  exportShowBiomoleculeSelectedHandles, exportColorBiomoleculesByValue,
  exportAnimationFrameRate, exportLoopAnimation,
  creation,lastsave,publicstatus,lockuserid,locktime)
VALUES (
  _name, _description,
  _width, _height, _showPores,
  _poreFillColor, _poreStrokeColor,
  _membraneHeight, _membraneCurvature, _minCompartmentHeight,
  _ranksep, _nodesep,
  _animationFrameRate, _loopAnimation,
  _exportShowBiomoleculeSelectedHandles, _exportColorBiomoleculesByValue,
  _exportAnimationFrameRate, _exportLoopAnimation,
  NOW(),NOW(), _publicstatus, _ownerid, NOW());
SET @networkid = last_insert_id();

#permissions
IF _autosave THEN
  SET @permissions='a';
ELSE
  SET @permissions='o';
END IF;
CALL grantnetworkpermissions(@networkid, _ownerid, @permissions);

#axes
INSERT INTO axes(networkid) VALUES(@networkid);

CALL getnetwork(@networkid, _ownerid);

SELECT @networkid id;

END $$


DROP PROCEDURE IF EXISTS `updatenetwork` $$
CREATE PROCEDURE `updatenetwork`(id BIGINT,
  description TEXT, publicstatus ENUM('No','Yes'),
  preview MEDIUMBLOB, width int, height int, showPores bool,
  poreFillColor INT, poreStrokeColor INT,
  membraneHeight FLOAT, membraneCurvature FLOAT, minCompartmentHeight FLOAT,
  ranksep FLOAT, nodesep FLOAT,
  animationFrameRate FLOAT, loopAnimation TINYINT,
  exportShowBiomoleculeSelectedHandles BOOL, exportColorBiomoleculesByValue BOOL,
  exportAnimationFrameRate FLOAT, exportLoopAnimation TINYINT)
BEGIN

#network
UPDATE networks
SET
  networks.description = description,  
  networks.preview = preview,
  networks.width = width,
  networks.height = height,
  networks.showPores = showPores,
  networks.poreFillColor = poreFillColor,
  networks.poreStrokeColor = poreStrokeColor,
  networks.membraneHeight = membraneHeight,
  networks.membraneCurvature = membraneCurvature,
  networks.minCompartmentHeight = minCompartmentHeight,
  networks.ranksep = ranksep,
  networks.nodesep = nodesep,
  networks.animationFrameRate = animationFrameRate,
  networks.loopAnimation = loopAnimation,
  networks.exportShowBiomoleculeSelectedHandles = exportShowBiomoleculeSelectedHandles,
  networks.exportColorBiomoleculesByValue = exportColorBiomoleculesByValue,
  networks.exportAnimationFrameRate = exportAnimationFrameRate,
  networks.exportLoopAnimation = exportLoopAnimation,
  networks.publicstatus = publicstatus
WHERE
  networks.id = id;

END $$

DROP PROCEDURE IF EXISTS `updatenetworkpreview` $$
CREATE PROCEDURE `updatenetworkpreview`(_id BIGINT, _preview MEDIUMBLOB)
BEGIN

UPDATE networks
SET preview = _preview
WHERE networks.id = _id;

END $$

DROP PROCEDURE IF EXISTS `updatenetworkproperties` $$
CREATE PROCEDURE `updatenetworkproperties`(_id BIGINT, _name VARCHAR(255), _description TEXT, _publicstatus ENUM('No','Yes'))
BEGIN

UPDATE networks
SET
  name=_name,
  description=_description,
  publicstatus=_publicstatus
WHERE
  networks.id=_id;
END $$

DROP PROCEDURE IF EXISTS `addbiomoleculestyles` $$
CREATE PROCEDURE `addbiomoleculestyles` (_networkid BIGINT, _id BIGINT,
  _name VARCHAR(255), _shape VARCHAR(255), _color INT, _outline INT)
BEGIN

INSERT INTO biomoleculestyles (networkid, id, name, shape, color, outline)
VALUES (_networkid, _id, _name, _shape, _color, _outline);

END $$

DROP PROCEDURE IF EXISTS `addcompartments` $$
CREATE PROCEDURE `addcompartments` (networkid BIGINT, id BIGINT,
  name VARCHAR(255), color INT, membranecolor INT, phospholipidbodycolor INT,
  phospholipidoutlinecolor INT, height FLOAT)
BEGIN

INSERT INTO compartments (networkid, id, name, color, membranecolor, phospholipidbodycolor, phospholipidoutlinecolor, height)
VALUES (networkid, id, name, color, membranecolor, phospholipidbodycolor, phospholipidoutlinecolor, height);

END $$


DROP PROCEDURE IF EXISTS `addbiomolecules` $$
CREATE PROCEDURE `addbiomolecules` (networkid BIGINT, id BIGINT,
  name VARCHAR(255), label VARCHAR(255), regulation VARCHAR(255), comments TEXT, x FLOAT, y FLOAT, biomoleculestyleid BIGINT, compartmentid BIGINT)
BEGIN

INSERT INTO biomolecules (networkid, id, name, label, regulation, comments, x, y, biomoleculestyleid, compartmentid)
VALUES (networkid, id, name, label, regulation, comments, x, y, biomoleculestyleid, compartmentid);

END $$

DROP PROCEDURE IF EXISTS `addedges` $$
CREATE PROCEDURE `addedges` (networkid BIGINT, id BIGINT,
  frombiomoleculeid BIGINT, tobiomoleculeid BIGINT, sense BOOL, path TEXT)
BEGIN

INSERT INTO edges (networkid, id, frombiomoleculeid, tobiomoleculeid, sense, path)
VALUES (networkid, id, frombiomoleculeid, tobiomoleculeid, sense, path);


END $$

###############################################################
## remove old data while saving
###############################################################

DROP PROCEDURE IF EXISTS `deletenetwork` $$
CREATE PROCEDURE `deletenetwork`(id BIGINT)
BEGIN

CALL dropnetworkpermissions(id);
CALL dropedges(id);
CALL dropbiomolecules(id);
CALL dropcompartments(id);
CALL dropbiomoleculestyles(id);
CALL dropaxes(id);
CALL dropexperiments(id);

DELETE FROM networks WHERE networks.id = id;

END $$

DROP PROCEDURE IF EXISTS `dropnetworkpermissions` $$
CREATE PROCEDURE `dropnetworkpermissions`(networkid BIGINT)
BEGIN

DELETE FROM permissions
WHERE permissions.networkid=networkid;

END $$

DROP PROCEDURE IF EXISTS `dropedges` $$
CREATE PROCEDURE `dropedges` (networkid BIGINT)
BEGIN

DELETE FROM edges WHERE edges.networkid=networkid;

END $$

DROP PROCEDURE IF EXISTS `dropbiomolecules` $$
CREATE PROCEDURE `dropbiomolecules` (networkid BIGINT)
BEGIN

DELETE FROM biomolecules WHERE biomolecules.networkid=networkid;

END $$

DROP PROCEDURE IF EXISTS `dropcompartments` $$
CREATE PROCEDURE `dropcompartments` (networkid BIGINT)
BEGIN

DELETE FROM compartments WHERE compartments.networkid=networkid;

END $$

DROP PROCEDURE IF EXISTS `dropbiomoleculestyles` $$
CREATE PROCEDURE `dropbiomoleculestyles`(networkid BIGINT)
BEGIN

DELETE FROM biomoleculestyles WHERE biomoleculestyles.networkid=networkid;

END $$

DROP PROCEDURE IF EXISTS `dropaxes` $$
CREATE PROCEDURE `dropaxes`(networkid BIGINT)
BEGIN

DELETE FROM axes WHERE axes.networkid = networkid;

END $$

DROP PROCEDURE IF EXISTS `dropexperiments` $$
CREATE PROCEDURE `dropexperiments`(networkid BIGINT)
BEGIN

DELETE FROM experiments WHERE experiments.networkid = networkid;

DELETE FROM channels      WHERE channels.networkid      = networkid;
DELETE FROM conditions    WHERE conditions.networkid    = networkid;
DELETE FROM dosages       WHERE dosages.networkid       = networkid;
DELETE FROM individuals   WHERE individuals.networkid   = networkid;
DELETE FROM populations   WHERE populations.networkid   = networkid;
DELETE FROM timepoints    WHERE timepoints.networkid    = networkid;

DELETE FROM statistics    WHERE statistics.networkid    = networkid;

DELETE FROM perturbations WHERE perturbations.networkid = networkid;
DELETE FROM associations  WHERE associations.networkid  = networkid;

END $$

DELIMITER ;