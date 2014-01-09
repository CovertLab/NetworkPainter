package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Path;
	import com.degrafa.GraphicPoint;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a y-shaped receptor. Overrides base shape port function.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/yreceptor.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class YReceptorShape extends ComplexShapeBase
	{
		
		public function YReceptorShape(size:Number, strokeColor:uint, fillColor:uint) 
		{
			var path:Path;
			
			super(size, strokeColor, fillColor);
			
			var bounds:Rectangle = new Rectangle(0, -40, 120, 80);
			
			path = new Path('M 0,-80 h 40 l 20,40 l 20,-40 h 40 l -40,80 v 80 h -40 v -80 l -40,-80 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			translateScale(size, bounds, [1.25, 1.25]);
		}
		
		override public function port(theta:Number, sense:Boolean):GraphicPoint {
			var tx:Number = -60;
			var ty:Number = -40;
			var scale:Number = 2 * size / 120;
			
			var points:Array = [
				new GraphicPoint(translateScalePoint(120, tx, scale), translateScalePoint( -80, ty, scale)),
				new GraphicPoint(translateScalePoint(120, tx, scale), translateScalePoint( -80, ty, scale)),
				new GraphicPoint(translateScalePoint(80, tx, scale), translateScalePoint( 0, ty, scale)),
				new GraphicPoint(translateScalePoint(80, tx, scale), translateScalePoint( 80, ty, scale)),
				new GraphicPoint(translateScalePoint(40, tx, scale), translateScalePoint( 80, ty, scale)),
				new GraphicPoint(translateScalePoint(40, tx, scale), translateScalePoint( 0, ty, scale))];
			
			return computeConvexPolygonPort(points, theta, sense);
		}
		
	}
	
}