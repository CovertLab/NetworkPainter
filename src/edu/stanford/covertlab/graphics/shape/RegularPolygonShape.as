package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.GraphicPoint;
	
	/**
	 * Draws a regular polygon.
	 * <ul>
	 * <li>diamond</li>
	 * <li>hexagon</li>
	 * <li>octagon</li>
	 * <li>pentagon</li>
	 * <li>septagon</li>
	 * <li>square</li>
	 * <li>triangle</li>
	 * </ul>
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/diamond.png" />
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/hexagon.png" />
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/octagon.png" />
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/pentagon.png" />
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/septagon.png" />
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/square.png" />
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/triangle.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class RegularPolygonShape extends PolygonShapeBase
	{
		public function RegularPolygonShape(size:Number, strokeColor:uint, fillColor:uint, nsides:uint=4,theta:Number=0)
		{		
			super(size, regularPolygonPoints(1, nsides), strokeColor, fillColor, theta);
		}
		
		protected function regularPolygonPoints(size:Number,nsides:uint, rotation:Number = 0):Array {
			var points:Array = [];
			var i:uint=0;
			for (i = 0; i < nsides; i++) {			
				points.push(new GraphicPoint(size*Math.sin(rotation+i / nsides * 2 * Math.PI), -size*Math.cos(rotation+i / nsides * 2 * Math.PI)));
			}
			return points;
		}
	}
	
}