package edu.stanford.covertlab.util
{
	
	/**
	 * Generates an MXML representation of an actionscript object. Also contains a function
	 * for parsing MXML to an actionscript object. Used by network manager to generate
	 * MXML representation of network for compilation with viewer.
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * @see edu.stanford.covertlab.networkpainter.Viewer
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AS2MXML 
	{
		import br.com.stimuli.string.printf;
		import flash.xml.XMLDocument;
		import mx.collections.ArrayCollection;
		import mx.controls.Alert;
		
		//supports very simple actionscript object to mxml object conversion
		public static function as2mxml(object:Object):String		
		{
			var i:uint;
			var j:uint;
			var k:uint;
			var key:String;	
			var key2:String;
			var str:String = '';
			
			for (key in object) {
				if (object[key] is String) {
					str += printf('<mx:String id="%s"><![CDATA[%s]]></mx:String>', key, object[key]);
				}else if (object[key] is Boolean) {
					str += printf('<mx:Boolean id="%s">%s</mx:Boolean>', key, object[key]);
				}else if (object[key] is Number) {
					str += printf('<mx:Number id="%s">%f</mx:Number>', key, object[key]);
				}else if (object[key] is int) {
					str += printf('<mx:Number id="%s">%d</mx:Number>', key, object[key]);
				}else if (object[key] is uint) {
					str += printf('<mx:Number id="%s">%d</mx:Number>', key, object[key]);
				}else if (object[key] is Array || object[key] is ArrayCollection) {
					str += printf('<mx:Array id="%s">', key);
					for (i = 0; i < object[key].length; i++) {
						str += '<mx:Object';
						for(key2 in object[key][i]){
							if (object[key][i][key2] is String) str += printf(' %s="%s"', key2, HTML.escapeXML(object[key][i][key2]));
							else if (object[key][i][key2] is Boolean) str += printf(' %s="%s"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is Number) str += printf(' %s="%f"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is int) str += printf(' %s="%d"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is uint) str += printf(' %s="%d"', key2, object[key][i][key2]);
							else if (object[key][i][key2] is Array) {
								str += printf(' %s="{[',key2);
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
								str += ']}"';
							}							
						}
						str += '/>';
					}
					str += '</mx:Array>';
				}else if (object[key] is Object) {
					str += printf('<mx:Object id="%s"', key);
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

			var xml:XML = new XML('<mx:Object xmlns:mx="http://www.adobe.com/2006/mxml">' + str + '</mx:Object>');			
			return '<?xml version = "1.0" encoding = "UTF-8" standalone = "no"?>\n' +
				xml.toXMLString();
		}		
		
		public static function array2mxml(arr:Array, depth:uint=0):String		
		{
			var str:Array = [];
			for (var i:uint = 0; i < arr.length; i++) {
				if (arr[i] is Array) str.push(array2mxml(arr[i], depth + 1));
				else str.push(arr[i]);
			}
			
			if(depth==0){
				var xml:XML = new XML('<mx:Object xmlns:mx="http://www.adobe.com/2006/mxml"><mx:Object id="arr" value="{[' + str.join(',') + ']}"/></mx:Object>');			
				return '<?xml version = "1.0" encoding = "UTF-8" standalone = "no"?>\n' +
					xml.toXMLString();
			}else {
				return '[' + str.join(',') + ']';
			}
		}
		
		//inverts as2mxml
		public static function mxml2as(str:String):Object {
			var i:uint;
			var j:uint;
			var key:String;
			var xml:XML;
			var xmlDocument:XMLDocument;
			var object:Object = { };
			var attributes:Object;
			var arr:Array;			

			xml = new XML(str);
			xmlDocument = new XMLDocument();
			xmlDocument.ignoreWhite = true;
			xmlDocument.parseXML(xml.toXMLString());
			
			for (i = 0; i < xmlDocument.firstChild.childNodes.length; i++) {
				switch(xmlDocument.firstChild.childNodes[i].localName) {
					case 'String':
						object[xmlDocument.firstChild.childNodes[i].attributes.id] = String(xmlDocument.firstChild.childNodes[i].firstChild.nodeValue);
						break;
					case 'Number':
						object[xmlDocument.firstChild.childNodes[i].attributes.id] = Number(xmlDocument.firstChild.childNodes[i].firstChild.nodeValue);
						break;
					case 'Boolean':
						object[xmlDocument.firstChild.childNodes[i].attributes.id] = Boolean(xmlDocument.firstChild.childNodes[i].firstChild.nodeValue);
						break;
					case 'Array':
						arr = [];
						for (j = 0; j < xmlDocument.firstChild.childNodes[i].childNodes.length;j++){
							arr.push(xmlDocument.firstChild.childNodes[i].childNodes[j].attributes);
						}
						object[xmlDocument.firstChild.childNodes[i].attributes.id] = arr;
						break;
					case 'Object':
						attributes = xmlDocument.firstChild.childNodes[i].attributes;
						object[xmlDocument.firstChild.childNodes[i].attributes.id] = attributes;						
						break;
				}
			}
			return object;
		}
		
	}
	
}