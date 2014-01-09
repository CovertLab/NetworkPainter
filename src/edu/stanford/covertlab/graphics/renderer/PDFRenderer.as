package edu.stanford.covertlab.graphics.renderer 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.geometry.RoundedRectangle;
	import com.degrafa.geometry.segment.ClosePath;
	import com.degrafa.geometry.segment.CubicBezierTo;
	import com.degrafa.geometry.segment.EllipticalArcTo;
	import com.degrafa.geometry.segment.HorizontalLineTo;
	import com.degrafa.geometry.segment.LineTo;
	import com.degrafa.geometry.segment.MoveTo;
	import com.degrafa.geometry.segment.QuadraticBezierTo;
	import com.degrafa.geometry.segment.VerticalLineTo;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.LinearGradientStroke;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.Surface;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import mx.controls.Alert;
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.display.Display;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.Style;
	import org.alivepdf.images.IImage;
	import org.alivepdf.layout.Layout;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Method;
	
	/**
	 * Generates pdf with vector graphic illustrating of a Degrafa surface.
	 * 
	 * <p>Supports the following degrafa objects
	 * <ul>
	 * <li>Circle</li>
	 * <li>Ellipse</li>
	 * <li>Path (pdf doesn't support quadratic bezier curves or elliptical arcs)</li>
	 * <li>Polygon</li>
	 * <li>RasterText</li>
	 * <li>RegularRectangle</li>
	 * <li>RoundedRectangle</li>
	 * </ul></p>
	 * 
	 * <p>Strokes
	 * <ul>
	 * <li>SolidStroke</li>
	 * <li>LinearGradientStroke</li>
	 * </ul></p>
	 * 
	 * <p>Fills
	 * <ul>
	 * <li>SolidFill</li>
	 * <li>RadialGradientFill</li>
	 * </ul></p>
	 * 
	 * <p>Colors
	 * <ul>
	 * <li>hexadecimal only</li>
	 * </ul></p>
	 * 
	 * <p>Doesn't support 
	 * <ul>
	 * <li>quadratic bezier curves</li>
	 * <li>transforms, rotation</li>
	 * <li>gradient fills</li>
	 * <li>GraphicText</li>
	 * <li>fills on paths</li>
	 * <li>repeaters</li>
	 * <li>decorators</li>
	 * <li>SupSubRasterText</li>
	 * </ul></p>
	 * 
	 * @see org.alivepdf.pdf.PDF
	 * @see com.degrafa.Surface
	 *
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class PDFRenderer 
	{
				
		public function PDFRenderer():void {
			
		}
		
		public function render(surface:Surface, bounds:Rectangle = null, metaData:Object=null):ByteArray		
		{
			//initialize pdf
			var pdf:PDF = new PDF(
				Orientation.PORTRAIT, 
				Unit.POINT, 
				new Size([bounds.width, bounds.height], 'Custom', [bounds.width / 72, bounds.height / 72], [bounds.width / 72 * 25.4, bounds.height / 72 * 25.4]));			
			pdf.setDisplayMode( Display.FULL_PAGE, Layout.SINGLE_PAGE );
			pdf.setFont(FontFamily.ARIAL, Style.NORMAL, 10);
			
			//metadata
			if (metaData != null && metaData['creator']) pdf.setCreator(metaData.creator);
			if (metaData != null && metaData['author']) pdf.setTitle(metaData.author);
			if (metaData != null && metaData['author']) pdf.setAuthor(metaData.author);
			if (metaData != null && metaData['subject']) pdf.setSubject(metaData.subject);
			
			//add page for surface
			pdf.addPage();
									
			//draw geometry groups
			//BUG: if geometry elements that don't have fill are added to pdf over elements with fill, the fill of the first elements won't display in the pdf
			//     for no I've fixed by first drawing elements that don't have fills and then those with fills
			var i:uint;
			for (i = 0; i < surface.numChildren; i++)
				if (surface.getChildAt(i) is GeometryGroup) renderGeometryGroup(pdf, surface.getChildAt(i) as GeometryGroup, 0, 0, false);
			for (i = 0; i < surface.numChildren; i++)
				if (surface.getChildAt(i) is GeometryGroup) renderGeometryGroup(pdf, surface.getChildAt(i) as GeometryGroup, 0, 0, true);
			
			//get byte array
			return pdf.save(Method.LOCAL);
		}
			
		private function renderGeometryGroup(pdf:PDF, geometryGroup:GeometryGroup, x:Number = 0, y:Number = 0, renderFills:Boolean = true):void {			
			var i:uint;
			var geometry:Geometry;
			
			if (!geometryGroup.visible || geometryGroup.alpha==0) return;
									
			for (i = 0; i < geometryGroup.geometry.length; i++) {
				if (geometryGroup.geometry[i] is GeometryGroup) renderGeometryGroup(pdf, geometryGroup.geometry[i] as GeometryGroup, x + geometryGroup.x, y + geometryGroup.y, renderFills);
				else if (geometryGroup.geometry[i] is Geometry) {					
					geometry = geometryGroup.geometry[i] as Geometry;
					if ((renderFills && geometry.fill == null) || (!renderFills && geometry.fill != null)) continue;;
					
					renderStrokeAndFill(pdf, geometry);
					
					if (geometry is Circle) renderCircle(pdf, geometry as Circle, x + geometryGroup.x, y + geometryGroup.y);
					else if (geometry is Ellipse) renderEllipse(pdf, geometry as Ellipse, x + geometryGroup.x, y + geometryGroup.y);
					else if (geometry is Path) renderPath(pdf, geometry as Path, x + geometryGroup.x, y + geometryGroup.y);
					else if (geometry is Polygon) renderPolygon(pdf, geometry as Polygon, x + geometryGroup.x, y + geometryGroup.y);
					else if (geometry is RasterText) renderRasterText(pdf, geometry as RasterText, x + geometryGroup.x, y + geometryGroup.y);
					else if (geometry is RegularRectangle) renderRegularRectangle(pdf, geometry as RegularRectangle, x + geometryGroup.x, y + geometryGroup.y);
					else if (geometry is RoundedRectangle) renderRoundedRectangle(pdf, geometry as RoundedRectangle, x + geometryGroup.x, y + geometryGroup.y);
										
					pdf.endFill();
					pdf.end();					
				}
			}			
			
			for (i = 0; i < geometryGroup.numChildren; i++) {
				if (geometryGroup.getChildAt(i) is GeometryGroup) renderGeometryGroup(pdf, geometryGroup.getChildAt(i) as GeometryGroup, x + geometryGroup.x, y + geometryGroup.y, renderFills);				
			}			
		}
		
		private function renderCircle(pdf:PDF, geometry:Circle, x:Number, y:Number):void {
			pdf.drawCircle(x + geometry.x, y + geometry.y, geometry.radius);
		}
		
		private function renderEllipse(pdf:PDF, geometry:Ellipse, x:Number, y:Number):void {
			pdf.drawEllipse(x + geometry.x + geometry.width / 2, y + geometry.y + geometry.height / 2, geometry.width / 2, geometry.height / 2);
		}
		
		private function renderPath(pdf:PDF, geometry:Path, x:Number, y:Number):void {
			var curX:Number = 0;
			var curY:Number = 0;
			var endX:Number = 0;
			var endY:Number = 0;
			for (var i:uint; i < geometry.segments.length; i++) {
				if (geometry.segments[i].coordinateType == 'absolute') {
					if (geometry.segments[i] is ClosePath) {
						pdf.lineTo(x + endX, y + endY);
						curX = endX;
						curY = endY;
					}else if (geometry.segments[i] is CubicBezierTo) {
						pdf.curveTo(
							x + geometry.segments[i].cx, y + geometry.segments[i].cy, 
							x + geometry.segments[i].cx1, y + geometry.segments[i].cy1, 
							x + geometry.segments[i].x, y + geometry.segments[i].y);
						curX = geometry.segments[i].x;
						curY = geometry.segments[i].y;
					}else if (geometry.segments[i] is EllipticalArcTo) {
						pdf.lineTo(x + geometry.segments[i].x, y + geometry.segments[i].y);
						curX = geometry.segments[i].x;
						curY = geometry.segments[i].y;						
					}else if (geometry.segments[i] is HorizontalLineTo) {
						pdf.lineTo(x + geometry.segments[i].x, y + curY);
						curX = geometry.segments[i].x;
					}else if (geometry.segments[i] is LineTo) {
						pdf.lineTo(x + geometry.segments[i].x, y + geometry.segments[i].y);
						curX = geometry.segments[i].x;
						curY = geometry.segments[i].y;
					}else if (geometry.segments[i] is MoveTo) {
						pdf.moveTo(x + geometry.segments[i].x, y + geometry.segments[i].y);
						curX = endX = geometry.segments[i].x;
						curY = endY = geometry.segments[i].y;
					}else if (geometry.segments[i] is QuadraticBezierTo) {
						pdf.lineTo(x + geometry.segments[i].x, y + geometry.segments[i].y);
						curX = geometry.segments[i].x;
						curY = geometry.segments[i].y;
					}else if (geometry.segments[i] is VerticalLineTo) {
						pdf.lineTo(x + curX, y + geometry.segments[i].y);
						curY = geometry.segments[i].y;
					}
				}else {
					if (geometry.segments[i] is ClosePath) {
						pdf.lineTo(x + endX, y + endY);
						curX = x + endX;
						curY = y + endY;
					}else if (geometry.segments[i] is CubicBezierTo) {
						pdf.curveTo(
							x + curX + geometry.segments[i].cx, y + curY + geometry.segments[i].cy, 							
							x + curX + geometry.segments[i].cx1, y + curY + geometry.segments[i].cy1, 							
							x + curX + geometry.segments[i].x, y + curY + geometry.segments[i].y);
						curX += geometry.segments[i].x;
						curY += geometry.segments[i].y;
					}else if (geometry.segments[i] is EllipticalArcTo) {
						pdf.lineTo(x + curX + geometry.segments[i].x, y + curY + geometry.segments[i].y);
						curX += geometry.segments[i].x;
						curY += geometry.segments[i].y;					
					}else if (geometry.segments[i] is HorizontalLineTo) {
						pdf.lineTo(x + curX + geometry.segments[i].x, y + curY);
						curX += geometry.segments[i].x;
					}else if (geometry.segments[i] is LineTo) {
						pdf.lineTo(x + curX + geometry.segments[i].x, y + curY + geometry.segments[i].y);
						curX += geometry.segments[i].x;
						curY += geometry.segments[i].y;
					}else if (geometry.segments[i] is MoveTo) {
						pdf.moveTo(x + curX + geometry.segments[i].x, y + curY + geometry.segments[i].y);
						curX += geometry.segments[i].x;
						curY += geometry.segments[i].y;
						endX = curX;
						endY = curY;						
					}else if (geometry.segments[i] is QuadraticBezierTo) {
						pdf.lineTo(x + curX + geometry.segments[i].x, y + curY + geometry.segments[i].y);
						curX += geometry.segments[i].x;
						curY += geometry.segments[i].y;
					}else if (geometry.segments[i] is VerticalLineTo) {
						pdf.lineTo(x + curX, y + curY + geometry.segments[i].y);
						curY += geometry.segments[i].y;
					}
				}
			}
		}
		
		private function renderPolygon(pdf:PDF, geometry:Polygon, x:Number, y:Number):void {
			pdf.drawPolygone(pointsToPDF(geometry.points, x, y));
		}
		
		//BUG: can't measure text in AlivePDF, don't have a great way to center text on shape
		private function renderRasterText(pdf:PDF, geometry:RasterText, x:Number, y:Number):void {
			pdf.textStyle(new RGBColor(geometry.textColor));
			pdf.setFontSize(geometry.fontSize);
			pdf.addText(geometry.text, x + 0.9 * geometry.x, y + 0.4 * geometry.fontSize);
		}
		
		private function renderRegularRectangle(pdf:PDF, geometry:RegularRectangle, x:Number, y:Number):void {
			pdf.drawRect(new Rectangle(x + geometry.x, y + geometry.y, geometry.width, geometry.height));
		}
		
		private function renderRoundedRectangle(pdf:PDF, geometry:RoundedRectangle, x:Number, y:Number):void {
			pdf.drawRoundRect(new Rectangle(x + geometry.x, y + geometry.y, geometry.width, geometry.height), geometry.cornerRadius * 2);
		}
		
		private function renderStrokeAndFill(pdf:PDF, geometry:Geometry):void {
			renderStroke(pdf, geometry.stroke);
			renderFill(pdf, geometry.fill);
		}
		
		private function renderStroke(pdf:PDF, stroke:IGraphicsStroke):void {
			if (stroke == null) return;
			
			if (stroke is SolidStroke) {
				var solidStroke:SolidStroke = stroke as SolidStroke;
				pdf.lineStyle(new RGBColor(solidStroke.color as Number), solidStroke.weight, 0, solidStroke.alpha);
			}else if (stroke is LinearGradientStroke) {
				var linearGradientStroke:LinearGradientStroke = stroke as LinearGradientStroke;
				pdf.lineStyle(new RGBColor(linearGradientStroke.gradientStops[0].color as Number), linearGradientStroke.weight, 0, linearGradientStroke.gradientStops[0].alpha);
			}
		}
		
		private function renderFill(pdf:PDF, fill:IGraphicsFill):void {			
			if (fill == null) return;
			
			if (fill is SolidFill) {
				var solidFill:SolidFill = fill as SolidFill;
				pdf.beginFill(new RGBColor(solidFill.color as Number));
				pdf.setAlpha(solidFill.alpha);
			}else if (fill is RadialGradientFill) {
				var radialGradientFill:RadialGradientFill = fill as RadialGradientFill;
				pdf.beginFill(new RGBColor(radialGradientFill.gradientStops[1].color as Number));
				pdf.setAlpha(radialGradientFill.gradientStops[1].alpha);
			}
		}
		
		private function pointsToPDF(graphicPoints:Array, x:Number = 0, y:Number = 0 ):Array {
			var pointsArr:Array = [];
			for (var i:uint = 0; i < graphicPoints.length; i++) {
				pointsArr.push(x+graphicPoints[i].x);
				pointsArr.push(y+graphicPoints[i].y);
			}
			return pointsArr;
		}
		
	}
	
}