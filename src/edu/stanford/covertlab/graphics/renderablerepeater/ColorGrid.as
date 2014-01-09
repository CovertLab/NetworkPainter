package edu.stanford.covertlab.graphics.renderablerepeater
{
	
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.geometry.repeaters.Repeater;
	import com.degrafa.paint.SolidFill;	
	import com.degrafa.paint.SolidStroke;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	[Bindable]
	/**
	 * Draws a grid containing a rectangle for each element in the colors array.
	 * Used by the chart and biomolecule classes to draw heatmaps.
	 * 
	 * @see covertlab.stanford.edu.chart.Chart
	 * @see covertlab.stanford.edu.diagram.core.Biomolecule
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ColorGrid extends RenderableRepeater{
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _rows:uint = 0;
		private var _cols:uint = 0;
		private var _colors:Array = [];
		private var _bounds:Rectangle;
		
		public function ColorGrid(x:Number=0,y:Number=0,width:Number=0,
			height:Number=0,rows:uint=0,cols:uint=0,colors:Array=null){
			
			super();
			
			updateProperties(x, y, width, height, rows, cols, colors);
		}
		
		public function updateProperties(x:Number=0,y:Number=0,width:Number=0,
			height:Number = 0, rows:uint = 0, cols:uint = 0, colors:Array = null):void {
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			_rows = rows;
			_cols = cols;
			_colors = (colors != null ? colors : []);
			invalidated = true;
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
		
		public function get rows():uint {
			return _rows;
		}
		public function set rows(value:uint):void {
			if (value != _rows) {
				_rows = value;
				invalidated = true;
			}
		}
		
		public function get cols():uint {
			return _cols;
		}
		public function set cols(value:uint):void {
			if (value != _cols) {
				_cols = value;
				invalidated = true;
			}
		}
		
		public function get colors():Array {
			return _colors;
		}
		public function set colors(value:Array):void {
			_colors = (value != null ? value : []);
			invalidated = true;
		}

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
			if(invalidated){
				
				objectStack=[];
				_bounds = null;
				
				var i:int;				
				var j:int;
				var newRegularRectangle:RegularRectangle;
				var newLine:Line;
				
	    	    //loop calc and add the circle for each count    	
	        	for (i = 0; i < rows; i++) {					
	        		for (j = 0; j < cols; j++) {
						if ((j + i * cols) >= colors.length) continue;
						newRegularRectangle = new RegularRectangle(x + j * width / cols, y + i * height / rows, width / cols, height / rows);						
						newRegularRectangle.stroke = stroke;
						if (colors != null && colors.length > j + i * cols){
							newRegularRectangle.fill = new SolidFill(isNaN(colors[j + i * cols]) ? 0xFFFFFF :colors[j + i * cols]);
							newRegularRectangle.preDraw();
							calcBounds(newRegularRectangle.bounds);						
							objectStack.push(newRegularRectangle);							
							
							if (isNaN(colors[j + i * cols])) {
								newLine = new Line(x + j * width / cols, y + i * height / rows,
									x + (j + 1) * width / cols, y + (i + 1) * height / rows);
								newLine.stroke = new SolidStroke(0xFF0000, 0.5);
								newLine.preDraw();
								calcBounds(newLine.bounds);					
								objectStack.push(newLine);
									
								newLine = new Line(x + (j+1) * width / cols, y + i * height / rows,
									x + j * width / cols, y + (i + 1) * height / rows);
								newLine.stroke = new SolidStroke(0xFF0000, 0.5);
								newLine.preDraw();
								calcBounds(newLine.bounds);					
								objectStack.push(newLine);
							}
						}						
					}
				}
				invalidated=false;	
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
			
        	var item:*;
        	
        	for each (item in objectStack){
        		//draw the item
				item.draw(graphics,rc);
			}
			
	    }
	}
}