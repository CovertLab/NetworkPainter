package edu.stanford.covertlab.graphics.renderer 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.geometry.repeaters.Repeater;
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
	import edu.stanford.covertlab.graphics.renderablerepeater.RenderableRepeater;
	import edu.stanford.covertlab.graphics.SupSubRasterText;
	import edu.stanford.covertlab.util.HTML;
	import edu.stanford.covertlab.util.ColorUtils;
	import flash.geom.Rectangle;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	/**
	 * Translates canvas with Degrafa surfaces to SVG.
	 * 
	 * <p>Supports the following degrafa objects
	 * <ul>
	 * <li>Circle</li>
	 * <li>Ellipse</li>
	 * <li>Line</li>
	 * <li>Path</li>
	 * <li>Polygon</li>
	 * <li>RasterText (assumes centered)</li>
	 * <li>RegularRectangle</li>
	 * <li>RoundedRectangle</li>
	 * </ul></p>
	 * 
	 * <p>Custom graphics
	 * <ul>
	 * <li>colorbar</li>
	 * <li>colorgrid</li>
	 * <li>membranephospholipids</li>
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
	 * <li>Simple path objects: CubicBezier, EllipticArc, HorizontalLine, Move, Polyline, QuadraticBezier, VerticalLine
	 *     Paths using these segment types are supported only through the use of the degrafa Path Object</li>
	 * <li>AdvancedRectangle, RoundedRectangleComplex, RasterTextPlus</li>
	 * <li>Transforms</li>
	 * <li>GraphicText</li>
	 * <li>Decorator</li>
	 * </ul></p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class SVGRenderer 
	{
		public function SVGRenderer():void {
			
		}
		
		private var description:String;
		private var graphics:String;
		private var fills:Array;
		private var strokes:Array;
		
		public function render(image:UIComponent, bounds:Rectangle = null, metaData:Object = null):String				
		{		
			var i:uint;
			var j:uint;
			
			if (!bounds) bounds = image.getBounds(image);
			
			description = '';
			if(metaData){
				description=printf(
					'<desc>'+
						'<title>%s</title>'+
						'<subject>%s</subject>'+
						'<author>%s</author>'+
						'<generator>%s</generator>' +
						'<lastupdated>%s</lastupdated>'+
					'</desc>',
					metaData['title'], metaData['subject'], metaData['author'], metaData['creator'], metaData['timestamp']);
			}
			
			graphics = '';
			fills = [];
			strokes = [];
			for (i = 0; i < image.numChildren; i++){
				if (image.getChildAt(i) is GeometryGroup) graphics += renderGeometryGroup(image.getChildAt(i) as GeometryGroup);
				else if (image.getChildAt(i) is UIComponent) graphics += renderUIComponent(image.getChildAt(i) as UIComponent);
			}
			
			var defs:String = '';
			var styles:String = '';
			var stops:String = '';
			for (i = 0; i < fills.length; i++) {
				if (fills[i] is RadialGradientFill) {
					stops = '';
					for (j = 0; j < fills[i].gradientStops.length; j++) {
						stops += printf('<stop offset="%f" stop-color="#%s" stop-opacity="%f"/>', 
							fills[i].gradientStops[j].ratio, ColorUtils.hexToDec(fills[i].gradientStops[j].color), fills[i].gradientStops[j].alpha);
					}
					defs += printf('<radialGradient id="fill_%d">%s</radialGradient>', i,stops);
				}
			}
			
			for (i = 0; i < strokes.length; i++) {
				if (strokes[i] is LinearGradientStroke) {
					stops = '';
					for (j = 0; j < strokes[i].gradientStops.length; j++) {
						stops += printf('<stop offset="%f" stop-color="#%s" stop-opacity="%f"/>', 
							strokes[i].gradientStops[j].ratio, ColorUtils.hexToDec(strokes[i].gradientStops[j].color), strokes[i].gradientStops[j].alpha);
					}
					defs += printf('<linearGradient id="stroke_%d">%s</linearGradient>', i,stops);
				}
			}
						
			var svg:XML = new XML(printf(						
				'<svg width = "%d" height = "%d" viewBox="0 0 %d %d" version = "1.1" xmlns = "http://www.w3.org/2000/svg" >' +
				'%s' +
				'<defs>' +
				  '%s'+
				'</defs>' +
				'<style type="text/css"><![CDATA[\n' +
				'  text {\n'+
				'    text-anchor:middle;\n'+
				'    alignment-baseline:top;\n'+
				'    font-family:Arial;\n'+
				'  }\n' +
				'  %s' +
				'\n]]></style>' +
				'%s' +
				'</svg>',
				bounds.width, bounds.height, bounds.width, bounds.height, description, defs, styles, graphics));
			
			return '<?xml version = "1.0" encoding = "UTF-8" standalone = "no"?>\n'+
				'<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n' +
				svg.toXMLString();
		}
		
		private function renderSupSubRasterText(geometryGroup:SupSubRasterText):String {
			var htmlText:String = HTML.entitiesToDecimal(geometryGroup.text);			
			var svgText:String = '';
			var fontSize:Number = geometryGroup.fontSize;
			
			var regExp:RegExp = /<su[pb]>(.*?)<\/su[pb]>/ig;
			var result:Object = regExp.exec(htmlText);
			var lastIndex:uint = 0;
			
			if (!result) {
				svgText=htmlText;
				lastIndex = htmlText.length;
			}
					
			while (result) {
				//before
				svgText += htmlText.substr(lastIndex, result.index - lastIndex);
						
				//super/subscripted
				//use adobe illustrator size and baseline shift parameters, http://en.wikipedia.org/wiki/Superscript
				if (lastIndex > 0) svgText += '</tspan>';
				svgText += printf('<tspan dx="%f" dy="%f" font-size="58.3%">%s</tspan>',
					-.2 * fontSize, (result[0].substr(1, 3) == 'sup' ? -.33 * fontSize : .33 * fontSize), result[1]);
				if (result.index + result[0].length < htmlText.length) svgText += printf('<tspan dx="%f" dy="%f">', 
					-.2 * fontSize, (result[0].substr(1, 3) == 'sup' ? .33 * fontSize : -.33 * fontSize));
								
				lastIndex = result.index + result[0].length;
				result = regExp.exec(htmlText);
			}
			
			//after
			if (!result && lastIndex < htmlText.length) svgText += htmlText.substr(lastIndex, htmlText.length - lastIndex) + '</tspan>';
			
			return printf('<text x="%f" y="%f" font-size="%f" fill="#%s">%s</text>', 
				geometryGroup.x + geometryGroup.width / 2, geometryGroup.y + 1.1 * geometryGroup.fontSize, 
				geometryGroup.fontSize, ColorUtils.hexToDec((geometryGroup.fill as SolidFill).color as uint), svgText);
		}
		
		private function renderUIComponent(uiComponent:UIComponent = null):String {
			var i:uint
			if (!uiComponent.visible) return '';
			
			var svg:String = printf('<g transform="translate(%f %f) rotate(%f)" style="opacity:%f;">', 
				uiComponent.x, uiComponent.y, uiComponent.rotation, uiComponent.alpha);
										
			for (i = 0; i < uiComponent.numChildren; i++) {
				if (uiComponent.getChildAt(i) is GeometryGroup) svg += renderGeometryGroup(uiComponent.getChildAt(i) as GeometryGroup);
				else if (uiComponent.getChildAt(i) is UIComponent) svg += renderUIComponent(uiComponent.getChildAt(i) as UIComponent);
			}
			
			svg+='</g>'
			return svg;
		}
		
		private function renderGeometryGroup(geometryGroup:GeometryGroup = null):String {
			var i:uint
			if (!geometryGroup.visible) return '';
			
			var svg:String = printf('<g transform="translate(%f %f) rotate(%f)" style="opacity:%f;">', 
				geometryGroup.x, geometryGroup.y, geometryGroup.rotation, geometryGroup.alpha);
				
			svg += renderObjectStack(geometryGroup.geometry);
			
			for (i = 0; i < geometryGroup.numChildren; i++) {
				if (geometryGroup.getChildAt(i) is SupSubRasterText) svg += renderSupSubRasterText(geometryGroup.getChildAt(i) as SupSubRasterText);
				else if (geometryGroup.getChildAt(i) is GeometryGroup) svg += renderGeometryGroup(geometryGroup.getChildAt(i) as GeometryGroup);
			}
			
			svg+='</g>'
			return svg;
		}
			
		private function renderCircle(geometry:Circle):String {
			return printf('<circle cx="%f" cy="%f" r="%f" %s/>', geometry.centerX, geometry.centerY, geometry.radius, renderStrokeAndFill(geometry));
		}
		
		private function renderEllipse(geometry:Ellipse):String {
			return printf('<ellipse cx="%f" cy="%f" rx="%f" ry="%f" %s/>', geometry.x + geometry.width / 2, geometry.y + geometry.height / 2, geometry.width / 2, geometry.height / 2, renderStrokeAndFill(geometry));
		}
		
		private function renderLine(geometry:Line):String {
			return printf('<line x1="%f" y1="%f" x2="%f" y2="%f" %s/>', geometry.x, geometry.y, geometry.x1, geometry.y1, renderStrokeAndFill(geometry));
		}
		
		private function renderPath(geometry:Path):String {
			var pathData:Array = [];
			for (var i:uint; i < geometry.segments.length; i++) {
				if(geometry.segments[i].coordinateType=='absolute'){
					if (geometry.segments[i] is ClosePath) pathData.push('Z');
					else if (geometry.segments[i] is CubicBezierTo) pathData.push(printf('C %f,%f %f,%f %f,%f', geometry.segments[i].cx, geometry.segments[i].cy, geometry.segments[i].cx1, geometry.segments[i].cy1, geometry.segments[i].x, geometry.segments[i].y));						
					else if (geometry.segments[i] is EllipticalArcTo) pathData.push(printf('A %f,%f %f %f,%f %f,%f',geometry.segments[i].rx,geometry.segments[i].ry,geometry.segments[i].xAxisRotation,geometry.segments[i].largeArcFlag,geometry.segments[i].sweepFlag,geometry.segments[i].x,geometry.segments[i].y));
					else if (geometry.segments[i] is HorizontalLineTo) pathData.push(printf('H %f',geometry.segments[i].x));
					else if (geometry.segments[i] is LineTo) pathData.push(printf('L %f,%f',geometry.segments[i].x,geometry.segments[i].y));
					else if (geometry.segments[i] is MoveTo) pathData.push(printf('M %f,%f',geometry.segments[i].x,geometry.segments[i].y));
					else if (geometry.segments[i] is QuadraticBezierTo) pathData.push(printf('Q %f,%f %f,%f', geometry.segments[i].cx, geometry.segments[i].cy, geometry.segments[i].x, geometry.segments[i].y));						
					else if (geometry.segments[i] is VerticalLineTo) pathData.push(printf('V %f',geometry.segments[i].y));
				}else {
					if (geometry.segments[i] is ClosePath) pathData.push('z');
					else if (geometry.segments[i] is CubicBezierTo) pathData.push(printf('c %f,%f %f,%f %f,%f', geometry.segments[i].cx, geometry.segments[i].cy, geometry.segments[i].cx1, geometry.segments[i].cy1, geometry.segments[i].x, geometry.segments[i].y));						
					else if (geometry.segments[i] is EllipticalArcTo) pathData.push(printf('a %f,%f %f %f,%f %f,%f',geometry.segments[i].rx,geometry.segments[i].ry,geometry.segments[i].xAxisRotation,geometry.segments[i].largeArcFlag,geometry.segments[i].sweepFlag,geometry.segments[i].x,geometry.segments[i].y));
					else if (geometry.segments[i] is HorizontalLineTo) pathData.push(printf('h %f',geometry.segments[i].x));
					else if (geometry.segments[i] is LineTo) pathData.push(printf('l %f,%f',geometry.segments[i].x,geometry.segments[i].y));
					else if (geometry.segments[i] is MoveTo) pathData.push(printf('m %f,%f',geometry.segments[i].x,geometry.segments[i].y));
					else if (geometry.segments[i] is QuadraticBezierTo) pathData.push(printf('q %f,%f %f,%f', geometry.segments[i].cx, geometry.segments[i].cy, geometry.segments[i].x, geometry.segments[i].y));
					else if (geometry.segments[i] is VerticalLineTo) pathData.push(printf('v %f',geometry.segments[i].y));
				}
			}
			return printf('<path d="%s" %s/>',pathData.join(' '), renderStrokeAndFill(geometry));
		}
		
		private function renderPolygon(geometry:Polygon):String {
			var pointsData:Array = [];
			for (var i:uint = 0; i < geometry.points.length; i++) pointsData.push(geometry.points[i].x + ',' + geometry.points[i].y);
			return printf('<polygon points="%s" %s/>',pointsData.join(' '), renderStrokeAndFill(geometry));
		}
		
		private function renderRasterText(geometry:RasterText):String {
			return printf('<text x="%f" y="%f" font-size="%f">%s</text>', geometry.x+geometry.width/2, geometry.y + 1.1*geometry.fontSize, geometry.fontSize,geometry.text);
		}
		
		private function renderRegularRectangle(geometry:RegularRectangle):String {
			return printf('<rect x="%f" y="%f" width="%f" height="%f" %s/>', geometry.x, geometry.y, geometry.width, geometry.height, renderStrokeAndFill(geometry));
		}
		
		private function renderRoundedRectangle(geometry:RoundedRectangle):String {
			return printf('<rect x="%f" y="%f" width="%f" height="%f" rx="%f" ry="%f" %s/>', geometry.x, geometry.y, geometry.width, geometry.height, geometry.cornerRadius,geometry.cornerRadius, renderStrokeAndFill(geometry));
		}
		
		private function renderRenderableRepeater(geometry:RenderableRepeater):String {
			return renderObjectStack(geometry.getObjectStack());			
		}
		
		private function renderObjectStack(objectStack:Array):String {
			var svg:String = '';
			for each (var geometry:* in objectStack) {
				if (geometry is SupSubRasterText) svg += renderSupSubRasterText(geometry as SupSubRasterText);
				else if (geometry is GeometryGroup) svg += renderGeometryGroup(geometry as GeometryGroup);
				else if (geometry is Circle) svg += renderCircle(geometry as Circle);
				else if (geometry is Ellipse) svg += renderEllipse(geometry as Ellipse);
				else if (geometry is Line) svg += renderLine(geometry as Line);
				else if (geometry is Path) svg += renderPath(geometry as Path);
				else if (geometry is Polygon) svg += renderPolygon(geometry as Polygon);
				else if (geometry is RasterText) svg += renderRasterText(geometry as RasterText);
				else if (geometry is RegularRectangle) svg += renderRegularRectangle(geometry as RegularRectangle);
				else if (geometry is RoundedRectangle) svg += renderRoundedRectangle(geometry as RoundedRectangle);
				else if (geometry is RenderableRepeater) svg += renderRenderableRepeater(geometry as RenderableRepeater);
			}
			return svg;
		}
		
		private function renderStrokeAndFill(geometry:Geometry):String {
			return renderStroke(geometry.stroke) + renderFill(geometry.fill);
		}
		
		private function renderStroke(stroke:IGraphicsStroke):String {
			if (stroke == null) return ' stroke="none"';
			
			if (stroke is SolidStroke) {
				var solidStroke:SolidStroke = stroke as SolidStroke;
				return printf(' stroke="#%s"', ColorUtils.hexToDec(solidStroke.color as uint));
			}else if (stroke is LinearGradientStroke) {
				var idx:int = strokes.indexOf(stroke);
				if (idx == -1) { 
					strokes.push(stroke);
					idx = strokes.length - 1;
				}
				return printf(' stroke="url(#stroke_%d)"', idx);
			}
			
			return '';
		}
		
		private function renderFill(fill:IGraphicsFill):String {
			if (fill == null) return 'fill="none"';
			
			if (fill is SolidFill) {
				var solidFill:SolidFill = fill as SolidFill;
				return printf(' fill="#%s"', ColorUtils.hexToDec(solidFill.color as uint));
			}else if (fill is RadialGradientFill) {
				var idx:int = fills.indexOf(fill);
				if(idx==-1){
					fills.push(fill);
					idx = fills.length - 1;
				}
				return printf(' fill="url(#fill_%d)"', idx);
			}
			
			return '';
		}
		
	}
	
}