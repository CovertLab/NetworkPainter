package edu.stanford.covertlab.graphics.shape 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.GraphicPoint;
	import edu.stanford.covertlab.util.GraphicPointUtils;
	import org.alivepdf.colors.RGBColor;
	
	/**
	 * Base class for convex polygon shapes. Overrides base shape port function.
	 * 
	 * @see HouseShape
	 * @see ParallelogramShape
	 * @see RegularPolygonShape
	 * @see RectangleShape
	 * @see TrapeziumShape
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class PolygonShapeBase extends ShapeBase
	{
		public function PolygonShapeBase(size:Number, points:Array,  strokeColor:uint, fillColor:uint, theta:Number) 
		{			
			super(size, strokeColor, fillColor);
			var polygon:Polygon = new Polygon(GraphicPointUtils.rotateScalePoints(points,size,theta));
			polygon.stroke = stroke;
			polygon.fill = fill;
			geometryCollection.addItem(polygon);
		}
				
		override public function port(theta:Number, sense:Boolean):GraphicPoint {
			return computeConvexPolygonPort(geometry[0].points, theta, sense);
		}		
	}
	
}