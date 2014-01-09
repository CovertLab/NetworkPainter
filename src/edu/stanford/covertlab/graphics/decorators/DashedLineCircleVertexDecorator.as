package edu.stanford.covertlab.graphics.decorators 
{
	import com.degrafa.decorators.standard.SVGDashLine;
	import flash.display.Graphics;
    import com.degrafa.decorators.RenderDecoratorBase;
	
	/**
	 * Extension of SVG dashed line decorator which adds 
	 * <ul>
	 * <li>circles at vertices</li>
	 * <li>squares at midpoints of line and curve segments</li>
	 * </ul>
	 * 
	 * @see com.degrafa.decorators.standard.SVGDashLine
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/13/2009
	 */
	public class DashedLineCircleVertexDecorator extends SVGDashLine
	{
		public var size:uint;
		public var strokeColor:uint;
		public var fillColor:uint;
		private var curX:Number;
		private var curY:Number;
		
		public function DashedLineCircleVertexDecorator(size:uint = 2, strokeColor:uint = 0x000000, fillColor:uint = 0xFFFFFF)		
		{
			this.size = size;
			this.strokeColor = strokeColor;
			this.fillColor = fillColor;			
			curX = curY = 0;			
			
			super();
		}		
        
        override public function moveTo(x:Number, y:Number, graphics:Graphics):void {
			super.moveTo(x, y, graphics);
			
			graphics.lineStyle(1, strokeColor);
			graphics.beginFill(fillColor);
            graphics.drawCircle(x, y, size);
			graphics.endFill();
			
			curX = x;
			curY = y;
        }
				
        override public function lineTo(x:Number, y:Number, graphics:Graphics):void {
			super.lineTo(x, y, graphics);
			
			graphics.lineStyle(1, strokeColor);
			
			var theta:Number = Math.atan2(x - curX, y - curY);
			graphics.beginFill(fillColor);
			graphics.moveTo(
				(curX + x) / 2 - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI / 4),			
				(curY + y) / 2 - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI / 4));
			graphics.lineTo(
				(curX + x) / 2 - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI * 3 / 4),			
				(curY + y) / 2 - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI * 3 / 4));
			graphics.lineTo(
				(curX + x) / 2 - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI * 5 / 4),			
				(curY + y) / 2 - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI  * 5 / 4));
			graphics.lineTo(
				(curX + x) / 2 - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI * 7 / 4),			
				(curY + y) / 2 - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI * 7 / 4));
			graphics.lineTo(
				(curX + x) / 2 - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI / 4),			
				(curY + y) / 2 - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI / 4));
			graphics.endFill();
			
			graphics.beginFill(fillColor);
			graphics.drawCircle(x, y, size);
			graphics.endFill();
			
			curX = x;
			curY = y;
        }
		
        override public function curveTo(cx:Number, cy:Number, x:Number, y:Number, graphics:Graphics):void {		
			super.curveTo(cx, cy, x, y, graphics);
			
			graphics.lineStyle(1, strokeColor);

			var theta:Number = Math.atan2(x - curX, y - curY);
			graphics.beginFill(fillColor);
			graphics.moveTo(
				1 / 4 * (curX + 2 * cx + x) - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI / 4),			
				1 / 4 * (curY + 2 * cy + y) - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI / 4));
			graphics.lineTo(
				1 / 4 * (curX + 2 * cx + x) - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI * 3 / 4),			
				1 / 4 * (curY + 2 * cy + y) - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI * 3 / 4));
			graphics.lineTo(
				1 / 4 * (curX + 2 * cx + x) - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI * 5 / 4),			
				1 / 4 * (curY + 2 * cy + y) - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI  * 5 / 4));
			graphics.lineTo(
				1 / 4 * (curX + 2 * cx + x) - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI * 7 / 4),			
				1 / 4 * (curY + 2 * cy + y) - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI * 7 / 4));
			graphics.lineTo(
				1 / 4 * (curX + 2 * cx + x) - 0.75 * size * Math.SQRT2 * Math.cos(theta+Math.PI / 4),			
				1 / 4 * (curY + 2 * cy + y) - 0.75 * size * Math.SQRT2 * Math.sin(theta + Math.PI / 4));
			graphics.endFill();
			
			graphics.beginFill(fillColor);
			graphics.drawCircle(x, y, size);
			graphics.endFill();
			
			curX = x;
			curY = y;
        }
	}
	
}