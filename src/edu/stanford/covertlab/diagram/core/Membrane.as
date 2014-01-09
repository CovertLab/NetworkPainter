package edu.stanford.covertlab.diagram.core 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.Surface;
	import edu.stanford.covertlab.controls.ToolBarCanvasButton;
	import edu.stanford.covertlab.diagram.event.CompartmentEvent;
	import edu.stanford.covertlab.diagram.history.HistoryAction;	
	import edu.stanford.covertlab.diagram.window.EditBiomoleculeWindow;
	import edu.stanford.covertlab.graphics.renderablerepeater.MembranePhospholipids;
	import flash.events.MouseEvent;
	import flash.geom.Bezier;
	import flash.geom.Intersection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	/**
	 * Displays a pictorial representation of a membrane. Membranes are automatically displayed between compartments in the diagram
	 * Membranes inherits their color and phosholipid color from the preceeding compartment.
	 * 
	 * @see Compartment
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Membrane extends CompartmentBase
	{
		
		private var _myCurvature:Number;
		private var _myPhospholipidBodyColor:uint;
		private var _myPhospholipidOutlineColor:uint;
		
		private var phospholipidsGeometryGroup:GeometryGroup;
		private var phospholipidHeadSize:Number = 5;
		private var phospholipidLayers:Number = 2;
		private var phospholipidTailGap:Number = 1;
		private var phospholipidFill:RadialGradientFill;
		private var phospholipidFillStop_white:GradientStop;
		private var phospholipidFillStop_color:GradientStop;
		private var phospholipidStroke:SolidStroke;
		private var membranePhospholipids:MembranePhospholipids;
		
		private var resizeOffsetY:Number;
		
		public function Membrane(diagram:Diagram,color:uint, myPhospholipidBodyColor:uint, myPhospholipidOutlineColor:uint, width:Number,height:Number,myCurvature:Number, myUpperCompartment:Compartment) 
		{
			//setup phospholipds
			phospholipidsGeometryGroup = new GeometryGroup();
			addChild(phospholipidsGeometryGroup);			

			membranePhospholipids = new MembranePhospholipids(myWidth, myHeight, diagram.membraneCurvature, phospholipidHeadSize, phospholipidLayers, phospholipidTailGap);
			phospholipidsGeometryGroup.geometryCollection.addItem(membranePhospholipids);
			
			phospholipidFill = new RadialGradientFill();
			phospholipidFillStop_white=new GradientStop(0xFFFFFF,1,0.1);
			phospholipidFillStop_color=new GradientStop(0xFFFFFF,1,0.9);
			phospholipidFill.gradientStopsCollection.addItem(phospholipidFillStop_white);
			phospholipidFill.gradientStopsCollection.addItem(phospholipidFillStop_color);			
			membranePhospholipids.fill = phospholipidFill;
			
			phospholipidStroke = new SolidStroke(0x000000);
			membranePhospholipids.stroke = phospholipidStroke;			
						
			//construct super
			super(diagram, color, width, height, myUpperCompartment, null);
			this.myPhospholipidBodyColor = myPhospholipidBodyColor;
			this.myPhospholipidOutlineColor = myPhospholipidOutlineColor;
			this.myCurvature = myCurvature;
			
			visible = false;			
			BindingUtils.bindProperty(this, 'buttonMode', diagram, 'editingEnabled');
			BindingUtils.bindProperty(this, 'useHandCursor', diagram, 'editingEnabled');

			//resizing
			addEventListener(MouseEvent.MOUSE_DOWN, startResizeCompartments);
			
			BindingUtils.bindProperty(this, 'mouseEnabled', diagram, 'compartmentResizeEnable');
			addEventListener(MouseEvent.DOUBLE_CLICK, openEditWindow);				
			addEventListener(DragEvent.DRAG_ENTER, dragNewBiomoleculeEnterHandler);
			addEventListener(DragEvent.DRAG_DROP, dragNewBiomoleculeDropHandler);	
		}
		
		/************************************************
		* setters/getters
		* **********************************************/
		
		override public function set dim(value:Boolean):void {
			if (value != _dim) {
				super.dim = value;
				phospholipidsGeometryGroup.visible = !dim;
			}
		}
		
		public function get myName():String {
			if (myUpperCompartment && myLowerCompartment) return (myUpperCompartment as Compartment).myName + '-' + (myLowerCompartment as Compartment).myName;
			return '';
		}
		
		override public function set myWidth(value:Number):void {
			if (_myWidth != value) {
				super.myWidth = value;
				membranePhospholipids.membraneWidth = value;
			}
		}
		
		override public function set myHeight(value:Number):void {
			if (_myHeight != value) {
				super.myHeight = value;
				membranePhospholipids.membraneHeight = value;
			}
		}
		
		public function get minimumHeight():Number {
			return diagram.membraneHeight;
		}		
						
		override public function set myUpperCompartment(value:CompartmentBase):void {
			if(_myUpperCompartment!=value){
				_myUpperCompartment = value;
				y = myUpperCompartment.y + myUpperCompartment.myHeight;
				toolTip = myName;
			}
		}
		
		override public function set myLowerCompartment(value:CompartmentBase):void {
			if(_myLowerCompartment!=value){
				_myLowerCompartment = value;
				toolTip = myName;
			}
		}
		
		override public function get myPosition():String {
			return POSITION_MIDDLE;
		}
		override public function set myPosition(value:String):void { }
		
		public function get myCurvature():Number {
			return _myCurvature;
		}
		public function set myCurvature(value:Number):void {
			if (_myCurvature != value) {
				_myCurvature = value;
				membranePhospholipids.membraneCurvature = value;
			}
		}
		
		[Bindable] 
		public function get myPhospholipidBodyColor():uint {
			return _myPhospholipidBodyColor;
		}
		public function set myPhospholipidBodyColor(value:uint):void {
			if (_myPhospholipidBodyColor != value) {
				_myPhospholipidBodyColor = value;
				if (!dim) phospholipidFillStop_color.color = value;
			}
		}
		
		[Bindable] 
		public function get myPhospholipidOutlineColor():uint {
			return _myPhospholipidOutlineColor;
		}
		public function set myPhospholipidOutlineColor(value:uint):void {
			if (_myPhospholipidOutlineColor != value) {
				_myPhospholipidOutlineColor = value;
				if (!dim) phospholipidStroke.color = value;
			}
		}
		
		/************************************************
		* resizing compartments
		* **********************************************/		
		
		//BUG: dragging slow and buggy
		private function startResizeCompartments(event:MouseEvent):void {
			if (!diagram.compartmentResizeEnable) return;

			diagram.historyManager.addHistoryAction(new HistoryAction(myUpperCompartment, 'resize', { myHeight:myUpperCompartment.myHeight } ));
						
			resizeOffsetY = event.stageY;
			var topLimit:Number = myUpperCompartment.y + diagram.minCompartmentHeight;
			var botLimit:Number = (myLowerCompartment.myLowerCompartment != null)? (myLowerCompartment as Compartment).myMembrane.y : diagram.diagramHeight;
			botLimit -= (diagram.minCompartmentHeight + myHeight);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doResizeCompartments);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopResizeCompartments);
			startDrag(false, new Rectangle(0, topLimit, 0, botLimit - topLimit));
		}		
		
		private function doResizeCompartments(event:MouseEvent):void {
			var deltaHeight:Number = Math.max(
				-(myUpperCompartment.myHeight - diagram.minCompartmentHeight), 
				Math.min(myLowerCompartment.myHeight - diagram.minCompartmentHeight,
						 Math.round(event.stageY - resizeOffsetY)));

			resizeOffsetY = event.stageY;			
						
			myUpperCompartment.myHeight += deltaHeight;
			myLowerCompartment.y += deltaHeight;
			myLowerCompartment.myHeight -= deltaHeight;
			
			(myUpperCompartment as Compartment).stretchBiomolecules(0, 0, 0, deltaHeight);	
			(myLowerCompartment as Compartment).stretchBiomolecules(0, deltaHeight, 0, -deltaHeight);
			stretchBiomolecules(0, deltaHeight, 0, 0);
		}
		
		private function stopResizeCompartments(event:MouseEvent):void {
			doResizeCompartments(event);
			
			stopDrag();	
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doResizeCompartments);			
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopResizeCompartments);
			
			myUpperCompartment.dispatchEvent(new CompartmentEvent(CompartmentEvent.COMPARTMENT_UPDATE));
			myUpperCompartment.myLowerCompartment.dispatchEvent(new CompartmentEvent(CompartmentEvent.COMPARTMENT_UPDATE));
		}
		
		/************************************************
		* biomolecules and edges
		* **********************************************/
		
		//adjust positions of biomolecules in compartments whose size is changing
		public function stretchBiomolecules(deltaX:Number = 0, deltaY:Number = 0, deltaW:Number = 0, deltaH:Number = 0):void {				
			var biomolecules:ArrayCollection = this.biomolecules;
			for (var i:uint = 0; i < biomolecules.length; i++) {
				biomolecules[i].translateTo(x + (deltaX + biomolecules[i].x - x) / (myWidth - deltaW) * myWidth, biomolecules[i].y + deltaY, 0, false, true);
			}
		}
		
		/************************************************
		* intersction (used by edges to compute locations of pores)
		* **********************************************/
		
		public function intersectLine(x:Number, y:Number, x1:Number, y1:Number):* {
			var m:Number = (y1 - y) / (x1 - x);
			var b:Number = y - m * x;
			
			var qa:Number = 2 * myCurvature / Math.pow(myWidth, 2);
			var qb:Number = -(2 * myCurvature / myWidth + m);
			var qc:Number = this.y + myHeight / 2 - b;
			
			if (Math.pow(qb, 2) < 4 * qa * qc) return false;
			
			var intX:Number = (-qb - Math.sqrt(Math.pow(qb, 2) - 4 * qa * qc)) / (2 * qa);
			if (!(intX >= x && intX <= x1) && !(intX <= x && intX >= x1))
				intX = (-qb + Math.sqrt(Math.pow(qb, 2) - 4 * qa * qc)) / (2 * qa);
			
			if ((intX >= x && intX <= x1) || (intX<=x && intX>=x1)) return snapBiomolecule(intX,0);
			return false;
		}
		
		public function intersectCubicBezier(x:Number, y:Number, cx:Number, cy:Number, cx1:Number, cy1:Number, x1:Number, y1:Number):* {
			var bezier:Bezier = new Bezier(new Point(x, y + myHeight / 2), new Point(x + myWidth / 2, y + myHeight / 2 - myCurvature), new Point(x + myWidth, y + myHeight / 2));
			var intersection:Intersection = bezier.intersectionBezier(new Bezier(new Point(x, y), new Point((cx + cx1) / 2, (cy + cy1 / 2)), new Point(x1, y1)));
			
			if (intersection.targetTimes.length == 0) return false;
			return snapBiomolecule(bezier.getPoint(intersection.targetTimes[0]).x, 0);
		}
		
		/************************************************
		* export
		* **********************************************/
		public function dotCode(scale:Number):String{
			var biomolecules:ArrayCollection = this.biomolecules;
			var edges:ArrayCollection = this.edges;
			var i:uint;
			
			var dot:Object = { biomolecules:[], biomoleculeNames:[], edges:[]};
			for (i = 0; i < biomolecules.length; i++) {
				dot.biomolecules.push(biomolecules[i].dotCode(scale));
				dot.biomoleculeNames.push(biomolecules[i].myName);
			}
					
			// if empty, add a hidden node to maintain minimum height
			if (biomolecules.length == 0) {
				dot.biomolecules.push(printf('"%s" [style="invis",label="",shape="plaintext",fixedsize="true",width="0.01",height="%f"];', 
				'hidden' + diagram.compartmentsAndMembranes.getItemIndex(this),
				diagram.membraneHeight / scale));
			}
					
			// Add inter-membrane edges
			for (i = 0; i < edges.length; i++) {
				dot.edges.push(edges[i].dotCode(scale));
			}
			return printf('subgraph "cluster_membrane_%s" {\n    style=invis\n    %s\n    %s\n  }\n  {rank=same;%s}',
				myName, dot.biomolecules.join('\n    '), dot.edges.join('\n    '), dot.biomoleculeNames.join(';'));
		}
			
		
		/************************************************
		 * snap biomolecules
		 * **********************************************/
		public function snapBiomolecule(x:Number, y:Number):Object {
			x = Math.min(myWidth, Math.max(0, x));
			var t:Number = x / myWidth;
			var theta:Number = -Math.atan2(2 * (1 - 2 * x / myWidth) * diagram.membraneCurvature, myWidth) * 180 / Math.PI;
			return {x:x, y:this.y + myHeight / 2 -2 * (1 - t) * t * diagram.membraneCurvature,rotation:theta};
		}
		
		/************************************************
		* auto-layout
		* **********************************************/
		public function resizeToFit(rescale:Number):void {
			this.y = this.myUpperCompartment.y + this.myUpperCompartment.myHeight;
			this.myHeight = this.minimumHeight;
			
			for each(var biomolecule:Biomolecule in this.biomolecules) {
				biomolecule.translateTo(biomolecule.x, this.y + this.myHeight / 2, 1.5, false, true);
			}
			
			//trace(this.myName + " y: " + this.y + " - " + (this.myHeight+this.y));
		}
		
		/************************************************
		* drag new biomolecule onto diagram
		* **********************************************/	
		private function dragNewBiomoleculeEnterHandler(event:DragEvent):void {
			if (!event.dragSource.hasFormat('action') || event.dragSource.dataForFormat('action') != 'addBiomolecule') return;
			
			DragManager.acceptDragDrop(this);			
		}
		
		private function dragNewBiomoleculeDropHandler(event:DragEvent):void {
			if (!event.dragSource.hasFormat('action') || event.dragSource.dataForFormat('action') != 'addBiomolecule') return;
			
			var pt:Point = diagram.backgroundSurface.globalToLocal(new Point(event.dragSource.dataForFormat('cursorSurface').parent.x,event.dragSource.dataForFormat('cursorSurface').parent.y));
			var button:ToolBarCanvasButton = event.dragInitiator as ToolBarCanvasButton;
			var editBiomoleculeWindow:EditBiomoleculeWindow = new EditBiomoleculeWindow(diagram);
			var biomoleculeStyle:BiomoleculeStyle = button.data.biomoleculeStyle as BiomoleculeStyle;
			editBiomoleculeWindow.setBiomoleculeProperties(this, biomoleculeStyle, pt.x, pt.y);
			editBiomoleculeWindow.open();
			
			//temporarily add biomolecule to diagram
			var newBiomoleculeSurface:Surface = new Surface();
			newBiomoleculeSurface.x = pt.x;
			newBiomoleculeSurface.y = pt.y;
			newBiomoleculeSurface.alpha = 0.5;
			diagram.backgroundCanvas.addChild(newBiomoleculeSurface);
			
			var newBiomoleculeGeometryGroup:GeometryGroup = Biomolecule.getShape(biomoleculeStyle.myShape, Biomolecule.SIZE, biomoleculeStyle.myOutline, biomoleculeStyle.myColor);
			newBiomoleculeGeometryGroup.target = newBiomoleculeSurface;
			newBiomoleculeSurface.addChild(newBiomoleculeGeometryGroup);
			
			//remove temporarily added biomolecule when edit window closes
			editBiomoleculeWindow.addEventListener(CloseEvent.CLOSE, function(event:CloseEvent):void {
				diagram.backgroundCanvas.removeChild(newBiomoleculeSurface);
			});
		}
		
		/************************************************
		 * double click
		 * **********************************************/	
		public function openEditWindow(event:MouseEvent):void {
			(myUpperCompartment as Compartment).openEditWindow(event);
		}
	}
	
}