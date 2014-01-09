package edu.stanford.covertlab.util 
{	
	/**
	 * Miscellaneous utility functions for rotating, scaling, and reflecting arrays of graphic points
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class GraphicPointUtils 
	{
		
		public static function rotateScalePoints(graphicPoints:Array, scale:Number=1,rotation:Number = 0):Array {
			var theta:Number;
			var r:Number;
			for (var i:uint = 0; i < graphicPoints.length; i++) {
				r = Math.sqrt(Math.pow(graphicPoints[i].x, 2) + Math.pow(graphicPoints[i].y, 2));
				theta = Math.atan2(graphicPoints[i].y, graphicPoints[i].x);
				graphicPoints[i].x = r * scale * Math.cos(theta + rotation);
				graphicPoints[i].y = r * scale * Math.sin(theta + rotation);
			}
			return graphicPoints;
		}
			
		public static function reflectX(graphicPoints:Array):Array {
			for (var i:uint = 1; i < graphicPoints.length; i++) {
				graphicPoints[i].x *=-1;
			}
			return graphicPoints;
		}
		
		public static function reflectY(graphicPoints:Array):Array {
			for (var i:uint = 1; i < graphicPoints.length; i++) {
				graphicPoints[i].y *=-1;
			}
			return graphicPoints;
		}
		
	}
	
}