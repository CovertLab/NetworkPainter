package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.controls.ThumbnailTileList;
	import edu.stanford.covertlab.controls.ToolBarButton;
	import edu.stanford.covertlab.networkpainter.event.NetworkManagerEvent;
	import edu.stanford.covertlab.networkpainter.manager.NetworkManager;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import mx.binding.utils.BindingUtils;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.HDividedBox;
	import mx.containers.TabNavigator;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.Image;
	import mx.controls.List;
	import mx.controls.listClasses.ListBase;
	import mx.controls.Text;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window displaying the list of networks, and the properties of those networks,
	 * that a user has access to. Left-side displays the names of the networks. Selecting
	 * a network, populates the form on the right-side with the properties of the selected
	 * network. Right-side also displays preview image of network. Clicking on the open button 
	 * in the bottom right triggers the NetworkManager to load the network from the database 
	 * into the diagram.
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class OpenNetworkWindow extends TitleWindow
	{
	
		private var application:Application;
		private var networkManager:NetworkManager;
		
		private var thumbnailsButton:ToolBarButton;
		private var detailsButton:ToolBarButton;
		
		private var viewStack:ViewStack;
		private var tileList:ThumbnailTileList;
		private var dataGrid:DataGrid;
		private var preview:Image;
		private var nameText:Text;
		private var descriptionText:Text;
		private var permissionsText:Text;
		private var publicText:Text;
		private var ownerText:Text;
		private var creationText:Text;
		private var lastSaveText:Text;
		private var lockedUserText:Text;		

		[Embed(source = '../../image/application_view_tile.png')] private var thumbnailsImg:Class;
		[Embed(source = '../../image/application_view_detail.png')] private var detailsImg:Class;		
		
		public function OpenNetworkWindow(application:Application, networkManager:NetworkManager) 		
		{			
			var controlBar:ControlBar;
			var button:Button;
			
			this.application = application;
			this.networkManager = networkManager;
			
			//style
			title = 'Open Network';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//views
			var hBox:HBox = new HBox();
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
			
			viewStack = new ViewStack();
			viewStack.width = 618;
			viewStack.height = 452;
			viewStack.addEventListener(IndexChangedEvent.CHANGE, changeView);
			viewStack.setStyle('paddingTop', 0);
			viewStack.setStyle('paddingBottom', 0);
			viewStack.setStyle('paddingLeft', 0);
			viewStack.setStyle('paddingRight', 0);
			viewStack.setStyle('horizontalAlign', 'right');
			viewStack.setStyle('tabHeight', 16);
			addChild(viewStack);
			
			setupThumbnailsView();
			setupDetailsView();
					
			BindingUtils.bindProperty(dataGrid, 'dataProvider', networkManager, 'networks');
			BindingUtils.bindProperty(tileList, 'dataProvider', networkManager, 'networks');
			
			tileList.doubleClickEnabled = true;
			dataGrid.doubleClickEnabled = true;
			tileList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, openNetwork);
			dataGrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, openNetwork);
			
			//control bar
			controlBar = new ControlBar();
			addChild(controlBar);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.height = 16;
			button.label = 'Open';			
			button.addEventListener(MouseEvent.CLICK, openNetwork);
			controlBar.addChild(button);
			
			BindingUtils.bindSetter(function(value:int):void { button.enabled = (value > -1); }, tileList, 'selectedIndex');
			BindingUtils.bindSetter(function(value:int):void { button.enabled = (value > -1); }, dataGrid, 'selectedIndex');			
		}
		
		/**************************************************
		 * construct views
		 * ***********************************************/
		
		private function setupThumbnailsView():void {
			var vBox:VBox = new VBox();
			vBox.label = 'Thumbnails';
			vBox.width = 618;
			vBox.height = 452;
			viewStack.addChild(vBox);

			tileList = new ThumbnailTileList();
			vBox.addChild(tileList);
			
			var thumbnailFactory:ClassFactory = new ClassFactory(OpenNetworkWindow_ThumbnailTileListItemRenderer);
			thumbnailFactory.properties = { networkManager:networkManager };
			tileList.itemRenderer = thumbnailFactory;			
		}
		
		private function setupDetailsView():void {
			var vBox:VBox;
			var dataGridColumns:Array = [];
			var dataGridColumn:DataGridColumn;			
			
			//box
			vBox = new VBox();
			vBox.label = 'Details';
			vBox.percentHeight = 100;
			vBox.percentWidth = 100;
			viewStack.addChild(vBox);
			
			//networks grid
			dataGrid = new DataGrid();
			dataGrid.styleName = 'TitleWindowDataGrid';
			dataGrid.percentWidth = 100;
			dataGrid.percentHeight = 100;
			dataGrid.headerHeight = 14;
			dataGrid.rowHeight = 14;			
			vBox.addChild(dataGrid);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Name';
			dataGridColumn.dataField = 'name';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Description';
			dataGridColumn.dataField = 'description';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Permissions';
			dataGridColumn.dataField = 'permissions';
			dataGridColumn.labelFunction = function(item:Object, column:DataGridColumn):String {
				switch(item.permissions) {
					case 'o': return 'Owner'
					case 'r': return 'Reader';
					case 'w': return 'Writer';
					case 'n': default: return '';
				}
			};
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Public?';
			dataGridColumn.dataField = 'publicstatus';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Owner';
			dataGridColumn.dataField = 'owner';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Creation';
			dataGridColumn.dataField = 'creation';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Last Saved';
			dataGridColumn.dataField = 'lastsave';
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Locked User';
			dataGridColumn.dataField = 'lockuser';
			dataGridColumns.push(dataGridColumn);
								
			dataGrid.columns = dataGridColumns;
		}
		
		/**************************************************
		 * open, close window
		 * ***********************************************/
		public function open():void {
			networkManager.listNetworks();
			
			dataGrid.selectedIndex = -1;
			tileList.selectedIndex = -1;
			
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function openNetwork(event:Event):void {			
			var network:Object = (viewStack.selectedIndex == 0 ? tileList.selectedItem : dataGrid.selectedItem);			
			networkManager.openNetwork(network);
		}
	 
		public function close(event:Event=null):void{
			PopUpManager.removePopUp(this);
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

	}
}