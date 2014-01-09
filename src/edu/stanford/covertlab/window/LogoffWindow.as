package edu.stanford.covertlab.window 
{
	import edu.stanford.covertlab.manager.UserManager;
	import flash.events.MouseEvent;
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window which prompts user whether or not they wish to logoff. If
	 * user selects cancel, the window closes and nothing happens. If the user
	 * selects logoff the logoff method of the user manager is called.
	 * 
	 * @see edu.stanford.covertlab.manager.UserManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class LogoffWindow extends TitleWindow
	{
		private var application:Application;
		private var userManager:UserManager;
		
		public function LogoffWindow(application:Application, userManager:UserManager) 
		{
			var label:Label;
			var controlBar:ControlBar;
			var button:Button;
			
			this.application = application;
			this.userManager = userManager;
			
			//style
			title = 'Exit?';
			
			//children
			label = new Label();
			label.text = 'Are you sure you want to exit?';
			label.setStyle('paddingBottom', -2);
			addChild(label);
			
			controlBar = new ControlBar();
			controlBar.setStyle('horizontalAlign', 'center');
			controlBar.setStyle('paddingTop', 0);
			addChild(controlBar);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.label = 'Exit';
			button.width = 45;
			button.height = 16;
			button.addEventListener(MouseEvent.CLICK, logoffUser);
			controlBar.addChild(button);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.label = 'Cancel';
			button.width = 45;
			button.height = 16;
			button.addEventListener(MouseEvent.CLICK, cancel);
			controlBar.addChild(button);
		}
		
		public function open():void {
			PopUpManager.addPopUp(this, application, true);
			PopUpManager.centerPopUp(this);
		}
		
		private function logoffUser(event:MouseEvent):void {
			userManager.logoffUser(event,false);
		}
		
		private function cancel(event:MouseEvent):void {
			PopUpManager.removePopUp(this);
		}
		
	}
	
}