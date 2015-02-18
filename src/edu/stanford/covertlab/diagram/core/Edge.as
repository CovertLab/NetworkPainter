package edu.stanford.covertlab.diagram.core 
{
	import br.com.stimuli.string.printf;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.segment.CubicBezierTo;
	import com.degrafa.geometry.segment.LineTo;
	import com.degrafa.geometry.segment.MoveTo;
	import com.degrafa.GeometryGroup;
	import com.degrafa.GraphicPoint;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientStroke;
	import com.degrafa.paint.RadialGradientFill;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.transform.RotateTransform;
	import com.degrafa.transform.Transform;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.event.BiomoleculeEvent;
	import edu.stanford.covertlab.diagram.toolbar.ToolBar;
	import edu.stanford.covertlab.graphics.shape.PoreShape;
	import edu.stanford.covertlab.graphics.shape.ShapeBase;
	import edu.stanford.covertlab.util.ColorUtils;
	import flash.geom.Point;
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	
	/**
	 * Displays a pictorial representation of a "connection" between two biomolecules. Pictorial representation is of a path
	 * containing line, bezier, and arc segments with an arrow at the end. Pores are automatically drawn where paths cross
	 * membranes. Edges are automatically updated when either of the associated biomolecules is moved.
	 * 
	 * @see Biomolecule
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Edge extends GeometryGroup
	{		
		private var diagram:Diagram;		
		private var _from:Biomolecule;
		private var _to:Biomolecule;
		private var _sense:Boolean=true;
		private var _pathData:String = '';
		
		private var pathGeometryGroup:GeometryGroup;
		private var path:Path;
		private var arrow:Polygon;
		private var arrowGeometryGroup:GeometryGroup;
		private var poreGeometryGroup:GeometryGroup;
		private var _poreAlpha:Number;
		private var _dim:Boolean;
		
		public var toolTip:String = '';
		
		public function Edge(diagram:Diagram, from:Biomolecule, to:Biomolecule, sense:Boolean = true)
		{						
			//create pore, path, arrow
			poreGeometryGroup = new GeometryGroup();
			addChild(poreGeometryGroup);
			
			pathGeometryGroup = new GeometryGroup();
			addChild(pathGeometryGroup);
			
			path = new Path();			
			path.stroke = new SolidStroke(0x000000, 1, 1);
			pathGeometryGroup.geometryCollection.addItem(path);
			
			arrowGeometryGroup = new GeometryGroup();
			addChild(arrowGeometryGroup);
			
			arrow = new Polygon(arrowPoints(true));
			arrow.fill = new SolidFill(0x000000, 1);
			arrowGeometryGroup.geometryCollection.addItem(arrow);
			
			//binding
			BindingUtils.bindProperty(poreGeometryGroup, 'visible', diagram, 'showPores');
			BindingUtils.bindSetter(poreFillColorSetter, diagram, 'poreFillColor');
			BindingUtils.bindSetter(poreStrokeColorSetter, diagram, 'poreStrokeColor');
			
			//store properties
			this.diagram = diagram;
			this.sense = sense;			
			this.from = from;
			this.to = to;
			
			//tooltip
			toolTip = '';			
		}
		
		public function remove():void {
			diagram.removeEdge(this);
		}
		
		/************************************************
		* setter/getter
		* **********************************************/
		public function get from():Biomolecule {
			return _from;
		}
		public function set from(value:Biomolecule):void {
			if (_from != value) {
				if (_from != null) _from.removeEventListener(BiomoleculeEvent.BIOMOLECULE_MOVE, updateEdge);
				_from = value;
				if (_from != null) _from.addEventListener(BiomoleculeEvent.BIOMOLECULE_MOVE, updateEdge);
				updateEdge();
			}
		}
		
		public function get to():Biomolecule {
			return _to;
		}
		public function set to(value:Biomolecule):void {
			if (_to != value) {
				if (_to != null) _to.removeEventListener(BiomoleculeEvent.BIOMOLECULE_MOVE, updateEdge);
				_to = value;
				if (_to != null) _to.addEventListener(BiomoleculeEvent.BIOMOLECULE_MOVE, updateEdge);
				updateEdge();
			}
		}
		
		public function get sense():Boolean {
			return _sense;
		}
		public function set sense(value:Boolean):void {
			if (_sense != value) {
				_sense = value;
				arrow.points = arrowPoints(sense);
			}
		}
		
		
		//pore updating limited to pathData which only includes MoveTo, LineTo, and CubicBezierTo segments
		public function get pathData():String {
			return _pathData;
		}
		public function set pathData(value:String):void {
			if (_pathData != value) {
				_pathData = value;
				
				//set path
				path.data = pathData;
				path.preDraw();
				
				//update arrow				
				var pt1:Point = path.pointAt(1);
				arrowGeometryGroup.x = pt1.x;
				arrowGeometryGroup.y = pt1.y;
				arrowGeometryGroup.rotation = 180/Math.PI*path.angleAt(1)-90;				
			}
			
			//update pore(s)
			updatePores();
		}
		
		public function get poreAlpha():Number {
			return _poreAlpha;
		}
		public function set poreAlpha(value:Number):void {
			if (_poreAlpha != value) {
				_poreAlpha = value;
				poreGeometryGroup.alpha = value;
			}
		}
		
		public function get dim():Boolean {
			return _dim;
		}
		
		public function set dim(value:Boolean):void {
			if (dim != value) {
				_dim = value;
				for (var i:uint = 0; i < poreGeometryGroup.numChildren; i++) {
					(poreGeometryGroup.getChildAt(i) as PoreShape).fillColor = (dim ? Diagram.dimGrey[1] : diagram.poreFillColor);
					(poreGeometryGroup.getChildAt(i) as PoreShape).strokeColor = (dim ? Diagram.dimGrey[2] : diagram.poreStrokeColor);
					(poreGeometryGroup.getChildAt(i) as PoreShape).solidColor = dim;
				}
				(path.stroke as SolidStroke).color = (dim ? Diagram.dimGrey[2] : 0x000000);
				(arrow.fill as SolidFill).color = (dim ? Diagram.dimGrey[2] : 0x000000);
			}
		}
		
		/************************************************
		* display
		* **********************************************/
		
		public function updateEdge(event:BiomoleculeEvent = null):void {
			if (to == null || from == null) return;
			//compute ports
			var theta:Number = -Math.atan2(to.y - from.y, to.x - from.x)+Math.PI/2;
			var fromPort:GraphicPoint = from.computePort(theta);
			var toPort:GraphicPoint = to.computePort(theta-Math.PI,sense);
			
			//set path
			pathData = 'M ' + fromPort.x + ',' + fromPort.y + ' ' + 'L ' + toPort.x + ',' + toPort.y;
		}
		
		private function updatePores():void {
			while (poreGeometryGroup.numChildren > 0) poreGeometryGroup.removeChildAt(0);
			var upperCompartment:CompartmentBase;
			var lowerCompartment:CompartmentBase;
			var pore:PoreShape;
			var pt:Object;
			var i:uint;
			var segmentIndex:uint = 1;
			var intersection:*;

			if (from != null && from.myCompartment != null && to != null && to.myCompartment != null ) {
				if (from.myCompartment.y < to.myCompartment.y) {
					upperCompartment = (from.myCompartment is Membrane)? from.myCompartment.myLowerCompartment:from.myCompartment;
					lowerCompartment = (to.myCompartment is Membrane)? to.myCompartment.myUpperCompartment: to.myCompartment;
					while (upperCompartment != lowerCompartment 
							&& diagram.compartments.contains(upperCompartment) 
							&& diagram.compartments.contains(lowerCompartment)) {
						for (i = segmentIndex; i < path.segments.length; i++) {
							if (path.segments[i] is LineTo) {
								intersection = (upperCompartment as Compartment).myMembrane.intersectLine(
									path.segments[i - 1].x, path.segments[i - 1].y, 
									path.segments[i].x, path.segments[i].y);
							} else if (path.segments[i] is CubicBezierTo) {
								intersection = (upperCompartment as Compartment).myMembrane.intersectCubicBezier(
									path.segments[i - 1].x, path.segments[i - 1].y, 
									path.segments[i].cx, path.segments[i].cy,
									path.segments[i].cx1, path.segments[i].cy1,
									path.segments[i].x, path.segments[i].y);
							}
							if (intersection !== false) {
								segmentIndex = i;
								break;
							}
						}

						//draw pore in upperCompartment.myMembrane
						if (intersection !== false) {
							pore = new PoreShape(
								Biomolecule.SIZE, 
								(dim ? Diagram.dimGrey[2] : diagram.poreStrokeColor),
								(dim ? Diagram.dimGrey[1] : diagram.poreFillColor));
							pore.solidColor = dim;
							pore.x = intersection.x;
							pore.y = intersection.y;
							pore.rotation = intersection.rotation;
							pore.target = poreGeometryGroup;
							poreGeometryGroup.addChild(pore);
						}
						
						//move down compartment
						upperCompartment = upperCompartment.myLowerCompartment;
					}
				} else if (from.myCompartment.y > to.myCompartment.y) {					
					upperCompartment = (to.myCompartment is Membrane)? to.myCompartment.myLowerCompartment: to.myCompartment;
					lowerCompartment = (from.myCompartment is Membrane)? from.myCompartment.myUpperCompartment:from.myCompartment;
					while (upperCompartment != lowerCompartment) {
						for (i=segmentIndex; i < path.segments.length; i++) {						
							if (path.segments[i] is LineTo)
								intersection = (lowerCompartment.myUpperCompartment as Compartment).myMembrane.intersectLine( 
									path.segments[i - 1].x, path.segments[i - 1].y, 
									path.segments[i].x, path.segments[i].y);
							else if (path.segments[i] is CubicBezierTo)
								intersection = (lowerCompartment.myUpperCompartment as Compartment).myMembrane.intersectCubicBezier(
									path.segments[i - 1].x, path.segments[i - 1].y, 
									path.segments[i].cx, path.segments[i].cy,
									path.segments[i].cx1, path.segments[i].cy1,
									path.segments[i].x, path.segments[i].y);
							
							if (intersection !== false) {
								segmentIndex = i;
								break;
							}
						}

						//draw pore in upperCompartment.myMembrane
						if (intersection!==false) {
							pore = new PoreShape(
								Biomolecule.SIZE, 
								(dim ? Diagram.dimGrey[2] : diagram.poreStrokeColor),
								(dim ? Diagram.dimGrey[1] : diagram.poreFillColor));
							pore.solidColor = dim;
							pore.x = intersection.x;
							pore.y = intersection.y;
							pore.rotation = intersection.rotation;
							pore.target = poreGeometryGroup;
							poreGeometryGroup.addChild(pore);
						}
							
						//move up compartment
						lowerCompartment = lowerCompartment.myUpperCompartment;
					}
				}
			}
		}
		
		private function poreFillColorSetter(poreFillColor:uint):void 
		{
			for (var i:uint = 0; i < poreGeometryGroup.numChildren; i++) {
				(poreGeometryGroup.getChildAt(i) as PoreShape).fillColor = (dim ? Diagram.dimGrey[1] : poreFillColor);
			}
		}
		
		private function poreStrokeColorSetter(poreStrokeColor:uint):void 
		{
			for (var i:uint = 0; i < poreGeometryGroup.numChildren; i++) {
				(poreGeometryGroup.getChildAt(i) as PoreShape).strokeColor = (dim ? Diagram.dimGrey[2] : poreStrokeColor);
			}
		}
		
		/************************************************
		* dot code
		* **********************************************/
		public function dotCode(scale:Number):String {
			if(diagram.compartmentsAndMembranes.getItemIndex(from.myCompartment)<=diagram.compartmentsAndMembranes.getItemIndex(to.myCompartment)){
				return printf('"%s"->"%s" [arrowhead="%s"];', from.myName, to.myName, (sense ? 'normal' : 'tee'), ColorUtils.hexToDec(0x000000));
			}else{
				return printf('"%s"->"%s" [arrowhead="%s",dir="back"];', to.myName, from.myName, (sense ? 'normal' : 'tee'), ColorUtils.hexToDec(0x000000));
			}
		}
		
		/************************************************
		* arrow shapes
		* **********************************************/
		public static function arrowPoints(sense:Boolean, theta:Number = 0):Array {
			switch(sense) {
				case true:
					return [
						new GraphicPoint(0, 0),						
						new GraphicPoint( -0.75 * Biomolecule.SIZE * Math.sin( -Math.PI * 1 / 8 + theta), -0.75 * Biomolecule.SIZE * Math.cos( -Math.PI * 1 / 8 + theta)),
						new GraphicPoint( -0.75 * Biomolecule.SIZE * Math.sin( +Math.PI * 1 / 8 + theta), -0.75 * Biomolecule.SIZE * Math.cos(Math.PI * 1 / 8 + theta))];
				case false:
					return [
						new GraphicPoint( -0.35 * Biomolecule.SIZE * Math.sin( -Math.PI / 2 + theta), -0.35 * Biomolecule.SIZE * Math.cos( -Math.PI / 2 + theta)),						
						new GraphicPoint( -0.35 * Biomolecule.SIZE * Math.sin( -Math.PI / 2 + theta) - 0.2 * Biomolecule.SIZE * Math.sin(theta), -0.35 * Biomolecule.SIZE * Math.cos( -Math.PI / 2 + theta) - 0.2 * Biomolecule.SIZE * Math.cos(theta)),						
						new GraphicPoint( -0.35 * Biomolecule.SIZE * Math.sin(Math.PI / 2 + theta) - 0.2 * Biomolecule.SIZE * Math.sin(theta), -0.35 * Biomolecule.SIZE * Math.cos(Math.PI / 2 + theta) - 0.2 * Biomolecule.SIZE * Math.cos(theta)),						
						new GraphicPoint( -0.35 * Biomolecule.SIZE * Math.sin(Math.PI / 2 + theta), -0.35 * Biomolecule.SIZE * Math.cos(Math.PI / 2 + theta))];						
			}
			return [];
		}
		
	}
	
}