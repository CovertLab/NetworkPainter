package edu.stanford.covertlab.diagram.window 
{
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window user interface for searching through the list of biomolecules for a biomolecule with a matching name or label.
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Biomolecule
	 * @see edu.stanford.covertlab.diagram.core.Diagram
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class FindBiomoleculeWindow extends TitleWindow
	{
		private var diagram:Diagram;
		private var field:TextInput = new TextInput();
		private var errorMsg:Text;
		[Embed(source = '../../image/biomolecule.png')] private var myIcon:Class;
		public function FindBiomoleculeWindow(diagram:Diagram) 
		{
			titleIcon = myIcon;
			
			this.diagram = diagram;
			
			//set title
			title = 'Find Biomolecule';
			
			//setup close button
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//set layout
			layout = 'horizontal';
			
			//setup children
			var form:Form = new Form();
			form.styleName = 'TitleWindowForm';
			addChild(form);
			
			var formItem:FormItem = new FormItem();
			formItem.label = 'Find';
			formItem.styleName = 'TitleWindowFormItem';
			form.addChild(formItem);

			field.restrict = '\u0020-\u007E';
			field.maxChars = 255;
			field.width = 100;
			field.height = 14;
			field.styleName = 'TitleWindowTextInput';
			field.setStyle('backgroundAlpha', 1);
			formItem.addChild(field);
			
			var controlBar:ControlBar = new ControlBar();
			addChild(controlBar);
			
			errorMsg = new Text();
			errorMsg.styleName = 'ErrorMsg';
			errorMsg.visible = false;
			errorMsg.percentWidth = 100;
			errorMsg.height = 14;
			controlBar.addChild(errorMsg);

			var button:Button = new Button();
			button.label = 'Find';
			button.height = 16;
			button.styleName = 'TitleWindowButton';
			button.addEventListener(MouseEvent.CLICK, findBiomolecule);
			controlBar.addChild(button);			
		}		
		
		public function open():void {
			PopUpManager.addPopUp(this, diagram, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function close(event:CloseEvent):void {
			PopUpManager.removePopUp(this);
		}
		
		private function findBiomolecule(event:MouseEvent):void {
			if (!diagram.findBiomolecule(field.text)) {
				errorMsg.text = 'Cannot find biomolecules with the name or label "' + field.text +'"';
				errorMsg.visible = true;
			}else {
				errorMsg.text = '';
				errorMsg.visible = false;
			}
		}
		
	}
	
}