package edu.stanford.covertlab.graphics.renderer 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import mx.core.UIComponent;
	import mx.graphics.codec.JPEGEncoder;
	
	/**
	 * Generates a jpeg image of a UIComponent.
	 * 
	 * @see mx.graphics.codec.JPEGEncoder
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class JPEGRenderer 
	{
		
		public function JPEGRenderer():void {
			
		}
		
		public function render(image:UIComponent, bounds:Rectangle = null, metaData:Object = null):ByteArray		
		{			
			if (bounds == null) bounds = image.getBounds(image);
			
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height);
			bitmapData.draw(image, null, null, null, null, true);

			var encoder:JPEGEncoder = new JPEGEncoder(100);
			return encoder.encode(bitmapData);
		}
		
	}
	
}