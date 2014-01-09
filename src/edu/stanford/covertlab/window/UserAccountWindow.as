package edu.stanford.covertlab.window 
{
	import edu.stanford.covertlab.manager.UserManager;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window which allows to review and edit their user profile (name, email,
	 * affiliation, PI, etc.). When the user clicks save the saveUser method of the
	 * UserManager is called and the user's changes are committed to the user 
	 * database.
	 * 
	 * @see edu.stanford.covertlab.manager.UserManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */	
	public class UserAccountWindow extends TitleWindow
	{
		private var userManager:UserManager;
		private var application:Application;
		
		private var firstname:TextInput;
		private var lastname:TextInput;
		private var email:TextInput;
		private var principalinvestigator:TextInput;
		private var organization:TextInput;
		
		public function UserAccountWindow(application:Application, userManager:UserManager) 
		{
			var form:Form;
			var formItem:FormItem;
			var textInput:TextInput;			
			var controlBar:ControlBar;			
			var button:Button;
						
			this.application = application;
			this.userManager = userManager;			
			
			//style
			title = 'User Account';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//children
			form = new Form();			
			form.styleName = 'TitleWindowForm';
			addChild(form);
					
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'First Name';
			firstname = new TextInput();
			firstname.maxChars = 255;
			firstname.restrict='\u0020-\u007E';
			firstname.styleName = 'TitleWindowTextInput';
			firstname.width = 150;
			firstname.height = 14;
			formItem.addChild(firstname);			
			form.addChild(formItem);
		
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Last Name';
			lastname = new TextInput();
			firstname.maxChars = 255;
			firstname.restrict='\u0020-\u007E';
			lastname.styleName = 'TitleWindowTextInput';
			lastname.width = 150;
			lastname.height = 14;
			formItem.addChild(lastname);
			form.addChild(formItem);
		
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Email';
			email = new TextInput();
			email.maxChars = 255;
			email.restrict='\u0020-\u007E';
			email.styleName = 'TitleWindowTextInput';
			email.width = 150;
			email.height = 14;
			email.editable = false;
			email.enabled = false;
			formItem.addChild(email);			
			form.addChild(formItem);
		
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'PI';
			principalinvestigator = new TextInput();
			principalinvestigator.maxChars = 255;
			principalinvestigator.restrict='\u0020-\u007E';
			principalinvestigator.styleName = 'TitleWindowTextInput';
			principalinvestigator.width = 150;
			principalinvestigator.height = 14;
			formItem.addChild(principalinvestigator);			
			form.addChild(formItem);
		
			formItem = new FormItem();
			formItem.styleName = 'PrettyTightPopUpFormItem';
			formItem.label = 'Organization';
			organization = new TextInput();
			organization.maxChars = 255;
			organization.restrict='\u0020-\u007E';
			organization.styleName = 'TitleWindowTextInput';
			organization.width = 150;
			organization.height = 14;
			formItem.addChild(organization);			
			form.addChild(formItem);
			
			controlBar = new ControlBar();
			addChild(controlBar);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.height = 16;
			button.label = 'Save';
			button.addEventListener(MouseEvent.CLICK, save);
			controlBar.addChild(button);
			
			//binding
			BindingUtils.bindProperty(firstname, 'text', userManager, 'firstname');
			BindingUtils.bindProperty(lastname, 'text', userManager, 'lastname');
			BindingUtils.bindProperty(email, 'text', userManager, 'email');
			BindingUtils.bindProperty(principalinvestigator, 'text', userManager, 'principalinvestigator');
			BindingUtils.bindProperty(organization, 'text', userManager, 'organization');
		}
	
		public function open():void {
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function save(event:MouseEvent):void {
			userManager.firstname = firstname.text;
			userManager.lastname = lastname.text;
			userManager.email = email.text;
			userManager.principalinvestigator = principalinvestigator.text;
			userManager.organization = organization.text;
			
			userManager.saveUser();
		}
		
		public function close(event:CloseEvent = null):void {
			firstname.text = userManager.firstname;
			lastname.text = userManager.lastname;
			email.text = userManager.email;
			principalinvestigator.text = userManager.principalinvestigator;
			organization.text = userManager.organization;
			
			PopUpManager.removePopUp(this);
		}
	}
	
}