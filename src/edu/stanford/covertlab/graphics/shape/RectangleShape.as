package edu.stanford.covertlab.graphics.shape 
{
	
	import br.com.stimuli.string.printf;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.geometry.RoundedRectangle;
	import com.degrafa.GraphicPoint;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a rectangle or rounded rectangle.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/rectangle.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class RectangleShape extends ShapeBase
	{
		
		private var rounded:Boolean;		
		
		public function RectangleShape(size:Number, strokeColor:uint, fillColor:uint, rounded:Boolean=false) 
		{
			this.size = size;
			this.rounded = rounded;
			
			super(size, strokeColor, fillColor);
			
			var rectangle:*;

			if (rounded) rectangle = new RoundedRectangle(-size, -0.75 * size, 2*size, 1.5 * size, 6);
			else rectangle = new RegularRectangle(-size, -0.75 * size, 2 * size, 1.5 * size);
						
			rectangle.stroke = stroke;
			rectangle.fill = fill;
			geometryCollection.addItem(rectangle);
		}
			
		override public function port(theta:Number, sense:Boolean):GraphicPoint {
			var points:Array = [];
			points.push(new GraphicPoint( -size, -0.75 * size));
			points.push(new GraphicPoint(size, -0.75 * size));
			points.push(new GraphicPoint(size, 0.75 * size));
			points.push(new GraphicPoint( -size, 0.75 * size));
			return computeConvexPolygonPort(points, theta, sense);
		}
	}
	
}