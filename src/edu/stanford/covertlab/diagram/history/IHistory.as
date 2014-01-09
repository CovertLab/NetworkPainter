package edu.stanford.covertlab.diagram.history 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public interface IHistory
	{		
		function undoHistoryAction(action:String, data:Object):HistoryAction;
		
	}
	
}