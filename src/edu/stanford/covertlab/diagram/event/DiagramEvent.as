package edu.stanford.covertlab.diagram.event
{
	import flash.events.Event;
	
	/**
	 * Diagram event class. Defines two events.
	 * <ul>
	 * <li>User interaction -- user manager listens to this to keep track of time of last user ativity</li>
	 * <li>Network load completes -- network manager listens to this</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Diagram
	 * @see edu.stanford.covertlab.manager.UserManager
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class DiagramEvent extends Event
	{
		
		public function DiagramEvent(type:String) 
		{
			super(type);
		}
		
		public static const USER_INTERACTION:String = "userInteraction";
		public static const LOAD_COMPLETE:String = "loadComplete";
		public static const START_LOOP:String = "startLoop";
		public static const FINISH_LOOP:String = "finishLoop";
	}
	
}