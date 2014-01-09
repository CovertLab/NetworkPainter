package edu.stanford.covertlab.diagram.history 
{
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.event.DiagramEvent;
	
	/**
	 * Controls undo, redo stacks for diagram. Classes managed by this manager
	 * must implement IHistory and use HistoryAction.
	 * 
	 * @see HistoryAction
	 * @see IHistory
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/16/2009
	 */
	public class HistoryManager 
	{	
		private static const MAX_UNDO:Number = Infinity;
		
		[Bindable] public var modified:Boolean;
		[Bindable] public var undoEnabled:Boolean;
		[Bindable] public var redoEnabled:Boolean;
		
		private var undoStack:Array;		
		private var redoStack:Array;
		private var diagram:Diagram;
		
		public function HistoryManager(diagram:Diagram) 
		{
			this.diagram = diagram;				
			clear();
		}
		
		public function clear():void {
			undoStack = [];
			redoStack = [];
			undoEnabled = false;
			redoEnabled = false;			
			modified = false;
			
			diagram.dispatchEvent(new DiagramEvent(DiagramEvent.USER_INTERACTION));
		}
		
		public function addHistoryAction(action:HistoryAction):void {
			if (diagram.loadingNetwork) return;
						
			if (undoStack.length == MAX_UNDO) undoStack.shift();
			undoStack.push(action);
			undoEnabled = true;
			redoStack = [];
			redoEnabled = false;
			modified = true;
			
			diagram.dispatchEvent(new DiagramEvent(DiagramEvent.USER_INTERACTION));
		}
		
		public function undo():void {
			if (undoStack.length == 0) return;

			var action:HistoryAction = undoStack.pop();
			var inverseAction:HistoryAction = action.entity.undoHistoryAction(action.action, action.data) as HistoryAction;
			redoStack.push(inverseAction);
			if (undoStack.length == 0) undoEnabled = false;
			if (!redoEnabled) redoEnabled = true;
			
			diagram.dispatchEvent(new DiagramEvent(DiagramEvent.USER_INTERACTION));
		}

		public function redo():void {
			if (redoStack.length == 0) return;
			var action:HistoryAction = redoStack.pop();
			var inverseAction:HistoryAction = action.entity.undoHistoryAction(action.action, action.data) as HistoryAction;
			undoStack.push(inverseAction);
			if (redoStack.length == 0) redoEnabled = false;
			if (!undoEnabled) undoEnabled = true;
			
			diagram.dispatchEvent(new DiagramEvent(DiagramEvent.USER_INTERACTION));
		}
		
	}
	
}