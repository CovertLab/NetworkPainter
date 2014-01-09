package edu.stanford.covertlab.controls 
{
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.IToolTip;
	
	/**
	 * Tooltip for thumbnails in thumbnail tile list.
	 * 
	 * @see ThumbnailTileList
	 * @see ThumbnailTileListItemRenderer
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class ThumbnailTileListToolTip extends Form implements IToolTip
	{
		
		public function ThumbnailTileListToolTip()
		{		
			var formItem:FormItem;
			var text:Text;
			var label:Label;
			
			//style
			alpha = 1.0;
			width = 300;			
			verticalScrollPolicy = 'off';
			horizontalScrollPolicy = 'off';
			styleName = 'TitleWindowForm';	
			
			setStyle('borderStyle', 'solid');
			setStyle('borderColor', 0x999999);
			setStyle('borderThickness',0);
			setStyle('borderThicknessRight',0);
			setStyle('borderThicknessLeft',0);
			setStyle('borderThicknessTop',0);
			setStyle('borderThicknessBottom',0);
			setStyle('borderAlpha', 1);
			setStyle('backgroundColor', 0xE7E7E7);
			setStyle('dropShadowEnabled', true);
			setStyle('cornerRadius', 6);
			
			setStyle('paddingTop', 4);
			setStyle('paddingBottom', 4);
			setStyle('paddingLeft', 4);
			setStyle('paddingRight', 4);
		}
		
		/************************************************
		* implement IToolTip
		* **********************************************/
		public var _text:String='';
		public function get text():String {
			return _text;			
		}
		public function set text(value:String):void {
			if (text != value) {
				_text = value;
			}
		}
		
	}
	
}