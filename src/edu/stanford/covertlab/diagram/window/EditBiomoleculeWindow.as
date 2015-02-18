package edu.stanford.covertlab.diagram.window 
{

	import edu.stanford.covertlab.controls.GreekKeyboard;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.BiomoleculeStyle;
	import edu.stanford.covertlab.diagram.core.CompartmentBase;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.util.HTML;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import mx.containers.Box;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.HRule;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;	
	import mx.skins.halo.ComboBoxArrowSkin;
	
	/**
	 * PopUp window user interface for editing a biomolecule.
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Biomolecule
	 * 
	 * @author Ed Chen, chened@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class EditBiomoleculeWindow extends TitleWindow
	{
		
		[Bindable] private var diagram:Diagram;
		
		private var nameInput:TextInput;
		private var labelInput:TextInput;
		private var regulationInput:TextInput;
		private var styleInput:ComboBox;
		private var commentsInput:TextArea;
		private var errorMsg:Text;
		private var biomolecule:Biomolecule;
		private var compartment:CompartmentBase;
		private var biomoleculeStyle:BiomoleculeStyle;
		private var biomoleculeX:Number;
		private var biomoleculeY:Number;
		[Embed(source = '../../image/biomolecule.png')] private var myIcon:Class;
		
		// if edit is false then the window is being called to add a new molecule
		public function EditBiomoleculeWindow(diagram:Diagram, biomolecule:Biomolecule = null) 		
		{	
			var formItem:FormItem;
			var greekKeyboard:GreekKeyboard;
			
			titleIcon = myIcon;
			this.diagram = diagram;
			this.biomolecule = biomolecule;
			
			//set properties
			if (!diagram.editingEnabled) title = biomolecule.myName;
			else if(biomolecule) title = 'Editing ' + biomolecule.myName;
			else title = 'Add New Biomolecule';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			var topForm:Form = new Form();
			topForm.enabled = diagram.editingEnabled;
			if (!diagram.editingEnabled) topForm.setStyle('disabledOverlayAlpha', 0);
			topForm.styleName = 'TitleWindowForm';
			addChild(topForm);
			
			formItem = new FormItem();
			formItem.label = "Name";
			formItem.styleName = 'TitleWindowFormItem';
			topForm.addChild(formItem);
			
			nameInput = new TextInput();
			nameInput.width = 200;
			nameInput.height = 14;
			nameInput.maxChars = 255;
			nameInput.styleName = 'TitleWindowTextInput';
			nameInput.restrict = "a-zA-z0-9_";
			formItem.addChild(nameInput);
			
			formItem = new FormItem();
			formItem.label = "Label";
			formItem.styleName = 'TitleWindowFormItem';
			topForm.addChild(formItem);
			
			labelInput = new TextInput();
			labelInput.maxChars = 255;
			labelInput.restrict='\u0020-\u007E';
			labelInput.width = 200;
			labelInput.height = 14;
			labelInput.styleName = 'TitleWindowTextInput';
			formItem.addChild(labelInput);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.setStyle('paddingBottom', 4);
			greekKeyboard = new GreekKeyboard(labelInput);
			greekKeyboard.width = 200;
			greekKeyboard.rowCount = 2;
			formItem.addChild(greekKeyboard);
			topForm.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = "Regulation";			
			topForm.addChild(formItem);
			
			regulationInput = new TextInput();
			regulationInput.width = 200;
			regulationInput.height = 14;
			regulationInput.restrict = 'a-zA-Z0-9_|&(!\) ';
			regulationInput.maxChars = 255;
			regulationInput.styleName = 'TitleWindowTextInput';
			formItem.addChild(regulationInput);
			
			if(biomolecule){
				formItem = new FormItem();
				formItem.label = "Style"
				formItem.styleName = 'TitleWindowFormItem';
				topForm.addChild(formItem);
				
				styleInput = new ComboBox();
				styleInput.width = 200;
				styleInput.height = 14;
				styleInput.dataProvider = diagram.biomoleculestyles;
				styleInput.labelField = "myName";
				styleInput.styleName = 'TitleWindowComboBox';
				formItem.addChild(styleInput);
			}
			
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = "Comments";			
			topForm.addChild(formItem);
			
			commentsInput = new TextArea();
			commentsInput.restrict = '\u0020-\u007E';
			commentsInput.maxChars = 65535;
			commentsInput.width = 200;
			if (diagram.editingEnabled) commentsInput.height = 50;
			commentsInput.styleName = 'TitleWindowTextInput';
			formItem.addChild(commentsInput);						
					
			errorMsg = new Text();
			errorMsg.styleName = 'ErrorMsg';
			errorMsg.percentWidth = 100;
			errorMsg.visible = false;
			errorMsg.height = 14;
			
			if (diagram.editingEnabled) {
				var controlBar:ControlBar = new ControlBar();
				controlBar.setStyle('paddingTop', 2);
				addChild(controlBar);
				
				controlBar.addChild(errorMsg);
				
				var updateButton:Button = new Button();
				updateButton.addEventListener(MouseEvent.CLICK, validate);
				if(biomolecule) updateButton.label = "Update";
				else updateButton.label = "Add";
				updateButton.height = 16;
				updateButton.styleName = 'TitleWindowButton';
				controlBar.addChild(updateButton);				
			}else {
				topForm.addChild(errorMsg);
			}
			
			formHandler();
		}
		
		public function setBiomoleculeProperties(compartment:CompartmentBase, biomoleculeStyle:BiomoleculeStyle, biomoleculeX:Number, biomoleculeY:Number):void {
			this.compartment = compartment;
			this.biomoleculeStyle = biomoleculeStyle;
			this.biomoleculeX = biomoleculeX;
			this.biomoleculeY = biomoleculeY;
		}
		
		private function formHandler():void {
			if (!biomolecule) return;
			
			nameInput.text = biomolecule.myName;
			labelInput.text = biomolecule.myLabel;
			regulationInput.text = biomolecule.myRegulation;			
			if(styleInput != null){ // would be null if being used in add mode
				styleInput.selectedIndex = diagram.biomoleculestyles.getItemIndex(biomolecule.myStyle);
				if (styleInput.selectedIndex == -1) {
					styleInput.selectedIndex = 0;
				}								
			}
			commentsInput.text = biomolecule.myComments;
		}
	
		/******************************************************
		 * validate form
		 * ****************************************************/	
		private function validate(event:MouseEvent):void {
			var htmlError:String = HTML.validate(labelInput.text);
			
			if (htmlError!=null) {
				errorMsg.text = 'Please enter a valid label. '+htmlError;
				errorMsg.visible = true;
				return;
			}
			
			if (nameInput.text.length == 0) {
				errorMsg.text = 'Please select a name.';
				errorMsg.visible = true;
				return;
			}
			
			if (!nameInput.text.charAt(0).match(/[a-z]/i)) {
				errorMsg.text = 'Biomolecule name must start with a letter.';
				errorMsg.visible = true;
				return;
			}
			
			if (!Biomolecule.validateRegulation(regulationInput.text, diagram)) {
				errorMsg.text = 'Please check the syntax of the regulation.';
				errorMsg.visible = true;
				return;
			}
			
			for (var i:uint = 0; i < diagram.biomolecules.length; i++) {
				if (diagram.biomolecules.getItemAt(i) == biomolecule) continue;
				if (diagram.biomolecules.getItemAt(i).myName == nameInput.text) {
					errorMsg.text = 'Please select a unique name.';
					errorMsg.visible = true;
					return;
				}
			}
				
			// update biomolecule
			if (biomolecule) {
				biomolecule.update(nameInput.text, labelInput.text, regulationInput.text, biomolecule.myCompartment, 
					styleInput.selectedItem as BiomoleculeStyle, commentsInput.text);
			}else {
				biomolecule = new Biomolecule(diagram, compartment, biomoleculeStyle,	biomoleculeX, biomoleculeY, nameInput.text, 
					labelInput.text, regulationInput.text, commentsInput.text);
				biomolecule.dim = diagram.dimAnimation && diagram.animationNotStopped;
			}

			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
		/******************************************************
		 * opening, closing
		 * ****************************************************/		
		public function open():void {
			PopUpManager.addPopUp(this, diagram,true);
			PopUpManager.centerPopUp(this);
		}
		
		public function close(event:CloseEvent):void {
			PopUpManager.removePopUp(this);
		}
	}
	
}