package edu.stanford.covertlab.diagram.toolbar 
{
	import edu.stanford.covertlab.controls.ToolBarButton;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.containers.HBox;
	
	/**
	 * Toolbar containing controls for copy, cut, pase; undo, redo; zooming, and autolayout.
	 * 
	 * @see ToolBar
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ControlToolBar extends ToolBar
	{
	
		[Embed(source = '../../image/cut.png')] private var cutImg:Class;
		[Embed(source = '../../image/page_copy.png')] private var copyImg:Class;
		[Embed(source = '../../image/page_paste.png')] private var pasteImg:Class;
		[Embed(source = '../../image/arrow_undo.png')] private var undoImg:Class;
		[Embed(source = '../../image/arrow_redo.png')] private var redoImg:Class;
		[Embed(source = '../../image/zoom_in.png')] private var zoomInImg:Class;
		[Embed(source = '../../image/zoom_out.png')] private var zoomOutImg:Class;
		[Embed(source = '../../image/zoom_reset.png')] private var zoomResetImg:Class;
		[Embed(source = '../../image/zoom_fit.png')] private var zoomFitImg:Class;
		[Embed(source = '../../image/wand.png')] private var autoLayoutDiagramImg:Class;
		
		private var cutButton:ToolBarButton;
		private var copyButton:ToolBarButton;
		private var pasteButton:ToolBarButton;
		private var undoButton:ToolBarButton;
		private var redoButton:ToolBarButton;
		private var zoomInButton:ToolBarButton;
		private var zoomOutButton:ToolBarButton;
		private var zoomResetButton:ToolBarButton;
		private var zoomFitButton:ToolBarButton;
		private var fitBackgroundButton:ToolBarButton;
		private var autoLayoutDiagramButton:ToolBarButton;
		
		public function ControlToolBar(diagram:Diagram) 
		{		
			super(diagram);
			
			label = 'Edit';
			
			cutButton = new ToolBarButton('Cut', cutImg);
			cutButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.cut(); } );
			addChild(cutButton);
			
			copyButton = new ToolBarButton('Copy', copyImg);
			copyButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.copy(); } );
			addChild(copyButton);
			
			pasteButton = new ToolBarButton('Paste', pasteImg);
			pasteButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.paste(); } );
			addChild(pasteButton);
			
			undoButton = new ToolBarButton('Undo', undoImg);
			undoButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.historyManager.undo(); } );
			addChild(undoButton);
			
			redoButton = new ToolBarButton('Redo', redoImg);
			redoButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.historyManager.redo(); } );
			addChild(redoButton);
			
			zoomInButton = new ToolBarButton('Zoom In', zoomInImg);
			zoomInButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.zoomIn(); } );
			addChild(zoomInButton);
			
			zoomOutButton = new ToolBarButton('Zoom Out', zoomOutImg);
			zoomOutButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.zoomOut(); } );
			addChild(zoomOutButton);
			
			zoomResetButton = new ToolBarButton('Original Size', zoomResetImg);
			zoomResetButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.zoomReset(); } );
			addChild(zoomResetButton);
			
			zoomFitButton = new ToolBarButton('Zoom Fit', zoomFitImg);
			zoomFitButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.zoomFit(); } );
			addChild(zoomFitButton);
			
			//
			//fitBackgroundButton = new ToolBarButton('Fit Content', fitContentImg);
			//fitBackgroundButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.fitBackground(); } );
			//addChild(fitBackgroundButton);
			
			autoLayoutDiagramButton = new ToolBarButton('Auto Layout Diagram', autoLayoutDiagramImg);
			autoLayoutDiagramButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { diagram.autoLayoutDiagram(); } );
			addChild(autoLayoutDiagramButton);
			
			BindingUtils.bindProperty(cutButton, 'enabled', diagram, 'cutEnabled');
			BindingUtils.bindProperty(copyButton, 'enabled', diagram, 'copyEnabled');
			BindingUtils.bindProperty(pasteButton, 'enabled', diagram, 'pasteEnabled');
			BindingUtils.bindProperty(undoButton, 'enabled', diagram, ['historyManager', 'undoEnabled']);
			BindingUtils.bindProperty(redoButton, 'enabled', diagram, ['historyManager', 'redoEnabled']);
			BindingUtils.bindProperty(zoomInButton, 'enabled', diagram, 'zoomInEnabled');
			BindingUtils.bindProperty(zoomOutButton, 'enabled', diagram, 'zoomOutEnabled');
		}
	}
	
}