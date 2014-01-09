package edu.stanford.covertlab.diagram.history
{
	
	/**
	 * Stores information about an undo/redo command.
	 * <ul>
	 * <li>Command</li>
	 * <li>Object to which command should be applied</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Diagram
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class HistoryAction 
	{
		public var entity:Object;
		public var action:String;
		public var data:Object;
		
		public function HistoryAction(entity:Object, action:String, data:Object = null) 		
		{
			this.entity = entity;
			this.action = action;
			this.data = data;
		}
		
	}
	
}