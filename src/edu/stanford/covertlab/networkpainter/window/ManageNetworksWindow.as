package edu.stanford.covertlab.networkpainter.window 
{
	import caurina.transitions.properties.TextShortcuts;
	import edu.stanford.covertlab.networkpainter.manager.NetworkManager;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.List;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window which allows management of networks a user has access to.
	 * <ul>
	 * <li>rename network</li>
	 * <li>edit network description</li>
	 * <li>edit user permissions to a network (must have owner priviledges).</li>
	 * <li>delete network</li>
	 * </ul>
	 * 
	 * <p>User must have write access and network must not be locked by another user 
	 * to do these operations. Otherwise users will only be able to review the names
	 * and descriptions of the networks they have access to, and will not be able to 
	 * committ changes to the database.</p>
	 * 
	 * <p>Data is loaded from and saved to the NetworkManager.</p>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ManageNetworksWindow extends TitleWindow
	{
		private var application:Application;
		private var networkManager:NetworkManager;
		
		private var networksList:List;
		private var form:Form;
		private var networkName:TextInput;
		private var networkDescription:TextArea;
		private var networkPublic:ComboBox;
		private var networkPermissions:DataGrid;		
		private var saveButton:Button;
		private var deleteButton:Button;
		private var formEnabled:Boolean;
		private var _editable:Boolean;
		
		public var errorMsg:Text;
		
		public function ManageNetworksWindow(application:Application, networkManager:NetworkManager) 
		{
			var controlBar:ControlBar;
			var formItem:FormItem;
			var dataGridColumns:Array = [];
			var dataGridColumn:DataGridColumn;
			
			this.application = application;
			this.networkManager = networkManager;
			
			//style
			title = 'Manage Networks';
			layout = 'horizontal';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//children
			networksList = new List();			
			networksList.width = 150;
			networksList.rowHeight = 14;
			networksList.styleName = 'TitleWindowList';
			networksList.percentHeight = 100;
			networksList.labelField = 'name';
			networksList.addEventListener(ListEvent.CHANGE, itemChangeHandler);
			BindingUtils.bindProperty(networksList, 'dataProvider', networkManager, 'networks');
			addChild(networksList);
	
			form = new Form();
			form.styleName = 'TitleWindowForm';
			form.percentHeight = 100;
			addChild(form);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = 'Name';
			networkName = new TextInput();
			networkName.restrict = '\u0020-\u007E';
			networkName.maxChars = 255;
			networkName.width = 200
			networkName.height = 14;
			networkName.styleName = 'TitleWindowTextInput';
			formItem.addChild(networkName);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = 'Description';
			networkDescription = new TextArea();
			networkDescription.restrict = '\u0020-\u007E';
			networkDescription.maxChars = 65535;
			networkDescription.width = 200
			networkDescription.height = 100;
			networkDescription.styleName = 'TitleWindowTextArea';
			formItem.addChild(networkDescription);
			form.addChild(formItem);
		
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.setStyle('paddingTop', 4);
			formItem.setStyle('paddingBottom', 4);
			formItem.label = 'Public';
			networkPublic = new ComboBox();
			networkPublic.width = 200
			networkPublic.height = 14;
			networkPublic.styleName = 'TitleWindowComboBox';
			networkPublic.labelField = 'label';
			networkPublic.dataProvider = new ArrayCollection([ { label:'No', value:'No' }, { label:'Yes', value:'Yes' } ]);
			formItem.addChild(networkPublic);
			form.addChild(formItem);

			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = 'Permissions';
			networkPermissions = new DataGrid();			
			networkPermissions.width = 200;
			networkPermissions.rowHeight = 14;
			networkPermissions.headerHeight = 14;
			networkPermissions.styleName = 'TitleWindowDataGrid';
			networkPermissions.verticalScrollPolicy = 'on';
			networkPermissions.editable = true;		
			BindingUtils.bindProperty(networkPermissions, 'dataProvider', networkManager, 'networkPermissions');
			formItem.addChild(networkPermissions);
			form.addChild(formItem);

			dataGridColumn = new DataGridColumn();			
			dataGridColumn.headerText = 'User Name';
			dataGridColumn.dataField = 'user';
			dataGridColumn.editable = false;
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Permissions';
			dataGridColumn.dataField = 'permissions';
			dataGridColumn.editorDataField = 'value';
			dataGridColumn.labelFunction = PermissionsLabel;
			dataGridColumn.itemEditor = new ClassFactory(ManageNetworksWindow_DataGridColumn_PermissionsEditor);
			dataGridColumns.push(dataGridColumn);				
					
			networkPermissions.columns = dataGridColumns;
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.setStyle('paddingTop', 8);
			formItem.setStyle('paddingBottom', 4);
			formItem.percentWidth = 100;
			form.addChild(formItem);
			
			var hBox:HBox = new HBox();
			hBox.percentWidth = 100;
			formItem.addChild(hBox);
			
			errorMsg = new Text();
			errorMsg.setStyle('color', 0xFF0000);
			errorMsg.percentWidth = 100;
			hBox.addChild(errorMsg);
			
			saveButton = new Button();
			saveButton.styleName = 'TitleWindowButton';
			saveButton.height = 16;
			saveButton.label = 'Save';
			saveButton.addEventListener(MouseEvent.CLICK, saveNetwork);
			hBox.addChild(saveButton);	
			
			deleteButton = new Button();
			deleteButton.styleName = 'TitleWindowButton';
			deleteButton.height = 16;		
			deleteButton.label = 'Delete';
			deleteButton.addEventListener(MouseEvent.CLICK, deleteNetwork);
			hBox.addChild(deleteButton);	
			
			BindingUtils.bindProperty(saveButton, 'width', deleteButton, 'width');
		}
		
		public function open():void {
			networkManager.listNetworks();

			networksList.selectedIndex = -1;
			
			clearForm();
			
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function saveNetwork(event:MouseEvent):void {
			var network:Object = networksList.selectedItem;
			network.name = networkName.text;
			network.description = networkDescription.text;
			network.publicstatus = networkPublic.selectedItem.value;
			networkManager.saveNetworkProperties(network, networkPermissions.dataProvider as ArrayCollection);
		}
		
		private function deleteNetwork(event:MouseEvent):void {			
			networkManager.deleteNetwork(networksList.selectedItem);
			networksList.selectedIndex = -1;
			clearForm();
		}
		
		public function close(event:CloseEvent = null):void {
			clearForm();
			PopUpManager.removePopUp(this);
		}
		
		private function itemChangeHandler(event:ListEvent):void {
			errorMsg.text = '';
			if (networksList.selectedItem != null) {
				formEnabled = form.enabled = !(networksList.selectedItem.permissions == 'r' || networksList.selectedItem.locked || networkManager.id == networksList.selectedItem.id);
				networkName.text = networksList.selectedItem.name;
				networkDescription.text = networksList.selectedItem.description;
				networkPublic.selectedIndex = (networksList.selectedItem.publicstatus=='No' ? 0 : 1);
				networkManager.getNetworkPermissions(networksList.selectedItem.id);
				networkPermissions.enabled = deleteButton.enabled = (networksList.selectedItem.permissions == 'o');
			}else {
				clearForm();
			}
		}
		
		private function clearForm():void {
			formEnabled = form.enabled = false;
			networkName.text = '';
			networkDescription.text = '';
			networkPublic.selectedIndex = -1;
			networkPermissions.selectedIndex = -1;
			networkManager.getNetworkPermissions();
			errorMsg.text = '';
		}		
		
		public function get editable():Boolean {
			return _editable;
		}
		public function set editable (value:Boolean):void {
			if (_editable != value) {
				_editable = value;
				if (networksList) networksList.enabled = value;
				if (form) form.enabled = value && formEnabled;
			}
		}
		
		private function PermissionsLabel(item:Object, col:DataGridColumn):String {
			if (item == null) return '';
			var text:String;
			switch(item.permissions) {		
				case 'o': 
					text = 'Owner';
					break;
				case 'r': 
					text = 'Reader'; 
					break;
				case 'w': 
					text = 'Writer';
					break;			
				case 'n': 
				default:
					text = 'None'; 
					break;
			}
			return text;
		}
		
	}
	
}

import mx.controls.ComboBox;
class ManageNetworksWindow_DataGridColumn_PermissionsEditor extends ComboBox
{
	public function ManageNetworksWindow_DataGridColumn_PermissionsEditor()
	{
		editable = false;
		labelField = 'label';	
		dataProvider = [
			{label:'None', value:'n' },
			{label:'Owner', value:'o' },
			{label:'Reader', value:'r' },
			{label:'Write', value:'w' } ];
	}
	
	//private var _val:Object;
	override public function get value():Object {
		return selectedItem.value;
	}
	
	override public function set data(value:Object):void {  
		super.data = value;
		if (value) {
			switch(value.permissions) {
				case 'o':
					selectedIndex = 1;
					break;
				case 'r': 
					selectedIndex = 2; 
					break;
				case 'w': 
					selectedIndex = 3;
					break;			
				case 'n': 
				default:
					selectedIndex = 0;
					break;
			}
		}else {
			selectedIndex = -1;
		}
	}
}