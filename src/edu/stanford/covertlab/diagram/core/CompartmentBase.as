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
	 * @see Compartment
	 * @see CompartmentHotspot
	 * @see edu.stanford.covertlab.diagram.event.CompartmentEvent
	 * @see edu.stanford.covertlab.diagram.window.EditCompartmentWindow
	 * @see edu.stanford.covertlab.diagram.panel.CompartmentsPanel
	 * 	 
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class CompartmentBase extends Surface
	{
		public static const POSITION_ONLY:String = 'only';
		public static const POSITION_TOP:String = 'top';
		public static const POSITION_BOTTOM:String = 'bottom';
		public static const POSITION_MIDDLE:String = 'middle';
		
		protected var diagram:Diagram;
		protected var _myColor:uint;
		protected var _myWidth:Number;
		protected var _myHeight:Number;
		protected var _myUpperCompartment:CompartmentBase;
		protected var _myLowerCompartment:CompartmentBase;
		protected var _myPosition:String = POSITION_ONLY;
		protected var _dim:Boolean;
		
		protected var shapeGeometryGroup:GeometryGroup;
		protected var shape:Path;
		protected var gradientFill:RadialGradientFill;
		protected var gradientStroke:LinearGradientStroke;
		protected var fillStop_white:GradientStop;
		protected var fillStop_color:GradientStop;
		protected var strokeStop_white:GradientStop;
		protected var strokeStop_color:GradientStop;
		
		public function CompartmentBase(diagram:Diagram, color:uint = 0, width:Number=0, height:Number = 0, myUpperCompartment:Compartment = null, myLowerCompartment:Compartment = null) 
		{
			shapeGeometryGroup = new GeometryGroup();			
			shape = new Path();			
			
			gradientFill = new RadialGradientFill();
			fillStop_white = new GradientStop(0xFFFFFF,0.3,0.0);
			fillStop_color = new GradientStop(myColor,0.7,1);
			gradientFill.gradientStopsCollection.addItem(fillStop_white);
			gradientFill.gradientStopsCollection.addItem(fillStop_color);
			shape.fill = gradientFill;
			
			gradientStroke = new LinearGradientStroke();
			strokeStop_color = new GradientStop(myColor,1,0.05);
			strokeStop_white = new GradientStop(0xFFFFFF,1,0.95);
			gradientStroke.gradientStopsCollection.addItem(strokeStop_color);
			gradientStroke.gradientStopsCollection.addItem(strokeStop_white);		
			shape.stroke = gradientStroke;		

			this.diagram = diagram;			
			this.myUpperCompartment = myUpperCompartment;
			this.myLowerCompartment = myLowerCompartment;
			this.myColor = color;			
			this.myWidth = width;
			this.myHeight = height;
			
			
			addChildAt(shapeGeometryGroup,0);
			shapeGeometryGroup.geometryCollection.addItem(shape);			
		}
		
		/************************************************
		* setters/getters
		* **********************************************/
		[Bindable] 		
		public function get myColor():uint {
			return _myColor; 
		}
		public function set myColor(value:uint):void {
			if (_myColor != value) {
				_myColor = value;
				if(!dim){
					fillStop_color.color = value;
					strokeStop_color.color = value;
				}
			}
		}
		
		public function get dim():Boolean {
			return _dim;
		}
		
		public function set dim(value:Boolean):void {
			if (value != _dim) {
				_dim = value;
				if (dim) {
					fillStop_color.color = fillStop_white.color = Diagram.dimGrey.compartmentFill;
					strokeStop_color.color = strokeStop_white.color = Diagram.dimGrey.compartmentStroke;
				}else {
					fillStop_color.color = strokeStop_color.color = myColor;
					fillStop_white.color = strokeStop_white.color = 0xFFFFFF;
				}
			}
		}
		
		[Bindable] 
		public function get myWidth():Number {
			return _myWidth;
		}
		public function set myWidth(value:Number):void {
			if (_myWidth != value) {
				_myWidth = value;
				drawCompartment();
			}
		}
		
		[Bindable] 
		public function get myHeight():Number {
			return _myHeight;
		}

		public function set myHeight(value:Number):void {
			if (_myHeight != value) {
				_myHeight = value;
				drawCompartment();
			}
		}
		
		public function get myUpperCompartment():CompartmentBase {
			return _myUpperCompartment;
		}
		public function set myUpperCompartment(value:CompartmentBase):void {
			if(_myUpperCompartment!=value){
				_myUpperCompartment = value;
			}
		}
		
		public function get myLowerCompartment():CompartmentBase {
			return _myLowerCompartment;
		}
		public function set myLowerCompartment(value:CompartmentBase):void {
			if (_myLowerCompartment != value) {
				_myLowerCompartment = value;
			}
		}
				
		public function get myPosition():String {
			return _myPosition;
		}
		public function set myPosition(value:String):void {
			if (_myPosition != value) {
				_myPosition = value;
				drawCompartment();
			}
		}
		
		/************************************************
		* display
		* **********************************************/
		protected function determinePosition():void {
			if (myUpperCompartment == null) {
				if (myLowerCompartment == null) myPosition = POSITION_ONLY;
				else myPosition = POSITION_TOP;
			}else {
				if (myLowerCompartment == null) myPosition = POSITION_BOTTOM;
				else myPosition = POSITION_MIDDLE;
			}
		}
		
		protected function drawCompartment():void {
			var shapeData:String;			
			switch(myPosition) {
				case POSITION_ONLY:
					shapeData = 'M 0,0 ';
					shapeData += 'L 0,'+ myHeight + ' ';
					shapeData += 'L' + myWidth + ',' + myHeight + ' ';
					shapeData += 'L' + myWidth + ',0 ';
					shapeData += 'Z';
					break;
				case POSITION_TOP:
					shapeData = 'M 0,0 ';
					shapeData += 'L 0,' + myHeight + ' ';
					shapeData += 'Q' + Math.round(myWidth / 2.0) + ',' + (myHeight - diagram.membraneCurvature) + ' ' + myWidth + ',' + myHeight + ' ';
					shapeData += 'L' + myWidth + ',0 ';
					shapeData += 'Z';
					break;
				case POSITION_BOTTOM:
					shapeData = 'M 0,' + myHeight + ' ';
					shapeData += 'L 0,0 ';
					shapeData += 'Q' + Math.round(myWidth / 2.0) + ',' + (-diagram.membraneCurvature) + ' ' + myWidth + ',0 ';
					shapeData += 'L' + myWidth + ',' + myHeight + ' ';
					shapeData += 'Z';
					break;
				case POSITION_MIDDLE:
					shapeData = 'M 0,0 ';
					shapeData += 'Q' + Math.round(myWidth / 2.0) + ',' + (-diagram.membraneCurvature) + ' ' + myWidth + ',0 ';
					shapeData += 'L' + myWidth + ',' + myHeight + ' ';
					shapeData += 'Q' + Math.round(myWidth / 2.0) + ',' + (myHeight - diagram.membraneCurvature) + ' 0,' + myHeight + ' ';
					shapeData += 'Z';
					break;
			}
			shape.data = shapeData;
		}
				
		/************************************************
		* biomolecules and edges
		* **********************************************/
		public function get biomolecules():ArrayCollection {
			var biomolecules:ArrayCollection = new ArrayCollection();
			for (var i:uint; i < diagram.biomolecules.length; i++) {
				if (diagram.biomolecules[i].myCompartment == this) {
					biomolecules.addItem(diagram.biomolecules[i]);
				}
			}
			return biomolecules;
		}
		
		public function getBiomoleculesShapeBounds(global:Boolean = false):Rectangle {
			var left:Number = Infinity;
			var right:Number = -Infinity;
			var top:Number = Infinity;
			var bottom:Number = -Infinity;
			var bounds:Rectangle;
			var compartmentBiomolecules:ArrayCollection = this.biomolecules;
			
			for (var i:uint; i < compartmentBiomolecules.length; i++) {
					bounds = compartmentBiomolecules[i].getShapeBounds(global);
					left = Math.min(left, bounds.left);
					right = Math.max(right, bounds.right);
					top = Math.min(top, bounds.top);
					bottom = Math.max(bottom, bounds.bottom);
			}
			
			return new Rectangle(left, top, right - left, bottom - top);
		}
		
		public function get edges():ArrayCollection {
			var biomolecules:ArrayCollection = this.biomolecules;
			var edges:ArrayCollection = new ArrayCollection();
			for (var i:uint; i < diagram.edges.length; i++) {
				if (biomolecules.contains(diagram.edges[i].from) && 
					biomolecules.contains(diagram.edges[i].to)) {
					edges.addItem(diagram.edges[i]);
				}
			}
			return edges;
		}
		
		public function getMaxDegreeNode():Biomolecule {
			var maxDegree:int = -1;
			var degree:uint;
			var maxDegreeBiomolecule:Biomolecule;
			
			for each(var biomolecule:Biomolecule in this.biomolecules) {
				degree = biomolecule.countMyEdges()
				if (maxDegree < degree) {
					maxDegree = degree;
					maxDegreeBiomolecule = biomolecule;
				}
			}
			
			return maxDegreeBiomolecule;
		}
		
		public function getIsolatedNode():Biomolecule {
			var compartmentIndex:uint = diagram.compartmentsAndMembranes.getItemIndex(this);
			var maxDegree:int = -1;
			var degree:uint;
			var isolated:Boolean;
			var maxDegreeBiomolecule:Biomolecule;
			
			for each(var biomolecule:Biomolecule in this.biomolecules) {
				degree = biomolecule.countMyEdges();
				
				isolated = true;
				for each(var edge:Edge in biomolecule.getMyEdges()) {
					if (diagram.compartmentsAndMembranes.getItemIndex(edge.from.myCompartment) == compartmentIndex) {
						isolated = false;
					}
				}
				
				if (isolated && maxDegree < degree) {
					maxDegree = degree;
					maxDegreeBiomolecule = biomolecule;
				}				
			}
			
			return maxDegreeBiomolecule;
		}
	}
}