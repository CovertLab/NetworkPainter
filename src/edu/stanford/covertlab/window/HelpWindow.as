package edu.stanford.covertlab.window 
{
	import mx.containers.HDividedBox;
	import mx.containers.TitleWindow;
	import mx.controls.TextArea;
	import mx.controls.Tree;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;	
	
	/**
	 * PopUp window displaying help for an application. Left-side of window has tree
	 * of help section headings. Right-side of window displays the content of the selected
	 * help section.
	 * 
	 * <p>Help data must be of type HelpSection.</p>
	 * 
	 * @see HelpSection
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class HelpWindow extends TitleWindow
	{
		[Embed(source = '../image/help.png')] private var myIcon:Class;
		
		private var application:Application;
		private var helpData:HelpSection;
		private var aboutData:Object;
		private var hDividedBox:HDividedBox = new HDividedBox();
		private var tree:Tree = new Tree();
		private var textArea:TextArea = new TextArea();
				
		public function HelpWindow(application:Application, helpData:HelpSection, aboutData:Object) 
		{	
			titleIcon = myIcon;
			
			this.application = application;
			this.helpData = helpData;
			this.aboutData = aboutData;			
		
			//style
			width = 800;
			height = 600;
			title = aboutData.applicationName + ' Help';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			setStyle('horizontalAlign', 'center');
			setStyle('verticalAlign', 'center');
			
			//data
			helpData.label = title;
			
			//children
			hDividedBox.percentWidth = 100;
			hDividedBox.percentHeight = 100;
			addChild(hDividedBox);
			
			tree.percentWidth = 25;
			tree.percentHeight = 100;
			tree.labelField = 'label';
			tree.showRoot = false;
			tree.dataProvider = helpData;
			tree.addEventListener(ListEvent.CHANGE, treeChanged);
			hDividedBox.addChild(tree);
			
			textArea.percentWidth = 75;
			textArea.percentHeight = 100;
			textArea.editable = false;
			textArea.htmlText = helpData.htmlText(aboutData);
			hDividedBox.addChild(textArea);
		}
		
		public function open():void {
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function close(event:CloseEvent):void {
			PopUpManager.removePopUp(this);
		}
		
		private function treeChanged(event:ListEvent):void {
			textArea.htmlText = tree.selectedItem.htmlText(aboutData);	
		}
		

		
	}
	
}