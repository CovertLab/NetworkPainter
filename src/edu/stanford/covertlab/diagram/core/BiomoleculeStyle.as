package edu.stanford.covertlab.diagram.core 
{
	import br.com.stimuli.string.printf;
	import edu.stanford.covertlab.diagram.event.BiomoleculeStyleEvent;
	import edu.stanford.covertlab.diagram.history.HistoryAction;
	import edu.stanford.covertlab.diagram.history.IHistory;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	/**
	 * Rendering style object for biomolecules. Has shape, color, and outline attributes.
	 * Edited through the BiomoleculeStylesPanel.
	 * 
	 * @see Biomolecule
	 * @see edu.stanford.covertlab.diagram.event.BiomoleculeStyleEvent
	 * @see edu.stanford.covertlab.diagram.panel.StylesPanel
	 * @see edu.stanford.covertlab.diagram.window.EditBiomoleculeStyleWindow
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class BiomoleculeStyle extends EventDispatcher implements IHistory
	{
		private var diagram:Diagram;
		private var _myName:String;
		private var _myShape:String;
		private var _myColor:uint;
		private var _myOutline:uint;
		
		public function BiomoleculeStyle(diagram:Diagram, myName:String = '', myShape:String = '', 
		myColor:uint = 0, myOutline:uint = 0)		
		{
			//properties
			this.diagram = diagram;
			this.myName = myName;
			this.myShape = myShape;
			this.myColor = myColor;
			this.myOutline = myOutline;
			
			diagram.addBiomoleculeStyle(this);	
			
			//undo
			diagram.historyManager.addHistoryAction(new HistoryAction(this, 'remove'));
		}
		
		/************************************************
		* display
		* **********************************************/
		[Bindable]
		public function get myName():String {
			return _myName;
		}		
		public function set myName(value:String):void {
			if (_myName != value) {
				_myName = value;
			}
		}
		
		[Bindable]
		public function get myShape():String {
			return _myShape;
		}		
		public function set myShape(value:String):void {
			if (_myShape != value) {			
				_myShape = value;
			}
		}
		
		[Bindable]
		public function get myColor():uint {
			return _myColor;
		}		
		public function set myColor(value:uint):void {
			if (_myColor != value) {
				_myColor = value;
			}
		}
		
		[Bindable]
		public function get myOutline():uint {
			return _myOutline;
		}		
		public function set myOutline(value:uint):void {
			if (_myOutline != value) {
				_myOutline = value;								
			}
		}
		
		public function update(myName:String = '', myShape:String = '', myColor:uint = 0, myOutline:uint = 0, 
		addHistoryAction:Boolean = true):Object {			
			var undoData:Object = { myName:this.myName, myShape:this.myShape, myColor:this.myColor, myOutline:this.myOutline };
			if (addHistoryAction) diagram.historyManager.addHistoryAction(new HistoryAction(this, 'update', undoData));
			
			this.myName = myName;
			this.myShape = myShape;
			this.myColor = myColor;
			this.myOutline = myOutline;
			
			diagram.updateBiomoleculeStyle(this);
			dispatchEvent(new BiomoleculeStyleEvent(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_UPDATE));
			
			return undoData;
		}
		
		public function remove(addHistoryAction:Boolean = true):Object {				
			var undoData:Object = biomolecules;
			if(addHistoryAction) diagram.historyManager.addHistoryAction(new HistoryAction(this, 'construct', undoData));
			
			diagram.removeBiomoleculeStyle(this);			
			dispatchEvent(new BiomoleculeStyleEvent(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_REMOVE));
			
			return undoData;
		}
		
		/************************************************
		* biomolecules
		* **********************************************/
		public function set biomolecules(value:ArrayCollection):void {
			for (var i:uint = 0; i < value.length; i++) {
				value[i].myStyle = this;
			}
		}
		
		public function get biomolecules():ArrayCollection {
			var biomolecules:ArrayCollection = new ArrayCollection();
			for (var i:uint=0; i < diagram.biomolecules.length; i++) {
				if (diagram.biomolecules[i].myStyle == this) {
					biomolecules.addItem(diagram.biomolecules[i]);
				}
			}
			return biomolecules;
		}
		
		/************************************************
		 * undo, redo
		 * *********************************************/
		public function undoHistoryAction(action:String, data:Object):HistoryAction {
			var inverseAction:String = '';
			var inverseData:Object = { };
			
			switch(action) {
				case 'remove':
					inverseAction = 'construct';
					inverseData = remove(false);
					break;
				case 'update':
					inverseAction = 'update';
					inverseData = update(data.myName, data.myShape, data.myColor, data.myOutline, false);
					break;
				case 'construct':
					inverseAction = 'remove';
					biomolecules = data as ArrayCollection;
					diagram.addBiomoleculeStyle(this);
					break;
			}
			
			return new HistoryAction(this, inverseAction, inverseData);
		}
	}
	
}