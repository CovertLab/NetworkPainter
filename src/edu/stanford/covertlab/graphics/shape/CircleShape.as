package edu.stanford.covertlab.graphics.shape 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Circle;
	import com.degrafa.GraphicPoint;
	import org.alivepdf.colors.RGBColor;
	
	/**
	 * Draws a circle. Overrides base shape port function.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/circle.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class CircleShape extends ShapeBase
	{		
			
		public function CircleShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			this.size = size;
			super(size, strokeColor, fillColor);
			
			var circle:Circle = new Circle(0,0, size);
			circle.stroke = stroke;
			circle.fill = fill;
			geometryCollection.addItem(circle);
		}
				
		override public function port(theta:Number,sense:Boolean):GraphicPoint {
			return new GraphicPoint(size * Math.sin(theta), size * Math.cos(theta));
		}
		
	}
	
}