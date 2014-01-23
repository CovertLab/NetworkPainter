package edu.stanford.covertlab.graphics.renderablerepeater
{
	
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.geometry.repeaters.Repeater;
	import com.degrafa.paint.SolidFill;	
	import com.degrafa.paint.SolidStroke;
	import flash.display.Graphics;
	import flash.geom.Rectangle;

	[Bindable]
	/**
	 * Draws a rectangle containing a subrectangle of the same width for each element in the color array.
	 * Used by the Chart class as a color scale.
	 * 
	 * @see covertlab.stanford.edu.chart.Chart
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ColorBar extends RenderableRepeater{
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _colors:Array;
		private var _bounds:Rectangle;
		
		public function ColorBar(x:Number=0, y:Number=0, width:Number=0,
			height:Number=0, count:Number=0, colors:Array=null){
			
			super();
			
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			
			super.count = count;
			
			this.colors = colors;
		}
		
		override public function get x():Number{
			return _x;
		}
		override public function set x(value:Number):void{
			if(_x != value){
				_x = value;
				invalidated=true;
			}
		}
		
		override public function get y():Number{
			return _y;
		}
		override public function set y(value:Number):void{
			if(_y != value){
				_y = value;
				invalidated=true;
			}
		}
								
		override public function get width():Number{
			return _width;
		}
		override public function set width(value:Number):void{
			if(_width != value){
				_width = value;
				invalidated=true;
			}
		}
				
		override public function get height():Number{
			return _height;
		}
		override public function set height(value:Number):void{
			if(_height != value){
				_height = value;
				invalidated=true;	
			}
		}
				
		public function get colors():Array {
			return _colors;
		}
		public function set colors(value:Array):void {
			_colors = value;
			invalidated = true;
		}
		
		/**
		* The tight bounds of this element as represented by a Rectangle object. 
		**/
		override public function get bounds():Rectangle{
			return _bounds;	
		}
		
		
		/**
		* Calculates the bounds for this element. 
		**/
		private function calcBounds(unionRectangle:Rectangle):void{
			
			if(_bounds){
				_bounds = _bounds.union(unionRectangle);
			}
			else{
				_bounds = unionRectangle;
			}
		}	
		
		/**
		* @inheritDoc 
		**/
		override public function preDraw():void{
			if(invalidated) {
				
				objectStack = [];
				_bounds = null;
				
				var newRegularRectangle:RegularRectangle;
				
	    	    //loop calc and add the circle for each count    	
	        	for (var i:int = 0; i< count; i++) {	
	        		
	    			newRegularRectangle = new RegularRectangle(x, y + height * (1 - (i + 1) / count), width, height / count);
					//BUG: in Solid Fill for colors near 0x000500
					if (colors != null && colors.length > i) {
						newRegularRectangle.fill = new SolidFill(colors[i]);
						newRegularRectangle.stroke = new SolidStroke(colors[i]);
					}
        		
					//add to the bounds
					newRegularRectangle.preDraw();
        			calcBounds(newRegularRectangle.bounds);
        		
        			objectStack.push(newRegularRectangle);        		
				}
				
				//border
				newRegularRectangle = new RegularRectangle(x, y, width, height);
				newRegularRectangle.stroke = stroke;
				objectStack.push(newRegularRectangle);
			
				invalidated = false;	
			}
		}
		
		/**
		* Begins the draw phase for geometry objects. All geometry objects 
		* override this to do their specific rendering.
		* 
		* @param graphics The current context to draw to.
		* @param rc A Rectangle object used for fill bounds. 
		**/
		override public function draw(graphics:Graphics,rc:Rectangle):void{	
			
			preDraw();
			
        	var item:RegularRectangle;
        	
        	for each (item in objectStack){
        		//draw the item
				item.draw(graphics,rc);
			}
			
	    }
	}
}