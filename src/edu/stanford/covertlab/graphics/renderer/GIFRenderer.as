package edu.stanford.covertlab.graphics.renderer 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import mx.core.UIComponent;
	import org.gif.encoder.GIFEncoder;
	
	/**
	 * Generates a gif image of a UIComponent.
	 * 
	 * @see org.gif.encoder.GIFEncoder
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class GIFRenderer 
	{
		
		public function GIFRenderer() 
		{
			
		}
		
		//BUG: gif encoding is slow
		//     perhaps we should warn the user
		public function render(image:UIComponent, bounds:Rectangle = null, metaData:Object = null):ByteArray		
		{
			if (bounds == null) bounds = image.getBounds(image);
			
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height);
			bitmapData.draw(image, null, null, null, null, true);
			
			var myGIFEncoder:GIFEncoder = new GIFEncoder();  
			myGIFEncoder.start();  
			myGIFEncoder.setRepeat(0);  
			myGIFEncoder.setDelay(100);
			myGIFEncoder.addFrame(bitmapData);  
			myGIFEncoder.finish();  
			return myGIFEncoder.stream;  
		}
	}
	
}