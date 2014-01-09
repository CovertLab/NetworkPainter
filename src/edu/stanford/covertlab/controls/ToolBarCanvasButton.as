package edu.stanford.covertlab.controls
{
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flexlib.controls.CanvasButton;
	import mx.binding.utils.BindingUtils;
	
	/**
	 * Base class for NewBiomoleculeToolBar buttons.
	 * 
	 * @see NewBiomoleculeToolBar
	 * 
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ToolBarCanvasButton extends CanvasButton
	{

		private var disabledFilter:ColorMatrixFilter;
		
		public function ToolBarCanvasButton(toolTip:String = '', skin:Class = null, selectedSkin:Class = null, disabledFilter:ColorMatrixFilter=null)		
		{
			this.toolTip = toolTip;
						
			if (skin != null) {
				setStyle('skin', skin);
				setStyle('downSkin', skin);
			}
			if (selectedSkin != null) {
				setStyle('selectedUpSkin', selectedSkin);
				setStyle('selectedOverSkin', selectedSkin);
				setStyle('selectedOverSkin', selectedSkin);
			}
			
			if (!disabledFilter) {
				disabledFilter=new ColorMatrixFilter([
						0,0,0,0,0,
						0,0,0,0,0,
						0,0,0,0,0,
						0, 0, 0, .15, 0]);
			}
			this.disabledFilter = disabledFilter;
		}
		
		override protected function rollOverHandler(evt:MouseEvent):void {
			if(enabled) filters = [new DropShadowFilter(4,45,0,0.5,4,4)];	
		}
		
		override protected  function rollOutHandler(evt:MouseEvent):void {
			if(enabled) filters = [];
		}
		  
		override protected  function mouseDownHandler(evt:MouseEvent):void {
			if (enabled) filters=[new ColorMatrixFilter([
					0.8,0,0,0,0,
					0,0.8,0,0,0,
					0,0,0.8,0,0,
					0, 0, 0, 1, 0])];
		}
		  
		override public function set enabled(value:Boolean):void {
			if (value != enabled) {
				if (!value){
					filters = [disabledFilter];
				}else {
					filters = [];
				}
				super.enabled = value;
			}
		}
		
	}
	
}