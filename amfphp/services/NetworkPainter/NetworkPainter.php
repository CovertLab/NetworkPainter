<?php

class NetworkPainter 
{	
	/**
	 * NetworkPainter Webservice
	 *
	 * Supports several operations:
	 * <ul>
	 * <li>List networks available to a user</li>
	 * <li>Get details for a network, including preview image</li>
	 * <li>Get user permissions on a network</li>
	 * <li>Save a new network</li>
	 * <li>Update a network, including a png preview</li>
	 * <li>Save basic properties of a network</li>
	 * <li>Load a network</li>
	 * <li>Renew, clear network locks</li>
	 * <li>Delete a network</li>
	 * </ul>
	 *
	 * @author Jonathan Karr
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/30/2009
	 */
	
	private $NAME 				= "NetworkPainter";
	private $VERSION			= "1.0.0";
	
	public function NetworkPainter()
	{			
	}
	
	/** 
	 * Get allowed networks
	 */
	public function listNetworks($userid) {
		$sql = "CALL getallowednetworks($userid)";
		return $this->getResultSet($sql);
	}
	
	/** 
	 * Get network details
	 */
	public function getNetworkDetails($userid, $networkid) {
		$sql = "CALL getnetwork($networkid, $userid);";
		$network = array_shift($this->runQuery($sql));
		$network['animationFrameRate'] = (float) $network['animationFrameRate'];
		$network['exportAnimationFrameRate'] = (float) $network['exportAnimationFrameRate'];
		$network['exportColorBiomoleculesByValue'] = (bool) $network['exportColorBiomoleculesByValue'];
		$network['exportLoopAnimation'] = (bool) $network['exportLoopAnimation'];
		$network['exportShowBiomoleculeSelectedHandles'] = (bool) $network['exportShowBiomoleculeSelectedHandles'];
		$network['height'] = (int) $network['height'];
		$network['id'] = (int) $network['id'];
		$network['locked'] = (bool) $network['locked'];
		$network['lockuserid'] = (int) $network['lockuserid'];
		$network['loopAnimation'] = (bool) $network['loopAnimation'];
		$network['membraneCurvature'] = (float) $network['membraneCurvature'];
		$network['membraneHeight'] = (float) $network['membraneHeight'];
		$network['minCompartmentHeight'] = (float) $network['minCompartmentHeight'];
		$network['networkid'] = (int) $network['networkid'];
		$network['nodesep'] = (float) $network['nodesep'];
		$network['poreFillColor'] = (int) $network['poreFillColor'];
		$network['poreStrokeColor'] = (int) $network['poreStrokeColor'];
		$network['ranksep'] = (float) $network['ranksep'];
		$network['showPores'] = (bool) $network['showPores'];
		$network['width'] = (int) $network['width'];
		$network['preview'] = new ByteArray($network['preview']);		
		return $network;
	}
	
	/** 
	 * Get network permissions
	 */
	public function getNetworkPermissions($networkid) {
		$sql = "CALL getnetworkpermissions($networkid)";
		return $this->getResultSet($sql);
	}
	
	/** 
	 * Save a new network
	 */
	public function saveAsNetwork($userid, $name, $description, $publicstatus, $width, $height, $showPores, 
	$poreFillColor, $poreStrokeColor, $membraneHeight, $membraneCurvature, $minCompartmentHeight, $ranksep, $nodesep, 
	$animationFrameRate, $loopAnimation, $exportShowBiomoleculeSelectedHandles, $exportColorBiomoleculesByValue, 
	$exportAnimationFrameRate, $exportLoopAnimation) {
		$name = mysql_escape_string($name);
		$description = mysql_escape_string($description);
		$showPores += 0;
		$exportShowBiomoleculeSelectedHandles += 0;
		$exportColorBiomoleculesByValue += 0;
		$sql = "CALL savenewnetwork($userid, '$name', '$description', '$publicstatus', $width, $height, $showPores,".
				"$poreFillColor, $poreStrokeColor, $membraneHeight, $membraneCurvature, $minCompartmentHeight, ".
				"$ranksep, $nodesep, $animationFrameRate, $loopAnimation,".
				"$exportShowBiomoleculeSelectedHandles, $exportColorBiomoleculesByValue,".
				"$exportAnimationFrameRate, $exportLoopAnimation, false)";
		$result = $this->runQuery($sql);		
		return (int) $result[0]['id'];
	}
	
	/**
	 * Updates a network
	 */
	public function updateNetwork($networkid, $userid, $network, $preview) {
		extract($network);
		$showPores += 0;
		$exportShowBiomoleculeSelectedHandles += 0;
		$exportColorBiomoleculesByValue += 0;
		$description = mysql_escape_string($description);
		$sql  = "CALL updatenetwork($networkid, '$description', '$publicstatus',".
					($preview == null ? 'null' : "'".mysql_escape_string($preview->data)."'").", ".
					"$width, $height, $showPores, $poreFillColor, $poreStrokeColor,".
					"$membraneHeight, $membraneCurvature, $minCompartmentHeight, $ranksep, $nodesep, $animationFrameRate, $loopAnimation,".
					"$exportShowBiomoleculeSelectedHandles, $exportColorBiomoleculesByValue, $exportAnimationFrameRate, $exportLoopAnimation);";
		$sql .= "CALL renewnetworklock($userid, $networkid);";
		$sql .= "CALL dropedges($networkid);";
		$sql .= "CALL dropbiomolecules($networkid);";
		$sql .= "CALL dropcompartments($networkid);";
		$sql .= "CALL dropbiomoleculestyles($networkid);";
		
		for ($j = 0; $j < count($biomoleculestyles); $j++) {
			extract(array_map('mysql_escape_string', $biomoleculestyles[$j]));
			$sql .= "CALL addbiomoleculestyles($networkid, $j, '$name', '$shape', $color, $outline);";
		}

		for ($j = 0; $j < count($compartments); $j++) {
			extract(array_map('mysql_escape_string', $compartments[$j]));
			$sql .= "CALL addcompartments($networkid, $j, '$name', $color, $membranecolor, $phospholipidbodycolor, $phospholipidoutlinecolor, $height);";
		}

		for ($j = 0; $j < count($biomolecules); $j++) {
			extract(array_map('mysql_escape_string', $biomolecules[$j]));
			$sql .= "CALL addbiomolecules($networkid, $j, '$name', '$label', '$regulation', '$comments', $x, $y, $biomoleculestyleid, $compartmentid);";
		}

		for ($j = 0; $j < count($edges); $j++) {
			extract(array_map('mysql_escape_string', $edges[$j]));
			$sense += 0;
			$sql .= "CALL addedges($networkid, $j, $frombiomoleculeid, $tobiomoleculeid, $sense, '$path');";
		}

		$sql .="CALL updatelastsave($networkid);";
		
		$this->runQuery($sql);
	}
	
		
	/** 
	 * Save network properties 
	 */
	public function saveNetworkProperties($networkid, $name, $description, $publicStatus, $networkPermissions, $permissions) {
		$name = mysql_escape_string($name);
		$description = mysql_escape_string($description);		
		$sql = "CALL updatenetworkproperties($networkid ,'$name','$description','$publicStatus');";
		if ($networkPermissions == 'o') {
			$sql .= "CALL dropnetworkpermissions($networkid);";
			for ($i = 0; $i < count($permissions); $i++) {
				if ($permissions[$i]['permissions'] != 'n') {
					$sql .= "CALL grantnetworkpermissions($networkid,".$permissions[$i]['userid'].",'".$permissions[$i]['permissions']."');";
				}
			}
		}
		$this->runQuery($sql);
	}
	
	/** 
	 * Open network
	 */
	public function loadNetwork($userid, $networkid) {	
		return $this->getNetworkDetails($userid, $networkid);
	}
	 
	public function loadNetworkBiomoleculestyles($userid, $networkid) {	
		$sql = "CALL getbiomoleculestyles($networkid, $userid)";
		return $this->getResultSet($sql);		
	}
	
	public function loadNetworkCompartments($userid, $networkid) {	
		$sql = "CALL getcompartments($networkid, $userid)";
		return $this->getResultSet($sql);
	}
	
	public function loadNetworkBiomolecules($userid, $networkid) {	
		$sql = "CALL getbiomolecules($networkid, $userid)";
		return $this->getResultSet($sql);
	}
	
	public function loadNetworkEdges($userid, $networkid) {	
		$sql = "CALL getedges($networkid, $userid)";
		return $this->getResultSet($sql);
	}
	
	/** 
	 * Renew network lock
	 */
	public function renewNetworkLock($userid,$networkid) {
		$sql = "CALL renewnetworklock($userid, $networkid)";
		$this->runQuery($sql);
	}
	
	/** 
	 * Clear network lock
	 */
	public function clearNetworkLock($networkid) {
		$sql = "CALL clearnetworklock($networkid)";
		$this->runQuery($sql);
	}
	
	/** 
	 * Delete network
	 */
	public function deleteNetwork($networkid) {
		$sql = "CALL deletenetwork($networkid)";
		$this->runQuery($sql);
	}
	
	/**
	 * Experiments
	 */
	public function getExperiments($networkId) {
		//get axis properties
		$axes = array_shift($this->runQuery("SELECT * FROM axes WHERE networkid=$networkId"));
		
		//type cast axis properties
		$axes['dynamicRange']           = ($axes['dynamicRange'] ? (float) $axes['dynamicRange'] : NAN);		
		$axes['clusterBiomoleculeAxis'] = (bool) $axes['clusterBiomoleculeAxis'];
		$axes['clusterAnimationAxis']   = (bool) $axes['clusterAnimationAxis'];
		$axes['clusterComparisonXAxis'] = (bool) $axes['clusterComparisonXAxis'];
		$axes['clusterComparisonYAxis'] = (bool) $axes['clusterComparisonYAxis'];
		$axes['optimalLeafOrder']       = (bool) $axes['optimalLeafOrder'];
		
		//retrieve experiments
		$experiments = $this->runQuery("SELECT * FROM experiments WHERE networkid=$networkId ORDER BY id");
		foreach ($experiments as $iExperiment => $experiment) {
			$experimentId = $experiment['id'];
			$experiment['channels']      = $this->runQuery("SELECT * FROM channels      WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['conditions']    = $this->runQuery("SELECT * FROM conditions    WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['dosages']       = $this->runQuery("SELECT * FROM dosages       WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['individuals']   = $this->runQuery("SELECT * FROM individuals   WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['populations']   = $this->runQuery("SELECT * FROM populations   WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['timepoints']    = $this->runQuery("SELECT * FROM timepoints    WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['statistics']    = $this->runQuery("SELECT * FROM statistics    WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['associations']  = $this->runQuery("SELECT * FROM associations  WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");
			$experiment['perturbations'] = $this->runQuery("SELECT * FROM perturbations WHERE networkid=$networkId && experimentid = $experimentId ORDER BY id");			
			
			foreach($experiment['statistics'] as $iStatistic => $statistic){
				$experiment['statistics'][$iStatistic]['value'] = (float) $statistic['value'];
			}
			
			$experiments[$iExperiment] = $experiment;
		}
		
		return array_merge($axes, array('experiments' => $experiments));
	}
	
	public function setExperiments($networkId, $data){
		//cleanup
		$this->runQuery("CALL dropaxes($networkId);");
		$this->runQuery("CALL dropexperiments($networkId);");
		
		//update axes
		$sqlTemplate = <<<SQL
		INSERT INTO axes(
			networkid,
			channelAxis, conditionAxis, dosageAxis, individualAxis, populationAxis, timepointAxis,
			biomoleculeAxisControl, animationAxisControl, comparisonXAxisControl, comparisonYAxisControl,
			equation, dynamicRange, colormap,
			clusterBiomoleculeAxis, clusterAnimationAxis, clusterComparisonXAxis, clusterComparisonYAxis,
			optimalLeafOrder, distanceMetric, linkage
			)
		VALUES (
			%d,
			%s, %s, %s, %s, %s, %s,
			'%s', '%s', '%s', '%s',
			'%s', %s, '%s',
			%d, %d, %d, %d,
			%d, '%s', '%s');
SQL;
	
		$sql = sprintf($sqlTemplate, $networkId,
			($data['channelAxis']    ? "'".$data['channelAxis']."'"    : "null"), 
			($data['conditionAxis']  ? "'".$data['conditionAxis']."'"  : "null"), 
			($data['dosageAxis']     ? "'".$data['dosageAxis']."'"     : "null"), 
			($data['individualAxis'] ? "'".$data['individualAxis']."'" : "null"), 
			($data['populationAxis'] ? "'".$data['populationAxis']."'" : "null"), 
			($data['timepointAxis']  ? "'".$data['timepointAxis']."'"  : "null"), 
			$data['biomoleculeAxisControl'], 
			$data['animationAxisControl'], 
			$data['comparisonXAxisControl'], 
			$data['comparisonYAxisControl'],
			$data['equation'], 
			(is_nan($data['dynamicRange']) ? "null" : sprintf('%f', $data['dynamicRange'])), 
			$data['colormap'],
			$data['clusterBiomoleculeAxis'], 
			$data['clusterAnimationAxis'], 
			$data['clusterComparisonXAxis'], 
			$data['clusterComparisonYAxis'],
			$data['optimalLeafOrder'], $data['distanceMetric'], $data['linkage']);		
		$this->runQuery($sql);
			
		//update experiments
		foreach ($data['experiments'] as $iExperiment => $experiment) {
			$this->runQuery(sprintf("INSERT INTO experiments (id, networkid, name) VALUES ($iExperiment, $networkId, '%s')", mysql_escape_string($experiment['name'])));
			
			foreach ($experiment['channels'] as $iChannel => $channel)
				$this->runQuery(sprintf("INSERT INTO channels (id, experimentid, networkid, name) VALUES ($iChannel, $iExperiment, $networkId, '%s')", mysql_escape_string($channel['name'])));
			foreach ($experiment['conditions'] as $iCondition => $condition)
				$this->runQuery(sprintf("INSERT INTO conditions (id, experimentid, networkid, name) VALUES ($iCondition, $iExperiment, $networkId, '%s')", mysql_escape_string($condition['name'])));
			foreach ($experiment['dosages'] as $iDosage => $dosage)
				$this->runQuery(sprintf("INSERT INTO dosages (id, experimentid, networkid, name) VALUES ($iDosage, $iExperiment, $networkId, '%s')", mysql_escape_string($dosage['name'])));
			foreach ($experiment['individuals'] as $iIndividual => $individual)
				$this->runQuery(sprintf("INSERT INTO individuals (id, experimentid, networkid, name) VALUES ($iIndividual, $iExperiment, $networkId, '%s')", mysql_escape_string($individual['name'])));
			foreach ($experiment['populations'] as $iPopulation => $population)
				$this->runQuery(sprintf("INSERT INTO populations (id, experimentid, networkid, name) VALUES ($iPopulation, $iExperiment, $networkId, '%s')", mysql_escape_string($population['name'])));
			foreach ($experiment['timepoints'] as $iTimepoint => $timepoint)
				$this->runQuery(sprintf("INSERT INTO timepoints (id, experimentid, networkid, name) VALUES ($iTimepoint, $iExperiment, $networkId, '%s')", mysql_escape_string($timepoint['name'])));
							
			foreach ($experiment['statistics'] as $iStatistic => $statistic){
				$sql = sprintf(
					"INSERT INTO statistics (id, experimentid, networkid, channel, `condition`, dosage, individual, population, timepoint, `value`) ".
					"VALUES ($iStatistic, $iExperiment, $networkId, '%s', '%s', '%s', '%s', '%s', '%s', %f)", 
					mysql_escape_string($statistic['channel']), 
					mysql_escape_string($statistic['condition']), 
					mysql_escape_string($statistic['dosage']), 
					mysql_escape_string($statistic['individual']), 
					mysql_escape_string($statistic['population']), 
					mysql_escape_string($statistic['timepoint']), 
					$statistic['value']);
				$this->runQuery($sql);
			}
			
			foreach ($experiment['associations'] as $iAssociation => $association)
				$this->runQuery(sprintf("INSERT INTO associations (id, experimentid, networkid, channel, biomoleculeid) VALUES ($iAssociation, $iExperiment, $networkId, '%s', %d)", mysql_escape_string($association['channel']), $association['biomoleculeid']));
			foreach ($experiment['perturbations'] as $iPerturbation => $perturbation)
				$this->runQuery(sprintf("INSERT INTO perturbations (id, experimentid, networkid, `condition`, activity, biomoleculeid) VALUES ($iPerturbation, $iExperiment, $networkId, '%s', '%s', %d)", mysql_escape_string($perturbation['condition']), $perturbation['activity'], $perturbation['biomoleculeid']));
		}
	}
	
	/** 
	 * helper functions
	 */
	private function runQuery($sql){
        $link = new mysqli('localhost', 'networkpainter', 'networkpainter', 'networkpainter');
		if (mysqli_connect_error()) die(mysqli_connect_error());
		
		$rows = array();
		if ($link->multi_query($sql)){
			do{
				if ($result = $link->store_result()) {
					while ($row = $result->fetch_assoc()) {
						array_push($rows,$row);
					}
					$result->free();
				}
			} while ($link->next_result());
		}else{
			die($link->error);
		}
		
		$link->close();
		return $rows;
	}
	
	private function getResultSet($sql){		
        $link = @mysql_connect('localhost', 'networkpainter', 'networkpainter', 0, 65536) or die(mysql_error());
		mysql_select_db('networkpainter', $link) or die(mysql_error($link));
		$result = mysql_query($sql, $link);
		
		if(!$result) return mysql_error($link);
		if(($lastInsertID = mysql_insert_id($link)) != 0) return $lastInsertID;
	
		@mysql_close($link);
		return $result;
	}

	/**
     * Class name.
     * @returns a string that reprezent class name.
     */
	public function getName()
	{
		return $this->NAME;
	}
	
	/**
     * Class version.
     * @returns a string that reprezent class version.
     */
	public function getVersion()
	{
		return $this->VERSION;
	}
}

?>
