package edu.stanford.covertlab.controls
{
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import mx.binding.utils.BindingUtils;
	import mx.controls.Button;
	
	/**
	 * Base class for toolbar buttons. Skins button class with an image and applies color filter on rollover and mouse down.
	 * 
	 * @see AnimationBar
	 * @see ControlToolBar
	 * @see NewComponentToolBar
	 * @see SimpleControlBar
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ToolBarButton extends Button
	{	
		private var disabledFilter:ColorMatrixFilter;

		public function ToolBarButton(toolTip:String = '', skin:Class = null, selectedSkin:Class = null, disabledFilter:ColorMatrixFilter=null)		
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
				disabledFilter = new ColorMatrixFilter([
						0, 0, 0, 0, 0,
						0, 0, 0, 0, 0,
						0, 0, 0, 0, 0,
						0, 0, 0, .15, 0]);
			}
			this.disabledFilter = disabledFilter;
		}
		
		override protected function rollOverHandler(evt:MouseEvent):void {
			if (enabled) filters = [new DropShadowFilter(4, 45, 0, 0.5, 4, 4)];
		}
		
		override protected  function rollOutHandler(evt:MouseEvent):void {
			if (enabled) filters = [];
		}
		  
		override protected  function mouseDownHandler(evt:MouseEvent):void {
			if (enabled) filters = [new ColorMatrixFilter([
					0.8, 0, 0, 0, 0,
					0, 0.8, 0, 0, 0,
					0, 0, 0.8, 0, 0,
					0, 0, 0, 1, 0])];
		}
		  
		override public function set enabled(value:Boolean):void {
			if (value != enabled) {
				if (!value) {
					filters = [disabledFilter];
				}else {
					filters = [];
				}
				super.enabled = value;
			}
		}
	}
	
}