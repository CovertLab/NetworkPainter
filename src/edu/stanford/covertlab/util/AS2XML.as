package edu.stanford.covertlab.util 
{
	
	/**
	 * Converts between XML and actionscript representation of an object. 
	 * Used by network manager to export and import networks to/from XML.
	 * 
	 * @see edu.stanford.covertlab.networkpainter.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AS2XML 
	{
		import br.com.stimuli.string.printf;
		import flash.xml.XMLDocument;
		import mx.collections.ArrayCollection;
				
		//supports very simple actionscript object to xml conversion
		public static function as2xml(object:Object,objectName:String='xml'):String		
		{
			var i:uint;
			var j:uint;
			var k:uint;
			var key:String;	
			var key2:String;
			var str:String = '';
			
			for (key in object) {
				if (object[key] is String) {
					str += printf('<%s><![CDATA[%s]]></%s>', key, object[key], key);
				}else if (object[key] is Boolean) {
					str += printf('<%s>%s</%s>', key, object[key], key);
				}else if (object[key] is Number) {
					str += printf('<%s>%f</%s>', key, object[key], key);
				}else if (object[key] is int) {
					str += printf('<%s>%d</%s>', key, object[key], key);
				}else if (object[key] is uint) {
					str += printf('<%s>%d</%s>', key, object[key], key);
				}else if (object[key] is Array || object[key] is ArrayCollection) {
					str += printf('<%s>', key);
					for (i = 0; i < object[key].length; i++) {
						str += printf('<%s ',key.substr(0,key.length-1));
						for(key2 in object[key][i]){
							if (object[key][i][key2] is String) str += printf(' %s="%s"', key2, HTML.escapeXML(object[key][i][key2]));
							else if (object[key][i][key2] is Boolean) str += printf(' %s="%s"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is Number) str += printf(' %s="%f"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is int) str += printf(' %s="%d"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is uint) str += printf(' %s="%d"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is Array) {
								str += printf(' %s="[',key2);
								for (j = 0; j < object[key][i][key2].length; j++) {
									if (object[key][i][key2][j] is Number) str += printf('%f', object[key][i][key2][j]);
									else if (object[key][i][key2][j] is uint) str += printf('%d', object[key][i][key2][j]);
									else if (object[key][i][key2][j] is int) str += printf('%d', object[key][i][key2][j]);
									else if (object[key][i][key2][j] is Boolean) str += printf('%s', object[key][i][key2][j]);
									else if (object[key][i][key2][j] is Array) {
										str += '[';
										for (k = 0; k < object[key][i][key2][j].length; k++) {
											if (object[key][i][key2][j][k] is Number) str += printf('%f', object[key][i][key2][j][k]);
											else if (object[key][i][key2][j][k] is uint) str += printf('%d', object[key][i][key2][j][k]);
											else if (object[key][i][key2][j][k] is int) str += printf('%d', object[key][i][key2][j][k]);
											else if (object[key][i][key2][j][k] is Boolean) str += printf('%s', object[key][i][key2][j][k]);
											if (k < object[key][i][key2][j].length - 1) str += ',';
										}
										str += ']';
									}
									if (j < object[key][i][key2].length - 1) str += ',';
								}
								str += ']"';
							}
						}
						str += '/>';
					}
					str += printf('</%s>', key);				
				}else if (object[key] is Object) {
					str += printf('<%s', key);
					for (key2 in object[key]) {
						if (key2 == 'id') continue;
						if (object[key][key2] is String) str += printf(' %s="%s"', key2, HTML.escapeXML(object[key][key2]));
						else if (object[key][key2] is Boolean) str += printf(' %s="%s"', key2, object[key][key2]);
						else if (object[key][key2] is Number) str += printf(' %s="%f"', key2, object[key][key2]);
						else if (object[key][key2] is int) str += printf(' %s="%d"', key2, object[key][key2]);
						else if (object[key][key2] is uint) str += printf(' %s="%d"', key2, object[key][key2]);
					}
					str += '/>';
				}
			}		
						
			var xml:XML = new XML(printf('<%s>' + str + '</%s>', objectName, objectName));
			return '<?xml version = "1.0" encoding = "UTF-8" standalone = "no"?>\n' +
				xml.toXMLString();
		}
		
		//inverts as2xml
		public static function xml2as(str:String):Object {
			var i:uint;
			var j:uint;
			var xml:XML;
			var xmlDocument:XMLDocument;
			var object:Object = { };
			var arr:Array;			
			
			xml = new XML(str);
			xmlDocument = new XMLDocument();
			xmlDocument.ignoreWhite = true;
			xmlDocument.parseXML(xml.toXMLString());

			for (i = 0; i < xmlDocument.firstChild.childNodes.length; i++) {
				if (xmlDocument.firstChild.childNodes[i].childNodes.length < 2) {
					if (xmlDocument.firstChild.childNodes[i].firstChild != null) {
						object[xmlDocument.firstChild.childNodes[i].nodeName] = xmlDocument.firstChild.childNodes[i].firstChild.nodeValue;
						// to deal with case of when there is  only one nested child but its not the value
						if (xmlDocument.firstChild.childNodes[i].firstChild.nodeValue == null) {
							object[xmlDocument.firstChild.childNodes[i].nodeName] = [xmlDocument.firstChild.childNodes[i].childNodes[0].attributes];
						}
					}
					else {
						object[xmlDocument.firstChild.childNodes[i].nodeName] = null;
					}
				}else {
					arr = [];
					for (j = 0; j < xmlDocument.firstChild.childNodes[i].childNodes.length; j++) {
						arr.push(xmlDocument.firstChild.childNodes[i].childNodes[j].attributes);
					}
					object[xmlDocument.firstChild.childNodes[i].nodeName] = arr;
				}
			}
			return object;
		}
		
	}
	
}