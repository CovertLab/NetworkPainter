package edu.stanford.covertlab.graphics.printer 
{
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import mx.core.UIComponent;
	
	/**
	 * Creates flash print job from canvas containing Degrafa surfaces.
	 * 
	 * @see com.degrafa.Surface
	 * @see flash.printing.PrintJob
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Printer 
	{
		/**
		 * BUG: node labels print with white background text in vector print mode; this is not a 
		 *      problem in bitmap printing mode; perhaps we want to build a sprite specifically for 
		 *      printing (and png, jpeg rendering) which doesn't contain degrafa raster text and 
		 *      will display at higher quality in vector mode; additionally we can't use degrafa GraphicText
		 *      because apparently it can't be created programmatically with actionscript, only declaratively
		 *      in MXML.
		 * BUG: background surface sprite not scaling properly (printScale doesn't have desired effect)
		 * BUG: printing not centered on page
		 */
		public static function print(image:UIComponent, bounds:Rectangle = null):void {
			//create print job
			var printJob:PrintJob = new PrintJob();
			
			//set printing mode to bitmap
			var printJobOptions:PrintJobOptions = new PrintJobOptions(true);		
			
			//catch if user cancels print job
			if (printJob.start()) {

				//remember initial background surfaces properties
				var userScale:Number = image.scaleX;
				var printScale:Number;
				var printRotation:Number;
				
				//rotate, translate, and scale background surfaces				
				if ((printJob.pageWidth > printJob.pageHeight && bounds.width > bounds.height) ||
					(printJob.pageWidth < printJob.pageHeight && bounds.width < bounds.height)) {
					printScale = Math.min(printJob.pageWidth / bounds.width, printJob.pageHeight / bounds.height);
					printRotation = 0;					
				}else {
					printScale = Math.min(printJob.pageWidth / bounds.height, printJob.pageHeight / bounds.width);
					printRotation = 90;
				}
				image.scaleX = printScale;
				image.scaleY = printScale;
				image.rotation = printRotation;
				
				//add background surfaces to print job
				//send print job to printer
				try {
					printJob.addPage(image, null, printJobOptions);
					printJob.send();
				}catch (error:Error) {
					//trace('Print job failed.');
				}
				
				//revert to initial background surfaces properties
				image.rotation = 0;			
				image.scaleX = userScale;
				image.scaleY = userScale;	
			}else {
				trace('Print job cancelled.');
			}
		}
		
	}
	
}