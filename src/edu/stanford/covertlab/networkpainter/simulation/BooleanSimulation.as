package edu.stanford.covertlab.networkpainter.simulation 
{
	import br.com.stimuli.string.printf;
	import flash.utils.ByteArray;
	import mx.collections.ArrayCollection;
	
	/**
	 * Generates MATLAB code for a Boolean simulation of the biological network described by a diagram.
	 * 
	 * @see BooleanSimulation
	 * @see edu.stanford.covertlab.diagram.core.Diagram
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class BooleanSimulation 
	{
		[Embed(source = 'BooleanSimulation.m', mimeType='application/octet-stream')] private static const templateBinaryData:Class;
		
		public static function generateSimulation(times:Array, biomolecules:ArrayCollection, conditions:Array, 
		perturbations:Array, metaData:Object=null):String
		{
			var i:uint;
			var j:uint;
			
			if (metaData == null) metaData = { title:'', subject:'', author:'', creator:'', timestamp:'' };

			//times
			if (times == null || times.length == 0)
				times = [{name: "0'"}];
			var timesCode:Array = [];
			for (i = 0; i < times.length; i++) timesCode.push(printf("'%s'", times[i].name.replace("'", "''")));
			
			//biomolecules
			if (biomolecules == null) biomolecules = new ArrayCollection();
			var biomoleculesCode:Array = [];
			biomoleculesCode.push(printf("biomolecules = repmat(struct('name', '', 'expression', '', 'initialCondition', []), %d, 1);", biomolecules.length));
			for (i = 0; i < biomolecules.length; i++) {
				biomoleculesCode.push(printf("biomolecules(%d) = struct('name', '%s', 'expression', '%s', 'initialCondition', %d);",
					i + 1, biomolecules[i].name, (biomolecules[i].regulation =='' ? 'true' : biomolecules[i].regulation.replace('!','~')), 0));
			}
			
			//conditions
			if (conditions == null || conditions.length == 0)
				conditions = [ { 'name': 'Basal condition' } ];
			var conditionsCode:Array = [];			
			conditionsCode.push(printf("conditions = repmat(struct('name', '', 'perturbations', []), %d, 1);", conditions.length));
			for (i = 0; i < conditions.length; i++) {
				conditionsCode.push(printf("conditions(%d) = struct('name', '%s', 'perturbations', []);", i + 1, conditions[i].name));				
				var idx:uint = 0;
				var perturbationsCode:Array = [];
				for (j = 0; j < perturbations.length; j++) {
					if (perturbations[j].condition != conditions[i].name) continue;
					idx ++;
					perturbationsCode.push(printf("conditions(%d).perturbations(%d) = struct('biomolecule', '%s', 'expression', '%s');", 
						i + 1, idx, perturbations[j].biomolecule.myName, (perturbations[j].activity == 'on')));
				}
				if (idx > 0){
					conditionsCode.push(printf("conditions(%d).perturbations = repmat(struct('biomolecule', '', 'expression', ''), %d, 1);", i + 1, idx));
					conditionsCode = conditionsCode.concat(perturbationsCode);
				}
			}
			
			//insert code segments into template code
			var templateByteArray:ByteArray = new templateBinaryData();
			var templateCode:String = templateByteArray.readUTFBytes(templateByteArray.length);
			return printf(templateCode, 
				(metaData['title'] as String).replace(/\W/g, '_'),
				metaData['title'], (metaData['subject'] as String).replace(/[\r\n]+/g, "\n%    "), 
				metaData['author'], metaData['creator'], metaData['timestamp'],
				timesCode.join('; '), biomoleculesCode.join('\n'), conditionsCode.join('\n'));
		}		
	}	
}