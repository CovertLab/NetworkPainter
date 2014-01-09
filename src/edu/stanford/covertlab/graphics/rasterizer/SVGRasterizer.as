package edu.stanford.covertlab.graphics.rasterizer 
{
	import edu.stanford.covertlab.graphics.renderer.SVGRenderer;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import mx.core.UIComponent;
	
	/**
	 * Uses Inkscape (via webservice) to convert a canvas with Degrafa surfaces to 
	 * png, ps, eps, or pdf.
	 * <ol>
	 * <li>Convert surface to SVG</li>
	 * <li>Post SVG to webservice</li>
	 * <li>Webservice converts SVG to one of png, ps, eps, pdf using Inkscape</li>
	 * <li>Webservice returns conveted SVG</li>
	 * <li>Prompt user to save converted file to local disk</li>
	 * </ol>
	 * 
	 * @see covertlab.stanford.edu.graphics.renderer.SVGRenderer
	 * @see com.degrafa.Surface
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class SVGRasterizer 
	{

		public function SVGRasterizer():void {
			
		}
		
		//available formats: png, ps, eps, pdf
		public function rasterize(format:String, fileName:String, image:UIComponent, bounds:Rectangle = null, metaData:Object = null):void {
			var svgRenderer:SVGRenderer = new SVGRenderer();
			
			var urlVariables:URLVariables = new URLVariables();						
			urlVariables.format = format;
			urlVariables.svg = svgRenderer.render(image, bounds, metaData);
			
			var urlRequest:URLRequest = new URLRequest('services/svgRasterizer.php');
			urlRequest.method = 'POST';
			urlRequest.data = urlVariables;
						
			var fileReference:FileReference = new FileReference();
			fileReference.download(urlRequest, fileName + '.' + format);
		}
	}
	
}