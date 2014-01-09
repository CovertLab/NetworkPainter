<?php

class Reactome 
{	
	/**
	 * Reactome Webservice
	 *
	 * Supports two operations:
	 * 1. List pathways in Reactome database
	 * 2. Get a pathway in the Reactome database by its id.
	 *
	 * See @link http://www.reactome.org/download/index.html for documentation on Reactome SOAP Web Service.
	 *
	 * @author Jonathan Karr
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/20/2009
	 */
	
	private $NAME 				= "Reactome";
	private $VERSION			= "1.0.0";

	private $ReactomeClient;
	
	public function Reactome()
	{
		$this->ReactomeClient=new SoapClient("http://www.reactome.org:8080/caBIOWebApp/services/caBIOService?wsdl");	
	}
	
	/** Lists several properties of each pathway:
	 *	- compartment
	 *	- evidenceType
	 *	- goBiologicalProcess
	 *	- hasComponent
	 *	- id
	 *	- inferredFrom
	 *	- literatureReference
	 *	- name = "3' -UTR-mediated translational regulation"
	 *	- orthologousEvent
	 *	- precedingEvent
	 *	- species
	 *	- summation
	 */
	public function listPathways() {
		$pathwaysVerbose = $this->ReactomeClient->listTopLevelPathways();
		
		$pathwaysCompact = array();
		foreach($pathwaysVerbose as $pathwayVerbose) {
			array_push($pathwaysCompact, array('id' => $pathwayVerbose-> id, 'name' => $pathwayVerbose-> name));
		}
		
		return $pathwaysCompact;
	}
	
	/**
	 */
	public function getPathway($id) {
		return $this->ReactomeClient->queryById($id);
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