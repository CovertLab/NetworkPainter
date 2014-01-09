package edu.stanford.covertlab.controls
{
	import mx.controls.Image;
	
	[Style(name = "borderColor", type = "uint", format = "Color", inherit = "no")]	
	[Style(name = "borderThickness", type = "Number", format = "Length", inherit = "no")]	
	[Style(name = "borderAlpha", type = "Number", format = "Length", inherit = "no")]
	[Style(name = "cornerRadius", type = "Number", format = "Length", inherit = "no")]
	
	
	/**
	 * Image with border. Inspired by http://www.flexer.info/2008/06/10/how-to-make-an-image-with-border/.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class ImageBorder extends Image
	{
			
		// initialization
		public function ImageBorder():void
		{					
			super();
		}
		
		// overriding the update function
		override protected function updateDisplayList(w:Number,h:Number):void
		{
			super.updateDisplayList(w, h);
			
			// clear graphics
			// we want only one rectangle
			graphics.clear();
			
			if (!source) return;
			if (isNaN(contentWidth) || isNaN(contentHeight)) return;
			
			var borderThickness:Number = getStyle('borderThickness');
			if (isNaN(borderThickness) || borderThickness <= 0) return;
			
			// set line style with with 0 and alpha 0
			graphics.lineStyle(borderThickness*2, getStyle('borderColor'), getStyle('borderAlpha'), false);
			
			// draw rectangle
			graphics.drawRoundRect((width - contentWidth) / 2, (height - contentHeight) / 2, contentWidth, contentHeight, 
				getStyle('cornerRadius'), getStyle('cornerRadius'));
		}		
		
	}
	
}