package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.GeometryComposition;
	import com.degrafa.GeometryGroup;
	import com.degrafa.GraphicPoint;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientStroke;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.paint.VectorFill;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * Base class for shapes. Defines port function base on shape bounding box.
	 * 
	 * @see CircleShape
	 * @see ComplexShapeBase
	 * @see EllipseShape	 
	 * @see PolygonShapeBase
	 * @see RectangleShape
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ShapeBase extends GeometryGroup
	{
		protected var size:Number;
		protected var theta:Number;
		public var labelOffsetX:Number = 0;
		public var labelOffsetY:Number = 0;
		
		protected var _strokeColor:uint;
		protected var _fillColor:uint;
		protected var _solidColor:Boolean = false;
		protected var _hash:Boolean = false;
		
		private var gradientFill:RadialGradientFill;
		private var fillStop_white:GradientStop;
		private var fillStop_color:GradientStop;
		private var gradientStroke:LinearGradientStroke;
		private var strokeStop_white:GradientStop;
		private var strokeStop_color:GradientStop;
		private var hashFill:VectorFill;
		private var hashStroke:SolidStroke;
		
		public function ShapeBase(size:Number = 0, strokeColor:uint = 0x000000, fillColor:uint = 0x000000):void {			
			super();
			
			//fill
			gradientFill = new RadialGradientFill();
			fillStop_white = new GradientStop(0xFFFFFF, 1, 0.10);
			fillStop_color = new GradientStop(fillColor, 1, 0.95);
			gradientFill.gradientStopsCollection.addItem(fillStop_white);
			gradientFill.gradientStopsCollection.addItem(fillStop_color);
			fill = gradientFill;			
			
			//stroke
			gradientStroke = new LinearGradientStroke();
			gradientStroke.focalPointRatio = 0.5;
			strokeStop_color = new GradientStop(0x000000, 1, 0.05);
			strokeStop_white = new GradientStop(strokeColor, 1, 0.95);
			gradientStroke.gradientStopsCollection.addItem(strokeStop_color);
			gradientStroke.gradientStopsCollection.addItem(strokeStop_white);
			stroke = gradientStroke;
			
			//hash fill
			var hashSource:GeometryComposition = new GeometryComposition();
			hashStroke = new SolidStroke(0x000000, 0.5);
			
			var regularRectangle:RegularRectangle = new RegularRectangle(0, 0, 20, 20);
			regularRectangle.fill = new SolidFill(0xFFFFFF);
			hashSource.geometryCollection.addItem(regularRectangle);
			
			var line:Line = new Line(0, 0, 20, 20);
			line.stroke = hashStroke;
			hashSource.geometryCollection.addItem(line);
			
			line = new Line(0, 20, 20, 0);
			line.stroke = hashStroke;
			hashSource.geometryCollection.addItem(line);
			
			hashFill = new VectorFill(hashSource);
			hashFill.clipSource = new RegularRectangle(0, 0, 20, 20);
			hashFill.repeatX = 'repeat';
			hashFill.repeatY = 'repeat';
			
			this.size = size;
			this.fillColor = fillColor;
			this.strokeColor = strokeColor;
		}
		
		public function get strokeColor():uint {
			return _strokeColor;
		}		
		public function set strokeColor(value:uint):void {
			if (_strokeColor != value) {
				_strokeColor = value;
				strokeStop_white.color = value;
				if (solidColor) strokeStop_color.color = value;
			}
		}
		
		public function get fillColor():uint {
			return _fillColor;
		}		
		public function set fillColor(value:uint):void {
			if (_fillColor != value) {
				_fillColor = value;
				fillStop_color.color = value;
				if (solidColor) fillStop_white.color = value;
				hashStroke.color = value;
			}
		}
		
		public function get solidColor():Boolean {
			return _solidColor;
		}		
		public function set solidColor(value:Boolean):void {
			if (_solidColor != value) {
				_solidColor = value;
				if (_solidColor) {
					fillStop_white.color = fillColor;
					strokeStop_color.color = strokeColor;
				}else {
					fillStop_white.color = 0xFFFFFF;
					strokeStop_color.color = 0x000000;
				}
			}
		}
		
		public function get hash():Boolean {
			return _hash;
		}
		public function set hash(value:Boolean):void {
			if (value != hash) {
				_hash = value;
				for (var i:uint = 0; i < geometry.length; i++) {
					if (hash) geometry[i].fill = hashFill;
					else geometry[i].fill = fill;
				}
			}
		}

		public function getPortBounds():Rectangle {						
			var minX:Number=Infinity;
			var minY:Number=Infinity;
			var maxX:Number=-Infinity;
			var maxY:Number=-Infinity;
			
			for (var i:uint = 0; i < geometry.length; i++) {
				if (geometry[i].fill == null) continue;
				minX = Math.min(minX, geometry[i].bounds.x);
				minY = Math.min(minY, geometry[i].bounds.y);
				maxX = Math.max(maxX, geometry[i].bounds.x + geometry[i].bounds.width);
				maxY = Math.max(maxY, geometry[i].bounds.y + geometry[i].bounds.height);
			}
			
			if (minX == Infinity) minX = minY = maxX = maxY = 0;
			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
		public function port(theta:Number, sense:Boolean):GraphicPoint {
			return computeConvexPolygonPort(rectangleToPoints(getPortBounds()), theta, sense);
		}
		
		protected function computeConvexPolygonPort(points:Array, theta:Number, sense:Boolean):GraphicPoint {
			var i:uint;
			var thetaPrev:Number = Math.atan2(points[0].x, points[0].y);
			var thetaNext:Number;
			var portX:Number;
			var portY:Number;
			var m:Number;
			var b:Number;
			
			theta = normalizeAngle(theta);
			
			//loop over all edges
			points.push(points[0]);
			for (i = 0; i < points.length-1; i++) {
				if (theta == thetaPrev) return points[i];
				
				//compute angles from center (0,0) of shape to vertices of edge
				thetaNext = Math.atan2(points[i + 1].x, points[i + 1].y);
				
				//check if angle of regulation line (line from centers of biomolecules) is between angles of the two vertices of the biomolecule's shape's edge
				//angles of consecutive vertices must be decreasing (eg as in regular polygons)
				if ((theta > thetaNext && theta <= thetaPrev) ||  
				    (thetaPrev <= 0 && thetaNext > 0 && (theta<= thetaPrev || theta>thetaNext)))
				{					
					//compute intersection of regulation line and shape edge
					if (Math.abs(theta) == Math.PI / 2) {
						portY = 0;
						if(points[i].y!=points[i+1].y){
							portX = points[i].x + points[i].y * (points[i].x - points[i + 1].x) / (points[i].y - points[i + 1].y);
						}else {
							portX = (points[i].x + points[i + 1].x) / 2;
						}
					}else if (points[i + 1].x == points[i].x) {
						portX = points[i].x;
						portY = portX / Math.tan(theta);
					}else  {
						m = (points[i + 1].y - points[i].y) / (points[i + 1].x - points[i].x);
						b = points[i].y - m * points[i].x;
						portY = b / (1 - m * Math.tan(theta));
						portX = portY * Math.tan(theta);
					}					
					return new GraphicPoint(portX, portY);
				}
			
				thetaPrev = thetaNext;
			}
			return new GraphicPoint(0, 0);
		}
		
		//put angle on range [-PI,PI]
		protected function normalizeAngle(theta:Number):Number {
			if (theta < 0) theta = 2 * Math.PI * Math.ceil(Math.abs(theta) / (2 * Math.PI)) + theta;			
			theta += Math.PI;
			theta = theta % (2 * Math.PI);
			theta -= Math.PI;
			return theta;
		}		
		
		protected function rectangleToPoints(rectangle:Rectangle):Array {
			return [
				new GraphicPoint(rectangle.x, rectangle.y),
				new GraphicPoint(rectangle.x + rectangle.width, rectangle.y),
				new GraphicPoint(rectangle.x + rectangle.width, rectangle.y + rectangle.height),
				new GraphicPoint(rectangle.x, rectangle.y + rectangle.height)];				
		}
	}
	
}