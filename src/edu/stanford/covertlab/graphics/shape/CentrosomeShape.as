package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Path;
	import com.degrafa.GraphicPoint;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a centrosome. Overrides base port function with an ellipse-based port function.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/centrosome.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class CentrosomeShape extends ComplexShapeBase
	{
		
		public function CentrosomeShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			var ellipse:Ellipse;
			var path:Path;
			
			super(size, strokeColor, fillColor);
			
			var bounds:Rectangle = new Rectangle(0,0,20,20);
			
			ellipse = new Ellipse(10,10,10,10);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
			
			path = new Path(
				'M 10,0 '+
				'v -20 '+
				'M 10,20 '+
				'v 20 '+
				'M 19,5 '+
				'l 17,-10 '+
				'M 19,15 '+
				'l 17,10 '+
				'M 1,15 '+
				'l -17,10 '+
				'M 1,5 '+
				'l -17,-10');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			translateScale(size, bounds);
		}
		
		override public function port(theta:Number, sense:Boolean):GraphicPoint {
			return new GraphicPoint(size * Math.sin(theta), size * Math.cos(theta));
		}
		
	}
	
}