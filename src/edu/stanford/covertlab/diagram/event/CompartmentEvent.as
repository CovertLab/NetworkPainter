package edu.stanford.covertlab.diagram.event
{
	import flash.events.Event;
	
	/**
	 * Compartment event class. Defines one event.
	 * <ul>
	 * <li>Update -- called when compartment color, membrane color, phospholipid color, or name is changed</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Compartment
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class CompartmentEvent extends Event
	{
		
		public function CompartmentEvent(type:String) 
		{
			super(type);
		}
		
		public static const COMPARTMENT_UPDATE:String = "compartmentUpdate";		
		public static const COMPARTMENT_REMOVE:String = "compartmentRemove";		
	}
	
}