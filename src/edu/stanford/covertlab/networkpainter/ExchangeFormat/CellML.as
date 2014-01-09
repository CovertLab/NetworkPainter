package edu.stanford.covertlab.networkpainter.ExchangeFormat 
{
	import br.com.stimuli.string.printf;
	import edu.stanford.covertlab.util.HTML;
	import edu.stanford.covertlab.util.MathML;
	
	/**
	 Supports CellML specification v1.1. Maps components by the following:
	 *   Meta Data            -> rdf
	 *   Biomolecule          -> component
	 *   Compartment/Membrane -> group
	 *   Regulation           -> connection
	 * 
	 * See CellML specification @link http://www.cellml.org/specifications/cellml_1.1/ for more information.
	 * 
	 * @param	metaData
	 * @return	CellML string
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/3/2009
	 */
	public class CellML 
	{
		
		 public static function export(network:Object, metaData:Object):String {
			var i:uint;
			var j:uint;			
			var components:String = '';
			
			//list of compartments
			for (i = 0; i < network.compartments.length; i++) {
				components += printf('<component name="%s"/>', network.compartments[i].name);
			}
			
			//list of membranes
			for (i = 0; i < network.compartments.length-1; i++) {
				components += printf('<component name="%s"/>', network.compartments[i].name + '_' + network.compartments[i + 1].name + '_Membrane');
			}
			
			//list of biomolecules
			for (i = 0; i < network.biomolecules.length; i++) {
				var variable:String = printf('<variable units="binary" public_interface="out" name="%s" initial_value="0"/>', 
					network.biomolecules[i].name);
				
				var inputs:String = '';				
				for (j = 0; j < network.edges.length; j++) {
					if (network.edges[j].tobiomoleculeid == i) {
						inputs += printf('<variable units="binary" public_interface="in" name="%s"/>', network.biomolecules[network.edges[j].frombiomoleculeid].name);
					}
				}
				
				var regulation:String = '';
				if (network.biomolecules[i].regulation != '') {
					regulation = printf(
						'<math xmlns="http://www.w3.org/1998/Math/MathML" cmeta:id="%s_regulation">' + 
							'%s'+
						'</math>', 
						network.biomolecules[i].name, MathML.infix2MathML(network.biomolecules[i].name + '=' + network.biomolecules[i].regulation,'cellml:units="binary"'));
				}
				
				components += printf(
					'<component name="%s">' +
						'<rdf:RDF>' +
							'<rdf:Description>' + 
								'<dc:Subject><![CDATA[%s]]></dc:Subject>' +
							'</rdf:Description>' +
						'</rdf:RDF>' +
						'%s' +
						'%s' +
						'%s' +
					'</component>', 
					network.biomolecules[i].name, network.biomolecules[i].comments, variable, inputs, regulation);
			}
						
			//list of biomolecules in each compartment
			var groups:String = '';
			for (i = 0; i < network.compartments.length; i++) {
				var groupComponents:String = '';
				for (j = 0; j < network.biomolecules.length; j++) {
					if (network.biomolecules[j].compartmentid == 2 * i) {
						groupComponents += printf('<component_ref component="%s"/>', network.biomolecules[j].name);
					}
				}
				
				groups += printf(
					'<group>' +
						'<relationship_ref name="%s" relationship="containment"/>' +
						'<component_ref component="%s">' +
							'%s' +
						'</component_ref>' +
					'</group>',
					network.compartments[i].name, network.compartments[i].name, groupComponents);
			}
			
			//list of biomolecules in each membrane
			for (i = 0; i < network.compartments.length-1; i++) {
				groupComponents = '';
				for (j = 0; j < network.biomolecules.length; j++) {
					if (network.biomolecules[j].compartmentid == 2 * i + 1) {						
						groupComponents += printf('<component_ref component="%s"/>', network.biomolecules[j].name);
					}
				}
				
				groups += printf(
					'<group>' +
						'<relationship_ref name="%s" relationship="containment"/>' +
						'<component_ref component="%s">' +
							'%s' +
						'</component_ref>' +
					'</group>',
					network.compartments[i].name + '_' + network.compartments[i + 1].name + '_Membrane', 
					network.compartments[i].name + '_' + network.compartments[i + 1].name + '_Membrane', 
					groupComponents);
			}
			
			//list of edges
			var connections:String = '';
			for (i = 0; i < network.edges.length; i++) {
				connections += printf(
					'<connection>' +
						'<map_components component_1="%s" component_2="%s"/>' +
						'<map_variables variable_1="%s" variable_2="%s"/>' +
					'</connection>',
					network.biomolecules[network.edges[i].frombiomoleculeid].name, network.biomolecules[network.edges[i].tobiomoleculeid].name, 
					network.biomolecules[network.edges[i].frombiomoleculeid].name, network.biomolecules[network.edges[i].frombiomoleculeid].name);
			}
						
			var xml:XML = new XML(printf(
				'<model xmlns="http://www.cellml.org/cellml/1.1#" ' +
					'xmlns:cellml="http://www.cellml.org/cellml/1.1#" ' +
					'xmlns:cmeta="http://www.cellml.org/metadata/1.0#" ' +		
					'xmlns:dc="http://purl.org/dc/elements/1.1/" ' +
					'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" ' +					
					'cmeta:id="%s" name="%s">' +
					'<rdf:RDF>' +
						'<rdf:Description rdf:about="#%s">' +
							'<dc:Title><![CDATA[%s]]></dc:Title>' +
							'<dc:Subject><![CDATA[%s]]></dc:Subject>' +
							'<dc:Contributor><![CDATA[%s]]></dc:Contributor>' +
							'<dc:Creator><![CDATA[%s]]></dc:Creator>' +
							'<dc:Date><![CDATA[%s]]></dc:Date>' +
						'</rdf:Description>' +						
					'</rdf:RDF>' +
					'<units name="binary">' +
						'<unit multiplier="1" units="dimensionless" />' +
					'</units>' +
					'%s' +
					'%s' + 
					'%s' +
				'</model>',
				metaData.title.replace(/\W/, '_'), 
				HTML.escapeXML(metaData.title), 
				metaData.title.replace(/\W/,'_'),
				metaData.title, metaData.subject, metaData.author, metaData.creator, metaData.timestamp,
				components, groups, connections));
			return '<?xml version="1.0" encoding="UTF-8"?>\n' + xml.toXMLString();			
		}
		
	}
	
}