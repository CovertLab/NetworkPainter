package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Path;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a flagellum.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/flagellum.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class FlagellumShape extends ComplexShapeBase
	{
		
		public function FlagellumShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			var path:Path;
			super(size, strokeColor, fillColor);
			var bounds:Rectangle = new Rectangle(0,0,30,32);
			
			path = new Path('M 0,1 q 15,2 30,0 v 30 q -15,2 -30,0 v -30 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 0,1 q 15,2 30,0 q -15,-2 -30,0 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 10,1 q 5,1 10,0 v -5 q 2,-8 10,-10 h 15 v -10 h -25 q -8,2 -10,10 v 15 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 0,1 q 15,2 30,0 v 30 q -15,2 -30,0 v -30 q 15,-2 30,0 m -20,0 q 5,1 10,0 v -5 q 2,-8 10,-10 h 15 v -10 h -25 q -8,2 -10,10 v 15');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			translateScale(size, bounds);
		}
		
	}
	
}