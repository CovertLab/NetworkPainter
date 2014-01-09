package edu.stanford.covertlab.diagram.event
{
	
	import flash.events.Event;
	
	/**
	 * Biomolecule event class. Defines two events.
	 * <ul>
	 * <li>Move -- called when biomolecule moved</li>
	 * <li>Update -- called when biomolecule color, outline, name, label, or regulation is updated</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Biomolecule
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class BiomoleculeEvent extends Event
	{
		
		public function BiomoleculeEvent(type:String) 
		{
			super(type);
		}
		
		public static const BIOMOLECULE_MOVE:String = "biomoleculeMove";
		public static const BIOMOLECULE_UPDATE:String = "biomoleculeUpdate";
	}
}