package edu.stanford.covertlab.graphics.renderer 
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;		
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	import org.alivepdf.display.Display;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.Style;
	import org.alivepdf.images.IImage;
	import org.alivepdf.images.ResizeMode;
	import org.alivepdf.layout.Layout;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Method;

	
	/**
	 * Generates a multi-page pdf with a page for each element in an array of bitmap data
	 * of frames.
	 * 
	 * @see org.alivepdf.pdf.PDF
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class MultipagePDFRenderer 
	{
		
		public function MultipagePDFRenderer() 
		{
			
		}
		
		public function render(frames:Array, metaData:Object = null):ByteArray {
			//initialize pdf
			var pdf:PDF = new PDF(
				Orientation.PORTRAIT, 
				Unit.POINT, 
				new Size([frames[0].width, frames[0].height], 'Custom', [frames[0].width / 72, frames[0].height / 72], [frames[0].width / 72 * 25.4, frames[0].height / 72 * 25.4]));	
			pdf.setDisplayMode( Display.FULL_PAGE, Layout.SINGLE_PAGE );
			pdf.setFont(FontFamily.ARIAL, Style.NORMAL, 10);
			
			//metadata
			if (metaData != null && metaData['creator']) pdf.setCreator(metaData.creator);
			if (metaData != null && metaData['author']) pdf.setTitle(metaData.author);
			if (metaData != null && metaData['author']) pdf.setAuthor(metaData.author);
			if (metaData != null && metaData['subject']) pdf.setSubject(metaData.subject);
			
			var encoder:JPEGEncoder = new JPEGEncoder(100);
			
			//add page for surface
			for (var i:uint = 0; i < frames.length; i++) {
				pdf.addPage();
				pdf.addImageStream(encoder.encode(frames[i] as BitmapData), 0, 0, 0, 0, 1, ResizeMode.FIT_TO_PAGE);
			}
			
			//get byte array
			return pdf.save(Method.LOCAL);
		}
		
	}
	
}