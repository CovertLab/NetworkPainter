package edu.stanford.covertlab.graphics.shape 
{	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.GraphicPoint;
	
	/**
	 * Draws a trapezium.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/trapezium.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class TrapeziumShape extends PolygonShapeBase
	{
		override public function TrapeziumShape(size:Number, strokeColor:uint, fillColor:uint, theta:Number=0) 
		{
			var points:Array = [];
			points.push(new GraphicPoint(-0.5, -0.75));
			points.push(new GraphicPoint(0.5, -0.75));
			points.push(new GraphicPoint(1, 0.75));
			points.push(new GraphicPoint(-1, 0.75));			
			super(size,points, strokeColor, fillColor, theta);
		}
		
	}
	
}