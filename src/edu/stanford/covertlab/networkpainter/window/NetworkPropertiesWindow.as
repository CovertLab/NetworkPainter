package edu.stanford.covertlab.networkpainter.window 
{
	import br.com.stimuli.string.printf;
	import edu.stanford.covertlab.networkpainter.data.AboutData;
	import edu.stanford.covertlab.networkpainter.manager.ExperimentManager;
	import edu.stanford.covertlab.networkpainter.manager.NetworkManager;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.Accordion;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window diplaying the name and description of the current network.
	 * Also allows the user to edit the name and description of the current network.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class NetworkPropertiesWindow extends TitleWindow
	{
		private var application:Application;
		private var networkManager:NetworkManager;
		
		private var networkName:TextInput;
		private var networkDescription:TextArea;
		private var networkPublicstatus:ComboBox;
		private var networkPermissions:TextInput;
		private var networkPermalink:TextInput;
			
		public function NetworkPropertiesWindow(application:Application, networkManager:NetworkManager) 
		{			
			var accordion:Accordion;
			var form:Form;
			var formItem:FormItem;
			var textInput:TextInput;
			var controlBar:ControlBar;
			var button:Button;
			
			this.application = application;
			this.networkManager = networkManager;
			
			//style
			title = 'Network Properties';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//accordion
			accordion = new Accordion();
			accordion.height = 150;
			accordion.width = 285;
			accordion.styleName = 'TitleWindowAccordion';
			addChild(accordion);
			
			//basic properties (name, description, public status)
			form = new Form();
			form.percentWidth = 100;
			form.label = 'Basic';
			form.styleName = 'TitleWindowForm';
			form.setStyle('horizontalAlign', 'right');
			accordion.addChild(form);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Name';
			networkName = new TextInput();
			networkName.restrict = '\u0020-\u007E';
			networkName.maxChars = 255;
			networkName.styleName = 'TitleWindowTextInput';
			networkName.setStyle('horizontalAlign', 'right');
			networkName.width = 200;
			networkName.height = 14;
			networkName.enabled = false;
			formItem.addChild(networkName);			
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Description';
			networkDescription = new TextArea();
			networkDescription.maxChars = 65535;
			networkDescription.restrict='\u0020-\u007E';
			networkDescription.styleName = 'TitleWindowTextArea';
			networkDescription.width = 200;
			networkDescription.height = 60;
			formItem.addChild(networkDescription);			
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Public?';
			formItem.setStyle('paddingTop', 4);
			formItem.setStyle('paddingBottom', 2);
			networkPublicstatus = new ComboBox();
			networkPublicstatus.styleName = 'TitleWindowComboBox';
			networkPublicstatus.labelField = 'label';
			networkPublicstatus.dataProvider = new ArrayCollection([ { label:'No', value:'No' }, { label:'Yes', value:'Yes' } ]);
			networkPublicstatus.width = 200;
			networkPublicstatus.height = 14;
			formItem.addChild(networkPublicstatus);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Permalink';
			formItem.setStyle('paddingTop', 2);
			networkPermalink = new TextInput();
			networkPermalink.restrict = '\u0020-\u007E';
			networkPermalink.maxChars = 255;
			networkPermalink.styleName = 'TitleWindowTextInput';
			networkPermalink.setStyle('horizontalAlign', 'right');
			networkPermalink.width = 200;
			networkPermalink.height = 14;
			networkPermalink.editable = false;
			networkPermalink.enabled = false;
			formItem.addChild(networkPermalink);
			form.addChild(formItem);
			
			BindingUtils.bindProperty(networkName, 'text', networkManager, 'name');
			BindingUtils.bindProperty(networkDescription, 'text', networkManager, 'description');
			BindingUtils.bindSetter(function(value:String):void { 				
					networkPublicstatus.selectedIndex = (value == 'Yes') + 0;
				}, networkManager, 'publicstatus');
			BindingUtils.bindSetter(function(value:Object):void {
				networkPermalink.enabled = value.value == 'Yes';				
			}, networkPublicstatus, 'selectedItem');
			
			BindingUtils.bindSetter(function(networkID:uint):void {
				var aboutData:AboutData = new AboutData();
				networkPermalink.text = printf('%s/bin/view.php?networkID=%d', 
					aboutData.url, networkManager.id);
			}, networkManager, 'id');
			
			//details
			form = new Form();
			form.percentWidth = 100;	
			form.label = 'Details';
			form.styleName = 'TitleWindowForm';
			form.setStyle('horizontalAlign', 'right');
			accordion.addChild(form);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Owner';
			textInput = new TextInput();
			textInput.styleName = 'TitleWindowTextInput';
			textInput.width = 200;
			textInput.height = 14;
			textInput.enabled = false;
			BindingUtils.bindProperty(textInput, 'text', networkManager, 'owner');
			formItem.addChild(textInput);			
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Permissions';
			networkPermissions = new TextInput();
			networkPermissions.styleName = 'TitleWindowTextInput';
			networkPermissions.width = 200;
			networkPermissions.height = 14;
			networkPermissions.enabled = false;
			BindingUtils.bindSetter(function(value:String):void {
				switch(value) {
					case 'w': networkPermissions.text = 'Write'; break;
					case 'r': networkPermissions.text = 'Read'; break;
					case 'o': networkPermissions.text = 'Owner'; break;
					case 'a': networkPermissions.text = 'Administrator'; break;
					case 'n': networkPermissions.text = 'None'; break;
				}}, networkManager, 'permissions');
			formItem.addChild(networkPermissions);			
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Creation';
			textInput = new TextInput();
			textInput.styleName = 'TitleWindowTextInput';
			textInput.width = 200;
			textInput.height = 14;
			textInput.enabled = false;
			BindingUtils.bindProperty(textInput, 'text', networkManager, 'creation');
			formItem.addChild(textInput);			
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Last Save';
			textInput = new TextInput();
			textInput.styleName = 'TitleWindowTextInput';
			textInput.width = 200;
			textInput.height = 14;
			textInput.enabled = false;
			BindingUtils.bindProperty(textInput, 'text', networkManager, 'lastsave');
			formItem.addChild(textInput);			
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Locked User';
			textInput = new TextInput();
			textInput.styleName = 'TitleWindowTextInput';
			textInput.width = 200;
			textInput.height = 14;
			textInput.enabled = false;
			BindingUtils.bindProperty(textInput, 'text', networkManager, 'lockuser');
			formItem.addChild(textInput);			
			form.addChild(formItem);			
			
			controlBar = new ControlBar();
			addChild(controlBar);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.height = 16;
			button.label = 'Save';
			button.addEventListener(MouseEvent.CLICK, save);
			controlBar.addChild(button);			
		}
		
		public function open():void {
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function save(event:MouseEvent):void {
			networkManager.name = networkName.text;
			networkManager.description = networkDescription.text;
			networkManager.publicstatus = networkPublicstatus.selectedItem.value;
			close();
		}
		 
		private function close(event:Event = null):void {
			networkName.text = networkManager.name;
			networkDescription.text = networkManager.description;
			networkPublicstatus.selectedIndex = (networkManager.publicstatus=='No' ? 0 : 1);
			
			PopUpManager.removePopUp(this);
		}
	}
	
}