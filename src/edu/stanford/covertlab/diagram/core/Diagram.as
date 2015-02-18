package edu.stanford.covertlab.diagram.core 
{
	import br.com.stimuli.string.printf;
	import caurina.transitions.Tweener;
	import com.degrafa.core.collections.GeometryCollection;
	import com.degrafa.geometry.Geometry;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.Surface;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.event.BiomoleculeEvent;
	import edu.stanford.covertlab.diagram.event.BiomoleculeStyleEvent;
	import edu.stanford.covertlab.diagram.event.CompartmentEvent;
	import edu.stanford.covertlab.diagram.event.DiagramEvent;
	import edu.stanford.covertlab.diagram.history.HistoryAction;
	import edu.stanford.covertlab.diagram.history.HistoryManager;
	import edu.stanford.covertlab.diagram.history.IHistory;
	import edu.stanford.covertlab.diagram.overview.Overview;
	import edu.stanford.covertlab.diagram.toolbar.SimpleControlBar;
	import edu.stanford.covertlab.diagram.toolbar.AnimationBar;
	import edu.stanford.covertlab.diagram.toolbar.DiagramToolBarDocker;
	import edu.stanford.covertlab.diagram.toolbar.NewBiomoleculeToolBar;
	import edu.stanford.covertlab.diagram.window.EditBiomoleculeStyleWindow;
	import edu.stanford.covertlab.diagram.window.EditCompartmentWindow;
	import edu.stanford.covertlab.diagram.window.FindBiomoleculeWindow;
	import edu.stanford.covertlab.graphics.printer.Printer;
	import edu.stanford.covertlab.graphics.rasterizer.SVGRasterizer;
	import edu.stanford.covertlab.graphics.renderer.AnimatedGIFRenderer;
	import edu.stanford.covertlab.graphics.renderer.GIFRenderer;
	import edu.stanford.covertlab.graphics.renderer.JPEGRenderer;
	import edu.stanford.covertlab.graphics.renderer.MultipagePDFRenderer;
	import edu.stanford.covertlab.graphics.renderer.PNGRenderer;
	import edu.stanford.covertlab.graphics.renderer.SVGRenderer;
	import edu.stanford.covertlab.util.ColorUtils;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.Event;	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;	
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flexlib.containers.DockableToolBar;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.effects.easing.Linear;
	import mx.effects.Tween;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipOutput;
	
	/**
	 * Main biological network diagram class. Network diagram contains biomolecules, compartments/membranes, and edges (regulations) among
	 * biomolecules. Edges are created automatically from a simple mathematical description of a biomolecules regulation. The rendering
	 * style of diagram can be completed customized by the user through biomolecule styles (shape, color, outline attributes) and compartment attributes
	 * (color, membrane color, phospholipid color). Several advanced options are also available to fine tune diagram size, automatic layout, animation, 
	 * and exporting.
	 * 
	 * <p>Provides two modes:
	 * <ul>
	 * <li>Drawing mode -- network can be edited an viewed; biomolecules can be added, edited, and moved; compartments can be added, edited, and resized.
	 * <li>Form/Text mode -- several forms for editing biomolecules, biomolecule styles, compartments, and advanced options</li>
	 * </ul></p>
	 * 
	 * <p>Diagram has many features
	 * <ul>
	 * <li>Automatic layout -- uses GraphViz via a webservice</li>
	 * <li>Animation with experimental data
	 *   <ul>
	 *   <li>Animation toolbar with timeline</li>
	 *   <li>Play, pause, stop controls</li>
	 *   <li>Tweening</li>
	 *   </ul></li>
	 * <li>Can be saved, loaded from a database or xml files</li>
	 * <li>Exporting to several image (png, jpeg, gif, pdf, svg) formats and animation formats (gif, pdf, swf)</li>
	 * <li>Exporting to xml, mxml</li>
	 * <li>Standard UI features accessible via main menu and mouse and key bindings
	 *   <ul>
	 *   <li>Biomolecule(s) selection</li>
	 *   <li>Panning, zooming</li>
	 *   <li>Copy, cut, paste, delete</li>
	 *   <li>Undo, redo</li>
	 *   <li>Printing</li>
	 *   <li>Finding biomolecules</li>
	 *   </ul></li>
	 * <li>Overview window</li>
	 * <li>Full screen mode</li>
	 * <li>Exposes bindable array collections of biomolecules, biomolecule styles, comparments, and edges</li>
	 * <li>Editing, animation, new component toolbars</li>
	 * <li>Compartment "hotspots" on compartment addition</li>
	 * </ul></p>
	 * 
	 * <img src="../../../../../uml/diagram.png"/>
	 * 
	 * @see Biomolecule
	 * @see BiomoleculeStyle
	 * @see Compartment
	 * @see Membrane
	 * @see Edge
	 * @see edu.stanford.covertlab.diagram.event.DiagramEvent
	 * @see edu.stanford.covertlab.diagram.history.historyManager
	 * @see edu.stanford.covertlab.diagram.overview.Overview
	 * @see edu.stanford.covertlab.diagram.toolbar.AnimationToolBar
	 * @see edu.stanford.covertlab.diagram.toolbar.ControlToolBar
	 * @see edu.stanford.covertlab.diagram.toolbar.NewBiomoleculeToolBar
	 * @see edu.stanford.covertlab.diagram.toolbar.NewComponentToolBar
	 * @see edu.stanford.covertlab.diagram.panel.AdvancedOptionsPanel
	 * @see edu.stanford.covertlab.diagram.panel.BiomoleculesPanel
	 * @see edu.stanford.covertlab.diagram.panel.StylesPanel
	 * @see edu.stanford.covertlab.diagram.panel.CompartmentsPanel
	 * @see edu.stanford.covertlab.diagram.window.EditBiomoleculeStyleWindow
	 * @see edu.stanford.covertlab.diagram.window.EditBiomoleculeWindow
	 * @see edu.stanford.covertlab.diagram.window.EditCompartmentWindow
	 * @see edu.stanford.covertlab.diagram.window.FindBiomoleculeWindow
	 * @see edu.stanford.covertlab.networkpainter.manager.ExperimentManager
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @author Ed Chen, chened@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/15/2009
	 */
	public class Diagram extends Canvas implements IHistory
	{
		
		[Bindable] public var historyManager:HistoryManager;		
		public var toolBarDocker:DiagramToolBarDocker;
		
		public function Diagram() 
		{			
			// scrollwheel zoom
			//addEventListener(MouseEvent.MOUSE_WHEEL, scrollZoom);
			
			//style
			doubleClickEnabled = true;
			setStyle('backgroundColor', 0xCCCCCC);
			setStyle('borderStyle', 'solid');
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'off';
			percentWidth = 100;
			percentHeight = 100;
			
			//history manager
			historyManager = new HistoryManager(this);
			
			//diagram background, pan/zoom
			setupBackground();
			
			//overview
			overview = new Overview(this);
			overview.x = 5;
			overview.y = 30;
			overview.visible = overviewVisible = true;
			addChild(overview);
			
			//heatmaps legend
			setupHeatmapLegend();
			
			//translate biomolecules
			updateCompartmentsOfSelectedBiomoleculesTimer = new Timer(500, 1);
			updateCompartmentsOfSelectedBiomoleculesTimer.addEventListener(TimerEvent.TIMER_COMPLETE, updateCompartmentsOfSelectedBiomolecules);
			
			//setup compartment, membrane, biomolecule, edge geometry groups
			setupNetworkGeometryGroups();
			
			//border
			setupBackgroundBorder();
			
			//dockable toolbars
			toolBarDocker = new DiagramToolBarDocker(this);
			addChild(toolBarDocker);
			
			//full screen tool bars
			fullScreenControlToolBar = new SimpleControlBar(this);
			addChild(fullScreenControlToolBar);

			fullScreenAnimationToolBar = new AnimationBar(this);
			addChild(fullScreenAnimationToolBar);			
					
			//setup undo, redo stacks
			clearDiagram();
				
			//setup bind biomolecule
			//setup child windows
			findBiomoleculeWindow = new FindBiomoleculeWindow(this);
			
			//setup layout service
			autoLayoutDiagramService.url = 'services/autoLayoutDiagram.php';
			autoLayoutDiagramService.method = 'POST';
			autoLayoutDiagramService.resultFormat = 'text';
			autoLayoutDiagramService.addEventListener(ResultEvent.RESULT, autoLayoutDiagramServiceResultHandler);
			autoLayoutDiagramService.addEventListener(FaultEvent.FAULT, autoLayoutDiagramServiceFaultHandler);
			
			//setup auto layout animations
			autoLayoutDiagramEdgeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, autoLayoutDiagramUpdateEdges);
			autoLayoutDiagramBackgroundTimer.addEventListener(TimerEvent.TIMER_COMPLETE, autoLayoutDiagramUpdateBackground);
			
			//setup animation timer
			loopAnimation = true;
			dimAnimation = true;
			exportLoopAnimation = true;
			exportDimAnimation = true;
			fullScreenAnimationToolBar.repeatButton.selected = loopAnimation;
			toolBarDocker.animationbar.animationBar.repeatButton.selected = loopAnimation;
			
			animationFrameRate = 20;
			exportAnimationFrameRate = 20;
		}
		
		/************************************************
		* initialization
		* **********************************************/
		public function completeInitialization():void {
			zoomFit();
			
			this.addEventListener(Event.ACTIVATE, activate);
			this.addEventListener(Event.DEACTIVATE, deactivate);
			parentApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);			
		}
		
		public function clearDiagram():void {
			//clear compartment, membrane, biomolecule, edge geometry groups
			clearNetworkGeometryGroups();
			
			//reset style toolbar
			toolBarDocker.stylebar.clearBiomoleculeStyles();
			
			//clear measurement
			clearMeasurement();
			
			//reset undo and redo stacks
			clearPasteArray();
			historyManager.clear();
			
			//remove selections
			deselectBiomolecules();
			
			//zoomfit
			zoomFit();
		}
		
		/************************************************
		* keyboard binding
		* **********************************************/
		private var isFocused:Boolean = false;		
		
		private function activate(event:Event):void {
			isFocused = true;
		}
		
		private function deactivate(event:Event):void {
			isFocused = false;
		}
		
		private function keyDown(event:KeyboardEvent):void {		
			if(isFocused) {				
				if (!editingEnabled) return;
				
				//alt key pressed
				if (event.altKey) return;
				
				//shift and control keys pressed
				if (event.shiftKey && event.ctrlKey) return;
				
				//control key pressed
				if (event.ctrlKey) return;
				
				//control, shift, alt keys not pressed			
				switch(event.keyCode) {
					case Keyboard.ESCAPE: deselectBiomolecules(); break;
					case Keyboard.DELETE: trash(); break;
					case Keyboard.LEFT: translateSelectedBiomolecules(-1,0); break;
					case Keyboard.RIGHT: translateSelectedBiomolecules(1,0); break;
					case Keyboard.UP: translateSelectedBiomolecules(0,-1); break;
					case Keyboard.DOWN: translateSelectedBiomolecules(0, 1); break;
				}
			}
		}
		
		/************************************************
		* modes
		* **********************************************/		
		private var _fullScreen:Boolean = false;
		private var _fullScreenMode:Boolean = false;
		private var beforeFullScreenState:Object;
		public var fullScreenControlToolBar:SimpleControlBar;
		public var fullScreenAnimationToolBar:AnimationBar;
		private var _editingEnabled:Boolean=true;
		
		[Bindable] 
		public function get editingEnabled():Boolean {
			return _editingEnabled;			
		}
		public function set editingEnabled(value:Boolean):void {
			if (_editingEnabled != value) {
				compartmentResizeEnable = compartmentResizeEnable && value;
				fullScreenControlToolBar.visible = fullScreenAnimationToolBar.visible = !value || fullScreenMode;
				_editingEnabled = value;
			}
		}
		
		
		public function get fullScreenMode():Boolean {
			return _fullScreenMode;
		}
		public function set fullScreenMode(value:Boolean):void {
			if (_fullScreenMode != value) {
				_fullScreenMode = value;
				toolBarDocker.visible = !fullScreenMode && editingEnabled;
				fullScreenControlToolBar.visible = fullScreenAnimationToolBar.visible = fullScreenMode || !editingEnabled;				
				overview.visible = overviewVisible && !fullScreenMode;
				
				if (fullScreenMode) {					
					setStyle('backgroundColor', 0x000000);
					setStyle('borderStyle', 'none');
					setStyle('paddingBottom', 0);
					setStyle('paddingTop', 0);
					setStyle('paddingLeft', 0);
					setStyle('paddingRight', 0);
					
					fullScreenControlToolBar.alpha = fullScreenAnimationToolBar.alpha = 0;
				}else {
					setStyle('backgroundColor', 0xCCCCCC);
					setStyle('borderStyle', 'solid');
					setStyle('paddingBottom', 10);
					setStyle('paddingTop', 10);
					setStyle('paddingLeft', 10);
					setStyle('paddingRight', 10);
					
					fullScreenControlToolBar.alpha = fullScreenAnimationToolBar.alpha = 1;
				}
			}
		}
		
		public function get fullScreen():Boolean {
			return _fullScreen;
		}
		public function set fullScreen(value:Boolean):void {
			if (_fullScreen != value) {
				_fullScreen = value;
				fullScreenMode = value;
				if (fullScreen) {									
					beforeFullScreenState = { x:backgroundCanvas.x, y:backgroundCanvas.y,
						scale:backgroundCanvas.scaleX,
						width:diagramWidth, height:diagramHeight };
					zoomFit(stage.fullScreenWidth, stage.fullScreenHeight, 0);
				}else {
					backgroundCanvas.x = beforeFullScreenState.x;
					backgroundCanvas.y = beforeFullScreenState.y;
					backgroundCanvas.scaleX = beforeFullScreenState.scale;
					backgroundCanvas.scaleY = beforeFullScreenState.scale;
					diagramWidth = beforeFullScreenState.width;
					diagramHeight = beforeFullScreenState.height;
				}
			}
		}
		
		/************************************************
		* data sources
		* **********************************************/
		public var loadingNetwork:Boolean = false;
		
		public function loadNetwork(network:Object):void {			
			var i:uint;
			
			//set diagram state
			loadingNetwork = true;
			
			//remove pre-existing biomolecules and edges
			clearDiagram();	
			
			//turn off sorting
			biomoleculestyles.sort = null;

			//diagram properties
			diagramWidth = network.width;
			diagramHeight = network.height;
			showPores = network.showPores;
			poreFillColor = network.poreFillColor;
			poreStrokeColor = network.poreStrokeColor;

			membraneHeight = network.membraneHeight;
			membraneCurvature = network.membraneCurvature;
			minCompartmentHeight = network.minCompartmentHeight;			

			nodesep = network.nodesep;
			ranksep = network.ranksep;
			
			animationFrameRate = network.animationFrameRate;
			loopAnimation = network.loopAnimation;
			dimAnimation = network.dimAnimation;
			fullScreenAnimationToolBar.repeatButton.selected = loopAnimation;
			toolBarDocker.animationbar.animationBar.repeatButton.selected = loopAnimation;
						
			exportShowBiomoleculeSelectedHandles = network.exportShowBiomoleculeSelectedHandles;
			exportColorBiomoleculesByValue = network.exportColorBiomoleculesByValue;
			exportLoopAnimation = network.exportLoopAnimation;
			exportAnimationFrameRate = network.exportAnimationFrameRate;			
			exportDimAnimation = network.exportDimAnimation;
			
			//create compartments
			var upperCompartment:Compartment;
			if(network.compartments){ // may be null if import does it
				for (i = 0; i < network.compartments.length; i++) {
					new Compartment(this, network.compartments[i].name,
						network.compartments[i].color, network.compartments[i].membranecolor,
						network.compartments[i].phospholipidbodycolor, network.compartments[i].phospholipidoutlinecolor,
						diagramWidth, 0, upperCompartment);
					upperCompartment = compartments[compartments.length - 1];
					compartments[i].myHeight = network.compartments[i].height;
					if (i > 0) compartments[i - 1].myHeight = network.compartments[i - 1].height;
					if (i > 0) compartments[i].y = compartments[i - 1].y + compartments[i - 1].myHeight + membraneHeight;
				}
			}

			//create biomolecule styles
			if(network.biomoleculestyles){ // may be null if import does it
				for (i = 0; i < network.biomoleculestyles.length; i++) {
					new BiomoleculeStyle(this,
						network.biomoleculestyles[i].name, 
						network.biomoleculestyles[i].shape, 
						network.biomoleculestyles[i].color,
						network.biomoleculestyles[i].outline);
				}
			}
			
			//create biomolecules
			if(network.biomolecules){ // may be null if import does it
				for (i = 0; i < network.biomolecules.length; i++) {
					new Biomolecule(this,
						compartmentsAndMembranes[network.biomolecules[i].compartmentid],
						biomoleculestyles[network.biomolecules[i].biomoleculestyleid],
						network.biomolecules[i].x,
						network.biomolecules[i].y,
						network.biomolecules[i].name,
						network.biomolecules[i].label,
						'',
						network.biomolecules[i].comments);
				}
			}
			//set regulation
			for (i = 0; i < biomolecules.length; i++) {
				this.biomolecules[i].myRegulation = network.biomolecules[i].regulation;
			}
			
			//update edges
			/*if(network.edges) { // may be null if import does it
				for (i = 0; i < network.edges.length; i++) {
					if (network.edges[i].path == null || network.edges[i].path == '') continue;
					edges[i].pathData = network.edges[i].path;
				}
			}
			*/
			
			//sort
			sortBiomoleculeStyles();
			sortBiomolecules();			
			
			//zoom fit
			zoomFit(); //BUG: sometimes this is called too early and the diagram isn't fit to screen
						
			dispatchEvent(new DiagramEvent(DiagramEvent.LOAD_COMPLETE));
			
			//clear history
			clearPasteArray();
			historyManager.clear();
					
			//set network state
			loadingNetwork = false;
		}			
			
		public function generateNetwork():Object {
			var biomoleculestyles:ArrayCollection = new ArrayCollection();
			var compartments:ArrayCollection = new ArrayCollection();
			var biomolecules:ArrayCollection = new ArrayCollection();
			var edges:ArrayCollection = new ArrayCollection();
			var i:uint;
			
			for (i = 0; i < this.biomoleculestyles.length; i++) {
				biomoleculestyles.addItem( { 
					name:this.biomoleculestyles[i].myName,
					shape:this.biomoleculestyles[i].myShape,
					color:this.biomoleculestyles[i].myColor,
					outline:this.biomoleculestyles[i].myOutline } );
			}
			
			for (i = 0; i < this.compartments.length; i++) {
				compartments.addItem( { 
					name:this.compartments[i].myName,
					color:this.compartments[i].myColor,
					membranecolor:this.compartments[i].myMembraneColor,
					phospholipidbodycolor:this.compartments[i].myPhospholipidBodyColor,
					phospholipidoutlinecolor:this.compartments[i].myPhospholipidOutlineColor,
					height:this.compartments[i].myHeight } );
			}
			
			for (i = 0; i < this.biomolecules.length; i++) {
				biomolecules.addItem( { 
					name:this.biomolecules[i].myName,
					label:this.biomolecules[i].myLabel,
					regulation:this.biomolecules[i].myRegulation,
					comments:this.biomolecules[i].myComments,
					x:this.biomolecules[i].x,
					y:this.biomolecules[i].y,
					biomoleculestyleid:this.biomoleculestyles.getItemIndex(this.biomolecules[i].myStyle),
					compartmentid:this.compartmentsAndMembranes.getItemIndex(this.biomolecules[i].myCompartment) } );
			}
			
			for (i = 0; i < this.edges.length; i++) {
				var fromIdx:int = this.biomolecules.getItemIndex(this.edges[i].from);
				var toIdx:int = this.biomolecules.getItemIndex(this.edges[i].to);
				
				if (fromIdx == -1 || toIdx == -1)
					continue;
				
				edges.addItem( { 
					frombiomoleculeid:fromIdx,
					tobiomoleculeid:toIdx,
					sense:this.edges[i].sense,
					path:this.edges[i].pathData} );
			}
			
			return {
				width:diagramWidth,
				height:diagramHeight,
				showPores:showPores,
				poreFillColor:poreFillColor,
				poreStrokeColor:poreStrokeColor,
				membraneHeight:membraneHeight,
				membraneCurvature:membraneCurvature,
				minCompartmentHeight:minCompartmentHeight,
				nodesep:nodesep,
				ranksep:ranksep,
				animationFrameRate:animationFrameRate,
				loopAnimation:loopAnimation,
				dimAnimation:dimAnimation,
				exportShowBiomoleculeSelectedHandles:exportShowBiomoleculeSelectedHandles,
				exportColorBiomoleculesByValue:exportColorBiomoleculesByValue,
				exportAnimationFrameRate:exportAnimationFrameRate,
				exportLoopAnimation:exportLoopAnimation,
				exportDimAnimation:exportDimAnimation,
				biomoleculestyles:biomoleculestyles, 
				compartments:compartments, 
				biomolecules:biomolecules, 
				edges:edges};
		}
		
		/************************************************
		* background, pan/zoom
		* **********************************************/
		private var _diagramWidth:uint=800;
		private var _diagramHeight:uint = 600;		
		public var backgroundCanvas:Canvas;
		public var backgroundSurface:Surface;
		private var backgroundGeometryGroup:GeometryGroup;
		private var backgroundRectangle:RegularRectangle;
		private var backgroundMask:Shape;
		private var backgroundBorderSurface:Surface;
		private var backgroundBorderGeometryGroup:GeometryGroup;
		private var backgroundBorderRectangle:RegularRectangle;
		private var offsetX:Number;
		private var offsetY:Number;
		private var mouseDownTimer:uint;		
		private var overview:Overview;
		private var _zoomLevel:Number;
		public var panZoomEnabled:Boolean = true;
		[Bindable] public var zoomInEnabled:Boolean;
		[Bindable] public var zoomOutEnabled:Boolean;
		[Bindable] public var overviewVisible:Boolean;
		
		private function setupBackground():void {									
			//canvas
			backgroundCanvas = new Canvas();
			backgroundCanvas.addEventListener(MouseEvent.MOUSE_DOWN, startMultiSelect);
			backgroundCanvas.addEventListener(MouseEvent.MOUSE_UP, endMultiSelect);
			backgroundCanvas.addEventListener(MouseEvent.MOUSE_DOWN, startPan);
			backgroundCanvas.addEventListener(MouseEvent.MOUSE_UP, endPan);
			backgroundCanvas.addEventListener(MouseEvent.CLICK, clearSelectedBiomolecules);
			addChild(backgroundCanvas);
			
			//surface
			backgroundSurface = new Surface();			
			backgroundCanvas.addChild(backgroundSurface);
			
			//mask
			backgroundMask = new Shape();
			backgroundMask.graphics.beginFill(0xFFFFFF);
			backgroundMask.graphics.drawRect( -1, -1, diagramWidth + 2, diagramHeight + 2);
			backgroundMask.graphics.endFill();
			backgroundSurface.addChild(backgroundMask);
			backgroundCanvas.mask = backgroundMask;
			
			//white background
			backgroundGeometryGroup = new GeometryGroup();			
			backgroundGeometryGroup.target = backgroundSurface;
			backgroundSurface.addChild(backgroundGeometryGroup);
			
			backgroundRectangle=new RegularRectangle(0, 0, diagramWidth, diagramHeight);
			backgroundRectangle.fill = new SolidFill(0xFFFFFF, 1);
			backgroundGeometryGroup.geometryCollection.addItem(backgroundRectangle);
			
			//drag 'n drop new style
			backgroundCanvas.addEventListener(DragEvent.DRAG_ENTER, dragNewBiomoleculeStyleEnterHandler);
			backgroundCanvas.addEventListener(DragEvent.DRAG_DROP, dragNewBiomoleculeStyleDropHandler);
		}
		
		private function setupBackgroundBorder():void {
			//white border
			backgroundBorderSurface = new Surface();
			backgroundCanvas.addChild(backgroundBorderSurface);
			
			backgroundBorderGeometryGroup = new GeometryGroup();			
			backgroundBorderGeometryGroup.target = backgroundSurface;
			backgroundBorderSurface.addChild(backgroundBorderGeometryGroup);
			
			backgroundBorderRectangle = new RegularRectangle(0, 0, diagramWidth, diagramHeight);
			backgroundBorderRectangle.stroke = new SolidStroke(0x999999, 1);
			backgroundBorderGeometryGroup.geometryCollection.addItem(backgroundBorderRectangle);
		}
		
		[Bindable]
		public function get diagramWidth():uint {
			return _diagramWidth;
		}
		public function set diagramWidth(value:uint):void {
			if (value != _diagramWidth) {
				backgroundRectangle.width = backgroundBorderRectangle.width = value;
				backgroundMask.width = value + 2;
				resizeCompartments(diagramWidth,value,diagramHeight,diagramHeight);
				_diagramWidth = value;
			}
		}
		
		[Bindable]
		public function get diagramHeight():uint {
			return _diagramHeight;
		}
		public function set diagramHeight(value:uint):void {
			if (value != _diagramHeight) {
				backgroundRectangle.height = backgroundBorderRectangle.height = value;
				backgroundMask.height = value + 2;
				resizeCompartments(diagramWidth, diagramWidth, diagramHeight, value);
				_diagramHeight = value;				
			}
		}
		
		private var start:Point;
		private function startMultiSelect(event:MouseEvent):void {
			if (event.target != backgroundGeometryGroup && !compartmentsCanvas.contains(event.target as GeometryGroup)) return;
			if (!event.shiftKey) {
				return; // dont do anything if shift key is NOT selected
			}

			deselectBiomolecules();
			start = backgroundGeometryGroup.globalToLocal(new Point(event.stageX, event.stageY));
			addEventListener(MouseEvent.MOUSE_MOVE, drawSelectRect);
		}
		
		private var selectRectangle:GeometryGroup = null;
		private function drawSelectRect(event:MouseEvent):void {
			
			var stop:Point = backgroundSurface.globalToLocal(new Point(event.stageX, event.stageY));
			if (selectRectangle != null) {
				backgroundSurface.removeChild(selectRectangle);
			}
			selectRectangle = new GeometryGroup();
			var tmpRect:RegularRectangle = new RegularRectangle(start.x, start.y, stop.x - start.x, stop.y - start.y);
			tmpRect.stroke = new SolidStroke(0x000000, 1, 1.5);
			tmpRect.fill = new SolidFill(0x000000, 0.1);
			selectRectangle.geometryCollection.addItem(tmpRect);
			selectRectangle.target = backgroundSurface;
			backgroundSurface.addChild(selectRectangle);
		}
		
		private function endMultiSelect(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, drawSelectRect);
			if (selectRectangle == null) 
				return;
			
			backgroundSurface.removeChild(selectRectangle);
			for (var i:uint = 0; i < biomolecules.length; i++) {
				if (selectRectangle.hitTestPoint(biomolecules[i].x, biomolecules[i].y)){
					selectBiomolecule(biomolecules[i], true);
				}
			}
			selectRectangle = null;
		}
		
		private function startPan(event:MouseEvent):void {
			if (!panZoomEnabled) return;
			if (event.target != backgroundGeometryGroup && !compartmentsCanvas.contains(event.target as GeometryGroup)) return;
			if (event.shiftKey) {
				return; // dont do anything if shift key IS selected
			}
			var pt:Point = parent.globalToLocal(new Point(event.stageX, event.stageY));
			offsetX = pt.x - backgroundCanvas.x;
			offsetY = pt.y - backgroundCanvas.y;
			addEventListener(MouseEvent.MOUSE_MOVE, doPan);
			mouseDownTimer = getTimer();
		}
		
		private function doPan(event:MouseEvent):void {
			if (!panZoomEnabled) return;
			var pt:Point = parent.globalToLocal(new Point(event.stageX, event.stageY));
			Tweener.addTween(backgroundCanvas, { x:Math.round(pt.x - offsetX), y:Math.round(pt.y - offsetY), time:0.5 } );
		}
		
		private function endPan(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, doPan);
		}
		
		private function scrollZoom(event:MouseEvent):void {
			if (!panZoomEnabled) return;
			
			if (event.delta > 0) {
				zoomIn();
			} else {
				zoomOut();
			}
		}
		
		//BUG: display quality low on zooming 
		//     perhaps need to change Biomolecule.SIZE and redraw biomolecules, or
		//	   maybe we should set the "default" zoom to some value less than 1
		public function zoomIn():void {
			setZoomLevel(zoomLevel + 1);
		}

		public function zoomOut():void {
			setZoomLevel(zoomLevel - 1);
		}

		public function zoomFit(width:int = -1, height:int = -1, tweenTime:Number = 1):void {
			var zoomX:Number;
			var zoomY:Number;
			var zoomScale:Number;
			
			if (width == -1) width = this.width;
			if (height == -1) height = this.height;

			if (diagramWidth / diagramHeight > width / height) {
				zoomX = 0;
				zoomScale = width / diagramWidth;
				zoomY = Math.round((height - diagramHeight * zoomScale) / 2);
			}else {
				zoomY = 0;
				zoomScale = height / diagramHeight;
				zoomX = Math.round((width - diagramWidth * zoomScale) / 2);
			}
			
			zoomLevel = Math.log(zoomScale) / Math.log(1.25);
			
			if (tweenTime > 0) {
				Tweener.addTween(backgroundCanvas, { 
					x:zoomX,
					y:zoomY,
					scaleX:zoomScale, 
					scaleY:zoomScale, 
					time:1 } );
			}else {
				Tweener.removeTweens(backgroundCanvas);
				backgroundCanvas.x = zoomX;
				backgroundCanvas.y = zoomY;
				backgroundCanvas.scaleX = backgroundCanvas.scaleY = zoomScale;
			}
		}
		
		public function zoomReset():void {
			setZoomLevel(0);
		}
		
		public function setZoomLevel(value:Number):void {
			if (value == zoomLevel) return;
			
			var scaleFactor:Number;
			value = Math.max( -4, Math.min(4, value));
			if (value > zoomLevel) {
				scaleFactor = Math.pow(1.25, value) / backgroundCanvas.scaleX;
				Tweener.addTween(backgroundCanvas, {
					x:Math.round(backgroundCanvas.x - (scaleFactor-1) * backgroundCanvas.scaleX * diagramWidth / 2),
					y:Math.round(backgroundCanvas.y - (scaleFactor-1) * backgroundCanvas.scaleX * diagramHeight / 2),
					scaleX:backgroundCanvas.scaleX * scaleFactor, 
					scaleY:backgroundCanvas.scaleX * scaleFactor, 
					time:1 } );
			}else if (value < zoomLevel) {
				scaleFactor = backgroundCanvas.scaleX / Math.pow(1.25, value);
				Tweener.addTween(backgroundCanvas, { 
					x:Math.round(backgroundCanvas.x + (1-1/scaleFactor) * backgroundCanvas.scaleX * diagramWidth / 2),
					y:Math.round(backgroundCanvas.y + (1-1/scaleFactor) * backgroundCanvas.scaleX * diagramHeight / 2),
					scaleX:backgroundCanvas.scaleX / scaleFactor, 
					scaleY:backgroundCanvas.scaleX / scaleFactor, 
					time:1 } );
			}
			zoomLevel = value;
		}
		
		[Bindable]
		public function get zoomLevel():Number {
			return _zoomLevel;
		}
		public function set zoomLevel(value:Number):void {
			if (value != _zoomLevel) {
				_zoomLevel = value;
				zoomInEnabled = zoomLevel < 4;
				zoomOutEnabled = zoomLevel > -4;
			}
		}
		
		// Click variables
		private var lastClick:uint = 0;
		private const doubleClickDuration:uint = 500;
		
		public function toggleOverview():void {
			overviewVisible = !overviewVisible;
			overview.visible = overviewVisible;
		}
		
		public function disableOverview():void {
			overviewVisible = false;
			overview.close();
		}
		
		/************************************************
		* compartments, membranes, biomolecules, edges geometry groups
		* **********************************************/		
		private var edgesSurface:Surface;
		private var biomoleculesSurface:Surface;
		
		private function setupNetworkGeometryGroups():void {
			var sort:Sort;
			
			// new styles
			biomoleculestyles = new ArrayCollection();

			// add compartments	
			compartmentsCanvas = new Canvas();
			compartments = new ArrayCollection();
			backgroundCanvas.addChild(compartmentsCanvas);
			
			// add membranes (they are basically automatic compartments)
			membranesCanvas = new Canvas();
			backgroundCanvas.addChild(membranesCanvas);
			
			//compartments and membranes array collection (used for biomolecule's compartment combobox)
			compartmentsAndMembranes = new ArrayCollection();

			//add edges and biomolecules
			edgesSurface = new Surface();
			backgroundCanvas.addChild(edgesSurface);
			
			edgesGeometryGroup = new GeometryGroup();
			edges = new ArrayCollection();
			edgesSurface.addChild(edgesGeometryGroup);
			
			biomoleculesSurface = new Surface();
			backgroundCanvas.addChild(biomoleculesSurface);
			
			biomolecules = new ArrayCollection();
		}
		
		private function clearNetworkGeometryGroups():void {
			biomoleculestyles.removeAll();
			compartments.removeAll();
			compartmentsAndMembranes.removeAll();
			biomolecules.removeAll();
			edges.removeAll();
			
			while (compartmentsCanvas.numChildren > 0) compartmentsCanvas.removeChildAt(0);
			while (membranesCanvas.numChildren > 0) membranesCanvas.removeChildAt(0);
			while (biomoleculesSurface.numChildren > 0) biomoleculesSurface.removeChildAt(0);
			while (edgesGeometryGroup.numChildren > 0) edgesGeometryGroup.removeChildAt(0);
		}
		
		/************************************************
		* Compartments
		* **********************************************/
		[Bindable] public var compartments:ArrayCollection;
		[Bindable] public var compartmentsAndMembranes:ArrayCollection;
		private var compartmentsCanvas:Canvas;
		private var membranesCanvas:Canvas;
		[Bindable] public var compartmentResizeEnable:Boolean = true;
		public var minCompartmentHeight:Number;
		public var membraneHeight:Number;
		public var membraneCurvature:Number;

		public function addCompartment(compartment:Compartment):void {
			var upperCompartmentDeltaH:Number = 0;
			var lowerCompartmentDeltaH:Number = 0;
			var lowerCompartmentDeltaY:Number = 0;
			
			//adjust upper and lower compartments
			if (compartment.myUpperCompartment)	compartment.myUpperCompartment.myLowerCompartment = compartment;
			if (compartment.myLowerCompartment)	compartment.myLowerCompartment.myUpperCompartment = compartment;
			
			//add to array collections, canvases
			var idx:uint = (compartment.myUpperCompartment ? compartments.getItemIndex(compartment.myUpperCompartment) + 1: 0);
			compartments.addItemAt(compartment, idx);
			compartmentsCanvas.addChildAt(compartment, idx);
			membranesCanvas.addChildAt(compartment.myMembrane, idx);
			if (compartment.myUpperCompartment && !compartment.myLowerCompartment) {
				compartmentsAndMembranes.addItemAt((compartment.myUpperCompartment as Compartment).myMembrane, 2 * idx - 1);
			}
			compartmentsAndMembranes.addItemAt(compartment, 2*idx);
			if (compartment.myLowerCompartment) {
				compartmentsAndMembranes.addItemAt(compartment.myMembrane, 2 * idx + 1);
			}
			
			//vertical layout
			switch(compartment.myPosition) {
				case CompartmentBase.POSITION_TOP:
					compartment.myHeight = (compartment.myLowerCompartment.myHeight - membraneHeight) / 2;
					lowerCompartmentDeltaH = -(compartment.myHeight + compartment.myMembrane.myHeight);
					lowerCompartmentDeltaY = -lowerCompartmentDeltaH;
					compartment.myLowerCompartment.myHeight += lowerCompartmentDeltaH;
					compartment.myLowerCompartment.y += lowerCompartmentDeltaY;
					break;
				case CompartmentBase.POSITION_BOTTOM:
					compartment.myHeight = (compartment.myUpperCompartment.myHeight - membraneHeight) / 2;
					upperCompartmentDeltaH = -compartment.myHeight;
					compartment.myUpperCompartment.myHeight += upperCompartmentDeltaH; 
					break;
				case CompartmentBase.POSITION_MIDDLE:
					compartment.myHeight = (compartment.myUpperCompartment.myHeight - membraneHeight) / 2;
					upperCompartmentDeltaH = -(compartment.myHeight + compartment.myMembrane.myHeight);
					compartment.myUpperCompartment.myHeight += upperCompartmentDeltaH;
					break;
				case CompartmentBase.POSITION_ONLY:
					compartment.myHeight = diagramHeight;
					break;
			}
			
			//biomolecule positions
			if (compartment.myUpperCompartment) {
				compartment.y = compartment.myUpperCompartment.y + compartment.myUpperCompartment.myHeight + (compartment.myUpperCompartment as Compartment).myMembrane.myHeight;
				(compartment.myUpperCompartment as Compartment).stretchBiomolecules(0, 0, 0, upperCompartmentDeltaH);
				(compartment.myUpperCompartment as Compartment).myMembrane.stretchBiomolecules(0, 0, 0, upperCompartmentDeltaH);				
			}
			if (compartment.myLowerCompartment) {
				(compartment.myLowerCompartment as Compartment).stretchBiomolecules(0,lowerCompartmentDeltaY, 0, lowerCompartmentDeltaH);
			}
		}
		
		public function updateCompartment(compartment:Compartment): void {
			compartments.itemUpdated(compartment);
			compartmentsAndMembranes.itemUpdated(compartment);
			if(compartmentsAndMembranes.getItemIndex(compartment.myMembrane)>-1) compartmentsAndMembranes.itemUpdated(compartment.myMembrane);
		}
		
		public function removeCompartment(compartment:Compartment):void {
			//remove compartment
			var indx:int = compartments.getItemIndex(compartment);
			if (indx == -1) return;
			compartments.removeItemAt(indx);
			compartmentsCanvas.removeChildAt(indx);
			compartmentsAndMembranes.removeItemAt(2 * indx);
			if(indx < compartments.length){
				membranesCanvas.removeChildAt(indx);
			}

			if (compartment.myLowerCompartment) {
				compartmentsAndMembranes.removeItemAt(2 * indx); // was be 2indx+1 but everything moved down so now 2*indx
			}

			//adjust upper and lower compartments of remaining compartments
			if (compartment.myUpperCompartment) {
				compartment.myUpperCompartment.myLowerCompartment = compartment.myLowerCompartment;
			}
			if (compartment.myLowerCompartment) {
				compartment.myLowerCompartment.myUpperCompartment = compartment.myUpperCompartment;
			}
			
			//adjust vertical layout
			switch(compartment.myPosition) {
				case CompartmentBase.POSITION_BOTTOM:
				case CompartmentBase.POSITION_MIDDLE:
					compartment.myUpperCompartment.myHeight += compartment.myHeight + membraneHeight;
					break;				
				case CompartmentBase.POSITION_TOP:
					compartment.myLowerCompartment.myHeight += compartment.myHeight + compartment.myMembrane.myHeight;
					compartment.myLowerCompartment.y = 0;
					break;
				case CompartmentBase.POSITION_ONLY:
					break;
			}

			//assign biomolecules to other compartments
			var allmols:ArrayCollection;
			var biomolecules:ArrayCollection;
			var i:uint;
			biomolecules = compartment.biomolecules;
			for (i = 0; i < biomolecules.length; i++) {
				biomolecules[i].updateCompartment(0);
			}
			
			biomolecules=compartment.myMembrane.biomolecules;
			for (i = 0; i < biomolecules.length; i++) {
				biomolecules[i].updateCompartment(0);
			}
		}
						
		private function resizeCompartments(oldWidth:uint, newWidth:uint, oldHeight:uint, newHeight:uint):void {
			var oldMembraneHeight:Number = membraneHeight;
			var oldMembraneCurvature:Number = membraneCurvature;						
			minCompartmentHeight = 40;
			membraneHeight = 25.5;
			membraneCurvature = 50 * newWidth / 800.0;			
			var dMembraneH:Number = membraneHeight - oldMembraneHeight;
			var dMembraneC:Number = membraneCurvature - oldMembraneCurvature;
			
			if (compartments.length == 0) return;
			
			var dW:Number = newWidth - oldWidth;						
			var dY:Number;
			var dH:Number;
			var scaleY:Number = (newHeight - (compartments.length - 1) * membraneHeight) / (oldHeight - (compartments.length - 1) * oldMembraneHeight);
			
			var y:Number = 0;
			
			for (var i:uint = 0; i < compartments.length; i++) {				
				dY = y - compartments[i].y;
				dH = (scaleY - 1) * compartments[i].myHeight;
				
				compartments[i].y = y;
				compartments[i].myWidth = newWidth;
				compartments[i].myHeight += dH;
				
				compartments[i].myMembrane.myHeight = membraneHeight;
				compartments[i].myMembrane.myCurvature = membraneCurvature;
				
				compartments[i].stretchBiomolecules(0, dY, dW, dH);
				compartments[i].myMembrane.stretchBiomolecules(0, dY + dH, dW, dMembraneH);
				
				y += compartments[i].myHeight + membraneHeight;
			}
		}
		
		/************************************************
		* biomolecule styles
		* **********************************************/
		[Bindable] public var biomoleculestyles:ArrayCollection;
		
		public function addBiomoleculeStyle(biomoleculeStyle:BiomoleculeStyle):void {
			biomoleculestyles.addItem(biomoleculeStyle);
			toolBarDocker.stylebar.addStyle(biomoleculeStyle);			
			sortBiomoleculeStyles();
		}
		
		public function updateBiomoleculeStyle(biomoleculeStyle:BiomoleculeStyle):void {
			biomoleculestyles.itemUpdated(biomoleculeStyle);
			sortBiomoleculeStyles();			
		}
		
		public function removeBiomoleculeStyle(biomoleculeStyle:BiomoleculeStyle):void {
			var idx:int = biomoleculestyles.getItemIndex(biomoleculeStyle);
			biomoleculestyles.removeItemAt(idx);
			
			//set any biomolecules assigned to this style to an alternative style			
			var biomolecules:ArrayCollection = biomoleculeStyle.biomolecules;
			for (var i:uint = 0; i < biomolecules.length; i++) {
				biomolecules[i].myStyle = biomoleculestyles[0];
			}
		}
		
		public function sortBiomoleculeStyles():void {
			if (loadingNetwork) return;
			
			var sort:Sort = new Sort();
			sort.fields = [new SortField('myName', true)];
			sort.sort(biomoleculestyles.source);
			
			for (var i:uint = 0; i < biomoleculestyles.length; i++) {
				toolBarDocker.stylebar.setChildIndex(
					toolBarDocker.stylebar.getBiomoleculeStyleButton(biomoleculestyles[i]),
					i + 1);
			}
		}
		
		private function dragNewBiomoleculeStyleEnterHandler(event:DragEvent):void {
			if (!event.dragSource.hasFormat('action') || event.dragSource.dataForFormat('action') != 'addBiomoleculeStyle') return;			
			
			DragManager.acceptDragDrop(backgroundCanvas);	
		}
				
		private function dragNewBiomoleculeStyleDropHandler(event:DragEvent):void {
			if (!event.dragSource.hasFormat('action') || event.dragSource.dataForFormat('action') != 'addBiomoleculeStyle') return;			
			
			var editBiomoleculeStyleWindow:EditBiomoleculeStyleWindow = new EditBiomoleculeStyleWindow(this);
			editBiomoleculeStyleWindow.open();
		}
				
		/************************************************
		* biomolecules
		* **********************************************/
		[Bindable] public var biomolecules:ArrayCollection = new ArrayCollection();
		private var selectedBiomolecules:ArrayCollection = new ArrayCollection();
		private var updateCompartmentsOfSelectedBiomoleculesTimer:Timer;
		private var biomoleculeDragStart:Point;
		
		public function addBiomolecule(biomolecule:Biomolecule):void {
			biomolecule.addEventListener(MouseEvent.MOUSE_DOWN, biomoleculeMouseDownHandler);
			biomolecule.addEventListener(MouseEvent.MOUSE_UP, biomoleculeMouseUpHandler);
			biomoleculesSurface.addChild(biomolecule);
			biomolecules.addItem(biomolecule);
			sortBiomolecules();
		}
		
		public function updateBiomolecule(biomolecule:Biomolecule):void {
			biomolecules.itemUpdated(biomolecule);
			sortBiomolecules();
		}
		
		public function removeBiomolecule(biomolecule:Biomolecule):void {
			biomolecule.removeEventListener(MouseEvent.MOUSE_DOWN, biomoleculeMouseDownHandler);
			biomolecule.removeEventListener(MouseEvent.MOUSE_UP, biomoleculeMouseUpHandler);
			biomolecules.removeItemAt(biomolecules.getItemIndex(biomolecule));			
			biomoleculesSurface.removeChild(biomolecule);
		}
		
		public function getCompartmentOfBiomolecule(x:Number,y:Number):CompartmentBase {
			var i:uint;
			var pt:Point = backgroundSurface.localToGlobal(new Point(x, y));
						
			for (i = 0; i < compartments.length-1; i++) {
				if (compartments[i].myMembrane.hitTestPoint(pt.x, pt.y)) return compartments[i].myMembrane;
			}
	
			for (i = 0; i < compartments.length; i++) {
				if (compartments[i].hitTestPoint(pt.x, pt.y)) return compartments[i];
			}
			
			return null;
		}
		
		public function selectBiomolecule(biomolecule:Biomolecule, control:Boolean = false, shift:Boolean = false):void {
			if (updateCompartmentsOfSelectedBiomoleculesTimer.running) {				
				updateCompartmentsOfSelectedBiomoleculesTimer.stop();
				updateCompartmentsOfSelectedBiomoleculesTimer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
			
			//update selected biomolecules
			if (control || shift) {
				biomolecule.selected = !biomolecule.selected;
				if (biomolecule.selected) {
					selectedBiomolecules.addItem(biomolecule);
				}
				else { 
					selectedBiomolecules.removeItemAt(selectedBiomolecules.getItemIndex(biomolecule));
				}
			}
			// only deselect if the selected biomolecule is not selected
			else if(!biomolecule.selected) {
				deselectBiomolecules();
				selectedBiomolecules.addItem(biomolecule);
				biomolecule.selected = true;
			}
			
			//update cut, copy buttons
			cutEnabled = (selectedBiomolecules.length > 0);
			copyEnabled = (selectedBiomolecules.length > 0);
		}
		
		public function selectAllBiomolecules():void {
			deselectBiomolecules();
			for (var i:uint = 0; i < biomolecules.length; i++) {
				if(!biomolecules[i].selected) selectBiomolecule(biomolecules[i], true);
			}
		}
				
		public function clearSelectedBiomolecules(event:MouseEvent):void {			
			//differentiate between clearing selected biomolecules and panning
			if (mouseDownTimer + 250 < getTimer()) return;
			
			//make sure that a biomolecule wasn't also clicked; in which case defer to the biomolecule for event handling
			if (event.target != backgroundGeometryGroup && !compartmentsCanvas.contains(event.target as GeometryGroup) ) return;
			
			//update selected biomolecules
			deselectBiomolecules();
			
			//update cut, copy
			cutEnabled = false;
			copyEnabled = false;
		}
		
		private function deselectBiomolecules():void {
			if (updateCompartmentsOfSelectedBiomoleculesTimer.running) {
				updateCompartmentsOfSelectedBiomoleculesTimer.stop();
				updateCompartmentsOfSelectedBiomoleculesTimer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
			
			while(selectedBiomolecules.length>0) {
				selectedBiomolecules[0].selected = false;
				selectedBiomolecules.removeItemAt(0);
			}
		}
		
		private function updateCompartmentsOfSelectedBiomolecules(event:TimerEvent):void {
			for (var i:uint = 0; i < selectedBiomolecules.length; i++) {
				selectedBiomolecules[i].updateCompartment();
			}
		}
			
		//returns bounding box for all selected biomolecules (relative to background surface)
		private function getSelectedBiomoleculesBounds():Rectangle {
			if (selectedBiomolecules.length == 0) return new Rectangle(0, 0, 0, 0);
			
			var biomoleculeBounds:Rectangle = selectedBiomolecules[0].getShapeBounds();
			var left:Number = selectedBiomolecules[0].x + biomoleculeBounds.left;
			var right:Number = selectedBiomolecules[0].x + biomoleculeBounds.right;
			var top:Number = selectedBiomolecules[0].y + biomoleculeBounds.top;
			var bottom:Number = selectedBiomolecules[0].y + biomoleculeBounds.bottom;
			
			for (var i:uint=1; i < selectedBiomolecules.length; i++) {
				biomoleculeBounds = selectedBiomolecules[i].getShapeBounds();
				left = Math.min(left, selectedBiomolecules[i].x + biomoleculeBounds.left);
				right = Math.max(right, selectedBiomolecules[i].x + biomoleculeBounds.right);
				top = Math.min(top, selectedBiomolecules[i].y + biomoleculeBounds.top);
				bottom = Math.max(bottom, selectedBiomolecules[i].y + biomoleculeBounds.bottom);
			}
			
			return new Rectangle(left, top, right - left, bottom - top);
		}
		
		private function get selectedBiomoleculePositions():ArrayCollection {
			var value:ArrayCollection = new ArrayCollection();
			for (var i:uint = 0; i < selectedBiomolecules.length; i++) {
				value.addItem( { biomolecule:selectedBiomolecules[i], x:selectedBiomolecules[i].x, y:selectedBiomolecules[i].y } );
			}
			return value;
		}
		
		private function translateSelectedBiomolecules(deltaX:int, deltaY:int):void {
			var selectedBiomoleculeBounds:Rectangle = getSelectedBiomoleculesBounds();
			if (selectedBiomoleculeBounds.left + deltaX < 0) return;
			if (selectedBiomoleculeBounds.top + deltaY < 0) return;
			if (selectedBiomoleculeBounds.right + deltaX > diagramWidth) return;
			if (selectedBiomoleculeBounds.bottom + deltaY > diagramHeight) return;

			if (!updateCompartmentsOfSelectedBiomoleculesTimer.running) 
				historyManager.addHistoryAction(new HistoryAction(this, 'translateBiomolecules', selectedBiomoleculePositions));

			for (var i:uint = 0; i < selectedBiomolecules.length; i++)
				selectedBiomolecules[i].translate(deltaX, deltaY, 0, false, false);
			
			updateCompartmentsOfSelectedBiomoleculesTimer.reset();
			updateCompartmentsOfSelectedBiomoleculesTimer.start();
		}
		
		// MOUSE draggin ete
		private function biomoleculeMouseDownHandler(event:MouseEvent):void {
			if (!editingEnabled) return;
			
			var biomol:Biomolecule = event.currentTarget as Biomolecule;			
			selectBiomolecule(biomol, event.ctrlKey, event.shiftKey);

			historyManager.addHistoryAction(new HistoryAction(this, 'translateBiomolecules', selectedBiomoleculePositions));
			
			biomoleculeDragStart = new Point(biomol.x, biomol.y);
			compartmentResizeEnable = false;
			biomol.addEventListener(MouseEvent.MOUSE_MOVE, biomoleculeMouseMoveHandler);
			
			biomoleculesSurface.removeChild(biomol);
			biomoleculesSurface.addChild(biomol);
			
			biomol.startDrag(false, getBiomoleculeDragBounds(biomol));
		}
		
		//returns drag limits for biomolecule on which startDrag will be called
		private function getBiomoleculeDragBounds(biomolecule:Biomolecule):Rectangle {
			var selectedBiomoleculeBounds:Rectangle = getSelectedBiomoleculesBounds();
			var biomoleculeBounds:Rectangle = biomolecule.getShapeBounds();
			
			var left:Number = Math.max(0, -selectedBiomoleculeBounds.left) + (biomolecule.x - selectedBiomoleculeBounds.left);
			var top:Number = Math.max(0,-selectedBiomoleculeBounds.top) + (biomolecule.y - selectedBiomoleculeBounds.top);
			var width:Number = diagramWidth-selectedBiomoleculeBounds.width;
			var height:Number = diagramHeight-selectedBiomoleculeBounds.height;
			
			return new Rectangle(left, top, width, height); 
		}
		
		private function biomoleculeMouseMoveHandler(event:MouseEvent):void {	
			var biomol:Biomolecule = event.currentTarget as Biomolecule;
			biomol.dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_MOVE));
			biomol.dispatchEvent(new BiomoleculeEvent(BiomoleculeEvent.BIOMOLECULE_UPDATE));
			dragRestOfBiomolecules(biomol.x, biomol.y, biomol);
			event.updateAfterEvent();
		}
		
		// translates all the other selected biomolecules except the one passed in
		private function dragRestOfBiomolecules(toX:Number, toY:Number, biomol:Biomolecule):void {
			for (var i:uint = 0; i < selectedBiomolecules.length; i++) {
				if(selectedBiomolecules[i] != biomol){
					selectedBiomolecules[i].translate(toX - biomoleculeDragStart.x, toY - biomoleculeDragStart.y,0,false,false);
					//trace(selectedBiomolecules[i].myLabel);
				}
			}
			biomoleculeDragStart.x = toX;
			biomoleculeDragStart.y = toY;
		}
		
		private function biomoleculeMouseUpHandler(event:MouseEvent):void {
			var biomol:Biomolecule = event.currentTarget as Biomolecule;
			
			biomol.removeEventListener(MouseEvent.MOUSE_MOVE, biomoleculeMouseMoveHandler);
			biomol.stopDrag();
			compartmentResizeEnable = editingEnabled;

			for (var i:uint = 0; i < selectedBiomolecules.length; i++) {
				selectedBiomolecules[i].updateCompartment(0.25);
			}
		}
		
		public function getBiomoleculeByName(str:String, exactMatch:Boolean = true, startIdx:uint = 0):* {
			var idx:uint;
			for (var i:uint = 0; i < biomolecules.length; i++) {
				//search through biomolecules starting at startIdx (used by findBiomolecule)
				idx = (i + startIdx) % biomolecules.length;
				
				//exact match
				if (biomolecules[idx].myName == str) return biomolecules[idx];
				
				//looser match (used by findBiomolecule)
				if (!exactMatch && 
					(biomolecules[idx].myName.toLowerCase().search(str.toLowerCase()) > -1 || 
					biomolecules[idx].myLabel.toLowerCase().search(str.toLowerCase()) > -1) )
					return biomolecules[idx];
			}
			return false;
		}
		
		public function sortBiomolecules():void {
			if (loadingNetwork) return;
			
			var sort:Sort = new Sort();
			sort.fields = [new SortField('myName', true)];
			sort.sort(biomolecules.source);
		}
		
		/************************************************
		* edges
		* **********************************************/
		
		private var edgesGeometryGroup:GeometryGroup;
		[Bindable] public var edges:ArrayCollection = new ArrayCollection();
		[Bindable] public var showPores:Boolean = true;
		[Bindable] public var poreFillColor:uint = 0xFFD700;
		[Bindable] public var poreStrokeColor:uint = 0xCDAD00;
		
		public function addEdge(fromName:String, to:Biomolecule,sense:Boolean=true):Edge {
			var from:Biomolecule = getBiomoleculeByName(fromName) as Biomolecule;
			
			if (from == null || to == null) return null;
			
			var edge:Edge = new Edge(this, from, to, sense);
			edge.dim = dimAnimation && animationNotStopped;
			edge.target = edgesGeometryGroup;		
			edgesGeometryGroup.addChild(edge);			
			edges.addItem(edge);
			
			return edge;
		}
				
		public function removeEdge(edge:Edge):void {
			
			if (edges.contains(edge)) {
				edges.removeItemAt(edges.getItemIndex(edge));	
			}
			if (edgesGeometryGroup.contains(edge)) {
				edgesGeometryGroup.removeChild(edge);
			}
		}
		
		
		public function findEdgeByName(fromName:String, toName:String):* {
			for (var i:uint = 0; i < edges.length; i++) {
				if (edges[i].from.myName == fromName && edges[i].to.myName == toName) return edges[i];
			}
			return false;
		}
		
		/************************************************
		* advanced options
		* **********************************************/		
		public function updateAdvancedOptions(diagramWidth:uint, diagramHeight:uint, showPores:Boolean, poreFillColor:uint, poreStrokeColor:uint,
		ranksep:uint, nodesep:uint, loopAnimation:Boolean, animationFrameRate:Number, dimAnimation:Boolean,
		exportShowBiomoleculeSelectedHandles:Boolean, exportColorBiomoleculesByValue:Boolean, exportAnimationFrameRate:Number, exportLoopAnimation:Boolean, exportDimAnimation:Boolean,
		addHistoryAction:Boolean = true):Object {
			var undoData:Object = {
				diagramWidth:this.diagramWidth,
				diagramHeight:this.diagramHeight,
				showPores:this.showPores,
				poreFillColor:this.poreFillColor,
				poreStrokeColor:this.poreStrokeColor,
				ranksep:this.ranksep,
				nodesep:this.nodesep,
				//loopAnimation:this.loopAnimation,
				//animationFrameRate:this.animationFrameRate,
				//dimAnimation:this.dimAnimation,
				exportShowBiomoleculeSelectedHandles:this.exportShowBiomoleculeSelectedHandles,
				exportColorBiomoleculesByValue:this.exportColorBiomoleculesByValue
				//exportAnimationFrameRate:this.exportAnimationFrameRate,
				//exportLoopAnimation:this.exportLoopAnimation,
				//exportDimAnimation:this.exportDimAnimation
				};
				
			if (addHistoryAction) historyManager.addHistoryAction(new HistoryAction(this, 'updateAdvancedOptions', undoData));
			
			//graphics
			this.diagramWidth = diagramWidth;
			this.diagramHeight = diagramHeight;
			this.showPores = showPores;
			this.poreFillColor = poreFillColor;
			this.poreStrokeColor = poreStrokeColor;
			
			//layout			
			this.ranksep = ranksep;
			this.nodesep = nodesep;
			
			//animation
			this.loopAnimation = loopAnimation;			
			this.animationFrameRate = animationFrameRate;
			this.dimAnimation = dimAnimation;
			this.fullScreenAnimationToolBar.repeatButton.selected = loopAnimation;
			toolBarDocker.animationbar.animationBar.repeatButton.selected = loopAnimation;
			
			//export
			this.exportShowBiomoleculeSelectedHandles = exportShowBiomoleculeSelectedHandles;
			this.exportColorBiomoleculesByValue = exportColorBiomoleculesByValue;
			this.exportAnimationFrameRate = exportAnimationFrameRate;
			this.exportLoopAnimation = exportLoopAnimation;
			this.exportDimAnimation = exportDimAnimation;
			
			return undoData;
		}

		/************************************************
		* layout
		* **********************************************/	
		private var autoLayoutDiagramService:HTTPService = new HTTPService();
		private var autoLayoutDiagramEdgeTimer:Timer=new Timer(1500,1);
		private var autoLayoutDiagramBackgroundTimer:Timer = new Timer(2250, 1);
		
		[Bindable] public var ranksep:uint = 18;
		[Bindable] public var nodesep:uint = 54;
		[Bindable] public var rankdir:uint = 0;
		private var rankdirTypes:Array = ['TB', 'BT', 'LR', 'RL'];
		
		public function autoLayoutDiagram():void {
			autoLayoutDiagramService.send({dotCode:dotCode()});
		}
		
		private function autoLayoutDiagramServiceResultHandler(event:ResultEvent):void {
			//add old sizes of compartments, old positions of biomolecules to undo stack
			historyManager.addHistoryAction(new HistoryAction(this, 'autoLayout', 
				{ compartmentPositions:compartmentPositions, biomoleculePositions:biomoleculePositions } ));
			
			var pattern:RegExp;
			var matches:Object;
			var biomolecule:Biomolecule;
			var scale:Number = 1;
			var unscaledHeight:Number = 0;
			var doNotScaleHeight:Number = 0;
			var compartmentHeight:Number;
			var rescale:Number;
			var compartment:*;
			
			edgesGeometryGroup.alpha = 0;
			
			// get scale
			pattern = /^graph (\d+\.*\d*) (\d+\.*\d*) (\d+\.*\d*)$/m;
			matches = pattern.exec(event.result.toString());
			if (matches != null) scale = parseFloat(matches[1]);
			
			//parse nodes
			pattern = /^node (\w+) (\d+\.*\d*) (\d+\.*\d*) (\d+\.*\d*) (\d+\.*\d*) "?.*"? solid \w+ #\w+ #\w+$/gm;
			matches = pattern.exec(event.result.toString());
			while (matches != null) {
				biomolecule = getBiomoleculeByName(matches[1], true);
								
				//update biomolecule position
				biomolecule.translateTo(parseFloat(matches[2]) * scale, parseFloat(matches[3]) * scale, 0, false, false);
				
				//get next biomolecule
				matches = pattern.exec(event.result.toString());
			}
			
			// not needed if there is just one compartment
			if (compartmentsAndMembranes.length != 1) {
				// sum heights of compartments
				for each(compartment in this.compartments) {
					compartmentHeight = compartment.getBiomoleculesShapeBounds(true).height;
					if (compartmentHeight == -Infinity) {
						doNotScaleHeight += compartment.minimumHeight;
					}
					else {
						unscaledHeight += compartmentHeight;
					}					
				}
				// add membrane number of arrow spaces above and below the membrane and the membrane space
				doNotScaleHeight += (this.compartments.length - 1) * 3 * this.membraneHeight;
				
				rescale = (diagramHeight - doNotScaleHeight) / unscaledHeight;
				//trace(rescale);
				
				for each(compartment in compartmentsAndMembranes) compartment.resizeToFit(rescale);
				
				//for each(compartment in compartmentsAndMembranes) trace("after - " + compartment.myName + ": " + compartment.getBiomoleculesShapeBounds(true));
			}			
			
			//redisplay edges, fit background			
			autoLayoutDiagramEdgeTimer.start();
			autoLayoutDiagramBackgroundTimer.start();			
		}
		
		private function autoLayoutDiagramUpdateEdges(event:TimerEvent):void {
			Tweener.addTween(edgesGeometryGroup, {alpha:1, time:1.5} );
		}
		
		private function autoLayoutDiagramUpdateBackground(event:TimerEvent):void {
			//this function needs to go
			//fitBackground();
		}
		
		private function autoLayoutDiagramServiceFaultHandler(event:FaultEvent):void {
			Alert.show('Auto layout diagram failed.','Auto Layout Error');
		}		
		
		public function dotCode(scale:uint=1,metaData:Object=null):String {
			var dot:Object = { compartments:[], membranes:[], edges:[], scale:scale };
			var metaDataStr:String = '';
			var i:uint;
						
			if (metaData != null) {
				metaDataStr=printf(
					'  /*\n' +
					'   * Name: %s\n' +
					'   * Author: %s\n' +
					'   * Generator: %s\n' +
					'   * Generated: %s\n' +
					'   */\n\n',
					metaData.title, metaData.author, metaData.creator, metaData.timestamp);
			}
				
			var fromCompartment:uint;
			var toCompartment:uint;
			var connected:Array = new Array(compartmentsAndMembranes.length - 1);
			
			// initialize Boolean array
			for (i = 0; i < connected.length; i++) connected[i] = false;
			
			//compartments
			for (i = 0; i < compartments.length; i++) dot.compartments.push(compartments[i].dotCode(scale));
			
			//membranes
			for (i = 0; i < compartments.length - 1; i++) dot.membranes.push(compartments[i].myMembrane.dotCode(scale));
			
			//between compartment edges
			for (i = 0; i < edges.length; i++) {
				fromCompartment = compartmentsAndMembranes.getItemIndex(edges[i].from.myCompartment);
				toCompartment = compartmentsAndMembranes.getItemIndex(edges[i].to.myCompartment);
				if (fromCompartment == toCompartment - 1) {
					connected[fromCompartment] = true;
				}
				if (fromCompartment != toCompartment) {
					dot.edges.push(edges[i].dotCode(scale));
				}
			}
			
			// connect unconnected compartments
			var fromBiomolecule:Biomolecule;
			var toBiomolecule:Biomolecule;
			for (i = 0; i < connected.length; i++) {
				if (!connected[i]) {
					fromBiomolecule = compartmentsAndMembranes[i].getMaxDegreeNode();
					toBiomolecule = compartmentsAndMembranes[i + 1].getIsolatedNode();
					dot.edges.push(printf('"%s"->"%s" [style="invis"];',
								  (fromBiomolecule == null) ? 'hidden' + i : fromBiomolecule.myName,
								  (toBiomolecule == null) ? 'hidden' + (i+1) : toBiomolecule.myName, ColorUtils.hexToDec(0x000000)));
				}
			}			
			
			return printf('digraph G {\n'+
				'%s' +
				'  size="%f,%f!";\n' +
				'  clusterrank=global;\n' +
				'  nodesep=%f;\n' +
				'  ranksep=%f;\n' +			
				'  rankdir=%s;\n' +				
				'  center=true;\n' +
				'  ratio="fill";\n' +
				'  margin=0;\n' +
				'  fontname=Arial;\n' +
				'  charset=latin1;\n\n' +
				'  node [fixedsize="true"];\n' +
				'  edge [color="#000000"];\n\n' +
				'  %s\n\n' +
				'  %s\n\n' +
				'  %s\n}', 
				metaDataStr,
				diagramWidth / scale , 
				diagramHeight/ scale, 
				nodesep / scale, 
				ranksep / scale,
				rankdirTypes[rankdir], 
				dot.compartments.join('\n\n  '), dot.membranes.join('\n\n  '), dot.edges.join('\n  '));
		}
		
		private function autoCenter():Object {
			var left:Number = Infinity;
			var right:Number = -Infinity;
			var top:Number = Infinity;
			var bottom:Number = -Infinity;
			var bounds:Rectangle;
			
			for each(var biomolecule:Biomolecule in biomolecules) {
					bounds = biomolecule.getShapeBounds();
					left = Math.min(left, bounds.left);
					right = Math.max(right, bounds.right);
					top = Math.min(top, bounds.top);
					bottom = Math.max(bottom, bounds.bottom);
			}
						
			bounds =  new Rectangle(left, top, right - left, bottom - top)
			
			return {deltaX:this.width/2 - bounds.width/2, deltaY:this.height/2 - bounds.height/2};
		}
		
		private function get compartmentPositions():ArrayCollection {
			var value:ArrayCollection = new ArrayCollection();
			for (var i:uint = 0; i < compartments.length; i++) {
				value.addItem( { compartment:compartments[i], myHeight:compartments[i].myHeight } );
			}
			return value;
		}
		
		private function set compartmentPositions(value:ArrayCollection):void {
			var y:Number = 0;
			for (var i:uint = 0; i < value.length; i++) {
				(value[i].compartment as Compartment).y = y;
				(value[i].compartment as Compartment).myHeight = value[i].myHeight;
				y += (value[i].compartment as Compartment).myHeight + membraneHeight;
			}
		}
		
		private function get biomoleculePositions():ArrayCollection {
			var value:ArrayCollection = new ArrayCollection();
			for (var i:uint = 0; i < biomolecules.length; i++) {
				value.addItem( { biomolecule:biomolecules[i], x:biomolecules[i].x, y:biomolecules[i].y } );
			}
			return value;
		}
		
		private function set biomoleculePositions(value:ArrayCollection):void {
			for (var i:uint = 0; i < value.length; i++) {
				(value[i].biomolecule as Biomolecule).translateTo(value[i].x, value[i].y);
			}
		}
		
		/************************************************
		* measurement/animation
		* **********************************************/
		//measurements		
		[Bindable] public var measurementLoaded:Boolean;
		private var biomoleculeAssociations:Array;
		private var measurement:Array;
		private var animationAxis:Array;
		public var comparisonXAxis:Array;
		public var comparisonYAxis:Array;
		
		public function clearMeasurement():void {			
			//reset measurement
			measurement = null;
			biomoleculeAssociations = null;
			animationAxis = null;
			measurementLoaded = false;
			
			//reset animation
			stopAnimation();
			animationIdxMax = 0;
			animationPosMax = 0;
			animationTimeMax = '';
		}
		
		public function loadMeasurement(biomoleculeAssociations:Array, 
		animationAxis:Array, comparisonXAxis:Array, comparisonYAxis:Array, 
		measurement:Array, startAnimation:Boolean = true):void {			
			clearMeasurement();
			measurementLoaded = true;
			
			this.animationAxis = animationAxis;
			this.comparisonXAxis = comparisonXAxis;
			this.comparisonYAxis = comparisonYAxis;
			this.biomoleculeAssociations = biomoleculeAssociations;
			this.measurement = measurement;			
			
			animationIdxMax = animationPosMax = animationAxis.length - 1;
			animationTimeMax = animationAxis[animationAxis.length - 1].name;
			animationTime = animationAxis[0].name;
			
			//update heatmap legend
			updateHeatmapLegend();			
			
			//move observed biomolecules to top
			for (var i:uint = 0; i < biomoleculeAssociations.length; i++ ) {
				biomoleculesSurface.removeChild(biomoleculeAssociations[i].biomolecule);
				biomoleculesSurface.addChild(biomoleculeAssociations[i].biomolecule);
			}
			
			//play
			if (startAnimation || animationNotStopped) {
				playAnimation();
			}
		}		
			
		//color maps	
		private var _colormap:String;
		
		[Bindable]
		public function get colormap():String {
			return _colormap;
		}
		public function set colormap(value:String):void {
			if (value != _colormap) {
				_colormap = value;				
			}
		}

		//animation
		[Bindable] public var animationPlaying:Boolean;
		[Bindable] public var animationNotStopped:Boolean;
		[Bindable] public var animationIdx:Number;
		[Bindable] public var animationPos:Number;
		[Bindable] public var animationTime:String;
		[Bindable] public var animationIdxMax:Number;
		[Bindable] public var animationPosMax:Number;
		[Bindable] public var animationTimeMax:String;		
		[Bindable] public var loopAnimation:Boolean = true;

		private var _dimAnimation:Boolean;
		[Bindable] 
		public function get dimAnimation():Boolean {
			return _dimAnimation;
		}
		public function set dimAnimation(value:Boolean): void {
			if (_dimAnimation != value) {
				_dimAnimation = value;
				dimComponents(animationNotStopped);
			}
		}
		
		private var _animationFrameRate:Number = 20;
		private var animationTween:Tween;
		public static const dimGrey:Object = {
			compartmentFill: 0xF0F0F0 , 
			compartmentStroke: 0xE8E8E8, 
			poreFill: 0xE8E8E8,
			poreStroke: 0xE0E0E0,
			biomoleculeFill: 0xA0A0A0,
			biomoleculeStroke: 0x000000,
			biomoleculeLabel: 0x000000
			};
		
		[Bindable]
		public function get animationFrameRate():Number {
			return _animationFrameRate;
		}
		public function set animationFrameRate(value:Number):void {
			if (_animationFrameRate != value && !isNaN(value)) {
				_animationFrameRate = value;
				if (animationTween) animationTween.duration = animationIdxMax * 60 / value * 1000;
			}
		}
				
		public function playPauseAnimation():void {
			animationPlaying = !animationPlaying;
			
			if (animationPlaying) {
				if (animationTween) animationTween.resume();
				else playAnimation();
			}
			else pauseAnimation();
		}
		
		public function playAnimation():void {		
			dimComponents(true, false);
			animationPlaying = true;
			animationNotStopped = true;
			animationIdx = animationPos = 0;
			animationTime = animationAxis[0].name;
			animationTween = new Tween(this, 0, animationIdxMax, animationIdxMax * 60 / animationFrameRate * 1000);
			animationTween.easingFunction = Linear.easeNone;
			animationTween.setTweenHandlers(updateAnimationTween, endAnimationTween);			
			dispatchEvent(new DiagramEvent(DiagramEvent.START_LOOP));
		}
		
		public function pauseAnimation():void {		
			animationPlaying = false;
			animationNotStopped = true;
			animationTween.pause();
		}
		
		public function stopAnimation():void {
			dimComponents(false, false);		
			animationPlaying = false;
			animationNotStopped = false;
			animationIdx = animationPos = 0;
			animationTime = (animationAxis is Array && animationAxis.length > 0 ? animationAxis[0].name : '');
			
			stopAnimationTween();		
		}
	
		public function updateAnimationTween(value:Number):void {
			if (animationAxis == null)
				return;
				
			value = Math.min(value, animationAxis.length - 1);
			animationPos = value;
			animationIdx = Math.floor(value);
			animationTime = animationAxis[animationIdx].name;
			value = value-animationIdx;
			
			for (var i:uint = 0; i < biomoleculeAssociations.length; i++) {
				var measurementIdx:uint = biomoleculeAssociations[i].measurementIdx;
				var myValue:Array = [];
				for (var j:uint = 0; j < measurement[measurementIdx][animationIdx].length; j++) {
					myValue.push([]);
					for (var k:uint = 0; k < measurement[measurementIdx][animationIdx][j].length; k++) {
						myValue[j].push(measurement[measurementIdx][animationIdx][j][k] * (1 - value) + 
							measurement[measurementIdx][Math.min(animationIdx + 1, measurement[measurementIdx].length - 1)][j][k] * value);
					}
				}
				biomoleculeAssociations[i].biomolecule.myValue = myValue;
			}
		}
		
		private function endAnimationTween(value:Number):void {
			updateAnimationTween(value);
			dispatchEvent(new DiagramEvent(DiagramEvent.FINISH_LOOP));
			
			if (loopAnimation) 
				playAnimation();
			else stopAnimation();
		}
			
		public function stopAnimationTween():void {
			if (animationTween != null) { 
				animationTween.stop(); 
				animationTween = null;
			}
			
			for (var i:uint = 0; i < biomolecules.length; i++ ) {
				biomolecules[i].myValue = null;
			}
		}
		
		public function getAnimationTime(idx:Number):String {
			if (animationAxis && Math.floor(idx) < animationAxis.length) 
				return animationAxis[Math.floor(idx)].name;
			else return '';
		}
		
		//alpha		
		public function dimComponents(dim:Boolean = false, exporting:Boolean = false):void {
			var i:uint;
			
			dim = dim && ((!exporting && dimAnimation) || (exporting && exportDimAnimation));
			
			if (compartments)
				for (i = 0; i < compartments.length; i++) compartments[i].dim = dim;
			if (biomolecules) 
				for (i = 0; i < biomolecules.length; i++) biomolecules[i].dim = dim;
			if (edges) 
				for (i = 0; i < edges.length; i++) edges[i].dim = dim;
			if (biomoleculeAssociations) 
				for (i = 0; i < biomoleculeAssociations.length; i++) biomoleculeAssociations[i].biomolecule.dim = false;
		}
		
		//comparison heatmaps
		import edu.stanford.covertlab.chart.LabeledColorGrid;
		
		[Bindable] public var comparisonHeatmapsVisible:Boolean = true;
		private var heatmapLegend:LabeledColorGrid;
		
		private function setupHeatmapLegend():void {
			heatmapLegend = new LabeledColorGrid();
			addChild(heatmapLegend);
					
			BindingUtils.bindProperty(heatmapLegend, 'visible', this, 'comparisonHeatmapsVisible')
			addEventListener(FlexEvent.CREATION_COMPLETE, positionHeatmapLegend);
		}

		private function positionHeatmapLegend(event:FlexEvent):void
		{
			heatmapLegend.x = 5;
			heatmapLegend.y = height - 35;			
		}

		private function updateHeatmapLegend():void {		
			var nCol:uint = comparisonXAxis.length;
			var nRow:uint = comparisonYAxis.length;

			var colLabels:Array = [];
			var rowLabels:Array = [];
			for (i = 0; i < nCol; i++) {
				colLabels.push(comparisonXAxis[i]['name']);
			}
			for (j = 0; j < nRow; j++) {
				rowLabels.push(comparisonYAxis[j]['name']);
			}

			var colors:Array = [];
			for (var i:uint = 0; i < nCol; i++) {
				for (var j:uint = 0; j < nRow; j++) {
					colors.push(0xFFFFFF);
				}
			}

			heatmapLegend.update(nCol, nRow, 12, 12, colLabels, rowLabels, colors);
		}
		
		public function toggleComparisonHeatmaps():void {
			comparisonHeatmapsVisible = !comparisonHeatmapsVisible;
		}
		
		
		/************************************************
		* cut, copy, paste, trash
		* **********************************************/
		[Bindable] public var cutEnabled:Boolean = false;
		[Bindable] public var copyEnabled:Boolean = false;
		[Bindable] public var pasteEnabled:Boolean = false;
		private var pasteArray:ArrayCollection = new ArrayCollection();
				
		public function cut(addHistoryAction:Boolean = true, addToPasteArray:Boolean=true):Object {
			if (addHistoryAction && selectedBiomolecules.length == 0) return null;
			
			var outgoingRegulations:ArrayCollection = new ArrayCollection();
			var regulatedBiomolecules:ArrayCollection = new ArrayCollection();
			var cutBiomolecules:ArrayCollection = new ArrayCollection(selectedBiomolecules.toArray());
			for (var i:uint = 0; i < edges.length; i++) {
				if (selectedBiomolecules.contains(edges[i].from) && !regulatedBiomolecules.contains(edges[i].to)) {
					regulatedBiomolecules.addItem(edges[i].to);
					outgoingRegulations.addItem( { biomolecule:edges[i].to, myRegulation:edges[i].to.myRegulation } );
				}
			}
			
			if (addToPasteArray) pasteArray.removeAll();
			for (i = 0; i < selectedBiomolecules.length; i++) {
				(selectedBiomolecules[i] as Biomolecule).remove(false);
				if (addToPasteArray) pasteArray.addItem(selectedBiomolecules[i].copy());
			}
			
			deselectBiomolecules();
			cutEnabled = false;
			copyEnabled = false;
			pasteEnabled = true;
			
			//undo
			var undoData:Object = { biomolecules: cutBiomolecules, outgoingRegulations:outgoingRegulations };
			if (addHistoryAction) historyManager.addHistoryAction(new HistoryAction(this, 'recycleBiomolecules', undoData));
			
			return undoData;
		}

		public function copy():void {
			if (selectedBiomolecules.length == 0) return;
			
			//clear paste array
			pasteArray.removeAll();
			
			//copy selected biomolecules, add to paste array
			for (var i:uint = 0; i < selectedBiomolecules.length; i++) {
				pasteArray.addItem(selectedBiomolecules[i].copy());
			}
			
			//update paste cuttons
			pasteEnabled = true;
		}
				
		public function paste(offset:Boolean = true):void {			
			if (pasteArray.length == 0) return;
			
			var biomolecule:Biomolecule;
			var pastedBiomolecules:ArrayCollection = new ArrayCollection();
			var newPasteArray:ArrayCollection = new ArrayCollection();
			
			//clear selected biomolecules
			deselectBiomolecules();
			
			//copy paste biomolecules, add to diagram
			for (var i:uint = 0; i < pasteArray.length; i++) {
				biomolecule = new Biomolecule(this, pasteArray[i].myCompartment, pasteArray[i].myStyle, pasteArray[i].x, pasteArray[i].y,
					pasteArray[i].myName, pasteArray[i].myLabel, pasteArray[i].myRegulation, pasteArray[i].myComments, false);
				biomolecule.dim = dimAnimation && animationNotStopped;
				selectBiomolecule(biomolecule, true);

				var bounds:Rectangle = biomolecule.getShapeBounds();
				if (offset) biomolecule.translate(2 * Biomolecule.SIZE, 2 * Biomolecule.SIZE);
				else biomolecule.updateCompartment(0);
				
				newPasteArray.addItem(biomolecule.copy());
				pastedBiomolecules.addItem(biomolecule);
			}
			
			//upate cut, paste buttons
			pasteArray = newPasteArray;
			cutEnabled = true;
			copyEnabled = true;
			pasteEnabled = true;
			
			//undo
			historyManager.addHistoryAction(new HistoryAction(this, 'trashBiomolecules', pastedBiomolecules));
		}
		
		public function trash(addHistoryAction:Boolean = true):Object {
			return cut(addHistoryAction, false);
		}
		
		private function clearPasteArray():void {			
			pasteArray.removeAll();
			cutEnabled = false;
			copyEnabled = false;
			pasteEnabled = false;
		}

		/************************************************
		* redo, undo
		* **********************************************/		
		public function undoHistoryAction(action:String, data:Object):HistoryAction {
			var inverseAction:String = '';
			var inverseData:Object = { };
			var i:uint = 0;
			switch(action) {
				case 'recycleBiomolecules':
					inverseAction = 'trashBiomolecules';
					inverseData = data.biomolecules;
					
					deselectBiomolecules();
					for (i = 0; i < data.biomolecules.length; i++) {
						addBiomolecule(data.biomolecules[i]);
						selectBiomolecule(data.biomolecules[i], true);
					}
					cutEnabled = true;
					copyEnabled = true;
					
					for (i = 0; i < data.outgoingRegulations.length; i++) {
						data.outgoingRegulations[i].biomolecule.myRegulation = data.outgoingRegulations[i].myRegulation;
					}
					
					for (i = 0; i < data.biomolecules.length; i++) {
						data.biomolecules[i].updateIncomingEdges();
					}
					break;
				case 'trashBiomolecules':					
					inverseAction = 'recycleBiomolecules';
					selectedBiomolecules = data as ArrayCollection;
					inverseData = trash(false);
					break;
				case 'pasteBiomolecules':
					inverseAction = 'cutBiomolecules';
					break;
				case 'translateBiomolecules':
					inverseAction = 'translateBiomolecules';
					inverseData = new ArrayCollection();
					for (i = 0; i < data.length; i++) {
						(inverseData as ArrayCollection).addItem( { biomolecule:data[i].biomolecule,
							x:data[i].biomolecule.x, y:data[i].biomolecule.y } );
					}
					biomoleculePositions = data as ArrayCollection;
					break;
				case 'autoLayout':
					inverseAction = 'autoLayout';
					inverseData = { compartmentPositions:compartmentPositions, biomoleculePositions:biomoleculePositions };
					compartmentPositions = data.compartmentPositions as ArrayCollection;
					biomoleculePositions = data.biomoleculePositions as ArrayCollection;
					break;
				case 'updateAdvancedOptions':
					inverseAction = 'updateAdvancedOptions';
					inverseData = updateAdvancedOptions(data.diagramWidth, data.diagramHeight, 
						data.showPores, data.poreFillColor, data.poreStrokeColor, data.ranksep, data.nodesep, 
						data.loopAnimation, data.animationFrameRate, data.dimAnimation,
						data.exportShowBiomoleculeSelectedHandles, data.exportColorBiomoleculesByValue, 
						data.exportAnimationFrameRate, data.exportLoopAnimation, data.exportDimAnimation, false);
					break;
			}
			
			return new HistoryAction(this, inverseAction, inverseData);
		}
			
		/************************************************
		* find (locating biomolecules)
		* **********************************************/
		private var findBiomoleculeWindow:FindBiomoleculeWindow;
		private var findBiomoleculeIdx:uint;

		public function openFindBiomoleculeWindow():void {
			findBiomoleculeIdx = 0;
			findBiomoleculeWindow.open();
		}
		
		public function findBiomolecule(search:String):Boolean {			
			var biomolecule:*= getBiomoleculeByName(search,false,findBiomoleculeIdx);
			if (biomolecule === false) return false;
			findBiomoleculeIdx = biomolecules.getItemIndex(biomolecule)+1;
			
			clearSelectedBiomolecules(new MouseEvent(MouseEvent.CLICK));
			selectBiomolecule(biomolecule);
			return true;
		}
		
		
		/************************************************
		* rendering, printing
		* **********************************************/
		[Bindable] public var exportShowBiomoleculeSelectedHandles:Boolean = false;
		[Bindable] public var exportColorBiomoleculesByValue:Boolean = false;
		[Bindable] public var exportAnimationFrameRate:Number = 20;
		[Bindable] public var exportLoopAnimation:Boolean = true;
		[Bindable] public var exportDimAnimation:Boolean = true;
		
		public function render(format:String, metaData:Object = null, 
		overrideShowBiomoleculeSelectedHandles:Boolean = false,
		overrideColorBiomoleculesByValue:Boolean = false,
		overrideComparisonHeatmapsVisible:Boolean = true):* {
			var data:*;
			var i:uint;
			var biomoleculeValues:Array = [];			
			var comparisonHeatmapsVisible:Boolean = this.comparisonHeatmapsVisible;
			
			//toggle off comparison heatmaps
			if (overrideComparisonHeatmapsVisible) {
				this.comparisonHeatmapsVisible = false;
			}
			
			//turn off biomolecule selected handles
			if (!exportShowBiomoleculeSelectedHandles || overrideShowBiomoleculeSelectedHandles) {
				for (i = 0; i < selectedBiomolecules.length; i++)
					selectedBiomolecules[i].selected = false;
			}
			
			//turn off biomolecule coloring by value
			if (!exportColorBiomoleculesByValue || overrideColorBiomoleculesByValue) {
				for (i = 0; i < biomolecules.length; i++){
					biomoleculeValues.push(biomolecules[i].myValue);
					biomolecules[i].myValue = null;
				}
			}
					
			//undim components
			if (animationNotStopped) dimComponents(false, true);
			
			//render
			switch(format) {
				case 'gif':
					var gifRenderer:GIFRenderer = new GIFRenderer();
					data = gifRenderer.render(backgroundCanvas, new Rectangle(0, 0, diagramWidth, diagramHeight), metaData);
					break;
				case 'jpg':
					var jpegRenderer:JPEGRenderer = new JPEGRenderer();
					data = jpegRenderer.render(backgroundCanvas, new Rectangle(0, 0, diagramWidth, diagramHeight), metaData);
					break;
				case 'png':		
					var pngRenderer:PNGRenderer = new PNGRenderer();
					data = pngRenderer.render(backgroundCanvas, new Rectangle(0, 0, diagramWidth, diagramHeight), metaData);
					break;					
				case 'svg':
					var svgRenderer:SVGRenderer = new SVGRenderer();
					data = svgRenderer.render(backgroundCanvas, new Rectangle(0, 0, diagramWidth, diagramHeight), metaData);
					break;
			}
			
			//reset comparison heatmaps
			this.comparisonHeatmapsVisible = comparisonHeatmapsVisible;
						
			//turn on biomolecule selected handles
			if (!exportShowBiomoleculeSelectedHandles || overrideShowBiomoleculeSelectedHandles) {
				for (i = 0; i < selectedBiomolecules.length; i++)
					selectedBiomolecules[i].selected = true;
			}
			
			//turn on biomolecule coloring by value
			if (!exportColorBiomoleculesByValue || overrideColorBiomoleculesByValue) {
				for (i = 0; i < biomolecules.length; i++)
					biomolecules[i].myValue = biomoleculeValues[i];
			}
			
			//dim components
			if (animationNotStopped) dimComponents(true, false);
			
			return data;
		}
		
		public function renderAnimation(format:String, metaData:Object):ByteArray {			
			var i:uint;
			var j:uint;
			var state:Array = [];
			var frames:Array = [];
			var bitmapData:BitmapData;
			var data:ByteArray;
			var svgRenderer:SVGRenderer = new SVGRenderer();
			
			//store current state, stop animation
			var animationPlaying:Boolean = this.animationPlaying;
			if (animationPlaying) {
				pauseAnimation();
				for (i = 0; i < biomolecules.length; i++) state.push(biomolecules[i].myValue);
			}
			
			//dim components
			if (!animationNotStopped) dimComponents(true, true);
						
			//create frames
			var bounds:Rectangle = new Rectangle(0, 0, diagramWidth, diagramHeight);
			for (i = 0; i <= animationIdxMax; i++) {
				for (j = 0; j < biomoleculeAssociations.length; j++ ) {					
					biomoleculeAssociations[j].biomolecule.myValue = measurement[biomoleculeAssociations[j].measurementIdx][i];
				}
				switch (format)
				{
					case 'gif':
					case 'pdf':
						bitmapData = new BitmapData(bounds.width, bounds.height);
						bitmapData.draw(backgroundCanvas, null, null, null, null, true);
						frames.push(bitmapData);
						break;
					case 'svg':						
						frames.push(svgRenderer.render(backgroundCanvas, new Rectangle(0, 0, diagramWidth, diagramHeight), metaData));
				}						
			}
			
			//restore state
			if (animationPlaying) {
				playPauseAnimation();
				for (i = 0; i < biomolecules.length; i++) biomolecules[i].myValue=state[i];
			}
			
			//dim components
			if (!animationNotStopped) dimComponents(true, false);
			
			//encode
			switch(format) {
				case 'gif':
					var gifRenderer:AnimatedGIFRenderer = new AnimatedGIFRenderer();
					data = gifRenderer.render(frames, exportLoopAnimation, exportAnimationFrameRate, metaData);
					break;
				case 'pdf':
					var pdfRenderer:MultipagePDFRenderer = new MultipagePDFRenderer();
					data = pdfRenderer.render(frames, metaData);
					break;
				case 'svg':
					var zo:ZipOutput = new ZipOutput();
					
					var byteArray:ByteArray = new ByteArray();
					byteArray.writeUTFBytes(this.render('svg', metaData, false, false, false));
					var ze:ZipEntry = new ZipEntry(printf('%s/%s.svg', metaData.title, 'reference'));
					zo.putNextEntry(ze);
					zo.write(byteArray);
					zo.closeEntry();
					
					for (i = 0; i < frames.length; i++) {
						byteArray = new ByteArray();
						byteArray.writeUTFBytes(frames[i] as String);
						
						ze = new ZipEntry(printf('%s/%s.svg', metaData.title, animationAxis[i].name));
						zo.putNextEntry(ze);
						zo.write(byteArray);
						zo.closeEntry();
					}
					
					zo.finish();
					data = zo.byteArray;
					break;
			}
			
			return data;
		}
		
		public function rasterize(format:String,metaData:Object):void {
			var svgRasterizer:SVGRasterizer = new SVGRasterizer();
			svgRasterizer.rasterize(format, (metaData && metaData['title'] ? metaData.title : 'network'), 
				backgroundCanvas, new Rectangle(0, 0, diagramWidth, diagramHeight), metaData);
		}
		
		public function print():void {
			Printer.print(backgroundCanvas, new Rectangle(0, 0, diagramWidth, diagramHeight));
		}
		
		
	}
	
}
