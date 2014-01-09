package edu.stanford.covertlab.controls
{
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.core.ClassFactory;
	import mx.events.ToolTipEvent;
	
	/**
	 * Thumbnails tile list item renderer.
	 * 
	 * @see ThumbnailTileList
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class ThumbnailTileListItemRenderer extends VBox
	{
		protected var image:ImageBorder;
		protected var nameBox:HBox;
		protected var nameLabel:Label;		
		
		public function ThumbnailTileListItemRenderer() 
		{
			super();			
		
			//style
			width = height = 150;
			clipContent = true;
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'off';			
			setStyle('horizontalAlign', 'center');
			setStyle('verticalGap', 4);
			setStyle('paddingTop', 4);
			setStyle('paddingBottom', 4);
			setStyle('paddingLeft', 4);
			setStyle('paddingRight', 4);
			
			//thumbnail				
			image = new ImageBorder();
			image.percentHeight = 100;
			image.percentWidth = 100;
			image.setStyle('horizontalAlign', 'center');
			image.setStyle('verticalAlign', 'middle');
			image.setStyle('borderColor', 0x7FCEFF);
			image.setStyle('borderThickness', 0);
			addChild(image);
			
			//label
			nameBox = new HBox();
			nameBox.percentWidth = 100;
			nameBox.setStyle('paddingTop', 2);
			nameBox.setStyle('paddingBottom', 2);
			nameBox.setStyle('paddingLeft', 2);
			nameBox.setStyle('paddingRight', 2);
			nameBox.setStyle('horizontalAlign', 'center');
			nameBox.setStyle('verticalAlign', 'middle');			
			addChild(nameBox);
			
			nameLabel = new Label();
			nameLabel.height = 12;
			nameLabel.percentWidth = 100;
			nameLabel.setStyle('paddingTop', -2);
			nameLabel.setStyle('paddingBottom', 0);
			nameLabel.setStyle('paddingLeft', 0);
			nameLabel.setStyle('paddingRight', 0);
			nameBox.addChild(nameLabel);
			
			//tooltip
			addEventListener(ToolTipEvent.TOOL_TIP_CREATE, createToolTip);			
		}
		
		public function set selected(value:Boolean):void {
			if (value) {
				image.setStyle('borderThickness', 4);
				nameBox.setStyle('backgroundColor', 0x7FCEFF);
			}else {
				image.setStyle('borderThickness', 0);
				nameBox.setStyle('backgroundColor', 0xFFFFFF);
			}
		}
			
		protected function createToolTip(event:ToolTipEvent):void {			
		}
	}
}

