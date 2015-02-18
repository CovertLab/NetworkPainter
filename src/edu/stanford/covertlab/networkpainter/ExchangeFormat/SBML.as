package edu.stanford.covertlab.networkpainter.ExchangeFormat 
{
	import br.com.stimuli.string.printf;
	import edu.stanford.covertlab.util.HTML;
	import edu.stanford.covertlab.util.MathML;
	
	/**
	 * Supports SBML Level 2 Version 1-4 according to the following mapping:
	 *   Meta Data               -> notes
	 *   Membranes/Compartments  -> sbml:compartment, sbml:compartmenttype
	 *   Biomolecule Style       -> sbml:speciesType, networkpainter:biomoleculeStyle
	 *   Biomolecules            -> sbml:species		 
	 *   Regulation              -> sbml:assignmentRule
	 * 
	 * Support for compartmentType and speciesType were introduced with SBML Level 2 Version 2.
	 * 
	 * Recommended use of SBML export is with MATLAB SBML ToolBox (http://sbml.org/Software/SBMLToolbox).
	 * The toolbox is built on top of libSBML and supports the newest version of SBML (Level 2, Version 4)
	 * 
	 * SBML export (Level 2 Version 1) was tested with CellDesigner (http://celldesigner.org/).
	 * CellDesigner doesn't support higher versions of SBML.	
	 * 
	 * See SBML specificatons @link http://sbml.org/Documents/Specifications for more information.
	 * 
	 * @param	metaData
	 * @return	SBML string
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/3/2009
	 */
	public class SBML 
	{
		
		public static function export(network:Object, metaData:Object, version:uint = 4):String {						
			var i:uint;

			//compartment types
			var listOfCompartmentTypes:String = '';;
			if (version >= 2) {
				listOfCompartmentTypes=
					'<listOfCompartmentTypes>' +
						'<compartmentType id="compartment"/>' +
						'<compartmentType id="membrane"/>' +
					'</listOfCompartmentTypes>';
			}
			
			//compartments
			var listOfCompartments:String = '';
			for (i = 0; i < network.compartments.length; i++) {
				listOfCompartments += printf(
					'<compartment id="%s" %s %s spatialDimensions="1" size="1">' +
						'<annotation>' +
							'<networkpainter:height>%d</networkpainter:height>' +
							'<networkpainter:color>%d</networkpainter:color>' +
							'<networkpainter:membranecolor>%d</networkpainter:membranecolor>' +
							'<networkpainter:phospholipidbodycolor>%d</networkpainter:phospholipidbodycolor>' +
							'<networkpainter:phospholipidoutlinecolor>%d</networkpainter:phospholipidoutlinecolor>' +
						'</annotation>' +
					'</compartment>',
					network.compartments[i].name,(version>=2 ? 'compartmentType="compartment"' : ''),
					(i < network.compartments.length - 1 ? ' outside="' + network.compartments[i].name + '_' + network.compartments[i + 1].name + '_Membrane' + '"' : ''),					
					network.compartments[i].height, network.compartments[i].color, network.compartments[i].membranecolor,
					network.compartments[i].phospholipidbodycolor, network.compartments[i].phospholipidoutlinecolor);
			}
			
			//membranes
			for (i = 0; i < network.compartments.length-1; i++) {
				listOfCompartments += printf(
					'<compartment id="%s" %s outside="%s" spatialDimensions="1" size="1"/>',
					network.compartments[i].name + '_' + network.compartments[i + 1].name + '_Membrane', 
					(version>=2 ? 'compartmentType="membrane"' : ''),
					network.compartments[i + 1].name);
			}
				
			//biomolecule styles
			var listOfSpeciesTypes:String = '';			
			if (version >= 2) {
				listOfSpeciesTypes += '<listOfSpeciesTypes>';
				for (i = 0; i < network.biomoleculestyles.length; i++) {
					listOfSpeciesTypes += printf('<speciesType id="%s"/>',network.biomoleculestyles[i].name);
				}
				listOfSpeciesTypes += '</listOfSpeciesTypes>';
			}
			
			//biomolecule styles
			var listOfBiomoleculeStyles:String = '';
			for (i = 0; i < network.biomoleculestyles.length; i++) {
				listOfBiomoleculeStyles += printf(
					'<networkpainter:biomoleculeStyle id="%s" shape="%s" color="%d" outline="%d"/>',
					network.biomoleculestyles[i].name, network.biomoleculestyles[i].name, 
					network.biomoleculestyles[i].shape, network.biomoleculestyles[i].color, network.biomoleculestyles[i].outline);
			}
			
			
			//biomolecules
			var listOfSpecies:String = '';
			for (i = 0; i < network.biomolecules.length; i++) {				
				var style:String = '';
				style = printf(
					'<networkpainter:biomoleculeStyle>%s</networkpainter:biomoleculeStyle>' +
					'<networkpainter:label><![CDATA[%s]]></networkpainter:label>' +
					'<networkpainter:regulation><![CDATA[%s]]></networkpainter:regulation>' +
					'<networkpainter:x>%d</networkpainter:x>' +
					'<networkpainter:y>%d</networkpainter:y>',
					network.biomoleculestyles[network.biomolecules[i].biomoleculestyleid].name, network.biomolecules[i].label,network.biomolecules[i].regulation,
					network.biomolecules[i].x, network.biomolecules[i].y);
				
				listOfSpecies += printf(
					'<species metaid="biomolecule_%s" id="%s" name="%s" %s compartment="%s" substanceUnits="binary" hasOnlySubstanceUnits="true" %s>' + 
						'<annotation>' +
							'%s' +
							'<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">' +
								'<rdf:Description rdf:about="#biomolecule_%s">' +
									'<dc:Subject><![CDATA[%s]]></dc:Subject>' +
								'</rdf:Description>' +
							'</rdf:RDF>' +
						'</annotation>' +
					'</species>',				
					network.biomolecules[i].name, network.biomolecules[i].name, network.biomolecules[i].label.replace(/<\/*(sup|sub)>/g, ''), 
					(version >= 2 ? 'speciesType="' + network.biomoleculestyles[network.biomolecules[i].biomoleculestyleid].name + '"' : ''),
					(network.biomolecules[i].compartmentid % 2 == 0 ? 
						network.compartments[network.biomolecules[i].compartmentid / 2].name : 
						network.compartments[(network.biomolecules[i].compartmentid - 1) / 2].name + '_' + network.compartments[(network.biomolecules[i].compartmentid + 1) / 2].name + '_Membrane'),
					(network.biomolecules[i].regulation=='' ? 'initialAmount="false"' : ''),
					style,
					network.biomolecules[i].name, network.biomolecules[i].comments);
			}
			
			//regulation
			var listOfRules:String = '';
			for (i = 0; i < network.biomolecules.length; i++) {
				if (network.biomolecules[i].regulation == '') continue;
				listOfRules += printf(
					'<assignmentRule variable="%s">' +
						'<math xmlns="http://www.w3.org/1998/Math/MathML">' +
							'%s'+
						'</math>'+
					'</assignmentRule>',
					network.biomolecules[i].name, MathML.infix2MathML(network.biomolecules[i].regulation));
			}
			
			//edges
			var listOfEdges:String = '';			
			for (i = 0; i < network.edges.length; i++) {
				listOfEdges += printf(
					'<networkpainter:edge from="%s"  to="%s" sense="%s" path="%s"/>',
					network.biomolecules[network.edges[i].frombiomoleculeid].name, network.biomolecules[network.edges[i].tobiomoleculeid].name,
					network.edges[i].sense, network.edges[i].path);					
			}
					
			var xml:XML = new XML(printf(
				'<sbml level="2" version="%d" xmlns="http://www.sbml.org/sbml/level2" ' +
					'xmlns:dc="http://purl.org/dc/elements/1.1/" ' +
					'xmlns:networkpainter="http://covert.stanford.edu/networkpainter" '+
					'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">' +			
					'<model id="%s">' +
						'<notes>' +
							'<body xmlns="http://www.w3.org/1999/xhtml">' +
								'<p>Title: %s</p>' +
								'<p>Subject: %s</p>' +
								'<p>Author: %s</p>' +
								'<p>Creator: %s</p>' +
								'<p>Created: %s</p>' +
							'</body>' +
						'</notes>' +
						'<annotation>' +
							'<networkpainter:width>%d</networkpainter:width>' +
							'<networkpainter:height>%d</networkpainter:height>' +
							'<networkpainter:showPores>%s</networkpainter:showPores>' +
							'<networkpainter:poreFillColor>%d</networkpainter:poreFillColor>' +
							'<networkpainter:poreStrokeColor>%d</networkpainter:poreStrokeColor>' +
							'<networkpainter:membraneHeight>%f</networkpainter:membraneHeight>' +
							'<networkpainter:membraneCurvature>%f</networkpainter:membraneCurvature>' +
							'<networkpainter:minCompartmentHeight>%f</networkpainter:minCompartmentHeight>' +
							'<networkpainter:ranksep>%d</networkpainter:ranksep>' +
							'<networkpainter:nodesep>%d</networkpainter:nodesep>' +
							'<networkpainter:animationFrameRate>%f</networkpainter:animationFrameRate>' +
							'<networkpainter:loopAnimation>%d</networkpainter:loopAnimation>' +
							'<networkpainter:dimAnimation>%d</networkpainter:dimAnimation>' +
							'<networkpainter:exportShowBiomoleculeSelectedHandles>%s</networkpainter:exportShowBiomoleculeSelectedHandles>' +
							'<networkpainter:exportColorBiomoleculesByValue>%s</networkpainter:exportColorBiomoleculesByValue>' +
							'<networkpainter:exportAnimationFrameRate>%f</networkpainter:exportAnimationFrameRate>' +
							'<networkpainter:exportLoopAnimation>%d</networkpainter:exportLoopAnimation>' +
							'<networkpainter:exportDimAnimation>%d</networkpainter:exportDimAnimation>' +
							'<networkpainter:listOfBiomoleculeStyles>%s</networkpainter:listOfBiomoleculeStyles>' +
							'<networkpainter:listOfEdges>%s</networkpainter:listOfEdges>' +
						'</annotation>' +
						'<listOfUnitDefinitions>' +
							'<unitDefinition id="binary">' +
							'<listOfUnits>' +
								'<unit kind="item" multiplier="1"/>' +
							'</listOfUnits>' +
							'</unitDefinition>' +
						'</listOfUnitDefinitions>' +
						'%s' +
						'%s' +
						'<listOfCompartments>%s</listOfCompartments>' +
						'<listOfSpecies>%s</listOfSpecies>' +
						'<listOfRules>%s</listOfRules>' +						
					'</model>' +
				'</sbml>',
				version,
				HTML.escapeXML(metaData.title), metaData.title, metaData.subject, metaData.author, metaData.creator, metaData.timestamp,
				network.width, network.height, network.showPores, network.poreFillColor, network.poreStrokeColor, network.membraneHeight, network.membraneCurvature, network.minCompartmentHeight, 
				network.ranksep, network.nodesep, network.animationFrameRate, network.loopAnimation, network.dimAnimation,
				network.exportShowBiomoleculeSelectedHandles, network.exportColorBiomoleculesByValue, network.exportAnimationFrameRate, network.exportLoopAnimation, network.exportDimAnimation,
				listOfBiomoleculeStyles, listOfEdges,
				listOfCompartmentTypes, listOfSpeciesTypes, listOfCompartments, listOfSpecies, listOfRules));
			return '<?xml version="1.0" encoding="UTF-8"?>\n' + xml.toXMLString();
		}
		
	}
	
}