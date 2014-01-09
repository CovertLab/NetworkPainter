package edu.stanford.covertlab.diagram.window 
{

	import edu.stanford.covertlab.diagram.core.Compartment;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;	
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;	
	
	/**
	 * PopUp window user interface for editing a compartment.
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Compartment
	 * 
	 * @author Ed Chen, chened@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class EditCompartmentWindow extends TitleWindow
	{
		
		[Bindable] private var diagram:Diagram;
		
		private var nameInput:TextInput;
		private var colorInput:ColorPicker;
		private var membraneInput:ColorPicker;
		private var phospholipidBodyInput:ColorPicker;
		private var phospholipidOutlineInput:ColorPicker;
		private var compartment:Compartment;
		private var errorMsg:Text;
		private var updateButton:Button;
		private var removeButton:Button;
		private var addUpperCompartment:Compartment;

		[Embed(source = '../../image/compartment.png')] private var myIcon:Class;
		// if edit is false then the window is being called to add a new molecule
		public function EditCompartmentWindow(diagram:Diagram, compartment:Compartment=null, addUpperCompartment:Compartment=null) 
		{	
			titleIcon = myIcon;
			var form:Form;
			var formItem:FormItem;
			var hBox:HBox;
			var controlBar:ControlBar;
			var box:HBox;
			var label:Label;
			
			this.addUpperCompartment = addUpperCompartment;
			this.diagram = diagram;
						
			//set properties
			if (!diagram.editingEnabled) title = compartment.myName;
			else if(compartment) title = 'Editing ' + compartment.myName;
			else title = 'Add New Compartment';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			this.compartment = compartment;
						
			form = new Form();
			form.enabled = diagram.editingEnabled;
			if (!diagram.editingEnabled) form.setStyle('disabledOverlayAlpha', 0);
			form.styleName = 'TitleWindowForm';
			addChild(form);
			
			formItem = new FormItem();
			formItem.label = 'Name';
			formItem.styleName = 'TitleWindowFormItem';			
			nameInput = new TextInput();
			nameInput.restrict = '0-9A-Za-z_';
			nameInput.maxChars = 255;
			nameInput.width = 200;
			nameInput.height = 14;
			nameInput.styleName = 'TitleWindowTextInput';
			formItem.addChild(nameInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = 'Colors';
			formItem.required = true;
			form.addChild(formItem);
			
			var tile:VBox = new VBox();
			tile.percentWidth = 100;
			tile.direction = 'horizontal';
			tile.setStyle('paddingTop', 0);
			tile.setStyle('paddingBottom', 0);
			tile.setStyle('verticalGap', 2);
			formItem.addChild(tile);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('paddingTop', 0);
			box.setStyle('paddingBottom', 0);
			box.setStyle('horizontalGap', 2);
			colorInput = new ColorPicker();
			colorInput.setStyle('paddingRight', 0);
			colorInput.showTextField = true;
			box.addChild(colorInput);
			label = new Label();			
			label.text = 'Compartment';
			box.addChild(label);
			tile.addChild(box);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('paddingTop', 0);
			box.setStyle('paddingBottom', 0);
			box.setStyle('horizontalGap', 2);
			membraneInput = new ColorPicker();
			membraneInput.setStyle('paddingRight', 0);
			membraneInput.showTextField = true;
			box.addChild(membraneInput);
			label = new Label();			
			label.text = 'Membrane';
			box.addChild(label);
			tile.addChild(box);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('paddingTop', 0);
			box.setStyle('paddingBottom', 0);
			box.setStyle('horizontalGap', 2);
			phospholipidBodyInput = new ColorPicker();
			phospholipidBodyInput.setStyle('paddingRight', 0);
			phospholipidBodyInput.showTextField = true;
			box.addChild(phospholipidBodyInput);
			label = new Label();			
			label.text = 'Phospholipid Body';
			box.addChild(label);
			tile.addChild(box);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('paddingTop', 0);
			box.setStyle('paddingBottom', 0);
			box.setStyle('horizontalGap', 2);
			phospholipidOutlineInput = new ColorPicker();
			phospholipidOutlineInput.setStyle('paddingRight', 0);
			phospholipidOutlineInput.showTextField = true;
			box.addChild(phospholipidOutlineInput);
			label = new Label();			
			label.text = 'Phospholipid Outline';
			box.addChild(label);
			tile.addChild(box);
			
			errorMsg = new Text();
			errorMsg.styleName = 'ErrorMsg';
			errorMsg.percentWidth = 100;
			errorMsg.visible = false;
			errorMsg.height = 14;

			if (diagram.editingEnabled) {
				controlBar = new ControlBar();
				addChild(controlBar);
				
				controlBar.addChild(errorMsg);
			
				updateButton = new Button();
				if(compartment){
					updateButton.label = "Update";
				} else {
					updateButton.label = "Add";
				}
				updateButton.width = 60;
				updateButton.height = 16;
				updateButton.styleName = 'TitleWindowButton';
				updateButton.addEventListener(MouseEvent.CLICK, validate);
				controlBar.addChild(updateButton);
				
				if(compartment){
					removeButton = new Button();
					removeButton.label = "Remove";
					removeButton.width = 60;
					removeButton.height = 16;
					removeButton.styleName = 'TitleWindowButton';
					removeButton.enabled = diagram.compartments.length > 1;
					removeButton.addEventListener(MouseEvent.CLICK, removeCompartment);
					controlBar.addChild(removeButton);
				}				
			}else {
				form.addChild(errorMsg);
			}
			
			formHandler();
		}
		
		private function formHandler():void {
			if (!compartment) return;
			
			nameInput.text = compartment.myName;
			colorInput.selectedColor = compartment.myColor;
			membraneInput.selectedColor = compartment.myMembraneColor;
			phospholipidBodyInput.selectedColor = compartment.myPhospholipidBodyColor;
			phospholipidOutlineInput.selectedColor = compartment.myPhospholipidOutlineColor;
		}
		
		private function validate(event:MouseEvent):void {
			if (nameInput.text.length == 0) {
				errorMsg.text = 'Please select a name.';
				errorMsg.visible = true;
				return;
			}
			
			if (!nameInput.text.charAt(0).match(/[a-z]/i)) {
				errorMsg.text = 'Comparatment name must start with a letter.';
				errorMsg.visible = true;
				return;
			}

			for (var i:uint = 0; i < diagram.compartments.length; i++) {
				if (diagram.compartments.getItemAt(i) == compartment) continue;
				if (diagram.compartments.getItemAt(i).myName == nameInput.text) {
					errorMsg.text = 'Please select a unique name.';
					errorMsg.visible = true;
					return;
				}
			}
			
			if (compartment) compartment.update(nameInput.text, colorInput.selectedColor, membraneInput.selectedColor, phospholipidBodyInput.selectedColor, phospholipidOutlineInput.selectedColor);
			else new Compartment(diagram, 
				nameInput.text, colorInput.selectedColor, membraneInput.selectedColor, 
				phospholipidBodyInput.selectedColor, phospholipidOutlineInput.selectedColor,					
				diagram.diagramWidth, 0, addUpperCompartment, (addUpperCompartment ? addUpperCompartment.myLowerCompartment as Compartment : (diagram.compartments.length > 0 ? diagram.compartments[0] : null)));

			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
		private function removeCompartment(event:MouseEvent):void {
			compartment.remove();
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
		/******************************************************
		 * opening, closing
		 * ****************************************************/		
		public function open():void {
			PopUpManager.addPopUp(this, diagram, true);
			PopUpManager.centerPopUp(this);
		}
		
		public function close(event:CloseEvent):void {
			PopUpManager.removePopUp(this);
		}	
	}
	
}
