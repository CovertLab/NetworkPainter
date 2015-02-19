package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.controls.ThumbnailTileList;
	import edu.stanford.covertlab.controls.ToolBarButton;
	import edu.stanford.covertlab.networkpainter.manager.NetworkManager;
	import edu.stanford.covertlab.service.KEGG;
	import edu.stanford.covertlab.service.Reactome;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import mx.binding.utils.BindingUtils;
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * Provides a window for a user to select a pathway to import from a database. Displays 
	 * a list of available pathways (name, category, last updated) as a datagrid. Displays
	 * preview images of a pathway upon selection in the datagrid. Loads a pathway into the 
	 * diagram through the network manager upon pathway selection. Uses either the KEGG, or 
	 * Reactome classes to populate the list of available pathways, to load a pathway, and 
	 * to provide a URL for a preview image of a pathway.
	 * 
	 * @see edu.stanford.covertlab.service.KEGG
	 * @see edu.stanford.covertlab.service.Reactome
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ImportNetworkWindow extends TitleWindow
	{
		private var application:Application;
		private var networkManager:NetworkManager;
		
		private var database:String;
		private var kegg:KEGG;
		private var reactome:Reactome;
		
		private var viewStack:ViewStack;
		private var tileList:ThumbnailTileList;
		private var dataGrid:DataGrid;
		private var thumbnailsButton:ToolBarButton;
		private var detailsButton:ToolBarButton;
		
		[Embed(source = '../../image/application_view_tile.png')] private var thumbnailsImg:Class;
		[Embed(source = '../../image/application_view_detail.png')] private var detailsImg:Class;
		
		public function ImportNetworkWindow(application:Application, networkManager:NetworkManager)
		{
		
			var controlBar:ControlBar;
			var dataGridColumns:Array = [];
			var dataGridColumn:DataGridColumn;
			var hBox:HBox;
			var vBox:VBox;
			var button:Button;
			
			this.application = application;
			this.application = application;
			this.networkManager = networkManager;
			
			//webservices
			kegg = new KEGG();			
			kegg.addEventListener(KEGG.KEGG_LISTPATHWAYS, listPathwaysHandler);
			kegg.addEventListener(KEGG.KEGG_GETPATHWAY, importPathwayHandler);
			kegg.addEventListener(KEGG.KEGG_FAULT, webserviceErrorHandler);
			
			reactome = new Reactome();			
			reactome.addEventListener(Reactome.REACTOME_LISTPATHWAYS, listPathwaysHandler);
			reactome.addEventListener(Reactome.REACTOME_GETPATHWAY, importPathwayHandler);
			reactome.addEventListener(Reactome.REACTOME_FAULT, webserviceErrorHandler);
			
			//style
			title = 'Import Network';
			layout = 'vertical';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//views
			hBox = new HBox();
			hBox.percentWidth = 100;
			hBox.setStyle('horizontalAlign', 'right');			
			addChild(hBox);
			
			thumbnailsButton = new ToolBarButton('Thumbnails', thumbnailsImg, null, new ColorMatrixFilter([
					0.8,0,0,0,0,
					0,0.8,0,0,0,
					0,0,0.8,0,0,
					0, 0, 0, 1, 0]));
			thumbnailsButton.enabled = false;
			thumbnailsButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { viewStack.selectedIndex = 0; } );
			hBox.addChild(thumbnailsButton);
			
			detailsButton = new ToolBarButton('Details', detailsImg, null, new ColorMatrixFilter([
					0.8,0,0,0,0,
					0,0.8,0,0,0,
					0,0,0.8,0,0,
					0, 0, 0, 1, 0]));
			detailsButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { viewStack.selectedIndex = 1; } );
			hBox.addChild(detailsButton);
			
			//view stack
			viewStack = new ViewStack();
			viewStack.width = 768;
			viewStack.height = 502;
			viewStack.addEventListener(IndexChangedEvent.CHANGE, changeView);
			viewStack.setStyle('paddingTop', 0);
			viewStack.setStyle('paddingBottom', 0);
			viewStack.setStyle('paddingLeft', 0);
			viewStack.setStyle('paddingRight', 0);
			viewStack.setStyle('horizontalAlign', 'right');
			viewStack.setStyle('tabHeight', 16);
			addChild(viewStack);
			
			//preview
			vBox = new VBox();
			vBox.percentWidth = 100;
			vBox.percentHeight = 100;
			viewStack.addChild(vBox);
			
			tileList = new ThumbnailTileList();
			tileList.columnCount = 3;
			tileList.rowCount = 2;
			tileList.rowHeight = 250;
			tileList.columnWidth = 250;
			vBox.addChild(tileList);
			
			var thumbnailFactory:ClassFactory = new ClassFactory(ImportNetworkWindow_ThumbnailTileListItemRenderer);
			thumbnailFactory.properties = { importNetworkWindow:this };
			tileList.itemRenderer = thumbnailFactory;
			
			//details view
			vBox = new VBox();
			vBox.percentWidth = 100;
			vBox.percentHeight = 100;
			viewStack.addChild(vBox);
			
			dataGrid = new DataGrid();
			dataGrid.styleName = 'TitleWindowDataGrid';
			dataGrid.percentWidth = 100;
			dataGrid.percentHeight = 100;
			dataGrid.headerHeight = 14;
			dataGrid.rowHeight = 14;
			vBox.addChild(dataGrid);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Category';
			dataGridColumn.width = 100;
			dataGridColumn.dataField = 'category';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Name';
			dataGridColumn.width = 100;
			dataGridColumn.dataField = 'name';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Last Updated';
			dataGridColumn.width = 100;
			dataGridColumn.dataField = 'lastUpdated';
			dataGridColumns.push(dataGridColumn);
										
			dataGrid.columns = dataGridColumns;
			
			tileList.doubleClickEnabled = true;
			dataGrid.doubleClickEnabled = true;
			tileList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, importPathway);
			dataGrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, importPathway);
			
			//control bar
			controlBar = new ControlBar();
			addChild(controlBar);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.height = 16;
			button.label = 'Open';
			button.addEventListener(MouseEvent.CLICK, importPathway);
			controlBar.addChild(button);
			
			BindingUtils.bindSetter(function(value:int):void { button.enabled = (value > -1); }, tileList, 'selectedIndex');
			BindingUtils.bindSetter(function(value:int):void { button.enabled = (value > -1); }, dataGrid, 'selectedIndex');	
			
		}
		
		public function open(database:String):void {
			this.database = database;
			tileList.selectedIndex = -1;
			dataGrid.selectedIndex = -1;
			switch(database) {
				case 'kegg': 
					title = 'Import Pathway from KEGG';
					kegg.listPathways(); 
					break;
				case 'reactome': 
					title = 'Import Pathway from Reactome';
					reactome.listPathways(); 
					break;
			}
			
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function listPathwaysHandler(event:Event):void {
			switch(database) {
				case 'kegg': 
					dataGrid.dataProvider = kegg.pathways; 
					tileList.dataProvider = kegg.pathways; 
					break;
				case 'reactome': 
					dataGrid.dataProvider = reactome.pathways;
					tileList.dataProvider = reactome.pathways;
					break;
			}			
		}		
		
		private function importPathway(event:Event):void {
			var pathway:Object = (viewStack.selectedIndex == 0 ? tileList.selectedItem : dataGrid.selectedItem);
			switch(database) {
				case 'kegg':
					kegg.getPathway(pathway);
					break;
				case 'reactome':
					reactome.getPathway(pathway);
					break;
			}
		}
		
		private function importPathwayHandler(event:Event):void {			
			var network:Object;
			switch(database) {
				case 'kegg':
					network = kegg.pathway;
					break;
				case 'reactome':
					network = reactome.pathway;
					break;
			}
			networkManager.fromObject(network, false, false, false, false);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
	 
		public function close(event:Event=null):void{
			PopUpManager.removePopUp(this);
		}
		
		/**************************************************
		 * preview source
		 * ***********************************************/	
		public function previewSource(pathway:Object):String {
			switch(database) {
				case 'kegg':
					return kegg.previewSource(pathway);
				case 'reactome':
					return reactome.previewSource(pathway);
			}			
			return null;
		}
		
		/**************************************************
		 * change view
		 * ***********************************************/		
		private function changeView(event:IndexChangedEvent):void {
			if (event.target.selectedIndex == 0 ) {
				tileList.selectedItem = dataGrid.selectedItem;
				thumbnailsButton.enabled = false;
				detailsButton.enabled = true;
			}else {
				dataGrid.selectedItem = tileList.selectedItem;
				thumbnailsButton.enabled = true;
				detailsButton.enabled = false;
			}
		}	
		
		/********************************************************************
		 * error handler
		 * *****************************************************************/
		private function webserviceErrorHandler(event:Event):void {
			var title:String;
			switch(database) {
				case 'kegg': 
					title = 'KEGG';
					break;
				case 'reactome':
					title = 'Reactome';
					break;
			}
			Alert.show('Please retry last action.', title + ' Error');			
		}
		
		
	}	
}