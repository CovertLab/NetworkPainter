package edu.stanford.covertlab.diagram.event
{
	import flash.events.Event;
	
	/**
	 * Biomolecule style event class. Defines three events.
	 * <ul>
	 * <li>Add -- called when style is added to diagram</li>
	 * <li>Update -- called when color, outline, or shaped is changed</li>
	 * <li>Remove -- called when style is deleted</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.diagram.core.BiomoleculeStyle
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class BiomoleculeStyleEvent extends Event
	{
		
		public function BiomoleculeStyleEvent(type:String) 
		{
			super(type);
		}
		
		public static const BIOMOLECULE_STYLE_UPDATE:String = "biomoleculeStyleUpdate";
		public static const BIOMOLECULE_STYLE_ADD:String = "biomoleculeStyleAdd";
		public static const BIOMOLECULE_STYLE_REMOVE:String = "biomoleculeStyleRemove";
		
	}
	
}