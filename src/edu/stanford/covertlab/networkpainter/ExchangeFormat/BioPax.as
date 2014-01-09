package edu.stanford.covertlab.networkpainter.ExchangeFormat 
{
	import br.com.stimuli.string.printf;
	import edu.stanford.covertlab.util.HTML;
	
	/**
	 * Supports BioPax Level 3, Version 0.92 according to the following mapping:
	 *   Meta Data               -> rdf
	 *   Membranes/Compartments  -> cellular location vocabulary
	 *   Biomolecule Style       -> entity reference group vocabulary
	 *   Biomolecules            -> physical entity		 
	 *   Regulation              -> control
	 * 
	 * See BioPax specificatons @link http://www.biopax.org/ for more information.
	 * 
	 * @param	metaData
	 * @return	BioPax string
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/3/2009
	 */
	public class BioPax 
	{
		
		public static function export(network:Object, metaData:Object):String {			
			var i:uint;
			
			var cellularLocations:String = '';
			for (i = 0; i < network.compartments.length; i++) {
				cellularLocations += printf('<bp:CellularLocationVocabulary rdf:ID="%s"/>', network.compartments[i].name);
			}
			for (i = 0; i < network.compartments.length-1; i++) {
				cellularLocations += printf('<bp:CellularLocationVocabulary rdf:ID="%s"/>', network.compartments[i].name + '_' + network.compartments[i + 1].name + '_Membrane');
			}
						
			var entityReferences:String = '';
			for (i = 0; i < network.biomoleculestyles.length; i++) {
				entityReferences += printf('<bp:EntityReferenceGroupVocabulary rdf:ID="%s"/>', network.biomoleculestyles[i].name);
			}
						
			var physicalEntities:String = '';
			for (i = 0; i < network.biomolecules.length; i++) {
				physicalEntities += printf(
					'<bp:PhysicalEntity rdf:ID="%s">' +
						'<bp:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string">%s</bp:name>' +					
						'<bp:referenceEntity rdf:resource="#%s"/>' +
						'<bp:cellularLocation rdf:resource="#%s"/>' +
						'<bp:comment rdf:datatype="http://www.w3.org/2001/XMLSchema#string">%s</bp:comment>' +
					'</bp:PhysicalEntity>',
					network.biomolecules[i].name, HTML.escapeXML(network.biomolecules[i].label.replace(/<\/*(sup|sub)>/g, '')) ,
					network.biomoleculestyles[network.biomolecules[i].biomoleculestyleid].name, 
					(network.biomolecules[i].compartmentid % 2 == 0 ? 
						network.compartments[network.biomolecules[i].compartmentid / 2].name : 
						network.compartments[(network.biomolecules[i].compartmentid - 1) / 2].name + '_' + network.compartments[(network.biomolecules[i].compartmentid + 1) / 2].name + '_Membrane'),						
					network.biomolecules[i].comments);
			}
				
			var controls:String = '';
			for (i = 0; i < network.edges.length; i++) {
				controls += printf(
					'<bp:Control rdf:ID="%s">' +
						'<bp:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string">%s</bp:name>' +
						'<bp:controller rdf:resource="#%s"/>' +
						'<bp:controlled rdf:resource="#%s"/>' +
						'<bp:controlType rdf:datatype="http://www.w3.org/2001/XMLSchema#string">%s</bp:controlType>' +
					'</bp:Control>',
					network.biomolecules[network.edges[i].frombiomoleculeid].name + '_' + network.biomolecules[network.edges[i].tobiomoleculeid].name,
					network.biomolecules[network.edges[i].frombiomoleculeid].name + (network.edges[i].sense ? ' -> ' : ' -| ') + network.biomolecules[network.edges[i].tobiomoleculeid].name,
					network.biomolecules[network.edges[i].frombiomoleculeid].name, network.biomolecules[network.edges[i].tobiomoleculeid].name, (network.edges[i].sense ? 'ACTIVATION' : 'INHIBITION'));
			}		
			
			var xml:XML = new XML(printf(
				'<rdf:RDF xmlns="http://www.reactome.org/biopax#" '+					
					'xmlns:bp="http://www.biopax.org/release/biopax-level3.owl#" ' +
					'xmlns:dc="http://purl.org/dc/elements/1.1/" ' +
					'xmlns:owl="http://www.w3.org/2002/07/owl#" '+
					'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">' +
					'<owl:Ontology rdf:about="">'+
						'<owl:imports rdf:resource="http://www.biopax.org/release/biopax-level3.owl" />'+
					'</owl:Ontology>' +
					'<rdf:Description>' +
						'<dc:Title><![CDATA[%s]]></dc:Title>' +
						'<dc:Subject><![CDATA[%s]]></dc:Subject>' +
						'<dc:Contributor><![CDATA[%s]]></dc:Contributor>' +
						'<dc:Creator><![CDATA[%s]]></dc:Creator>' +
						'<dc:Date><![CDATA[%s]]></dc:Date>' +
					'</rdf:Description>' +
					'%s' +
					'%s' +
					'%s' +
					'%s' +
				'</rdf:RDF>',
				metaData.title, metaData.subject, metaData.author, metaData.creator, metaData.timestamp,
				cellularLocations, entityReferences, physicalEntities, controls));

			var xmlString:String = xml.toXMLString();
			xmlString = xmlString.substr(0, xmlString.indexOf('>')) + 
				' xml:base="http://www.reactome.org/biopax"' + 
				xmlString.substr(xmlString.indexOf('>'), xmlString.length - xmlString.indexOf('>'));			
			return '<?xml version="1.0" encoding="UTF-8"?>\n' + xmlString;			
		}
		
	}
	
}