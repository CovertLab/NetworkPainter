package edu.stanford.covertlab.chart 
{
	import com.degrafa.geometry.Line;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.Surface;
	import edu.stanford.covertlab.colormap.Colormap;
	import edu.stanford.covertlab.graphics.rasterizer.SVGRasterizer;
	import edu.stanford.covertlab.graphics.renderablerepeater.ColorBar;
	import edu.stanford.covertlab.graphics.renderer.GIFRenderer;
	import edu.stanford.covertlab.graphics.renderer.JPEGRenderer;
	import edu.stanford.covertlab.graphics.renderer.PNGRenderer;
	import edu.stanford.covertlab.graphics.renderer.SVGRenderer;
	import edu.stanford.covertlab.graphics.SupSubRasterText;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mx.containers.Canvas;
	
	/**
	 * Displays color scale bar with labels.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/20/2009
	 */
	public class ColorScale extends Canvas
	{
		private var surface:Surface;
		private var colorBar:ColorBar;
		private var labelsGeometryGroup:GeometryGroup;
		
		private var _colormap:String;
		private var _scale:Array;
		
		public function ColorScale(colormap:String, scale:Array, colorBarWidth:uint = 20, colorBarHeight:uint = 200) 		
		{			
			var geometryGroup:GeometryGroup;
			var colors:Array;
			var i:uint;
			
			//properties
			_colormap = colormap;
			clipContent = false;
			useHandCursor = true;
			buttonMode = false;
			
			//surface
			surface = new Surface();
			surface.y = 5;
			addChild(surface);
			
			//geometry group
			geometryGroup = new GeometryGroup();
			geometryGroup.target = surface;
			surface.addChild(geometryGroup);
			
			//color bar
			colors = [];
			for (i = 0; i < 101; i++) colors.push(Colormap.scale(colormap, i / 100));			
			colorBar = new ColorBar(0, 0, colorBarWidth, colorBarHeight, colors.length, colors);
			colorBar.stroke = new SolidStroke(0x999999, 1, 2);
			geometryGroup.geometryCollection.addItem(colorBar);
						
			//color scale labels
			labelsGeometryGroup = new GeometryGroup();
			labelsGeometryGroup.x = colorBarWidth - 6;
			labelsGeometryGroup.target = surface;
			surface.addChild(labelsGeometryGroup);
			
			this.scale = scale;
			
			//dragging
			addEventListener(MouseEvent.MOUSE_DOWN, drag);
			addEventListener(MouseEvent.MOUSE_UP, dragEnd);
		}
		
		/**********************************************************
		 * setters, getters
		 * *******************************************************/
		override public function get width():Number {
			return colorBarWidth + labelsGeometryGroup.width - 6;
		}
		 
		public function get colorBarWidth():uint {
			return colorBar.width;
		}
		
		public function set colorBarWidth(value:uint):void {
			if (value != colorBar.width) {
				colorBar.width = value;
				labelsGeometryGroup.x = colorBarWidth - 6;
			}
		}
		
		public function get colorBarHeight():uint {
			return colorBar.height;
		}
		
		public function set colorBarHeight(value:uint):void {
			if (value != colorBar.height) {
				colorBar.height = value;
				for (var i:uint = 0; i < labelsGeometryGroup.numChildren; i++) {
					labelsGeometryGroup.getChildAt(i).y = 
						colorBarHeight * (labelsGeometryGroup.numChildren - i - 1) / (labelsGeometryGroup.numChildren - 1);
				}
			}
		}
		
		public function get colormap():String {
			return _colormap;
		}
		
		public function set colormap(value:String):void {
			if (value != _colormap) {
				_colormap = value;
				
				var colors:Array = [];
				for (var i:uint = 0; i < 101; i++) colors.push(Colormap.scale(colormap, i / 100));
				colorBar.colors = colors;				
			}
		}
		
		public function get scale():Array {
			return _scale;
		}
		
		public function set scale(value:Array):void {
			_scale = value;
			var line:Line;
			var stroke:SolidStroke = new SolidStroke(0x999999, 1, 2);
			var fill:SolidFill = new SolidFill(0x999999, 1);
			var labelsWidth:Number = 0;
			
			while (labelsGeometryGroup.numChildren > 0) 
				labelsGeometryGroup.removeChildAt(0);
			labelsGeometryGroup.geometry = [];
					
			for (var i:uint = 0; i < scale.length; i++) {
				var geometryGroup:GeometryGroup = new GeometryGroup();
				geometryGroup.y = colorBarHeight * (scale.length - i - 1) / (scale.length - 1);
				geometryGroup.target = labelsGeometryGroup;
				labelsGeometryGroup.addChild(geometryGroup);
				
				line = new Line(0, 0, 12, 0);
				line.stroke = stroke;
				geometryGroup.geometryCollection.addItem(line);				
				
				var tmp:Array = scale[i].toPrecision(3).split('e');				
				var label:SupSubRasterText = new SupSubRasterText();
				label.fill = fill;
				label.text = tmp[0] + (tmp.length > 1 ? ' &#215; 10<sup>' + tmp[1].replace('+', '') + '</sup>' : '');
				label.y = -8;
				label.x = 12;
				label.target = geometryGroup;
				labelsWidth = Math.max(labelsWidth, label.width);
				geometryGroup.addChild(label);
			}
			labelsGeometryGroup.width = labelsWidth + 12;
		}
		
		/**********************************************************
		 * drag colorscale
		 * *******************************************************/
		private function drag(event:MouseEvent):void {
			startDrag();
		}
		
		private function dragEnd(event:MouseEvent):void {
			stopDrag();
		}
		
		/**********************************************************
		 * visibility
		 * *******************************************************/
		public function toggleVisibility():void {
			visible = !visible;
		}
		
		/**********************************************************
		 * render, rasterize
		 * *******************************************************/
		public function render(format:String, metaData:Object = null):* {
			var data:*;
						
			//bounds
			var bounds:Rectangle = getBounds(this);
			bounds.bottom -= 6;
			
			//render						
			switch(format) {
				case 'gif':
					var gifRenderer:GIFRenderer = new GIFRenderer();
					data = gifRenderer.render(this, bounds, metaData);
					break;
				case 'jpg':
					var jpegRenderer:JPEGRenderer = new JPEGRenderer();
					data = jpegRenderer.render(this, bounds, metaData);
					break;
				case 'png':		
					var pngRenderer:PNGRenderer = new PNGRenderer();
					data = pngRenderer.render(this, bounds, metaData);
					break;					
				case 'svg':
					var svgRenderer:SVGRenderer = new SVGRenderer();
					data = svgRenderer.render(this, bounds, metaData);
					break;
			}
			
			return data;
		}
		
		public function rasterize(format:String, metaData:Object, fileName:String):void {
			var bounds:Rectangle = getBounds(this);
			bounds.bottom -= 6;
			
			var svgRasterizer:SVGRasterizer = new SVGRasterizer();
			svgRasterizer.rasterize(format, fileName, this, bounds, metaData);
		}
	}
	
}