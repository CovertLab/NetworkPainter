package edu.stanford.covertlab.graphics.shape 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.GraphicPoint;
	import org.alivepdf.colors.RGBColor;
	
	/**
	 * Draws an ellipse. Overrides base shape port function.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/ellipse.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class EllipseShape extends ShapeBase
	{	
		public function EllipseShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			this.size = size;
			super(size, strokeColor, fillColor);
			
			var ellipse:Ellipse = new Ellipse(0-size, -0.75*size, 2*size, 1.5*size);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
		}
				
		override public function port(theta:Number, sense:Boolean):GraphicPoint {
			return new GraphicPoint(size * Math.sin(theta),0.75 * size * Math.cos(theta));
		}
	}
	
}