package edu.stanford.covertlab.diagram.core 
{
	import br.com.stimuli.string.printf;
	import caurina.transitions.Tweener;
	import com.degrafa.GeometryGroup;
	import com.degrafa.GraphicPoint;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;	
	import com.degrafa.Surface;
	import edu.stanford.covertlab.colormap.Colormap;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.core.Edge;
	import edu.stanford.covertlab.diagram.event.BiomoleculeEvent;
	import edu.stanford.covertlab.diagram.event.BiomoleculeStyleEvent;
	import edu.stanford.covertlab.diagram.event.CompartmentEvent;
	import edu.stanford.covertlab.diagram.history.HistoryAction;
	import edu.stanford.covertlab.diagram.history.IHistory;
	import edu.stanford.covertlab.graphics.renderablerepeater.ColorGrid;
	import edu.stanford.covertlab.graphics.SelectHandles;
	import edu.stanford.covertlab.graphics.SupSubRasterText;
	import edu.stanford.covertlab.graphics.shape.*;
	import edu.stanford.covertlab.diagram.window.EditBiomoleculeWindow;
	import edu.stanford.covertlab.util.HTML;
	import edu.stanford.covertlab.util.ColorUtils;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	/**
	 * Biomolecule class. Displays a pictorial representation (according to its biomolecule style) of a biomolecule that can edited, 
	 * dragged, delete, and animated. Edited either through the EditBiomoleculeWindow or BiomolelculesPanel
	 * 
	 * <p>Features:
	 * <ul>
	 * <li>Snap to membrane</li>
	 * <li>Tween to new position</li>
	 * <li>Parses mathematical regulation statement and creates edges amond biomolecules</li>
	 * </ul></p>
	 * 
	 * @see BiomoleculeStyle
	 * @see Edge
	 * @see Compartment
	 * @see Membrane
	 * @see edu.stanford.covertlab.diagram.event.BiomoleculeEvent
	 * @see edu.stanford.covertlab.diagram.window.EditBiomoleculeWindow
	 * @see edu.stanford.covertlab.diagram.panel.BiomoleculesPanel
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @author Ed Chen, chened@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Biomolecule extends Surface implements IHistory
	{	
		
		public static const SIZE:Number = 20;
		
		private var _diagram:Diagram;
		private var _myName:String;
		private var _myLabel:String;
		private var _myRegulation:String;
		private var _myComments:String;
		private var _myCompartment:CompartmentBase;
		private var _myStyle:BiomoleculeStyle;
		private var _dim:Boolean;
		
		public var tmpChannel:Object;
		public var tmpCondition:Object;
		public var tmpActivity:Object;
		
		public function Biomolecule(diagram:Diagram, myCompartment:CompartmentBase, myStyle:BiomoleculeStyle, x:Number = 0, y:Number = 0, myName:String = null, 
		myLabel:String = null, myRegulation:String = null, myComments:String=null, addHistoryAction:Boolean=true) 
		{
			//style
			buttonMode = true;
			useHandCursor = true;
			doubleClickEnabled = true;					

			//create shape, label, select handles geometry objects
			shapeGeometryGroup = new ShapeBase();
			addChild(shapeGeometryGroup);
			
			labelGeometryGroup = new SupSubRasterText('', fontSize);
			labelGeometryGroup.fill = new SolidFill();
			addChild(labelGeometryGroup);
			
			selectedHandlesGeometryGroup = new SelectHandles(SIZE);
			selectedHandlesGeometryGroup.visible = false;
			addChild(selectedHandlesGeometryGroup);
			
			//heatmap
			heatmapGeometryGroup = new GeometryGroup();
			BindingUtils.bindSetter(function(value:Boolean):void { heatmapGeometryGroup.visible = (diagram.animationNotStopped && diagram.comparisonHeatmapsVisible && myValue!=null); }, diagram, 'comparisonHeatmapsVisible');
			BindingUtils.bindSetter(function(value:Boolean):void { heatmapGeometryGroup.visible = (diagram.animationNotStopped && diagram.comparisonHeatmapsVisible && myValue!=null); }, diagram, 'animationNotStopped');
			addChild(heatmapGeometryGroup);
			
			heatmap = new ColorGrid();
			heatmap.stroke = new SolidStroke(0x000000);
			heatmapGeometryGroup.geometryCollection.addItem(heatmap);
			
			//store properties
			this.x = x;
			this.y = y;
			this.diagram = diagram;
			this.myStyle = myStyle;
			this.myCompartment = myCompartment;
			this.myName = myName;
			this.myLabel = myLabel;
			this.myRegulation = myRegulation;
			this.myComments = myComments;
			
			//add mouse handlers
			addEventListener(MouseEvent.DOUBLE_CLICK, openEditWindow);
			
			//add to diagram
			diagram.addBiomolecule(this);
			
			//undo
			if (addHistoryAction) diagram.historyManager.addHistoryAction(new HistoryAction(this, 'remove'));
		}
		
		//copies label, regulation
		//generates unique name
		public function copy():Object {		
			//compute new unique name
			var newName:String;
			var pattern:RegExp =/copy_of_([\w\d_]+)_(\d+)/;
			var matches:Object = pattern.exec(myName);
			if (matches != null && diagram.getBiomoleculeByName(matches[1]) !== false) newName = printf('copy_of_%s_%d', matches[1], parseInt(matches[2]+1));
			else if (matches == null && diagram.getBiomoleculeByName(myName) !== false) newName = printf('copy_of_%s_%d', myName,1);
			else newName = myName;
			
			//clone biomolecule
			return { myCompartment:myCompartment, myStyle:myStyle, x:x, y:y, myName:newName, 
				myLabel:myLabel, myRegulation:myRegulation, myComments:myComments };
		}
		
		public function get diagram():Diagram {
			return _diagram;
		}
		public function set diagram(value:Diagram):void {
			_diagram = value;
		}
		
		[Bindable]
		public function get myCompartment():CompartmentBase {
			return _myCompartment;
		}
		public function set myCompartment(value:CompartmentBase):void {			
			if (_myCompartment != value) {
				_myCompartment = value;
				
				var pt:Object = snapToCompartment(x, y);
				x = pt.x;
				y = pt.y;
				this.rotation = pt.rotation;
				dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_MOVE));
			}
		}
		
		[Bindable]
		public function get myStyle():BiomoleculeStyle {
			return _myStyle;
		}
		public function set myStyle(value:BiomoleculeStyle):void {
			if (value != null) {				
				if (!dim && (_myStyle == null || value.myOutline != _myStyle.myOutline)) shapeGeometryGroup.strokeColor = value.myOutline;
				if (!dim && (_myStyle == null || value.myColor != _myStyle.myColor) && (!myValue || myValue.length == 0)) {
					shapeGeometryGroup.fillColor = value.myColor;
					setLabelColor();
				}
				if (_myStyle==null || value.myShape != _myStyle.myShape) updateShape(value.myShape, value.myOutline, value.myColor);
				if (_myStyle != null) _myStyle.removeEventListener(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_UPDATE, styleUpdateHandler);
				
				if (myStyle) myStyle.removeEventListener(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_UPDATE, styleUpdateHandler);
				value.addEventListener(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_UPDATE, styleUpdateHandler);
				
				_myStyle = value;
				dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_MOVE));
				onRefreshShape();
			}
		}
		
		private function styleUpdateHandler(event:BiomoleculeStyleEvent):void {
			if (!dim) shapeGeometryGroup.strokeColor = event.target.myOutline;
			if (!dim && (!myValue || myValue.length == 0)) shapeGeometryGroup.fillColor = event.target.myColor;
			updateShape(event.target.myShape, event.target.myOutline, event.target.myColor);
			dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_MOVE));
			onRefreshShape();
			setLabelColor();
		}
		
		[Bindable]
		public function get myName():String {
			return _myName;
		}
		public function set myName(value:String):void {
			if (_myName != value) {				

				//update regulatory rules of biomolecules regulated by this node
				for (var i:uint = 0; i < diagram.biomolecules.length; i++) {
					if (diagram.biomolecules.getItemAt(i).myRegulation.search(_myName) > -1) {
						var pattern:RegExp = new RegExp('(^|[^a-zA-Z0-9_])' + _myName + '([^a-zA-Z0-9_]|$)', 'g');
						diagram.biomolecules.getItemAt(i).myRegulation = diagram.biomolecules.getItemAt(i).myRegulation.replace(pattern, "$1" + value + "$2");
					}
				}
				
				//update value
				toolTip = value;
				_myName = value;
			}
		}
		
		[Bindable]
		public function get myLabel():String {
			return _myLabel;
		}
		public function set myLabel(value:String):void {
			if (_myLabel != value) {
				updateLabel(value);				
				_myLabel = value;	
			}
		}
		
		[Bindable]
		public function get myRegulation():String {
			return _myRegulation;
		}
		public function set myRegulation(value:String):void {
			if (_myRegulation != value) {
				if(validateRegulation(value,diagram)) {
					_myRegulation = value;
					updateIncomingEdges();
				}
			}
		}
		
		[Bindable]
		public function get myComments():String {
			return _myComments;
		}
		public function set myComments(value:String):void {
			if (_myComments != value) {
				_myComments = value;
			}
		}
		
		public function get dim():Boolean {
			return _dim;
		}
		
		public function set dim(value:Boolean):void {
			if (value != dim) {
				_dim = value;
				if (dim) {
					shapeGeometryGroup.strokeColor = Diagram.dimGrey[2];
					shapeGeometryGroup.fillColor = Diagram.dimGrey[1];
					shapeGeometryGroup.solidColor = true;
				}else if(!myValue || myValue.length == 0){
					shapeGeometryGroup.strokeColor = myStyle.myOutline;
					shapeGeometryGroup.fillColor = myStyle.myColor;
					shapeGeometryGroup.solidColor = false;
				}else {
					shapeGeometryGroup.strokeColor = myStyle.myOutline;
					shapeGeometryGroup.fillColor = (isNaN(myValue[0][0]) ? 0xFF0000 : Colormap.scale(diagram.colormap, myValue[0][0]));
					shapeGeometryGroup.solidColor = true;
					shapeGeometryGroup.hash = isNaN(myValue[0][0]);
				}
				setLabelColor();
			}
		}
		
		public function update(myName:String = '', myLabel:String = '', myRegulation:String = '', myCompartment:CompartmentBase = null, 
		myStyle:BiomoleculeStyle = null, myComments:String = '', addHistoryAction:Boolean = true):Object {			
			if (!validateRegulation(myRegulation, diagram)) return null;
							
			var undoData:Object = { myName:this.myName, myLabel:this.myLabel, myRegulation:this.myRegulation, myCompartment:this.myCompartment, myStyle:this.myStyle, myComments:myComments };
			if(addHistoryAction) diagram.historyManager.addHistoryAction(new HistoryAction(this, 'update', undoData));
			
			this.myName = myName;
			this.myLabel = myLabel;
			this.myRegulation = myRegulation;
			this.myCompartment = myCompartment;
			this.myStyle = myStyle;
			this.myComments = myComments;	
			
			diagram.updateBiomolecule(this);
			dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_UPDATE));
			return undoData;
		}
		
		public function remove(addHistoryAction:Boolean = true):Object {
			var undoData:ArrayCollection = myOutgoingRegulation;
			if (addHistoryAction) diagram.historyManager.addHistoryAction(new HistoryAction(this, 'construct', undoData));
			
			deleteIncomingEdges();
			deleteOutgoingEdges();
			diagram.removeBiomolecule(this);
			
			return undoData;
		}
		
		/************************************************
		* animation
		* **********************************************/		
		private var _myValue:Array = [];
		private var myOldValue:Array = [];
		
		public function get myValue():Array {
			return _myValue;
		}
		public function set myValue(value:Array):void {
			_myValue = value;
			if (value == null || value.length == 0) {
				shapeGeometryGroup.fillColor = myStyle.myColor;
				shapeGeometryGroup.solidColor = false;
				shapeGeometryGroup.hash = false;
			}else {
				shapeGeometryGroup.fillColor = (isNaN(value[0][0]) ? 0xFF0000 : Colormap.scale(diagram.colormap, value[0][0]));
				shapeGeometryGroup.solidColor = true;
				shapeGeometryGroup.hash = isNaN(value[0][0]);
				
				var colors:Array = [];
				for (var i:uint = 0; i < value.length; i++) {
					for (var j:uint = 0; j < value[i].length; j++) {
						colors.push(Colormap.scale(diagram.colormap, value[i][j]));
					}
				}
				
				var nRow:Number = value[0].length;
				var nCol:Number = value.length;
				if (nRow == 1 || nCol == 1) {
					var tmp:Number = Math.ceil(Math.sqrt(nRow * nCol - 1));
					nRow = Math.ceil((nRow * nCol - 1) / tmp);
					nCol = tmp;
				}
				var w:Number = 3/4 * SIZE * nCol;
				var h:Number = 3/4 * SIZE * nRow;
				heatmap.updateProperties(-w / 2, 0, w, h, nRow, nCol, colors);
				
				heatmap.y = getShapeBounds().bottom + heatmapOffsetY;
				heatmapGeometryGroup.visible = diagram.animationNotStopped && diagram.comparisonHeatmapsVisible && colors.length > 1;
			}
			setLabelColor();
		}
		
		/************************************************
		 * heatmap
		 * **********************************************/
		private var heatmapGeometryGroup:GeometryGroup;
		private var heatmap:ColorGrid;
		private var heatmapOffsetY:Number = SIZE / 4;
	
		/************************************************
		* display
		* **********************************************/
		public static var BIOMOLECULE_SHAPES:ArrayCollection = new ArrayCollection([ { name:'Circle' }, { name:'Diamond' }, 
				{ name:'Ellipse' }, { name:'Hexagon' }, { name:'House' }, { name:'Inverted House' }, { name:'Inverted Trapezium' }, 
				{ name:'Inverted Triangle' }, { name:'Octagon' }, { name:'Parallelogram' }, { name:'Pentagon' }, { name:'Rectangle' }, 
				{ name:'Rounded Rectangle' }, { name:'Septagon' }, { name:'Square' }, { name:'Trapezium' }, { name:'Triangle' }, 
				{ name:'7-Pass Transmembrane Receptor' }, { name:'ATPase' }, { name:'Centrosome' }, { name:'DNA' }, { name:'Endoplasmic Reticulum' }, 
				{ name:'Flagellum' }, { name:'Golgi' }, { name:'Ig' }, { name:'Ion channel' }, { name:'Mitochondrion' }, { name:'Pore' }, 
				{ name:'Y-Receptor' } ]);				
		
		private var selectedHandlesGeometryGroup:SelectHandles;
		private var labelGeometryGroup:SupSubRasterText;
		private var shapeGeometryGroup:ShapeBase;
		
		private var fontSize:Number = 10;
		
		private function updateLabel(label:String):void {
			labelGeometryGroup.text = label;			
			labelGeometryGroup.x = -labelGeometryGroup.width / 2 + shapeGeometryGroup.labelOffsetX;
			labelGeometryGroup.y = -labelGeometryGroup.height / 2 + shapeGeometryGroup.labelOffsetY;
		}
		
		private function updateShape(shapeName:String, outlineColor:uint, fillColor:uint):void {
			if (shapeName == '' && myStyle!=null) shapeName = myStyle.myShape;
			
			//remove old shapes
			removeChild(shapeGeometryGroup);
			shapeGeometryGroup = getShape(shapeName, SIZE, outlineColor, fillColor);
			
			shapeGeometryGroup.target = this;
			addChildAt(shapeGeometryGroup,0);
			setChildIndex(shapeGeometryGroup, 0);
		}
		
		public static function getShape(shapeName:String, drawsize:Number, drawstroke:uint, drawfill:uint):ShapeBase {
			switch(shapeName) {
				case 'Circle': return new CircleShape(drawsize, drawstroke, drawfill); break;
				case 'Rectangle': return new RectangleShape(drawsize, drawstroke, drawfill); break;
				case 'Diamond': return new RegularPolygonShape(drawsize, drawstroke, drawfill, 4); break;
				case 'Ellipse':	return new EllipseShape(drawsize, drawstroke, drawfill); break;
				case 'Hexagon': return new RegularPolygonShape(drawsize, drawstroke, drawfill, 6); break;
				case 'House': return new HouseShape(drawsize, drawstroke, drawfill); break;
				case 'Inverted House': return new HouseShape(drawsize, drawstroke, drawfill, Math.PI); break;
				case 'Inverted Trapezium': return new TrapeziumShape(drawsize, drawstroke, drawfill, Math.PI); break;
				case 'Inverted Triangle': return new RegularPolygonShape(drawsize, drawstroke, drawfill, 3, Math.PI); break;
				case 'Octagon': return new RegularPolygonShape(drawsize, drawstroke, drawfill, 8); break;
				case 'Parallelogram': return new ParallelogramShape(drawsize, drawstroke, drawfill); break;
				case 'Pentagon': return new RegularPolygonShape(drawsize, drawstroke, drawfill, 5); break;
				case 'Rectangle': return new RectangleShape(drawsize, drawstroke, drawfill, false); break; // added
				case 'Rounded Rectangle': return new RectangleShape(drawsize, drawstroke, drawfill, true); break;
				case 'Septagon': return new RegularPolygonShape(drawsize, drawstroke, drawfill, 7); break;
				case 'Square':	return new RegularPolygonShape(drawsize, drawstroke, drawfill, 4, Math.PI / 4); break;
				case 'Trapezium': return new TrapeziumShape(drawsize, drawstroke, drawfill); break;
				case 'Triangle': return new RegularPolygonShape(drawsize, drawstroke, drawfill, 3); break;
				case '7-Pass Transmembrane Receptor': return new PassTransmembraneReceptorShape(drawsize, drawstroke, drawfill); break;
				case 'ATPase': return new ATPaseShape(drawsize, drawstroke, drawfill); break;
				case 'Centrosome': return new CentrosomeShape(drawsize, drawstroke, drawfill); break;
				case 'DNA': return new DNAShape(drawsize, drawstroke, drawfill); break;
				case 'Endoplasmic Reticulum': return new EndoplasmicReticulumShape(drawsize, drawstroke, drawfill); break;
				case 'Flagellum': return new FlagellumShape(drawsize, drawstroke, drawfill); break;
				case 'Golgi': return new GolgiShape(drawsize, drawstroke, drawfill); break;
				case 'Ig': return new IgShape(drawsize, drawstroke, drawfill); break;
				case 'Ion channel': return new IonChannelShape(drawsize, drawstroke, drawfill); break;
				case 'Mitochondrion': return new MitochondrionShape(drawsize, drawstroke, drawfill); break;
				case 'Pore': return new PoreShape(drawsize, drawstroke, drawfill); break;
				case 'Y-Receptor': return new YReceptorShape(drawsize, drawstroke, drawfill); break;
				case 'None': // this would get confusing since it allows invisible nodes
				default: return new ShapeBase(drawsize, drawstroke, drawfill); break;
			}
		}
		
		private function setLabelColor():void {
			if (dim) {
				(labelGeometryGroup.fill as SolidFill).color = Diagram.dimGrey[3];
				return;
			}
			
			if (shapeGeometryGroup.hash || !shapeGeometryGroup.solidColor || shapeGeometryGroup.labelOffsetY > SIZE){
				(labelGeometryGroup.fill as SolidFill).color = 0x000000;
				return;
			}
			
			(labelGeometryGroup.fill as SolidFill).color = 
				ColorUtils.brightness(shapeGeometryGroup.fillColor) > 128 ? 0x000000 : 0xFFFFFF;
		}
		
		public function computePort(theta:Number, sense:Boolean = true):GraphicPoint {
			var points:Array = [];
			var port:GraphicPoint = shapeGeometryGroup.port(theta, sense);
			return new GraphicPoint(x + port.x, y + port.y);
		}
		
		/************************************************
		* dot code
		* **********************************************/		
		public function dotCode(scale:Number):String{
			var shapeBounds:Rectangle = getShapeBounds();					
			return printf('"%s" [label="%s",comments="%s",shape="%s",class="%s",fillcolor="#%s",color="#%s",fontsize="%f",pos="%f,%f",width="%f",height="%f"];' , 
				myName, HTML.entitiesToDecimal(myLabel).replace(/'/g,"\'"), myRegulation,
				(myStyle.myShape == 'None' ? 'plaintext' : 'box'),  (myStyle.myShape == 'None' ? '' : 'filled'),
				ColorUtils.hexToDec(myStyle.myColor), ColorUtils.hexToDec(myStyle.myOutline), fontSize,
				x / scale,
				y / scale,
				shapeBounds.width / scale,
				shapeBounds.height/ scale);
		}

	
		/************************************************
		* regulation
		* **********************************************/
		private var myEdges:ArrayCollection = new ArrayCollection();

		public static function validateRegulation(value:String, diagram:Diagram):Object {			
			var sense:Array = [];
			var depth:Array = [];
			var senseDepth:Array = [true];
			var currDepth:int;
			var currSense:Boolean = true;
			var i:uint;
			var pattern:RegExp;
			var matches:Array;
			var temp:Number;
			
			if (value == null) value = '';
			
			//don't need to check allowed characters (a-zA-z0-9_!|&) because already taken care of by input box
			
			//check logical operators
			pattern = /^((!?\()?!?[A-Za-z0-9]\w*( ?(\|\||\&\&) ?(!?\()?!?[A-Za-z0-9]\w*\)?)*)?$/;
			if (!pattern.test(value)) return null;
			
			//check all named biomolecules exist
			pattern = /\w+/g;
			matches = value.match(pattern);
			for (i = 0; i < matches.length; i++) {
				if (diagram.getBiomoleculeByName(matches[i]) === false) return null;
			}
			
			//check parenthesis, parse out sense
			currDepth = 0;
			for (i = 0; i < value.length; i++) {
				switch (value.charAt(i)){
				case '(': 
					currDepth++;
					if (i > 0 && value.charAt(i - 1) == '!') {
						if (senseDepth.length == currDepth) senseDepth.push(!senseDepth[currDepth - 1]);
						else senseDepth[currDepth] = !senseDepth[currDepth - 1]; 						
					}else {
						if (senseDepth.length == currDepth) senseDepth.push(senseDepth[currDepth - 1]);
						else senseDepth[currDepth] = senseDepth[currDepth - 1];
					}
					break;
				case ')': 
					currDepth--;
					break;
				}
				
				if (currDepth < 0) return null;
				depth.push(currDepth);
				
				if (i>0 && value.charAt(i-1) == '!') {
					sense.push(!senseDepth[currDepth]);
				}else {
					sense.push(senseDepth[currDepth]);
				}
			}
			
			return { sense:sense, matches:matches };
		}
		
		public function updateIncomingEdges():Boolean {
			var result:Object = validateRegulation(myRegulation, diagram);
			if (!result) return false;
			
			//remove old edges
			deleteIncomingEdges();
			
			//add edges
			for (var i:uint = 0; i < result.matches.length; i++) {
				var edge:Edge = diagram.addEdge(result.matches[i], this, result.sense[myRegulation.search(result.matches[i])]);
				if(edge) myEdges.addItem(edge);
			}
			return true;
		}
		
		// called by diagram to create pointers on delete	
		public function getMyEdges():ArrayCollection {
			return myEdges;
		}
		
		public function countMyEdges():uint {
			return myEdges.length;
		}
		
		// deletes from diagram
		private function deleteIncomingEdges():void {
			for (var i:uint = 0; i < myEdges.length; i++) {
				myEdges[i].remove();
			}
		}
		
		private function deleteOutgoingEdges():void {
			var deleteName:String = myName;
			var frontCase:RegExp;
			var parensCase:RegExp;
			var middleCase:RegExp;
			var cleanParens:RegExp;
			var patString:String;
			var regulation:String;
			
			// no parentheses and front case
			patString = "^!?" + deleteName + "(?: ?(?:\\|\\||\\&\\&) ?)?(\\S*)";
			frontCase = new RegExp(patString);
			
			// first term in parentheses
			patString = "(.*\\()!?" + deleteName + " ?(?:\\|\\||\\&\\&) ?(\\S+)";
			parensCase = new RegExp(patString, "g");
			
			// middle case
			patString = "(\\S+) ?(?:\\|\\||\\&\\&) ?!?" + deleteName + "(.*)";
			middleCase = new RegExp(patString, "g");
			
			// clean up empty or one-element parentheses
			patString = "\\((!?[A-Za-z]\\w*)?\\)";
			cleanParens = new RegExp(patString, "g");
			
			for (var i:uint = 0; i < diagram.biomolecules.length; i++) {
				regulation = diagram.biomolecules.getItemAt(i).myRegulation;
				regulation = regulation.replace(frontCase, "$1");
				regulation = regulation.replace(cleanParens, "$1");
				regulation = regulation.replace(parensCase, "$1$2");
				regulation = regulation.replace(cleanParens, "$1");
				regulation = regulation.replace(middleCase, "$1$2");
				regulation = regulation.replace(cleanParens, "$1");
				diagram.biomolecules.getItemAt(i).myRegulation = regulation;
			}
		}
		
		private function get myOutgoingRegulation():ArrayCollection {
			var value:ArrayCollection = new ArrayCollection();
			var pattern:RegExp = new RegExp('(^|[^a-zA-Z0-9_])' + _myName + '([^a-zA-Z0-9_]|$)', 'g');
			for (var i:uint = 0; i < diagram.biomolecules.length; i++) {
				if (diagram.biomolecules[i].myRegulation.match(pattern)){
					value.addItem( { biomolecule:diagram.biomolecules[i], myRegulation:diagram.biomolecules[i].myRegulation } );
				}
			}
			return value;
		}
		
		private function set myOutgoingRegulation(value:ArrayCollection):void {
			for (var i:uint = 0; i < value.length; i++) {
				value[i].biomolecule.myRegulation = value[i].myRegulation;
			}
		}
		
		/************************************************
		 * selection
		 * **********************************************/		
		private var _selected:Boolean = false;
		private var lastClick:uint = 0;
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set selected (value:Boolean):void {
			if (_selected != value) {
				if (value) onRefreshShape();
				selectedHandlesGeometryGroup.visible = value;
				_selected = value;
			}
		}
		
		private function onRefreshShape():void {
			var shapeBounds:Rectangle = getShapeBounds();
			
			selectedHandlesGeometryGroup.refresh(shapeBounds);
			
			if(labelGeometryGroup!=null){
				labelGeometryGroup.x = -labelGeometryGroup.width / 2 + shapeGeometryGroup.labelOffsetX;			
				labelGeometryGroup.y = -labelGeometryGroup.height / 2 + shapeGeometryGroup.labelOffsetY;
			}

			heatmap.y = Math.max(shapeBounds.bottom,shapeGeometryGroup.labelOffsetY) + heatmapOffsetY;
		}
		
		/************************************************
		 * double click
		 * **********************************************/
		private var editBiomoleculeWindow:EditBiomoleculeWindow;
		 
		public function openEditWindow(event:MouseEvent):void {
			editBiomoleculeWindow = new EditBiomoleculeWindow(diagram, this);
			editBiomoleculeWindow.open();
		}
		
		/************************************************
		 * moving...rest of mouse handling is done in diagram
		 * **********************************************/
		private function dispatchEvents():void {
			dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_MOVE));
			dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_UPDATE));
		}
		 
		public function translate(deltaX:Number, deltaY:Number, tweenTime:Number = 0, updateCompartment:Boolean = true, snap:Boolean = true):void {
			translateTo(x + deltaX, y + deltaY, tweenTime, updateCompartment, snap);
		}
		
		public function translateTo(x:Number, y:Number, tweenTime:Number = 0, updateCompartment:Boolean = true, snap:Boolean = true):void {
			var shapeBounds:Rectangle = getShapeBounds();
			x = Math.min(Math.max(x, -shapeBounds.left), diagram.diagramWidth - shapeBounds.right);
			y = Math.min(Math.max(y, -shapeBounds.top), diagram.diagramHeight - shapeBounds.bottom);
			
			var pt:Object;
			if (this.x != x || this.y != y) {
				if(updateCompartment) myCompartment = diagram.getCompartmentOfBiomolecule(x, y);
				if(snap) pt = snapToCompartment(x, y);
				else pt = { x:x, y:y, rotation:rotation };
				
				if (tweenTime>0) {
					Tweener.addTween(this, { x:pt.x, y:pt.y, rotation:pt.rotation, time:tweenTime,onComplete:dispatchEvents } );
				}else{
					this.x = pt.x;
					this.y = pt.y;
					this.rotation = pt.rotation;
					dispatchEvents();
				}		
			}
		}
		
		public function snapToCompartment(x:Number, y:Number):Object {			
			return myCompartment['snapBiomolecule'](x, y);
		}
		
		public function updateCompartment(tweenTime:Number=0.5):void {
			_myCompartment = diagram.getCompartmentOfBiomolecule(x, y);
			var pt:Object = snapToCompartment(x, y);
			if (tweenTime>0) {
				Tweener.addTween(this, { x:pt.x, y:pt.y, rotation:pt.rotation, time:tweenTime,onComplete:dispatchEvents } );
			}else{
				x = pt.x;
				y = pt.y;
				this.rotation = pt.rotation;
				dispatchEvents();
			}
		}
		
		// global flag toggles coordinate system
		public function getShapeBounds(global:Boolean = false):Rectangle {
			if (global) {
				var shapeBounds:Rectangle = shapeGeometryGroup.getBounds(this);
				
				// Shift shape bounds by the x-y coordinate of the biomolecule to get absolute coordinates
				shapeBounds.x += this.x;
				shapeBounds.y += this.y;
				
				return shapeBounds;
			}
			else return shapeGeometryGroup.getBounds(this);
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
					break;
				case 'update':					
					inverseAction = 'update';
					inverseData = update(data.myName, data.myLabel, data.myRegulation, data.myCompartment, data.myStyle, data.myComments, false);
					break;
				case 'construct':
					inverseAction = 'remove';
					myOutgoingRegulation = data as ArrayCollection;
					updateIncomingEdges();
					diagram.addBiomolecule(this);
					break;				
			}

			return new HistoryAction(this, inverseAction, inverseData);
		}
		
	}
	
}