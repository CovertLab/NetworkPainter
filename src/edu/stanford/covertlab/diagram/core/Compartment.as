package edu.stanford.covertlab.diagram.core 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.geometry.EllipticalArc;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.QuadraticBezier;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.geometry.RoundedRectangleComplex;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientStroke;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.Surface;
	import edu.stanford.covertlab.controls.ToolBarCanvasButton;
	import edu.stanford.covertlab.diagram.event.CompartmentEvent;
	import edu.stanford.covertlab.diagram.history.HistoryAction;
	import edu.stanford.covertlab.diagram.history.IHistory;	
	import edu.stanford.covertlab.diagram.window.EditBiomoleculeWindow;
	import edu.stanford.covertlab.diagram.window.EditCompartmentWindow;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	/**
	 * Main compartment class from which the membrane and hot spot classes derive. Displays a pictorial representation
	 * of a compartment in a biological network. Compartment has curvature, color, and membrane color attributes.
	 * Compartments are edited either through the EditCompartmentWindow or the CompartmentsPanel.
	 * 
	 * @see Membrane
	 * @see edu.stanford.covertlab.diagram.event.CompartmentEvent
	 * @see edu.stanford.covertlab.diagram.window.EditCompartmentWindow
	 * @see edu.stanford.covertlab.diagram.panel.CompartmentsPanel
	 * 	 
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Compartment extends CompartmentBase implements IHistory
	{		
		protected var _myName:String;
		
		[Bindable] public var myMembrane:Membrane;
		public var myTopHotspot:CompartmentHotspot;
		public var myBottomHotspot:CompartmentHotspot;
		
		private var editCompartmentWindow:EditCompartmentWindow;
		
		public function Compartment(diagram:Diagram, name:String = '', color:uint = 0, membraneColor:uint = 0, 
		phospholipidBodyColor:uint=0, phospholipidOutlineColor:uint=0,
		width:Number=0, height:Number = 0, myUpperCompartment:Compartment = null, myLowerCompartment:Compartment = null) 
		{
			myMembrane = new Membrane(diagram, membraneColor, phospholipidBodyColor, phospholipidOutlineColor, width, diagram.membraneHeight, diagram.membraneCurvature, this);
			myTopHotspot = new CompartmentHotspot(diagram, myUpperCompartment, width, 0, POSITION_TOP);
			myBottomHotspot = new CompartmentHotspot(diagram, this, width, 0, POSITION_BOTTOM);
			addChild(myTopHotspot);
			addChild(myBottomHotspot);
			
			this.myName = name;
			
			super(diagram, color, width, height, myUpperCompartment, myLowerCompartment);
					
			//undo			
			diagram.historyManager.addHistoryAction(new HistoryAction(this, 'remove', biomoleculePositions));
			
			//add to diagram			
			diagram.addCompartment(this);
			
			BindingUtils.bindProperty(this, 'mouseEnabled', diagram, 'compartmentResizeEnable');
			addEventListener(MouseEvent.DOUBLE_CLICK, openEditWindow);				
			addEventListener(DragEvent.DRAG_ENTER, dragNewBiomoleculeEnterHandler);
			addEventListener(DragEvent.DRAG_DROP, dragNewBiomoleculeDropHandler);	
		}		
		
		/************************************************
		* setters/getters
		* **********************************************/
		
		override public function set x(value:Number):void {
			super.x = value;
			myMembrane.x = value;
		}
		
		override public function set y(value:Number):void {
			super.y = value;
			myMembrane.y = value + myHeight;
		}
		
		override public function set dim(value:Boolean):void {
			super.dim = value;
			myMembrane.dim = value;
		}
		
		[Bindable]
		public function get myName():String {
			return _myName;
		}
		public function set myName(value:String):void {
			if (_myName != value) {
				toolTip = value;
				_myName = value;				
			}
		}
		
		override public function set myWidth(value:Number):void {
			if (_myWidth != value) {
				_myWidth = value;
				myMembrane.myWidth = value;
				myTopHotspot.myWidth = value;
				myBottomHotspot.myWidth = value;
				drawCompartment();
			}
		}
		
		override public function set myHeight(value:Number):void {
			if (_myHeight != value) {
				_myHeight = value;
				drawCompartment();
				myMembrane.y = y + myHeight;
				myTopHotspot.myHeight = myBottomHotspot.myHeight = (myHeight - myMembrane.myHeight) / 2;
				myTopHotspot.visible = (super.myPosition == POSITION_TOP || super.myPosition == POSITION_ONLY) && (myTopHotspot.myHeight>diagram.minCompartmentHeight);
				myBottomHotspot.y = myMembrane.myHeight + (myHeight - myMembrane.myHeight) / 2;
				myBottomHotspot.visible = (myBottomHotspot.myHeight > diagram.minCompartmentHeight);
			}
		}
		
		public function get minimumHeight():Number {
			return diagram.minCompartmentHeight;
		}
		
		override public function set myPosition(value:String):void {
			if (_myPosition != value) {
				_myPosition = value;
				drawCompartment();
				myMembrane.visible = (super.myPosition == POSITION_TOP || super.myPosition == POSITION_MIDDLE);
				myTopHotspot.myPosition = (super.myPosition == POSITION_TOP? POSITION_TOP : POSITION_MIDDLE);
				myTopHotspot.visible = (super.myPosition == POSITION_TOP || super.myPosition == POSITION_ONLY) && (myTopHotspot.myHeight>diagram.minCompartmentHeight);
				myBottomHotspot.myPosition = (super.myPosition == POSITION_BOTTOM? POSITION_BOTTOM : POSITION_MIDDLE);
			}
		}
		
		override public function set myLowerCompartment(value:CompartmentBase):void {
			if (_myLowerCompartment != value) {
				_myLowerCompartment = value;
				if (myLowerCompartment != null) myLowerCompartment.myUpperCompartment = this;
				if (myMembrane != null) myMembrane.myLowerCompartment = myLowerCompartment;
				determinePosition();
			}
		}
		
		override public function set myUpperCompartment(value:CompartmentBase):void {
			if(_myUpperCompartment!=value){
				_myUpperCompartment = value;
				if(myUpperCompartment!=null) myUpperCompartment.myLowerCompartment = this;
				determinePosition();
			}
		}
		
		[Bindable] 
		public function get myMembraneColor():uint {
			return myMembrane.myColor;
		}
		public function set myMembraneColor(value:uint):void {
			myMembrane.myColor=value;
		}
		
		[Bindable] 
		public function get myPhospholipidBodyColor():uint {
			return myMembrane.myPhospholipidBodyColor;
		}
		public function set myPhospholipidBodyColor(value:uint):void {
			myMembrane.myPhospholipidBodyColor=value;
		}
		
		[Bindable] 
		public function get myPhospholipidOutlineColor():uint {
			return myMembrane.myPhospholipidOutlineColor;
		}
		public function set myPhospholipidOutlineColor(value:uint):void {
			myMembrane.myPhospholipidOutlineColor=value;
		}
		
		public function update(myName:String = '', myColor:uint = 0, myMembraneColor:uint = 0,
		myPhospholipidBodyColor:uint=0, myPhospholipidOutlineColor:uint=0, addUndoAction:Boolean=true):Object {		
			var undoData:Object={ myName:this.myName, myColor:this.myColor, myMembraneColor:this.myMembraneColor, 
				myPhospholipidBodyColor: this.myPhospholipidBodyColor, myPhospholipidOutlineColor: this.myPhospholipidOutlineColor };				
			if (addUndoAction) diagram.historyManager.addHistoryAction(new HistoryAction(this, 'update', undoData));
				
			this.myName = myName;
			this.myColor = myColor;
			this.myMembraneColor = myMembraneColor;
			this.myPhospholipidBodyColor = myPhospholipidBodyColor;
			this.myPhospholipidOutlineColor = myPhospholipidOutlineColor;
			
			diagram.updateCompartment(this);		
			dispatchEvent(new CompartmentEvent(CompartmentEvent.COMPARTMENT_UPDATE));
			
			return undoData;
		}
		
		public function remove(addHistoryAction:Boolean = true):Object {							
			var undoData:Object = biomoleculePositions;
			if(addHistoryAction) diagram.historyManager.addHistoryAction(new HistoryAction(this, 'construct', undoData));
			
			diagram.removeCompartment(this);
			dispatchEvent(new CompartmentEvent(CompartmentEvent.COMPARTMENT_REMOVE));
			
			return undoData;
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
			editCompartmentWindow = new EditCompartmentWindow(diagram, this);
			editCompartmentWindow.open();
		}
		
		/************************************************
		* biomolecules and edges
		* **********************************************/
		
		//adjust positions of biomolecules in compartments whose size is changing
		public function stretchBiomolecules(deltaX:Number = 0, deltaY:Number = 0, deltaW:Number = 0, deltaH:Number = 0):void {	
			var biomolecules:ArrayCollection = this.biomolecules;
		
			for (var i:uint = 0; i < biomolecules.length; i++) {
				var t:Number = biomolecules[i].x / myWidth;
				var y:Number = this.y - (myPosition == POSITION_BOTTOM || myPosition == POSITION_MIDDLE ? 2 * (1 - t) * t * diagram.membraneCurvature : 0);
				var shapeBounds:Rectangle = biomolecules[i].getShapeBounds();
				biomolecules[i].translateTo(x + (deltaX + biomolecules[i].x + shapeBounds.left - x) / (myWidth - deltaW) * myWidth - shapeBounds.left,				
											y + (deltaY + biomolecules[i].y + shapeBounds.top - y) / (myHeight - deltaH) * myHeight - shapeBounds.top,											
											0, false, false);
			}
		}
		
		/************************************************
		 * snap biomolecules
		 * **********************************************/
		public function snapBiomolecule(x:Number, y:Number):Object {
			x = Math.min(myWidth, Math.max(0, x));
			var t:Number = x / myWidth;
			y = Math.max(this.y -2 * (1 - t) * t * diagram.membraneCurvature, Math.min(this.y + myHeight -2 * (1 - t) * t * diagram.membraneCurvature, y));
			return { x:x, y:y, rotation:0 };
		}
		
		/************************************************
		* auto-layout
		* **********************************************/
		public function resizeToFit(rescale:Number):void {
			var compartmentBounds:Rectangle = getBiomoleculesShapeBounds(true);
			var compartmentIndex:uint = diagram.compartmentsAndMembranes.getItemIndex(this);
			var newY:Number;
			var deltaY:Number;
			var deltaH:Number;
			
			//trace("before - " + myName + ": " + compartmentBounds);
			
			if (compartmentIndex == 0) {				
				if (compartmentBounds.height == -Infinity) {
					this.y = 0;
					this.myHeight = this.minimumHeight + diagram.membraneHeight;
				}
				else {
					this.y = 0;
					newY = 0;
					deltaY = 0 - compartmentBounds.y;
					deltaH = compartmentBounds.height * (rescale - 1);
					this.myHeight = compartmentBounds.height * rescale + diagram.membraneHeight;
					shiftAndRescale(deltaY, deltaH, compartmentBounds.top, compartmentBounds.height);
				}
			}
			else if (compartmentIndex == diagram.compartmentsAndMembranes.length - 1) {
				if (compartmentBounds.height == -Infinity) {
					this.myHeight = diagram.minCompartmentHeight + diagram.membraneHeight;
					this.y = diagram.diagramHeight - this.myHeight;
				}
				else {
					this.myHeight = compartmentBounds.height * rescale + diagram.membraneHeight;
					this.y = diagram.diagramHeight - this.myHeight;
					newY = diagram.diagramHeight - compartmentBounds.height * rescale;
					deltaY = (diagram.diagramHeight - compartmentBounds.height * rescale) - compartmentBounds.y;
					deltaH = compartmentBounds.height * (rescale - 1);
					shiftAndRescale(deltaY, deltaH, compartmentBounds.top, compartmentBounds.height);
				}
			}
			else {
				if (compartmentBounds.height == -Infinity) {
					this.y = diagram.compartmentsAndMembranes[compartmentIndex - 1].y + diagram.compartmentsAndMembranes[compartmentIndex - 1].myHeight;
					this.myHeight = this.minimumHeight + diagram.membraneHeight * 2;
				}
				else {
					this.y = diagram.compartmentsAndMembranes[compartmentIndex - 1].y + diagram.compartmentsAndMembranes[compartmentIndex - 1].myHeight;
					this.myHeight = compartmentBounds.height * rescale + diagram.membraneHeight * 2;
					newY = this.y + diagram.membraneHeight;
					deltaY = (this.y + diagram.membraneHeight) - compartmentBounds.y;
					deltaH = compartmentBounds.height * (rescale - 1);
					shiftAndRescale(deltaY, deltaH, compartmentBounds.top, compartmentBounds.height);
				}
			}
			
			//trace(this.myName + " y: " + this.y + " - " + (this.myHeight+this.y));
		}
		
		// BUG: Calculations are close, but seem slightly off
		private function shiftAndRescale(deltaY:Number, deltaH:Number, boundY:Number, boundHeight:Number):void {
			var newY:Number;
			
			for each(var biomolecule:Biomolecule in this.biomolecules) {
				newY = biomolecule.y;
				newY += (biomolecule.y - boundY) / boundHeight * deltaH;
				newY += deltaY;
				biomolecule.translateTo(biomolecule.x, newY, 1.5, false, true);
			}
		}

		/************************************************
		* export
		* **********************************************/
		public function dotCode(scale:Number):String{
			var biomolecules:ArrayCollection = this.biomolecules;
			var edges:ArrayCollection = this.edges;
			var i:uint;
			
			var dot:Object = { biomolecules:[], edges:[] };
			
			//biomolecules
			for (i = 0; i < biomolecules.length; i++) {
				dot.biomolecules.push(biomolecules[i].dotCode(scale));
			}

			// If empty, add a hidden node to maintain minimum height
			if (biomolecules.length == 0) {
				dot.biomolecules.push(printf('"%s" [style="invis",label="",shape="plaintext",fixedsize="true",width="0.01",height="%f"];', 
				'hidden' + diagram.compartmentsAndMembranes.getItemIndex(this),
				diagram.minCompartmentHeight / scale));
			}
			
			//inter-compartment edges
			for (i = 0; i < edges.length; i++) {
				dot.edges.push(edges[i].dotCode(scale));
			}
			return printf('subgraph "cluster_compartment_%s" {\n    style=invis\n    %s\n     %s\n  }',
				myName, dot.biomolecules.join('\n    '), dot.edges.join('\n    '));
		}
		
		/************************************************
		* undo/redo
		* **********************************************/
		public function undoHistoryAction(action:String, data:Object):HistoryAction {
			var inverseAction:String = '';
			var inverseData:Object = { };
			
			switch(action) {
				case 'remove':
					inverseAction = 'construct';
					inverseData = remove(false);
					biomoleculePositions = data as ArrayCollection;
					break;
				case 'update':
					inverseAction = 'update';
					inverseData = update(data.myName, data.myColor, data.myMembraneColor, data.myPhospholipidBodyColor, data.myPhospholipidOutlineColor, false);
					break;
				case 'resize':
					inverseAction = 'resize';
					inverseData = { myHeight:myHeight };
					
					var deltaH:Number = data.myHeight - myHeight;
					myHeight += deltaH;
					myLowerCompartment.y += deltaH;
					myLowerCompartment.myHeight -= deltaH;
					
					stretchBiomolecules(0, 0, 0, deltaH);					
					(myLowerCompartment as Compartment).stretchBiomolecules(0, deltaH, 0, -deltaH);
					myMembrane.stretchBiomolecules(0, deltaH, 0, 0);
					
					dispatchEvent(new CompartmentEvent(CompartmentEvent.COMPARTMENT_UPDATE));
					myLowerCompartment.dispatchEvent(new CompartmentEvent(CompartmentEvent.COMPARTMENT_UPDATE));
					break;					
				case 'construct':
					inverseAction = 'remove';
					inverseData = biomoleculePositions;
					diagram.addCompartment(this);					
					biomoleculePositions = data as ArrayCollection;
					break;
			}
			
			return new HistoryAction(this, inverseAction, inverseData);
		}
		
		private function get biomoleculePositions():ArrayCollection {
			var biomolecules:Array = [];
			if (myUpperCompartment) biomolecules = biomolecules.concat(myUpperCompartment.biomolecules.toArray()).concat((myUpperCompartment as Compartment).myMembrane.biomolecules.toArray());
			if (myLowerCompartment) biomolecules = biomolecules.concat(myLowerCompartment.biomolecules.toArray());			
			
			var biomoleculePositions:ArrayCollection = new ArrayCollection();
			for (var i:uint = 0; i < biomolecules.length; i++)
				biomoleculePositions.addItem( { biomolecule:biomolecules[i], x:biomolecules[i].x, y:biomolecules[i].y } );
				
			return biomoleculePositions;
		}
		
		private function set biomoleculePositions(biomoleculePositions:ArrayCollection):void {
			for (var i:uint = 0; i < biomoleculePositions.length; i++) {
				(biomoleculePositions[i].biomolecule as Biomolecule).translateTo(
					biomoleculePositions[i].x, biomoleculePositions[i].y);
			}
		}
	}
}