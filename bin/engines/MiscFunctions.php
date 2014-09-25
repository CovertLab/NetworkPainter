<?php

 /**
 * Miscellaneous functions.
 * <ul>
 * <li>Establish connection to database</li> 
 * <li>Run query on database</li> 
 * <li>Parse application meta data -- help, tutorial</li> 
 * </ul>
 * 
 * @see edu.stanford.covertlab.networkpainter.data.AboutData
 * @see edu.stanford.covertlab.networkpainter.data.TutorialData
 *
 * @author Jonathan Karr, jkarr@stanford.edu
 * @author Harendra Guturu, hguturu@stanford.edu
 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
 * @lastupdated 3/27/2009
 */

set_include_path(get_include_path() . PATH_SEPARATOR . '../lib/');
 
require_once('DB.php');
require_once('XML/MXML/Parser.php');


//opens connect to MySQL database
function databaseConnect($config, $pear_db = false){
	if ($pear_db) {
		$db_connection =& DB::connect("mysqli://".$config['user'].':'.$config['password'].'@'.$config['server'].'/'.$config['database']);
		if (DB::isError($db_connection)) die($db_connection->getMessage());
		return $db_connection;
	}else{
		$db_connection = new mysqli($config['server'], $config['user'], $config['password'], $config['database']);
		if (mysqli_connect_error()){
			printf("Connect failed: %s\n", mysqli_connect_error());
			exit();
		}
		return $db_connection;
	}
}

//runs query
function runQuery($link, $sql, $dieOnError = true) {
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
  }else {
	if($dieOnError) die($link->error);
	else return array(0, $link->error);
  }
  if ($dieOnError) return $rows;
  else return array(1, $rows);
}

function parseAboutData() {	
	$parser = new XML_MXML_Parser();
	$mxml = $parser->loadFile('../src/edu/stanford/covertlab/networkpainter/data/AboutData.mxml');

	$data = array();
	$data['applicationName'] = parseMXML($mxml->getElementById('applicationName'));
	$data['version'] = parseMXML($mxml->getElementById('version'));
	$data['releaseDate'] = parseMXML($mxml->getElementById('releaseDate'));
	$data['url'] = parseMXML($mxml->getElementById('url'));
	$data['email'] = parseMXML($mxml->getElementById('email'));
	$data['description'] = parseMXML($mxml->getElementById('description'));
	$data['newStuff'] = parseMXML($mxml->getElementById('newStuff'));
	$data['infoMsg'] = parseMXML($mxml->getElementById('infoMsg'));
	$data['keywords'] = parseMXML($mxml->getElementById('keywords'));
	$data['features'] = parseMXML($mxml->getElementById('features'));
	$data['developers'] = parseMXML($mxml->getElementById('developers'));
	$data['thirdPartySoftware'] = parseMXML($mxml->getElementById('thirdPartySoftware'));
	$data['requirements'] = parseMXML($mxml->getElementById('requirements'));
	$data['acknowledgements'] = parseMXML($mxml->getElementById('acknowledgements'));
	$data['disclaimer'] = parseMXML($mxml->getElementById('disclaimer'));
	return $data;
}

function parseTutorialData() {	
	$parser = new XML_MXML_Parser();
	$mxml = $parser->loadFile('../src/edu/stanford/covertlab/networkpainter/data/TutorialData.mxml');

	$data =  parseMXML($mxml->getElementById('tutorials'));
	return $data;
}

function formatTutorialData($data,$tags,$values) {
	$toc = $content = '';
	$width = 530;
	$height = 600 / 800 * 530;
	for ($i = 0; $i < count($data); $i++) {	
		$idx = $i + 1;
		extract($data[$i]);
		$toc.= "<li><a href=\"#tutorial_$idx\">$title</a></li>\n";
		$content.= "<a name=\"tutorial_$idx\"/>\n";
		$content.= "<h3>$title</h3>\n";
		$content.= "<table class=\"tutorial\" cellpadding=\"0\" cellspacing=\"0\">\n";
		$content.= "<tr>\n";
		$content.= "  <td style=\"width:530px;padding-right:25px;\">\n";		
		$content.= "    <a href=\"?tutorial=$idx\"><img src=\"../tutorials/tutorial_0".$idx.".png\"/></a>\n"; 
		$content.= "  </td>\n";
		$content.= "  <td style=\"width:200px;\">$description</td>\n";
		$content.= "</tr>\n";
		$content.= "</table>\n";
	}

	return str_replace($tags,$values,"<h2><applicationName/> <span class=\"red\">Tutorials</span></h2><ol class=\"top\">$toc</ol>$content");
}

function parseHelpData() {
	$parser = new XML_MXML_Parser();
	$mxml = $parser->loadFile('../src/edu/stanford/covertlab/networkpainter/data/HelpData.mxml');

	$root=$mxml->getElementsByTagName('covertlab:helpsection');
	$data = parseMXML($root[0]);
	
	return $data['children'];	
}

function formatHelpData($data,$tags,$values){
	list($content, $toc) = formatHelpSections($data,$tags,$values);
	return str_replace($tags,$values,"<h2><applicationName/> <span class=\"red\">Help</span></h2>\n    <ol class=\"top\">\n$toc    </ol>\n\n$content");
}

function formatHelpSections($data,$tags,$values,$depth=0,$parentAName='') {
	$content = $toc = '';	
	foreach($data as $section) {
	    if(array_key_exists("label",$section)){
			$aName=$parentAName.preg_replace('/\W/','_',$section['label']);
			$toc.= str_repeat(' ',4*($depth+2))."<li class=\"help".($depth + 1)."\"><a href=\"#$aName\">".$section['label']."</a>";
			if($depth<2 ) $content.= str_repeat(' ',4*($depth+1))."<a name=\"$aName\"/>\n";
		}else{
			$aName='';
		}
		
		switch($depth) {
		case 0: 
			$content.= str_repeat(' ',4*($depth+1))."<br/><br/>\n";
			if(array_key_exists("label",$section)) $content.= str_repeat(' ',4*($depth+1))."<h2> ".$section["label"]." </h2>\n"; 
			break;
		case 1: 
			if(array_key_exists("label",$section)) $content.= str_repeat(' ',4*($depth+1))."<h3>".$section["label"]."</h3>\n";
			break;
		case 2: 
			if(array_key_exists("label",$section)) $content.= str_repeat(' ',4*($depth+1))."<b>".$section["label"]."</b>\n";
			break;
		default: 
			if(array_key_exists("label",$section)) $content.= str_repeat(' ',4*($depth+1)).$section["label"]."\n"; 
			break;
		}
		if (array_key_exists("content",$section) && $section['content'] != '') {
			$content.= str_repeat(' ', 4*($depth + 1));
			if (substr($section['content'], 0, 3) == '<p>') $content.= preg_replace('/\s+/',' ',str_replace(array("\r\n","\t"), " ", str_replace($tags, $values, $section['content'])));
			else $content.= "<p>".preg_replace('/\s+/', ' ', str_replace(array("\r\n", "\t"), " ", str_replace($tags, $values, $section['content'])))."</p>";
			$content.= "\n";
		}
	  
		if (array_key_exists("children",$section) && is_array($section['children']) && count($section['children']) > 0) {
			list($childrenContent, $childrenToc) = formatHelpSections($section['children'], $tags, $values, $depth + 1, $aName.'_');	
			if ($depth < 1) { 
				$toc.= "\n".str_repeat(' ',4*($depth+3))."<ol class=\"help".($depth + 3)."\">\n";
				$toc.= $childrenToc;
				$toc.= str_repeat(' ',4*($depth+2))."</ol>";
			}
			$content.= $childrenContent;
		}
		$toc.= "</li>\n";	  
	}
	return array($content, $toc);
}

function parseMXML($mxml) {
	switch($mxml->elementName) {
	case 'arraycollection':
	case 'array':
		$data = array();
		for ($i = 0; $i < count($mxml->childNodes); $i++) {
			array_push($data, parseMXML($mxml->childNodes[$i]));
		}
		break;
	case 'covertlab:helpsection':
	    $data = array();
		$data['children'] = array();
		foreach($mxml->attributes as $attribute=>$value){
			$data[$attribute] = $value;
		}
		for ($i = 0; $i < count($mxml->childNodes); $i++) {
			switch($mxml->childNodes[$i]->elementName) {
			case 'covertlab:content':
				$data['content'] = $mxml->childNodes[$i]->cdata;
				break;
			case 'covertlab:children': 
				for ($j = 0; $j < count($mxml->childNodes[$i]->childNodes); $j++) {				
					array_push($data['children'], parseMXML($mxml->childNodes[$i]->childNodes[$j])); 
				}
				break;
			}
		}
		break;
	case 'Object':
		$data = array();
		if (count($mxml->childNodes) > 0) {
			for ($i = 0; $i < count($mxml->childNodes); $i++) {
				$data[$mxml->childNodes[$i]->cdata] =
					parseMXML($mxml->childNodes[$i]);
			}
		}else {
			foreach($mxml->attributes as $attribute=>$value){
				$data[$attribute] = $value;
			}
		}
		break;
	case 'string': 
		$data = $mxml->cdata; 
		break;
	}
	return $data;
}

?>