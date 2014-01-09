package edu.stanford.covertlab.diagram.toolbar 
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.Surface;
	import edu.stanford.covertlab.controls.ToolBarCanvasButton;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.BiomoleculeStyle;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.event.BiomoleculeStyleEvent;
	import edu.stanford.covertlab.graphics.shape.ShapeBase;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.binding.utils.BindingUtils;
	import mx.core.DragSource;
	import mx.managers.DragManager;
	
	/**
	 * Toolbar for add a new biomolecue to a diagram by dragging a button from a toolbar.
	 * 
	 * @see ToolBar
	 * @see edu.stanford.covertlab.diagram.core.Biomolecule
	 * 
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class NewBiomoleculeToolBar extends ToolBar
	{
		private const thumbnailSize:Number = 16;
		
		public function NewBiomoleculeToolBar(diagram:Diagram) 
		{
			super(diagram);
			
			label = "New Biomolecule";
		}		
		
		/*****************************************************
		 * add, update, remove styles
		 * **************************************************/
		public function addStyle(style:BiomoleculeStyle):void {
			var surfaces:Object = createSurfaces(style);
			var button:ToolBarCanvasButton = new ToolBarCanvasButton(style.myName);
			button.setStyle('skin', null);
			button.width = thumbnailSize;
			button.height = thumbnailSize;
			button.addChild(surfaces.thumbnailSurface);
			button.addEventListener(MouseEvent.MOUSE_DOWN, startAddBiomolecule);
			button.data = { biomoleculeStyle:style, cursorSurface:surfaces.cursorSurface };
			addChild(button);
			
			style.addEventListener(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_UPDATE, updateStyle);
			style.addEventListener(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_REMOVE, removeStyle);			
		}
		
		public function updateStyle(event:BiomoleculeStyleEvent):void {
			var biomoleculeStyle:BiomoleculeStyle = event.target as BiomoleculeStyle;
			var button:ToolBarCanvasButton = getBiomoleculeStyleButton(biomoleculeStyle);
			if (!button) return;
			
			button.toolTip = biomoleculeStyle.myName;				
			var surfaces:Object = createSurfaces(biomoleculeStyle);					
			button.removeChildAt(0);
			button.addChild(surfaces.thumbnailSurface);
			button.data.cursorSurface = surfaces.cursorSurface;					
		}
		
		private function removeStyle(event:BiomoleculeStyleEvent):void {
			var biomoleculeStyle:BiomoleculeStyle = event.target as BiomoleculeStyle;
			var idx:int = getBiomoleculeStyleIndex(biomoleculeStyle);
			if (idx == -1) return;
		
			removeChildAt(idx);			
		}
		
		// returns a object of {cursorSurface, thumbnailSurface}
		private function createSurfaces(style:BiomoleculeStyle):Object {			
			var cursorSurface:Surface = new Surface();
			var cursorGeometryGroup:GeometryGroup = Biomolecule.getShape(style.myShape, Biomolecule.SIZE, style.myOutline, style.myColor);
			cursorGeometryGroup.target = cursorSurface;
			cursorSurface.addChild(cursorGeometryGroup);
			BindingUtils.bindProperty(cursorSurface, 'scaleX', diagram.backgroundCanvas, 'scaleX');
			BindingUtils.bindProperty(cursorSurface, 'scaleY', diagram.backgroundCanvas, 'scaleY');
			
			var bounds:Rectangle = cursorGeometryGroup.getBounds(cursorGeometryGroup);
			
			var thumbnailSurface:Surface = new Surface();
			var thumbnailGeometryGroup:GeometryGroup = Biomolecule.getShape(style.myShape, Biomolecule.SIZE / Math.max(bounds.width, bounds.height) * thumbnailSize, 			
				style.myOutline, style.myColor);
			thumbnailGeometryGroup.x = ( -bounds.x - bounds.width / 2) / Math.max(bounds.width, bounds.height) * thumbnailSize + thumbnailSize / 2;
			thumbnailGeometryGroup.y = ( -bounds.y - bounds.height / 2) / Math.max(bounds.width, bounds.height) * thumbnailSize + thumbnailSize / 2;
			thumbnailGeometryGroup.target = thumbnailSurface;
			thumbnailSurface.addChild(thumbnailGeometryGroup);

			return { cursorSurface:cursorSurface, thumbnailSurface:thumbnailSurface };
		}
		
		/******************************************************
		 * start drag 'n drop
		 * ***************************************************/
		private function startAddBiomolecule(event:MouseEvent):void {
			var dragSource:DragSource = new DragSource();
			dragSource.addData('addBiomolecule', 'action');

			var button:ToolBarCanvasButton = event.target as ToolBarCanvasButton;
			var dragProxy:Surface = button.data.cursorSurface as Surface;
			dragSource.addData(dragProxy, 'cursorSurface');
			
			DragManager.doDrag(event.target as ToolBarCanvasButton, dragSource, event, dragProxy);
		}
		
		/*****************************************************
		 * remove all buttons
		 * **************************************************/
		public function clearBiomoleculeStyles():void {
			var dragger:DisplayObject = getChildAt(0);
			removeAllChildren();
			addChild(dragger);
		}
		
		/*****************************************************
		 * get index of biomolecule style
		 * **************************************************/
		public function getBiomoleculeStyleButton(biomoleculeStyle:BiomoleculeStyle):ToolBarCanvasButton {
			for (var i:uint = 1; i < numChildren; i++) {
				var button:ToolBarCanvasButton = getChildAt(i) as ToolBarCanvasButton;
				if (button.data.biomoleculeStyle == biomoleculeStyle) {
					return button;
				}
			}
			return null;
		}
		
		public function getBiomoleculeStyleIndex(biomoleculeStyle:BiomoleculeStyle):int {
			for (var i:uint = 1; i < numChildren; i++) {
				var button:ToolBarCanvasButton = getChildAt(i) as ToolBarCanvasButton;
				if (button.data.biomoleculeStyle == biomoleculeStyle) {
					return i;
				}
			}
			return -1;
		}
		
	}
	
}