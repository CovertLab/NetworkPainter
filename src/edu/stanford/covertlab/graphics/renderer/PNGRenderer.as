package edu.stanford.covertlab.graphics.renderer 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import mx.core.UIComponent;
	import mx.graphics.codec.PNGEncoder;
	
	/**
	 * Generates a png image of a UIComponent.
	 * 
	 * @see mx.graphics.codec.PNGEncoder
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class PNGRenderer 
	{
		
		public function PNGRenderer():void {
			
		}
		
		public function render(image:UIComponent, bounds:Rectangle = null, metaData:Object = null):ByteArray
		{
			if (bounds == null) {
				bounds = image.getBounds(image);
			}
			
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height);
			bitmapData.draw(image, null, null, null, null, true);
			
			var encoder:PNGEncoder = new PNGEncoder();
			return encoder.encode(bitmapData);
		}
		
	}
	
}