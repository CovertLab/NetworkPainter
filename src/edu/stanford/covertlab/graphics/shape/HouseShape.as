package edu.stanford.covertlab.graphics.shape 
{	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.GraphicPoint;

	/**
	 * Draws an ATPase.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/house.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class HouseShape extends PolygonShapeBase
	{
		override public function HouseShape(size:Number, strokeColor:uint, fillColor:uint, theta:Number=0) 
		{
			var points:Array = [];
			points.push(new GraphicPoint( -1, -0.25));
			points.push(new GraphicPoint(0, -1));
			points.push(new GraphicPoint(1, -0.25));
			points.push(new GraphicPoint(1, 0.5));
			points.push(new GraphicPoint(-1, 0.5));
			super(size, points, strokeColor, fillColor, theta);
		}
	}
	
}