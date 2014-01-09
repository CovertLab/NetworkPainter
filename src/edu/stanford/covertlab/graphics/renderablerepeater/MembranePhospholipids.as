package edu.stanford.covertlab.graphics.renderablerepeater
{
	
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.repeaters.Repeater;	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	[Bindable]
	/**
	 * Draws a curved phospholipid membrane with phospholipid heads and tails.
	 * Used by the compartment class.
	 * 
	 * @see covertlab.stanford.edu.diagram.core.Compartment
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class MembranePhospholipids extends RenderableRepeater{
		
		private var _membraneWidth:Number = 800;
		private var _membraneHeight:Number = 25;
		private var _membraneCurvature:Number = 25;
		private var _phospholipidHeadSize:Number = 5;
		private var _phospholipidLayers:Number = 2;
		private var _phospholipidTailGap:Number = 3;
		private var _bounds:Rectangle;
		
		public function MembranePhospholipids(membraneWidth:Number=800,membraneHeight:Number=25,membraneCurvature:Number=25,phospholipidHeadSize:Number=5, phospholipidLayers:Number=2, phospholipidTailGap:Number=3){
			
			super();
			
			this.membraneWidth = membraneWidth;
			this.membraneHeight = membraneHeight;
			this.membraneCurvature = membraneCurvature;
			this.phospholipidHeadSize=phospholipidHeadSize;
			this.phospholipidLayers=phospholipidLayers;
			this.phospholipidTailGap=phospholipidTailGap;	
		}
				
		public function get membraneWidth():Number{
			return _membraneWidth;
		}
		public function set membraneWidth(value:Number):void{
			if(_membraneWidth != value){
				_membraneWidth = value;
				invalidated=true;
			}
		}	
				
		public function get membraneHeight():Number{
			return _membraneHeight;
		}
		public function set membraneHeight(value:Number):void{
			if(_membraneHeight != value){
				_membraneHeight = value;
				invalidated=true;
			}
		}			
		
		public function get membraneCurvature():Number{
			return _membraneCurvature;
		}
		public function set membraneCurvature(value:Number):void{
			if(_membraneCurvature != value){
				_membraneCurvature = value;
				invalidated=true;
			}
		}	
				
		public function get phospholipidHeadSize():Number{
			return _phospholipidHeadSize;
		}
		public function set phospholipidHeadSize(value:Number):void{
			if(_phospholipidHeadSize != value){
				_phospholipidHeadSize = value;
				invalidated=true;
			}
		}	
				
		public function get phospholipidLayers():Number{
			return _phospholipidLayers;
		}
		public function set phospholipidLayers(value:Number):void{
			if(_phospholipidLayers != value){
				_phospholipidLayers = value;
				invalidated=true;
			}
		}	
				
		public function get phospholipidTailGap():Number{
			return _phospholipidTailGap;
		}
		public function set phospholipidTailGap(value:Number):void{
			if(_phospholipidTailGap != value){
				_phospholipidTailGap = value;
				invalidated=true;
			}
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
			if(invalidated){
				
				objectStack=[];
				_bounds = null;
				
				var newCircle:Circle;
				var newLine:Line;
				
				var offsetX:Number;
				var offsetY:Number;
				var y:Number;
				var x:Number;
				var i:Number;
				var t:Number;
				var cnt:Number;
				
				for (i=0; i < phospholipidLayers; i++) {
					offsetX = phospholipidHeadSize-((i * 2 / 3 * phospholipidHeadSize) % (2 * phospholipidHeadSize));
					offsetY = (i - (phospholipidLayers - 1) / 2) * 2 / 3 * phospholipidHeadSize;
					for (x = offsetX; x - phospholipidHeadSize <= membraneWidth; x += 2 * phospholipidHeadSize) {

						t = x / membraneWidth;
						y = offsetY - 2 * (1 - t) * t * membraneCurvature;
						
						//phospholipid heads
						newCircle = new Circle(x, y, phospholipidHeadSize);
						newCircle.fill = fill;
						newCircle.stroke = stroke;
						newCircle.accuracy = 8;
						newCircle.preDraw();						
						calcBounds(newCircle.bounds);
						objectStack.push(newCircle);
						
						newCircle = new Circle(x, y + membraneHeight, phospholipidHeadSize);
						newCircle.fill = fill;
						newCircle.stroke = stroke;
						newCircle.accuracy = 8;
						newCircle.preDraw();						
						calcBounds(newCircle.bounds);
						objectStack.push(newCircle);
						
						//phospholipid tails
						if (i == phospholipidLayers - 1) {
							newLine = new Line(x-phospholipidTailGap, y+phospholipidHeadSize+phospholipidTailGap, x-phospholipidTailGap, y+(membraneHeight-phospholipidTailGap)/2);
							newLine.stroke = stroke;
							newLine.preDraw();
							calcBounds(newLine.bounds);
							objectStack.push(newLine);
							
							newLine = new Line(x+phospholipidTailGap, y+phospholipidHeadSize+phospholipidTailGap, x+phospholipidTailGap, y+(membraneHeight-phospholipidTailGap)/2);
							newLine.stroke = stroke;
							newLine.preDraw();
							calcBounds(newLine.bounds);
							objectStack.push(newLine);
							
							newLine = new Line(x-phospholipidTailGap, y+(membraneHeight+phospholipidTailGap)/2, x-phospholipidTailGap, y+membraneHeight-phospholipidHeadSize-phospholipidTailGap);
							newLine.stroke = stroke;
							newLine.preDraw();
							calcBounds(newLine.bounds);
							objectStack.push(newLine);
							
							newLine = new Line(x+phospholipidTailGap, y+(membraneHeight+phospholipidTailGap)/2, x+phospholipidTailGap, y+membraneHeight-phospholipidHeadSize-phospholipidTailGap);
							newLine.stroke = stroke;
							newLine.preDraw();
							calcBounds(newLine.bounds);
							objectStack.push(newLine);
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