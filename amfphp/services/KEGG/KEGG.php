<?php

class KEGG 
{	
	/**
	 * KEGG Webservice
	 *
	 * Supports two operations:
	 * 1. List reference pathways in KEGG database
	 * 2. Get a reference pathway (limited to information contained in KGML format)
	 *
	 * Sources (last downloaded from KEGG 3/22/2009)
	 * - KGML: @link ftp://ftp.genome.jp/pub/kegg/xml/map/
	 * - GIF: @link ftp://ftp.genome.jp/pub/kegg/pathway/map/
	 *
	 * References
	 * - @link http://www.genome.jp/kegg/docs/xml/ 
	 *
	 * @author Jonathan Karr
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/22/2009
	 */
	
	private $NAME 				= "KEGG";
	private $VERSION			= "1.0.0";
	
	public function KEGG()
	{	
	}
	
	/**
	 * Lists references pathways
	 */
	public function listPathways() {
		$index = file('pathways.txt');
		array_shift($index);

		$pathways = array();
		foreach($index as $line) {
			$tmp = explode("\t", $line);
			array_push($pathways,array(
				'id' => $tmp[0], 
				'name' => $tmp[1], 
				'categoryNumber' => $tmp[2], 
				'categoryName' => $tmp[3], 
				'category' => $tmp[4], 
				'lastUpdated' => $tmp[5]));
		}
		
		return $pathways;
	}
	
	/**
	 * Returns a reference pathway
	 */
	public function getPathway($id) {
		return $this->parseKGML('KGML//'.$id.'.xml');
	}
	
	/**
	 * Limitations of KGML format (illusrated by (1) http://www.genome.jp/kegg/pathway/map/map05060.html; 
	 * (2) http://www.genome.jp/kegg/pathway/map/map05111.html)
	 * - Doesn't include annotations (in KEGG illustrations these appear as plain text 
	 *   (not enclosed in any box) and may be connected to small molecules, proteins, 
	 *   pathways, etc with arrows. 
	 * - Doesn't include node names or labels; these must be found using btit operation 
	 *   over SOAP which makes the slows down the import operation. Also, as a result,
	 *   names and labels will appear differently than in KEGG illustrations.
	 * - Additionally btit doesn't return text formatting (super/subscripting) and often
	 *   returns different capitalization
	 * - Some edges are not included (ex. HSPD1->PrPc in first example)
	 * - Edge annotations are not included (ex. "?" in first example)
	 * - Doesn't include graphics other than nodes (ex. membranes in second example)
	 * - Doesn't include edge path
	 * - Doesn't include any information about style of edge (eg. dashed)
	 */
	private function parseKGML($file) {
		$xml = new DOMDocument();
		$xml->load($file);		
		
		$pathway = $xml->getElementsByTagName('pathway')->item(0);
		$pathwayid = $pathway->attributes->getNamedItem('name')->nodeValue;
		
		//compartments
		$compartments = array(
			array('name' => 'Cytoplasm', 'color' => 0xD8D8D8, 'membranecolor' => 0x989898));
		
		//biomolecule styles
		$biomoleculestyles = array(
			array('name' => 'compound', 'shape' => 'Circle', 'color' => 0x8EB4E6 , 'outline' => 0x2F74D0 ),
			array('name' => 'protein', 'shape' => 'Rectangle', 'color' => 0xFF9797 , 'outline' => 0xFF4848 ),
			array('name' => 'pathway', 'shape' => 'Rounded Rectangle', 'color' => 0x99FD77 , 'outline' => 0x48FB0D ));
		
		//biomolecules			
		$entries = $pathway->getElementsByTagName('entry');
		$biomolecules = array();
		$biomoleculeIdxs = array();
		$biomoleculeIds = array();
		$biomoleculeTypes = array();
		$biomoleculeComponents = array();
		$reactionIdxs = array();
		$entryNames = array();
		$minX = INF;
		$maxX = -INF;
		$minY = INF;
		$maxY = -INF;
		$idx = -1;
		for ($i = 0; $i < $entries->length; $i++) {			
			$names = explode(' ', $entries->item($i)->attributes->getNamedItem('name')->nodeValue);
			$id = $names[0];			
			
			if (array_search($pathwayid, $names) !== false) 
				continue;
				
			$type = $entries->item($i)->attributes->getNamedItem('type')->nodeValue;			
			if ($type == 'group')
				continue;
			
			$idx++;
			
			$reaction = $entries->item($i)->attributes->getNamedItem('reaction');			
			$graphics = $entries->item($i)->getElementsByTagName('graphics');
			if ($graphics->length > 0) {
				$graphics = $graphics->item(0);
				$width = $graphics->attributes->getNamedItem('width')->nodeValue;
				$height = $graphics->attributes->getNamedItem('height')->nodeValue;
				$x = $graphics->attributes->getNamedItem('x')->nodeValue + width / 2;
				$y = $graphics->attributes->getNamedItem('y')->nodeValue + height / 2;
			}else {
				$x = 20;
				$y = 20;
			}			
			
			switch($type) {
				case 'compound': 
					$biomoleculestyleid = 0;
					$width = $height = 20;
					break;
				case 'enzyme':
				case 'ortholog':
					$biomoleculestyleid = 1;
					$width = 20;
					$height = 15;
					break;
				case 'map': 
					$biomoleculestyleid = 2;
					$width = 20;
					$height = 15;
					break;
			}			
			$minX = min($minX, $x - $width);
			$maxX = max($maxX, $x + $width);
			$minY = min($minY, $y - $height);
			$maxY = max($maxY, $y + $height);

			if ($reaction) {
				$reaction = explode(' ', $reaction->nodeValue);
				foreach($reaction as $reactionId) {
					$reactionIdxs[$reactionId] = $idx;
				}
			}
			foreach($names as $name) {
				$entryNames[$name] = $idx;
			}
			$biomoleculeIdxs[$entries->item($i)->attributes->getNamedItem('id')->nodeValue] = $idx;
			array_push($biomoleculeIds, $id);
			array_push($biomoleculeTypes, $type);
			array_push($biomolecules, array(
				'compartmentid' => 0,
				'biomoleculestyleid' => $biomoleculestyleid,
				'name' => '',
				'label' => '',
				'regulation' => '',
				'comments' => '',
				'x' => $x,			
				'y' => $y));
				
			$components = $entries->item($i)->getElementsByTagName('component');
			$biomoleculeComponents[$idx] = array();
			for ($j = 0; $j < $components->length; $j++) {				
				array_push($biomoleculeComponents[$idx], $components->item($j)->attributes->getNamedItem('id')->nodeValue);
			}
		}
		
		//biomolecule names, labels, comments		
		$tmp = array_merge(
			file('http://rest.kegg.jp/list/compound'),
			file('http://rest.kegg.jp/list/orthology'),
			file('http://rest.kegg.jp/list/enzyme'),
			file('http://rest.kegg.jp/list/pathway')
			);
		$labels = array();
		foreach ($tmp as $line){
			list($id, $label) = explode("\t", rtrim($line));
			$id = rtrim($id);
			$label = array_shift(explode('; ', rtrim($label)));
			$labels[$id] = $label;
		}
		
		for ($i = 0; $i < count($biomolecules); $i++) {
			$id = $biomoleculeIds[$i];
			$biomolecules[$i]['name'] = str_replace(":", "_", $id);
			$biomolecules[$i]['label'] = $labels[$id];
			$biomolecules[$i]['comments'] = null;
		}
		
		//regulation
		$edges = array();
		
		//entry1->from
		//entry2->to
		$relations = $pathway->getElementsByTagName('relation');		
		for ($i = 0; $i < $relations->length; $i++) {
			$fromName = $relations->item($i)->attributes->getNamedItem('entry1')->nodeValue;
			$toName = $relations->item($i)->attributes->getNamedItem('entry2')->nodeValue;
			if (!array_key_exists($fromName, $biomoleculeIdxs) || !array_key_exists($toName, $biomoleculeIdxs)) continue;
			$frombiomoleculeid = $biomoleculeIdxs[$fromName];
			$tobiomoleculeid = $biomoleculeIdxs[$toName];

			//get sense, intermediate compounds
			$sense = true;
			$subtypes = $relations->item($i)->getElementsByTagName('subtype');
			for ($j = 0; $j < $subtypes->length; $j++) {
				$subtype = $subtypes->item($j)->attributes->getNamedItem('name')->nodeValue;
				$value = $subtypes->item($j)->attributes->getNamedItem('value')->nodeValue;
				switch($subtype) {
					case 'inhibition':
					case 'repression':
						$sense = false;
						break;
					case 'compound':
					case 'hidden compound':
						continue;
				}
			}
				
			if ($biomolecules[$tobiomoleculeid]['regulation'] != '') $biomolecules[$tobiomoleculeid]['regulation'] .= ($sense ? ' || ' : ' && ');
			$biomolecules[$tobiomoleculeid]['regulation'] .= ($sense ? '' : '!').$biomolecules[$frombiomoleculeid]['name'];				
			array_push($edges, array(
				'frombiomoleculeid' => $frombiomoleculeid,			
				'tobiomoleculeid' => $tobiomoleculeid,
				'sense' => $sense,
				'path' => ''));		
		}
		
		$reactions = $pathway->getElementsByTagName('reaction');		
		for ($i = 0; $i < $reactions->length; $i++) {
			$enzymeName = $reactions->item($i)->attributes->getNamedItem('name')->nodeValue;
			if (!array_key_exists($enzymeName, $reactionIdxs)) continue;
			$enzymebiomoleculeid = $reactionIdxs[$enzymeName];
			
			$substrates = $reactions->item($i)->getElementsByTagName('substrate');
			for ($j = 0; $j < $substrates->length; $j++) {			
				$substrateName = $substrates->item($j)->attributes->getNamedItem('name')->nodeValue;
				if (!array_key_exists($substrateName, $entryNames)) continue;
				$substratebiomoleculeid = $entryNames[$substrateName];
				if ($biomolecules[$enzymebiomoleculeid]['regulation'] != '') $biomolecules[$enzymebiomoleculeid]['regulation'] .= ' || ';
				$biomolecules[$enzymebiomoleculeid]['regulation'] .= $biomolecules[$substratebiomoleculeid]['name'];
				array_push($edges, array(
					'frombiomoleculeid' => $substratebiomoleculeid,			
					'tobiomoleculeid' => $enzymebiomoleculeid,
					'sense' => true,
					'path' => ''));
			}
			
			$products = $reactions->item($i)->getElementsByTagName('product');
			for ($j = 0; $j < $products->length; $j++) {
				$productName = $products->item($j)->attributes->getNamedItem('name')->nodeValue;
				if (!array_key_exists($productName, $entryNames)) continue;
				$productbiomoleculeid = $entryNames[$productName];
				if ($biomolecules[$productbiomoleculeid]['regulation'] != '') $biomolecules[$productbiomoleculeid]['regulation'] .= ' || ';
				$biomolecules[$productbiomoleculeid]['regulation'] .= $biomolecules[$enzymebiomoleculeid]['name'];
				array_push($edges, array(
					'frombiomoleculeid' => $enzymebiomoleculeid,
					'tobiomoleculeid' => $productbiomoleculeid,
					'sense' => true,
					'path' => ''));
			}
		}

		//pathway attributes
		$tmp = file('http://rest.kegg.jp/get/' . $pathwayid);
		foreach ($tmp as $line) {
			$attr = rtrim(substr($line, 0, 12));
			$val = rtrim(substr($line, 12));
			switch ($attr) {
				case 'NAME': $name = $val; break;
				case 'DESCRIPTION': $description = $val; break;
			}
		}
		
		//shift and scale
		$scale = 2;
		$width = $scale * ($maxX - $minX);
		$height = $scale * ($maxY - $minY);
		$compartments[0]['width'] = $width;
		$compartments[0]['height'] = $height;
		foreach($biomolecules as $idx => $biomolecule) {
			$biomolecules[$idx]['x'] = $scale * ($biomolecules[$idx]['x'] - $minX);
			$biomolecules[$idx]['y'] = $scale * ($biomolecules[$idx]['y'] - $minY);
		}		

		return array(
			'name' => $name,
			'description' => $description,		
			'width' => $width,
			'height' => $height,
			
			'compartments' => $compartments,			
			'biomoleculestyles' => $biomoleculestyles,			
			'biomolecules' => $biomolecules,			
			'edges' => $edges);
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