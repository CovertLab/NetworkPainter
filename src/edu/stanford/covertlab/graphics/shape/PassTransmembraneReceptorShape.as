package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Path;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a 7-pass transmembrane receptor.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/7passreceptor.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class PassTransmembraneReceptorShape extends ComplexShapeBase
	{
		
		public function PassTransmembraneReceptorShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			var path:Path;
			var ellipse:Ellipse;
			
			super(size, strokeColor, fillColor);
			
			var bounds:Rectangle = new Rectangle(0, -40, 159, 117);
			
			ellipse = new Ellipse(8,20,8,20);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
			
			ellipse = new Ellipse(28,20,8,20);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);

			ellipse = new Ellipse(48,20,8,20);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);

			ellipse = new Ellipse(68,20,8,20);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);

			ellipse = new Ellipse(88,20,8,20);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);

			ellipse = new Ellipse(108,20,8,20);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);

			ellipse = new Ellipse(128,20,8,20);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
			
			path = new Path(
				'M 150,-40 '+
				'c -30,40 -150,-10 -142,40 '+
				'm 0,40 '+
				'c -10,20 30,20 20,0 '+
				'm 0,-40 '+
				'c -10,-20 30,-20 20,0 '+
				'm 0,40 '+
				'c -10,20 30,20 20,0 '+
				'm 0,-40 '+
				'c -10,-20 30,-20 20,0 '+
				'm 0,40 '+
				'c -10,40 -60,20 -80,30 '+
				'c 10,5 100,10 100,-30 '+
				'm 0,-40 '+
				'c -10,-20 30,-20 20,0 '+
				'm 0,40 '+
				'q 0,20 30,12');
			path.stroke = stroke;
			geometryCollection.addItem(path);
						
			translateScale(size, bounds, [2.5, 2.5]);
			
			labelOffsetY = 2.5 * bounds.height * size / Math.max(bounds.width, bounds.height) + 5;
		}
		
	}
	
}