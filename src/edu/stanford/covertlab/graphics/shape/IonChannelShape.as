package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Path;
	import flash.geom.Rectangle;
	
	/**
	 * Draws an ion channel.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/ionchannel.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class IonChannelShape extends ComplexShapeBase
	{
		
		public function IonChannelShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			var path:Path;
			super(size, strokeColor, fillColor);
			var bounds:Rectangle = new Rectangle(0, 0, 100, 138);
			
			path = new Path('M 0,13 q 50,-20 100,0 l -5,5 q -45,-20 -90,0 l -5,-5 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 5,18 q 45,-20 90,0 q -20,60 0,120 q -45,-20 -90,0 q 20,-60 0,-120 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 0,13 l 5,5 q 20,60 0,120 l -5,-5 q 20,-60 0,-120 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 100,13 q -20,60 0,120 l -5,5 q -20,-60 0,-120 l 5,-5 z');
			path.fill = fill;
			geometryCollection.addItem(path);

			path = new Path('M 0,13 q 50,-20 100,0 l -5,5 q -45,-20 -90,0 l -5,-5 q 20,60 0,120 l 5,5 q 20,-60 0,-120 m 90,0 q -20,60 0,120 l 5,-5 q -20,-60 0,-120 m -5,125 q -45,-20 -90,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			translateScale(size, bounds, [1.25, 1.25]);
		}
		
	}
	
}