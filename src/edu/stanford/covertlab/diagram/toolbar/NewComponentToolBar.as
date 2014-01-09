package edu.stanford.covertlab.diagram.toolbar 
{
	import edu.stanford.covertlab.controls.ToolBarButton;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import mx.controls.Image;
	import mx.core.DragSource;
	import mx.events.DragEvent;
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import mx.managers.DragManager;
	
	/**
	 * Toolbar containing buttons for adding new compartments and biomolecule styles to a diagram.
	 * Clicking the add new compartment button triggers the display of compartment "hot spots" which
	 * indicate where a compartment would be inserted. When a hotspot is selected an EditCompartmentWindow
	 * popup window is opened. Clicking the new biomolecule style button opens an EditBiomoleculeStyle 
	 * popup window.
	 * 
	 * @see ToolBar
	 * @see edu.stanford.covertlab.diagram.core.CompartmentHotspot
	 * 
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class NewComponentToolBar extends ToolBar
	{
		[Embed(source = '../../image/compartmentadd.png')] private var addCompartmentImg:Class;
		[Embed(source = '../../image/biomoleculeadd.png')] private var addBiomoleculeStyleImg:Class;
		private var newCompartmentButton:ToolBarButton;
		private var newBiomoleculeStyleButton:ToolBarButton;
		
		public function NewComponentToolBar(diagram:Diagram) 
		{
			super(diagram);
			
			label = "New Component";
			
			newCompartmentButton = new ToolBarButton('New Compartment', addCompartmentImg);
			newCompartmentButton.addEventListener(MouseEvent.MOUSE_DOWN, startAddCompartment);
			addChild(newCompartmentButton);
			
			newBiomoleculeStyleButton = new ToolBarButton('New BiomoleculeStyle', addBiomoleculeStyleImg);
			newBiomoleculeStyleButton.addEventListener(MouseEvent.MOUSE_DOWN, startAddBiomoleculeStyle );
			addChild(newBiomoleculeStyleButton);
		}
		
		/*********************************************************************
		 * Compartments
		**********************************************************************/	
		private function startAddCompartment(event:MouseEvent):void {
			if (!compartmentCanBeAdded()) return;
			
			var dragSource:DragSource = new DragSource();
			dragSource.addData('addCompartment', 'action');

			var dragProxy:Image = new Image();
			dragProxy.source = newCompartmentButton.getStyle('skin');

			DragManager.doDrag(newCompartmentButton, dragSource, event, dragProxy);
		}
		
		private function compartmentCanBeAdded():Boolean {
			for (var i:uint = 0; i < diagram.compartments.length; i++) {
				if (diagram.compartments[i].myTopHotspot.visible || diagram.compartments[i].myBottomHotspot.visible)				
					return true;
			}
			
			Alert.show('Unable to add compartments. Increase diagram size and retry.', 'Add Compartment Error');						
			return false;
		}
				
		/*********************************************************************
		 * Biomolecule Styles
		**********************************************************************/
		private function startAddBiomoleculeStyle(event:MouseEvent):void {
			var dragSource:DragSource = new DragSource();
			dragSource.addData('addBiomoleculeStyle', 'action');

			var dragProxy:Image = new Image();
			dragProxy.source = newBiomoleculeStyleButton.getStyle('skin');

			DragManager.doDrag(newBiomoleculeStyleButton, dragSource, event, dragProxy);
		}
		
	}
}