package edu.stanford.covertlab.diagram.core 
{
	import edu.stanford.covertlab.diagram.window.EditCompartmentWindow;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	/**
	 * Displays "hot spots" in a diagram where a compartment can be inserted. When a user clicks on 
	 * a "hot spot" an EditCompartmentWindow appears prompting the user for the name and colors of the
	 * new compartment. If the user clicks ok, a new compartment is added at the desired location.
	 * 
	 * @see Compartment
	 * @see edu.stanford.covertlab.diagram.window.EditCompartmentWindow
	 * 
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009.
	 */
	public class CompartmentHotspot extends CompartmentBase
	{
		protected var _selected:Boolean;
		
		public function CompartmentHotspot(diagram:Diagram, myUpperCompartment:Compartment, width:Number, height:Number, myPosition:String = POSITION_TOP) 
		{
			super(diagram, 0, width, height, myUpperCompartment);
			
			//appearance
			_myPosition = myPosition;
			this.gradientStroke.weight = 5;
			this.fillStop_color.color = 0xCCCCCC;
			this.fillStop_color.alpha = 0.8;
			this.fillStop_white.color = 0xCCCCCC;
			this.fillStop_white.alpha = 0.8;
			this.strokeStop_color.color = 0x000000;
			this.strokeStop_white.color = 0x000000;
			alpha = 0;
			drawCompartment();
			
			//drag 'n drop
			addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
			addEventListener(DragEvent.DRAG_DROP, dragDropHandler);			
		}
		
		
		/************************************************
		* setters/getters
		* **********************************************/	
		override public function set myColor(value:uint):void { }

		
		/************************************************
		* dragging
		* **********************************************/
		protected function dragEnterHandler(event:DragEvent):void {			
			if (!event.dragSource.hasFormat('action') || event.dragSource.dataForFormat('action') != 'addCompartment') return;
			
			selected = true;
			DragManager.acceptDragDrop(this);			
		}
		
		protected function dragExitHandler(event:DragEvent):void {
			if (!event.dragSource.hasFormat('action') || event.dragSource.dataForFormat('action') != 'addCompartment') return;
			
			selected = false;
		}
		
		protected function dragDropHandler(event:DragEvent):void {
			if (!event.dragSource.hasFormat('action') || event.dragSource.dataForFormat('action') != 'addCompartment') return;
			
			selected = false;			
			var editCompartmentWindow:EditCompartmentWindow = new EditCompartmentWindow(diagram, null, myUpperCompartment as Compartment);
			editCompartmentWindow.open();			
		}
		
		/************************************************
		* select/highlight
		* **********************************************/
		protected function get selected():Boolean {
			return _selected;
		}
			
		protected function set selected(value:Boolean):void {
			if (_selected != value) {
				_selected = value;
				if (_selected) alpha = 100;
				else alpha = 0;
			}
		}
	}
	
}