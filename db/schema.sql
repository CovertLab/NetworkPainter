-- MySQL tables store:
-- - networks: compartments, styles, biomolecules, edges, axes, permissions 
-- - experiments: channels, conditions, dosages, individuals, populations, timepoints, associations, perturbations
-- - users
--
-- @author Jonathan Karr, jkarr@stanford.edu
-- @affiliation Covert Lab, Department of Bioengineering, Stanford University
-- @lastupdated 1/11/2013

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

-------------------------------------------
-- networks
-------------------------------------------

CREATE TABLE `networks` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` text collate latin1_general_ci,
  
  `preview` mediumblob NOT NULL,
  `width` int(11) NOT NULL,
  `showPores` tinyint(1) NOT NULL,
  `poreFillColor` int(10) NOT NULL,
  `poreStrokeColor` int(10) NOT NULL,
  `height` int(11) NOT NULL,
  `membraneHeight` float NOT NULL,
  `membraneCurvature` float NOT NULL,
  `minCompartmentHeight` float NOT NULL,
  `ranksep` float NOT NULL,
  `nodesep` float NOT NULL,
  `animationFrameRate` float NOT NULL,
  `loopAnimation` tinyint(1) NOT NULL,
  `dimAnimation` tinyint(1) NOT NULL,
  `exportShowBiomoleculeSelectedHandles` tinyint(1) NOT NULL,
  `exportColorBiomoleculesByValue` tinyint(1) NOT NULL,
  `exportAnimationFrameRate` float NOT NULL,
  `exportLoopAnimation` tinyint(1) NOT NULL,
  `exportDimAnimation` tinyint(1) NOT NULL,
  
  `creation` datetime NOT NULL,
  `lastsave` datetime NOT NULL,
  `publicstatus` enum('No','Yes') NOT NULL default 'No',
  `lockuserid` bigint(20) unsigned NOT NULL,
  `locktime` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  FULLTEXT KEY `name` (`name`,`description`)
) ENGINE=MyISAM;

CREATE TABLE `compartments` (
  `id` bigint(20) unsigned NOT NULL COMMENT 'unique per networkid',
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `color` int(10) unsigned NOT NULL,
  `membranecolor` int(10) unsigned NOT NULL,
  `phospholipidbodycolor` int(10) NOT NULL,
  `phospholipidoutlinecolor` int(10) NOT NULL,
  `height` float NOT NULL,
  KEY `networkid` (`networkid`),
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

CREATE TABLE `biomoleculestyles` (
  `id` bigint(20) unsigned NOT NULL COMMENT 'unique per networkid',
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `shape` varchar(255) NOT NULL,
  `color` int(10) unsigned NOT NULL,
  `outline` int(10) unsigned NOT NULL,
  KEY `networkid` (`networkid`),
  KEY `id` (`id`),
  FULLTEXT KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

CREATE TABLE `biomolecules` (
  `id` bigint(20) unsigned NOT NULL COMMENT 'unique per networkid',
  `networkid` bigint(20) unsigned NOT NULL,
  `compartmentid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `label` text collate latin1_general_ci,
  `biomoleculestyleid` bigint(20) unsigned NOT NULL,
  `regulation` text collate latin1_general_ci,
  `comments` text collate latin1_general_ci,
  `x` float NOT NULL,
  `y` float NOT NULL,
  KEY `networkid` (`networkid`,`compartmentid`),
  KEY `id` (`id`),
  FULLTEXT KEY `name` (`name`,`label`,`regulation`,`comments`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

CREATE TABLE `edges` (
  `id` bigint(20) NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `frombiomoleculeid` bigint(20) unsigned NOT NULL,
  `tobiomoleculeid` bigint(20) unsigned NOT NULL,
  `sense` tinyint(1) NOT NULL,
  `path` text NOT NULL,
  KEY `networkid` (`networkid`,`frombiomoleculeid`,`tobiomoleculeid`),
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

CREATE TABLE `axes` (
  `networkid` bigint(20) NOT NULL,
  
  `channelAxis` enum('Biomolecule', 'Animation', 'Comparison-X', 'Comparison-Y') NULL default 'Biomolecule',
  `conditionAxis` enum('Biomolecule', 'Animation', 'Comparison-X', 'Comparison-Y') NULL default 'Comparison-X',
  `dosageAxis` enum('Biomolecule', 'Animation', 'Comparison-X', 'Comparison-Y') NULL default NULL,
  `individualAxis` enum('Biomolecule', 'Animation', 'Comparison-X', 'Comparison-Y') NULL default 'Comparison-Y',
  `populationAxis` enum('Biomolecule', 'Animation', 'Comparison-X', 'Comparison-Y') NULL default NULL,
  `timepointAxis` enum('Biomolecule', 'Animation', 'Comparison-X', 'Comparison-Y') NULL default 'Animation',
  
  `biomoleculeAxisControl` enum('None','First','Last','Minimum','Maximum','Mean','Median') NOT NULL default 'None',
  `animationAxisControl` enum('None','First','Last','Minimum','Maximum','Mean','Median') NOT NULL default 'First',
  `comparisonXAxisControl` enum('None','First','Last','Minimum','Maximum','Mean','Median') NOT NULL default 'None',
  `comparisonYAxisControl` enum('None','First','Last','Minimum','Maximum','Mean','Median') NOT NULL default 'None',
  
  `equation` enum('Difference','Log 2 Ratio','Log 10 ratio','Ratio','Fold Change','No Equation','Raw') NOT NULL default 'Log 10 ratio',
  `dynamicRange` double NULL,
  `colormap` enum('Blue-Yellow','Green-Red','CytoBank Blue-Yellow','Grey') NOT NULL default 'CytoBank Blue-Yellow',
  
  `clusterBiomoleculeAxis` tinyint(1) NOT NULL default '0',
  `clusterAnimationAxis` tinyint(1) NOT NULL default '0',
  `clusterComparisonXAxis` tinyint(1) NOT NULL default '0',
  `clusterComparisonYAxis` tinyint(1) NOT NULL default '0',
  `optimalLeafOrder` tinyint(1) NOT NULL default '1',
  `distanceMetric` enum('Chebychev','City Block','Correlation','Cosine','Euclidean','Hamming','Jaccard','Minkowski') NOT NULL default 'Euclidean',
  `linkage` enum('Average','Complete','Single') NOT NULL default 'Average',
  PRIMARY KEY  (`networkid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-------------------------------------------
-- experiments
-------------------------------------------
CREATE TABLE `experiments` (
  `id` bigint(20) unsigned NOT NULL COMMENT 'unique per network',
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `id` (`id`),
  KEY `networkid` (`networkid`)
) ENGINE=MyISAM;

CREATE TABLE `channels` (
  `id` bigint(20) unsigned NOT NULL,
  `experimentid` bigint(20) unsigned NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`)
) ENGINE=MyISAM;

CREATE TABLE `conditions` (
  `id` bigint(20) unsigned NOT NULL,
  `experimentid` bigint(20) unsigned NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`)
) ENGINE=MyISAM;

CREATE TABLE `dosages` (
  `id` bigint(20) unsigned NOT NULL,
  `experimentid` bigint(20) unsigned NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`)
) ENGINE=MyISAM;

CREATE TABLE `individuals` (
  `id` bigint(20) unsigned NOT NULL,
  `experimentid` bigint(20) unsigned NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`)
) ENGINE=MyISAM;

CREATE TABLE `populations` (
  `id` bigint(20) unsigned NOT NULL,
  `experimentid` bigint(20) unsigned NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`)
) ENGINE=MyISAM;

CREATE TABLE `timepoints` (
  `id` bigint(20) unsigned NOT NULL,
  `experimentid` bigint(20) unsigned NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`)
) ENGINE=MyISAM;

CREATE TABLE `statistics` (
  `id` bigint(20) unsigned NOT NULL,
  `experimentid` bigint(20) unsigned NOT NULL,
  `networkid` bigint(20) unsigned NOT NULL,
  `channel` varchar(255) NOT NULL,
  `condition` varchar(255) NOT NULL,
  `dosage` varchar(255) NOT NULL,
  `individual` varchar(255) NOT NULL,
  `population` varchar(255) NOT NULL,
  `timepoint` varchar(255) NOT NULL,
  `value` double NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`),
  KEY `channel` (`channel`),
  KEY `condition` (`condition`),
  KEY `dosage` (`dosage`),
  KEY `individual` (`individual`),
  KEY `population` (`population`),
  KEY `timepoint` (`timepoint`)
) ENGINE=MyISAM;

CREATE TABLE `associations` (
  `id` bigint(20) unsigned NOT NULL COMMENT 'unique per experiment',
  `experimentid` bigint(20) unsigned NOT NULL COMMENT 'unique per network',
  `networkid` bigint(20) unsigned NOT NULL,
  `channel` varchar(255) NOT NULL,
  `biomoleculeid` bigint(20) unsigned NOT NULL,
  KEY `id` (`id`,`experimentid`,`biomoleculeid`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`),
  KEY `biomoleculeid` (`biomoleculeid`),  
  FULLTEXT KEY `channel` (`channel`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

CREATE TABLE `perturbations` (
  `id` bigint(20) NOT NULL,
  `experimentid` bigint(20) NOT NULL,
  `networkid` bigint(20) NOT NULL,
  `condition` varchar(255) NOT NULL,
  `activity` enum('Off', 'On') NOT NULL,
  `biomoleculeid` bigint(20) NOT NULL,
  KEY `id` (`id`),
  KEY `experimentid` (`experimentid`),
  KEY `networkid` (`networkid`),  
  KEY `biomoleculeid` (`biomoleculeid`),
  FULLTEXT KEY `condition` (`condition`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-------------------------------------------
-- permissions
-------------------------------------------

CREATE TABLE `permissions` (
  `networkid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  `permissions` enum('r','w','o','n','a') NOT NULL,
  KEY `networkid` (`networkid`,`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-------------------------------------------
-- users
-------------------------------------------
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `firstname` varchar(255) NOT NULL,
  `lastname` varchar(255) NOT NULL,
  `principalinvestigator` varchar(255) NOT NULL,
  `organization` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `logofferror` tinyint(1) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `email` (`email`),
  FULLTEXT KEY `name` (`firstname`, `principalinvestigator`, `organization`),
  FULLTEXT KEY `lastname` (`lastname`)
) ENGINE=MyISAM;
