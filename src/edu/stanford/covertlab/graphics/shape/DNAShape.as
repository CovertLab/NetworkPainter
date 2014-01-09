package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Path;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a double helix.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/dna.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class DNAShape extends ComplexShapeBase
	{
		
		public function DNAShape(size:Number, strokeColor:uint, fillColor:uint)
		{			
			var path:Path;
			
			super(size, strokeColor, fillColor);
			
			var bounds:Rectangle = new Rectangle(0,0,158,46);
						
			path = new Path('M 2.8,23 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 6.4,29 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 10,35 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 32.2,35 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 35.8,29 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 39.4,23 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 43,17 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 46.1,11 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 66.4,11 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 70,17 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 74.8,23 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 78.4,29 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 82,35 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 104.2,35 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 107.8,29 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 111.4,23 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 115,17 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 118.6,11 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 138.4,11 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 142,17 h 9 v -2.2 h -9 z');
			path.stroke = stroke;
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 37,26 q -18,36 -36,0 v -7.2 q 18,36 36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 37,26 q -18,36 -36,0 v -7.2 q 18,36 36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			path = new Path('M 49,26 q -18,36 -36,0 v -7.2 q 18,36 36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 49,26 q -18,36 -36,0 v -7.2 q 18,36 36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			path = new Path('M 49,18.8 q 18,-36 36,0 v 7.2 q -18,-36 -36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 49,18.8 q 18,-36 36,0 m 0,7.2 q -18,-36 -36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			path = new Path('M 37,18.8 q 18,-36 36,0 v 7.2 q -18,-36 -36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 37,18.8 q 18,-36 36,0 m 0,7.2 q -18,-36 -36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			path = new Path('M 109,26 q -18,36 -36,0 v -7.2 q 18,36 36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 109,26 q -18,36 -36,0 m 0,-7.2 q 18,36 36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			path = new Path('M 121,26 q -18,36 -36,0 v -7.2 q 18,36 36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 121,26 q -18,36 -36,0 m 0,-7.2 q 18,36 36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			path = new Path('M 121,18.8 q 18,-36 36,0 v 7.2 q -18,-36 -36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 121,18.8 q 18,-36 36,0 v 7.2 q -18,-36 -36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			path = new Path('M 109,18.8 q 18,-36 36,0 v 7.2 q -18,-36 -36,0');
			path.fill = fill;
			geometryCollection.addItem(path);
			
			path = new Path('M 109,18.8 q 18,-36 36,0 v 7.2 q -18,-36 -36,0');
			path.stroke = stroke;
			geometryCollection.addItem(path);
			
			translateScale(size, bounds, [3, 3]);
			
			labelOffsetY = 3 * bounds.height * size / Math.max(bounds.width, bounds.height) + 5;			
		}
		
	}
	
}