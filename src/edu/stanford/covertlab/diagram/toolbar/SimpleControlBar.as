package edu.stanford.covertlab.diagram.toolbar 
{
	import edu.stanford.covertlab.controls.ToolBarButton;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.containers.HBox;
	import mx.controls.Spacer;
	
	/**
	 * Simplified control toolbar for viewer. Contains zoom controls. Also contains button for opening meta data window.
	 * 
	 * @see edu.stanford.covertlab.networkpainter.Viewer
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class SimpleControlBar extends HBox
	{
		
		[Embed(source = '../../image/zoom_in.png')] private var zoomInImg:Class;
		[Embed(source = '../../image/zoom_out.png')] private var zoomOutImg:Class;
		[Embed(source = '../../image/zoom.png')] private var zoomResetImg:Class;
		[Embed(source = '../../image/zoom_fit.png')] private var zoomFitImg:Class;
		[Embed(source = '../../image/help.png')] private var aboutImg:Class;
		
		private var diagram:Diagram;
		private var zoomInButton:ToolBarButton;
		private var zoomOutButton:ToolBarButton;
		private var zoomResetButton:ToolBarButton;
		private var zoomFitButton:ToolBarButton;
		private var aboutButton:ToolBarButton;
		
		public function SimpleControlBar(diagram:Diagram) 
		{
			this.diagram = diagram;
			
			percentWidth = 100;
			styleName = 'dockingArea';
			setStyle('paddingTop', 4);
			setStyle('paddingBottom', 4);
			setStyle('paddingLeft', 4);
			setStyle('paddingRight', 4);
			visible = !diagram.editingEnabled || diagram.fullScreenMode;
			addEventListener(MouseEvent.ROLL_OVER, rollOver);
			addEventListener(MouseEvent.ROLL_OUT, rollOut);		
			
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
			
			BindingUtils.bindProperty(zoomInButton, 'enabled', diagram, 'zoomInEnabled');
			BindingUtils.bindProperty(zoomOutButton, 'enabled', diagram, 'zoomOutEnabled');
			
			var spacer:Spacer = new Spacer();
			spacer.percentWidth = 100;
			addChild(spacer);
			
			aboutButton = new ToolBarButton('About', aboutImg);
			aboutButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { parentApplication.aboutWindow.open(); } );
			addChild(aboutButton);			
		}
		
		private function rollOver(event:MouseEvent):void {
			if(diagram.fullScreenMode) alpha = 1;
		}
		
		private function rollOut(event:MouseEvent):void {
			if(diagram.fullScreenMode) alpha = 0;
		}
		
	}
	
}