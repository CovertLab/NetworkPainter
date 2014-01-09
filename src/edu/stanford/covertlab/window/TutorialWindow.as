package edu.stanford.covertlab.window 
{
	import mx.collections.ArrayCollection;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.List;
	import mx.controls.SWFLoader;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;	
	
	/**
	 * PopUp window which displays the tutorial for an application. Left-side of window has 
	 * list of tutorials. Right-side of window displays the content of the selected tutorial.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/6/2009
	 */
	public class TutorialWindow extends TitleWindow
	{
		[Embed(source = '../image/information.png')] private var myIcon:Class;		
		
		private var application:Application;
		private var tutorialData:Object;
		private var aboutData:Object;
		private var list:List = new List();
		private var vBox:VBox = new VBox();
		private var videoDisplay:SWFLoader = new SWFLoader();
		private var textArea:TextArea = new TextArea();
		
		public function TutorialWindow(application:Application, tutorialData:Object, aboutData:Object) 
		{
			titleIcon = myIcon;
			this.application = application;
			this.tutorialData = tutorialData;
			this.aboutData = aboutData;			
			
			//style
			title = aboutData.applicationName + ' Tutorial';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			setStyle('horizontalAlign', 'center');
			setStyle('verticalAlign', 'center');
			layout = 'horizontal';
			
			//children		
			list.width = 200;
			list.percentHeight = 100;
			list.labelField = 'title';
			list.dataProvider = tutorialData.tutorials;
			list.addEventListener(ListEvent.CHANGE, listChanged);
			addChild(list);
			
			vBox.setStyle('verticalGap', 10);
			vBox.setStyle('horizontalAlign', 'center');
			addChild(vBox);
			
			videoDisplay.width = 800;
			videoDisplay.height = 616;
			videoDisplay.setStyle('horizontalAlign', 'center');
			videoDisplay.setStyle('verticalAlign', 'top');
			vBox.addChild(videoDisplay);
			
			textArea.percentWidth = 100;
			textArea.height = 50;
			textArea.editable = false;
			vBox.addChild(textArea);
		}
		
		public function open():void {
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function close(event:CloseEvent):void {
			PopUpManager.removePopUp(this);
		}
		
		private function listChanged(event:ListEvent):void {
			//update video
			videoDisplay.unloadAndStop();
			videoDisplay.load(list.selectedItem.url);
			
			//update text area
			var text:String = list.selectedItem.description;
			text = text.replace(/[\n\t]/g, ' ').replace(/\s+/g, ' ');
			text = text.replace(/<\/p>/g, '</p><br/>');
			text = text.replace(/<ul>/g, '<textformat blockindent="-18">').replace(/<\/ul><\/p><br\/>/g,'</textformat></p>').replace(/<\/ul>/g, '</textformat>');
			text = text.replace(/<contact\/>/g, '<a href="mailto:' + aboutData.email +'">' + aboutData.email + '</a>');
			text = text.replace(/<applicationName\/>/g, aboutData.applicationName);		
			textArea.htmlText = text;			
		}	
	}
	
}