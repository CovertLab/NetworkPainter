package edu.stanford.covertlab.window 
{
	import mx.containers.TitleWindow;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window displaying metadata about an application (name, version, release date,
	 * list of developers, etc.).
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AboutWindow extends TitleWindow
	{
		[Embed(source = '../image/information.png')] private var myIcon:Class;
		
		private var application:Application;
		
		public function AboutWindow(application:Application, aboutData:Object)
		{
			titleIcon = myIcon;
			var newLabel:Label;
			var newText:Text;
			var i:uint;
			
			this.application = application;
			
			//properties
			title = 'About ' + aboutData.applicationName;
			showCloseButton = true;
			setStyle('horizontalAlign', 'center');
			setStyle('verticalAlign', 'center');			
			setStyle('paddingBottom', 8);
			setStyle('paddingBottom', 10);
			setStyle('paddingLeft', 30);
			setStyle('paddingRight', 30);
			setStyle('verticalGap',10);
			addEventListener(CloseEvent.CLOSE, close);
			
			//application name
			newLabel = new Label();
			newLabel.text = aboutData.applicationName;
			newLabel.setStyle('fontSize', 20);
			newLabel.setStyle('fontWeight', 'bold');
			newLabel.setStyle('paddingBottom', -14);
			addChild(newLabel);
			
			//version, release date
			newText = new Text();
			newText.htmlText = '<p align="center">Version: ' + aboutData.version+'\nReleased: '+aboutData.releaseDate+'</p>';
			addChild(newText);
			
			//developers
			newText = new Text();
			newText.htmlText = '<p align="center"><b>Development Team</b>';
			for (i = 0; i < aboutData.developers.length; i++) newText.htmlText += '\n'+aboutData.developers[i].foreName + ' ' + aboutData.developers[i].lastName;
			newText.htmlText += '</p>';
			addChild(newText);
		}
		
		public function open():void {
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
 
		private function close(event:CloseEvent):void{
		  PopUpManager.removePopUp(this);
		}
		
	}
	
}