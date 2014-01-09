package edu.stanford.covertlab.graphics.shape 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Path;
	import flash.geom.Rectangle;
	import org.alivepdf.colors.RGBColor;
	
	/**
	 * Draws an ATPase.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/atpase.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ATPaseShape extends ComplexShapeBase
	{
		
		public function ATPaseShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			var path:Path;
			var ellipse:Ellipse;
			
			super(size, strokeColor, fillColor);
			
			var bounds:Rectangle = new Rectangle(0, 0, 30, 32);
			
			path = new Path('M 30,1 v 30 q -15,2 -30,0 v -30 q 15,-2 30,0 z');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 0,1 q 15,2 30,0 q -15,-2 -30,0 z'); 
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 10,1 q 5,1 10,0 v -10 h -10 v 10 z');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 0,1 q 15,-2 30,0 v 30 q -15,2 -30,0 v -30 q 15,2 30,0 m -20,0 q 5,1 10,0 v -10 h -10 v 10');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			ellipse = new Ellipse(15,-19,8,10);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
			
			ellipse = new Ellipse(11,-17,8,10);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
			
			ellipse = new Ellipse(19,-17,8,10);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
			
			ellipse = new Ellipse(15,-15,8,10);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);
			
			translateScale(size, bounds);
		}		
	}
	
}