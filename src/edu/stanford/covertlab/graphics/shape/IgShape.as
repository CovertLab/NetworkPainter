package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Path;
	import com.degrafa.GraphicPoint;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a Ig receptor. Overrides base shape port function with bounds base on a convex polygon
	 * bounding the shape.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/ig.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class IgShape extends ComplexShapeBase
	{
		
		public function IgShape(size:Number, strokeColor:uint, fillColor:uint) 
		{
			var path:Path;
			super(size, strokeColor, fillColor);
			var bounds:Rectangle = new Rectangle(0, 0, 127, 131);
			
			path = new Path('M63,55 h10 v10 h-10 v-10 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 38,35 l-3,3 l2,2 l3,-3 l-2,-2 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 98,35 l3,3 l-2,2 l-3,-3 l2,-2 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 13,10 l 10,-10 l 40,40 v 80 h -14.1421 v -74.1421 l -35.8579,-35.8579 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 123,10 l -10,-10 l -40,40 v 80 h 14.1421 v -74.1421 l 35.8579,-35.8579 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 10,13 l -10,10 l 35,35 l 10,-10 l -35,-35 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 126,13 l 10,10 l -35,35 l -10,-10 l 35,-35 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M63,55 '+
				'h10 '+
				'v10 '+
				'h-10 '+
				'v-10 '+
				'M38,35 '+
				'l-3,3 '+
				'l2,2 '+
				'l3,-3 '+
				'l-2,-2 '+
				'M98,35 '+
				'l3,3 '+
				'l-2,2 '+
				'l-3,-3 '+
				'l2,-2 '+
				'M 13,10 '+
				'l 10,-10 '+
				'l 40,40 '+
				'v 80 '+
				'h -14.1421 '+
				'v -74.1421 '+
				'l -35.8579,-35.8579 '+
				'M 123,10 '+
				'l -10,-10 '+
				'l -40,40 '+
				'v 80 '+
				'h 14.1421 '+
				'v -74.1421 '+
				'l 35.8579,-35.8579 '+
				'M 13,10 '+
				'm -3,3 '+
				'l -10,10 '+
				'l 35,35 '+
				'l 10,-10 '+
				'l -35,-35 '+
				'M 123,10 '+
				'm 3,3 '+
				'l 10,10 '+
				'l -35,35 '+
				'l -10,-10 '+
				'l 35,-35');
			path.stroke = stroke;
			geometryCollection.addItem(path);
						
			translateScale(size, bounds, [2.0, 2.0]);
		}
		
		override public function port(theta:Number, sense:Boolean):GraphicPoint {					
			var tx:Number = -127/2;
			var ty:Number = -131/2;
			var scale:Number = 2 * size / 131;
			
			var points:Array = [
				new GraphicPoint(translateScalePoint(13, tx, scale), translateScalePoint(10, ty, scale)),				
				new GraphicPoint(translateScalePoint(23, tx, scale), translateScalePoint(0, ty, scale)),				
				new GraphicPoint(translateScalePoint(113, tx, scale), translateScalePoint(0, ty, scale)),				
				new GraphicPoint(translateScalePoint(123, tx, scale), translateScalePoint(10, ty, scale)),
				new GraphicPoint(translateScalePoint(126, tx, scale), translateScalePoint(13, ty, scale)),			
				new GraphicPoint(translateScalePoint(136, tx, scale), translateScalePoint(23, ty, scale)),				
				new GraphicPoint(translateScalePoint(87, tx, scale), translateScalePoint(72, ty, scale)),				
				new GraphicPoint(translateScalePoint(87, tx, scale), translateScalePoint(120, ty, scale)),					
				new GraphicPoint(translateScalePoint(49, tx, scale), translateScalePoint(120, ty, scale)),				
				new GraphicPoint(translateScalePoint(49, tx, scale), translateScalePoint(72, ty, scale)),				
				new GraphicPoint(translateScalePoint(0, tx, scale), translateScalePoint(23, ty, scale))];				
			
			return computeConvexPolygonPort(points, theta, sense)
		}
	}
	
}