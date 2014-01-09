package edu.stanford.covertlab.graphics 
{
	import com.degrafa.decorators.standard.SVGDashLine;
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import flash.geom.Rectangle;
	
	/**
	 * Displays select handles (dashed lines, circles at verticles, squares at midpoints of segments)
	 * for a geometry group.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/14/2009
	 */
	public class SelectHandles extends GeometryGroup
	{		
		protected var decorators:Array;
		protected var handlesFill:SolidFill;
		protected var handlesStroke:SolidStroke;
		
		public function SelectHandles(size:Number, fillColor:uint = 0xFFFFFF, strokeColor:uint = 0x000000) 		
		{
			handlesFill = new SolidFill(fillColor);
			handlesStroke = new SolidStroke(strokeColor);	
			
			var decorator:SVGDashLine = new SVGDashLine();
			decorator.dashArray = [size / 10, size / 10];
			decorators = [decorator];
		}
		
		public function refresh(shapeBounds:Rectangle):void {
			var square:RegularRectangle;
			var circle:Circle;			
			
			geometry = [];
			
			//lines
			var lines:RegularRectangle = new RegularRectangle(shapeBounds.left, shapeBounds.top, shapeBounds.width, shapeBounds.height);						
			lines.decorators = decorators;
			lines.stroke = handlesStroke;
			geometryCollection.addItem(lines);
			
			//squares
			square = new RegularRectangle((shapeBounds.left + shapeBounds.right) / 2 - 1.5, shapeBounds.top - 1.5, 3, 3);
			square.fill = handlesFill;
			square.stroke = handlesStroke;
			geometryCollection.addItem(square);
			
			square = new RegularRectangle(shapeBounds.right - 1.5, (shapeBounds.top + shapeBounds.bottom) / 2 - 1.5, 3, 3);
			square.fill = handlesFill;
			square.stroke = handlesStroke;
			geometryCollection.addItem(square);
			
			square = new RegularRectangle((shapeBounds.left + shapeBounds.right) / 2 - 1.5, shapeBounds.top - 1.5, 3, 3);
			square.fill = handlesFill;
			square.stroke = handlesStroke;
			geometryCollection.addItem(square);
			
			square = new RegularRectangle(shapeBounds.left - 1.5, (shapeBounds.top + shapeBounds.bottom) / 2 - 1.5, 3, 3);
			square.fill = handlesFill;
			square.stroke = handlesStroke;
			geometryCollection.addItem(square);
						
			//circles			
			circle = new Circle(shapeBounds.left, shapeBounds.top, 2);
			circle.fill = handlesFill;
			circle.stroke = handlesStroke;
			geometryCollection.addItem(circle);
			
			circle = new Circle(shapeBounds.right, shapeBounds.top, 2);
			circle.fill = handlesFill;
			circle.stroke = handlesStroke;
			geometryCollection.addItem(circle);
			
			circle = new Circle(shapeBounds.right, shapeBounds.bottom, 2);
			circle.fill = handlesFill;
			circle.stroke = handlesStroke;
			geometryCollection.addItem(circle);
			
			circle = new Circle(shapeBounds.left, shapeBounds.bottom, 2);
			circle.fill = handlesFill;
			circle.stroke = handlesStroke;
			geometryCollection.addItem(circle);
		}
		
	}
	
}