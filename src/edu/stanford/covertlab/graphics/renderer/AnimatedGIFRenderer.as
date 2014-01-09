package edu.stanford.covertlab.graphics.renderer 
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import org.gif.encoder.GIFEncoder;
	
	/**
	 * Converts an array of bitmap data to an animated gif.
	 * 
	 * @see org.gif.encoder.GIFEncoder
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AnimatedGIFRenderer 
	{
		
		public function AnimatedGIFRenderer() 
		{
			
		}
		
		//BUG: gif encoding is slow
		//     perhaps we should warn the user
		public function render(frames:Array, loopAnimation:Boolean, animationFrameRate:Number, metaData:Object = null):ByteArray {						
			var myGIFEncoder:GIFEncoder = new GIFEncoder();  
			myGIFEncoder.start();  
			myGIFEncoder.setRepeat(int(loopAnimation));
			myGIFEncoder.setDelay(60 / animationFrameRate * 1000);
			
			for (var i:uint = 0; i < frames.length; i++ )
				myGIFEncoder.addFrame(frames[i] as BitmapData);
	
			myGIFEncoder.finish();  
			return myGIFEncoder.stream;
		}
		
	}
	
}