package edu.stanford.covertlab.diagram.overview 
{
	import caurina.transitions.Tweener;	
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.geometry.RoundedRectangle;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.BitmapFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.Surface;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.controls.Alert;
	import mx.controls.VSlider;
	import mx.events.SliderEvent;
	import org.adm.runtime.ModeCheck;
	
	/**
	 * Displays a small window which shows the entirety of the current biological network.
	 * Window highlights the portion of the network which is currently visible, and allows
	 * you to drag the highlight box to pan the network.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Overview extends HBox
	{
		[Bindable] private var diagram:Diagram;
		private var canvas:Canvas
		private var mirrorGeometryGroup:GeometryGroup;
		private var mirror:RegularRectangle;
		private var highlightGeometryGroup:GeometryGroup;
		private var highlight:RegularRectangle;
		private var bitmapFill:BitmapFill;
		private var dragGeometryGroup:GeometryGroup;
		private var dragRoundedRectangle:RoundedRectangle;
		private var panOffsetX:Number;
		private var panOffsetY:Number;
		private var zoomLevel:VSlider;
				
		public function Overview(diagram:Diagram) 
		{
			this.diagram = diagram;
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'off';
			
			//canvas			
			canvas = new Canvas();
			canvas.useHandCursor = true;
			canvas.buttonMode = false;
			canvas.setStyle('borderStyle', 'solid');
			canvas.setStyle('borderThickness', 2);
			canvas.setStyle('cornerRadius', 0);
			canvas.setStyle('borderColor', 0x999999);
			addChild(canvas);
			
			//surface
			var surface:Surface = new Surface();
			canvas.addChild(surface);
			
			//mirror diagram
			mirrorGeometryGroup = new GeometryGroup();
			surface.addChild(mirrorGeometryGroup);
			
			mirror = new RegularRectangle();
			mirrorGeometryGroup.geometryCollection.addItem(mirror);			
			
			bitmapFill = new BitmapFill();
			bitmapFill.source = diagram.backgroundCanvas;
			bitmapFill.repeatX = 'none'
			bitmapFill.repeatY = 'none';
			bitmapFill.smooth = true;
			mirror.fill = bitmapFill;
			
			//highlight
			highlightGeometryGroup = new GeometryGroup();
			surface.addChild(highlightGeometryGroup);
			
			highlight = new RegularRectangle();
			highlight.fill = new SolidFill(0x000000, 0);
			highlight.stroke = new SolidStroke(0xFF0000);
			highlightGeometryGroup.geometryCollection.addItem(highlight);
			
			//zoom			
			zoomLevel= new VSlider();
			zoomLevel.minimum = -4;
			zoomLevel.maximum = 4;
			zoomLevel.tickInterval = 1;
			zoomLevel.setStyle('tickOffset', 3);
			zoomLevel.setStyle('tickLength', 5);			
			zoomLevel.showDataTip = false;
			zoomLevel.liveDragging = true;								
			BindingUtils.bindProperty(zoomLevel, 'value', diagram, 'zoomLevel');
			zoomLevel.addEventListener(SliderEvent.CHANGE, function(event:SliderEvent):void {
				if (diagram.overviewVisible)
					diagram.setZoomLevel(zoomLevel.value);
			});
			addChild(zoomLevel);
			
			//panning
			highlightGeometryGroup.addEventListener(MouseEvent.MOUSE_DOWN, panDiagram);
			highlightGeometryGroup.addEventListener(MouseEvent.MOUSE_UP, panDiagramEnd);
			highlightGeometryGroup.buttonMode = true;
			highlightGeometryGroup.useHandCursor = true;
			
			//dragging
			canvas.addEventListener(MouseEvent.MOUSE_DOWN, dragHighlight);
			canvas.addEventListener(MouseEvent.MOUSE_UP, dragHighlightEnd);
			
			//binding
			BindingUtils.bindSetter(positionHighlight, diagram.backgroundCanvas, 'x');
			BindingUtils.bindSetter(positionHighlight, diagram.backgroundCanvas, 'y');
			BindingUtils.bindSetter(positionHighlight, diagram, 'diagramWidth');
			BindingUtils.bindSetter(positionHighlight, diagram, 'diagramHeight');
			BindingUtils.bindSetter(positionHighlight, diagram.backgroundCanvas, 'scaleX');
			diagram.backgroundCanvas.addEventListener(Event.RENDER, function(event:Event):void { invalidateDisplayList();} );
		}
		
		/**********************************************************
		 * visibility of ovewview window
		 * *******************************************************/
		public function open():void {
			visible = true;
		}
		
		public function close():void {
			visible = false;
		}
		
		public function toggle():void {
			visible = !visible;
		}
		
		/**********************************************************
		 * refresh mirror of diagram
		 * *******************************************************/
		//TODO: mirror diagram better with vector filling
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			var bitmapData:BitmapData = new BitmapData(diagram.diagramWidth, diagram.diagramHeight);
			try {
				bitmapData.draw(diagram.backgroundCanvas, null, null, null, null, true);
				bitmapFill.source = bitmapData;
			}catch (error:ArgumentError) {
				if (ModeCheck.isDebugBuild()) {
					Alert.show('Bitmap data invalid.', 'Overview Error');
				}
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		/**********************************************************
		 * drag overview window
		 * *******************************************************/
		private function dragHighlight(event:MouseEvent):void {
			if (event.target == mirrorGeometryGroup || event.target==highlightGeometryGroup) return;
			this.startDrag();
		}
		
		private function dragHighlightEnd(event:MouseEvent):void {
			this.stopDrag();
		}
		
		/**********************************************************
		 * position red highlight rectangle
		 * *******************************************************/
		private function positionHighlight(value:*=null):void {
			var scale:Number;

			//overview size
			if (diagram.diagramWidth > diagram.diagramHeight) {
				mirror.width = 100;
				mirror.height = mirror.width * diagram.diagramHeight / diagram.diagramWidth;
				scale = mirror.width / diagram.diagramWidth;
			}else {
				mirror.height = 100;
				mirror.width = mirror.height * diagram.diagramWidth / diagram.diagramHeight;
				scale = mirror.height / diagram.diagramHeight;
			}
			highlight.width = mirror.width;
			highlight.height = mirror.height;
			canvas.width = mirror.width+5;
			canvas.height = zoomLevel.height = mirror.height+5;
			bitmapFill.scaleX = scale;
			bitmapFill.scaleY = scale;			
			
			//highlight
			highlightGeometryGroup.x = mirror.width * Math.min(1, Math.max(0, 
				-diagram.backgroundCanvas.x / (diagram.diagramWidth * diagram.backgroundCanvas.scaleX)));
			highlightGeometryGroup.y = mirror.height * Math.min(1, Math.max(0, 
				-diagram.backgroundCanvas.y / (diagram.diagramHeight * diagram.backgroundCanvas.scaleY)));
			highlight.width = Math.max(0,Math.min(mirror.width-highlightGeometryGroup.x, mirror.width * (
					Math.min(diagram.width, Math.max(diagram.backgroundCanvas.x + diagram.diagramWidth * diagram.backgroundCanvas.scaleX, 0)) - 
					Math.min(Math.max(0, diagram.backgroundCanvas.x),diagram.diagramWidth * diagram.backgroundCanvas.scaleX)
				) / (diagram.diagramWidth * diagram.backgroundCanvas.scaleX)));
			highlight.height = Math.max(0,Math.min(mirror.height-highlightGeometryGroup.y, mirror.height * (
					Math.min(diagram.height, Math.max(diagram.backgroundCanvas.y + diagram.diagramHeight * diagram.backgroundCanvas.scaleY,0)) - 
					Math.min(Math.max(0, diagram.backgroundCanvas.y),diagram.diagramHeight * diagram.backgroundCanvas.scaleY)
				) / (diagram.diagramHeight * diagram.backgroundCanvas.scaleY)));
		}		
		
		/**********************************************************
		 * drag red highlight rectangle, pan diagram
		 * *******************************************************/
		private function panDiagram(event:MouseEvent):void {
			panOffsetX = event.localX - highlightGeometryGroup.x;
			panOffsetY = event.localY - highlightGeometryGroup.y;
			highlightGeometryGroup.startDrag(false, new Rectangle(0,0, mirror.width-highlight.width, mirror.height-highlight.height));
			addEventListener(MouseEvent.MOUSE_MOVE, onPanDiagram);
		}
		
		private function onPanDiagram(event:MouseEvent):void {
			//BUG: panning doesn't keep up on fast mouse dragging; 
			//BUG: without tweening, panning doesn't track mouse
			Tweener.addTween(diagram.backgroundCanvas, { 
				x: -highlightGeometryGroup.x * (diagram.diagramWidth * diagram.backgroundCanvas.scaleX) / mirror.width,
				y: -highlightGeometryGroup.y * (diagram.diagramHeight * diagram.backgroundCanvas.scaleY) / mirror.height,
				time:0.1} );
			//diagram.backgroundCanvas.x = -highlightGeometryGroup.x * (diagram.diagramWidth * diagram.backgroundCanvas.scaleX) / mirror.width;
			//diagram.backgroundCanvas.y = -highlightGeometryGroup.y * (diagram.diagramHeight * diagram.backgroundCanvas.scaleY) / mirror.height;
		}
		
		private function panDiagramEnd(event:MouseEvent):void {
			highlightGeometryGroup.stopDrag();
			removeEventListener(MouseEvent.MOUSE_MOVE, onPanDiagram);
		}		
	}
	
}