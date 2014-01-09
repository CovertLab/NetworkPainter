package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.networkpainter.manager.NetworkManager;
	import flash.events.MouseEvent;
	import mx.collections.ArrayCollection;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window allows the user to save the current network to the database. 
	 * Network can be saved with a new name, or to save a new network to the database 
	 * (eg. one that was not loaded from the database but was constructed from scratch, 
	 * from XML import, or from import from a pathway database).
	 * 
	 * <p>PopUp window provides a text input for the user to input the desired name of the
	 * network.</p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class SaveAsNetworkWindow extends TitleWindow
	{
		private var application:Application;
		private var networkManager:NetworkManager;
		
		private var networkName:TextInput;
		private var networkDesc:TextArea;
		private var pubstatus:ComboBox;
		
		public function SaveAsNetworkWindow(application:Application, networkManager:NetworkManager) 
		{
			var form:Form;
			var formItem:FormItem;
			var textInput:TextInput;
			var textArea:TextArea;
			var controlBar:ControlBar;
			var button:Button;
			
			this.application = application;
			this.networkManager = networkManager;
			
			//style
			title = 'Save Network As';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);

			form = new Form();
			form.styleName = 'TitleWindowForm';
			addChild(form);
			
			formItem = new FormItem();
			formItem.label = 'Name';
			formItem.styleName = 'TitleWindowFormItem';
			networkName = new TextInput();
			networkName.restrict='\u0020-\u007E';
			networkName.maxChars = 255;
			networkName.styleName = 'TitleWindowTextInput';
			networkName.width = 150;
			networkName.height = 14;
			formItem.addChild(networkName);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Description';
			formItem.styleName = 'TitleWindowFormItem';
			networkDesc = new TextArea();
			networkDesc.restrict='\u0020-\u007E';
			networkDesc.maxChars = 65535;
			networkDesc.styleName = 'TitleWindowTextInput';
			networkDesc.width = 150;
			networkDesc.height = 30;
			formItem.addChild(networkDesc);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Public?';
			formItem.styleName = 'TitleWindowFormItem';
			formItem.setStyle('paddingTop', 4);
			formItem.setStyle('paddingBottom', 2);
			pubstatus = new ComboBox();
			pubstatus.labelField = 'label';
			pubstatus.dataProvider = new ArrayCollection([ { label:'No', value:'No' }, { label:'Yes', value:'Yes' } ]);
			pubstatus.selectedIndex = 0;
			pubstatus.styleName = 'TitleWindowComboBox';
			pubstatus.width = 150;
			pubstatus.height = 14;
			formItem.addChild(pubstatus);
			form.addChild(formItem);
			
			controlBar = new ControlBar();
			addChild(controlBar);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.height = 16;
			button.label = 'Save As';
			button.addEventListener(MouseEvent.CLICK, saveAsNetwork);
			controlBar.addChild(button);
		}
		
		public function open():void {
			networkName.text = '';
			networkDesc.text = '';
			pubstatus.selectedIndex = 0;
			
			PopUpManager.addPopUp(this, application, true);
			PopUpManager.centerPopUp(this);
		}
		
		private function saveAsNetwork(event:MouseEvent):void {
			if (networkName.text == "") {
				networkName.setStyle('borderColor', 0xFF0000);
				networkName.errorString = 'Select a network name.';
				return;
			}
			networkManager.saveAsNetwork(networkName.text, networkDesc.text, pubstatus.selectedItem.value);
			close();
		}

		private function close(event:CloseEvent=null):void{
			PopUpManager.removePopUp(this);
		}
	}
	
}

