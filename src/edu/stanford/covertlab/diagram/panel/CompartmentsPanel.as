package edu.stanford.covertlab.diagram.panel 
{

	import edu.stanford.covertlab.diagram.core.Compartment;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.event.CompartmentEvent;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.containers.Box;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;	
	import mx.controls.Button;
	import mx.controls.ColorPicker;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.events.ListEvent;
	
	/**
	 * Form-based user interface for creating, editing, and deleting compartments.
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Compartment
	 * 
	 * @author Ed Chen, chened@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class CompartmentsPanel extends Panel
	{
		
		[Bindable] public var diagram:Diagram;
		private var comlist:List;
		private var nameInput:TextInput;
		private var colorInput:ColorPicker;
		private var membraneInput:ColorPicker;
		private var phospholipidBodyInput:ColorPicker;
		private var phospholipidOutlineInput:ColorPicker;
		private var errorMsg:Text;
		private var addButton:Button;
		private var removeButton:Button;
		private var updateButton:Button;
		private var currCompartment:Compartment;
		
		public function CompartmentsPanel() 
		{
			var vBox:VBox;			
			var hBox:HBox;
			var form:Form;			
			var formItem:FormItem;
			var box:HBox;
			var label:Label;
			var colorsBox:VBox;
			
			//style
			title = 'Compartments';
			styleName = 'MainTab';
			layout = 'horizontal';

			//children
			// box for list		
			comlist = new List();
			comlist.rowHeight = 14;
			comlist.percentWidth = 100;
			BindingUtils.bindProperty(comlist, 'dataProvider', this, ['diagram', 'compartments']);
			comlist.labelField = 'myName';
			comlist.addEventListener(ListEvent.CHANGE, dgChangeHandler);
			addChild(comlist);
			
			// box for form
			vBox = new VBox();
			addChild(vBox);
			vBox.width = 300;
			vBox.percentHeight = 100;
			
			form = new Form();
			form.percentWidth = 100;
			form.percentHeight = 100;
			form.setStyle('borderStyle', 'solid');
			vBox.addChild(form);
			
			formItem = new FormItem();
			formItem.label = 'Name';
			nameInput = new TextInput();
			nameInput.restrict = '0-9A-Za-z_';
			nameInput.maxChars = 255;
			nameInput.width = 200;
			formItem.addChild(nameInput);
			form.addChild(formItem);
						
			formItem = new FormItem();
			formItem.label = 'Colors';
			form.addChild(formItem);
			
			colorsBox = new VBox();
			colorsBox.setStyle('verticalGap', 2);
			colorsBox.percentWidth = 100;
			formItem.addChild(colorsBox);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('horizontalGap', 2);
			colorInput = new ColorPicker();
			colorInput.setStyle('paddingRight', 0);
			colorInput.showTextField = true;
			box.addChild(colorInput);
			label = new Label();			
			label.text = 'Compartment';
			box.addChild(label);
			colorsBox.addChild(box);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('horizontalGap', 2);
			membraneInput = new ColorPicker();
			membraneInput.setStyle('paddingRight', 0);
			membraneInput.showTextField = true;
			box.addChild(membraneInput);
			label = new Label();			
			label.text = 'Membrane';
			box.addChild(label);
			colorsBox.addChild(box);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('horizontalGap', 2);
			phospholipidBodyInput = new ColorPicker();
			phospholipidBodyInput.setStyle('paddingRight', 0);
			phospholipidBodyInput.showTextField = true;
			box.addChild(phospholipidBodyInput);
			label = new Label();			
			label.text = 'Phospholipid Body';
			box.addChild(label);
			colorsBox.addChild(box);
			
			box = new HBox();
			box.setStyle('verticalAlign', 'middle');
			box.setStyle('horizontalGap', 2);
			phospholipidOutlineInput = new ColorPicker();
			phospholipidOutlineInput.setStyle('paddingRight', 0);
			phospholipidOutlineInput.showTextField = true;
			box.addChild(phospholipidOutlineInput);
			label = new Label();			
			label.text = 'Phospholipid Outline';
			box.addChild(label);
			colorsBox.addChild(box);
			
			errorMsg = new Text();
			errorMsg.percentWidth = 100;
			errorMsg.text = "";
			errorMsg.setStyle("color", 0xff0000);
			errorMsg.setStyle("fontWeight", "bold");
			form.addChild(errorMsg);
			
			hBox = new HBox();
			hBox.setStyle("horizontalAlign", "center");
			hBox.percentWidth = 100;
			vBox.addChild(hBox);
			
			addButton = new Button();
			addButton.label = 'Add New';
			addButton.width = 90;
			addButton.addEventListener(MouseEvent.CLICK, addCom);
			hBox.addChild(addButton);
			
			removeButton = new Button();
			removeButton.label = 'Remove';
			removeButton.width = 90;
			removeButton.enabled = false;
			removeButton.addEventListener(MouseEvent.CLICK, removeCom);
			hBox.addChild(removeButton);
			
			updateButton = new Button();
			updateButton.label = 'Update';
			updateButton.width = 90;
			updateButton.enabled = false;
			updateButton.addEventListener(MouseEvent.CLICK, updateCom);
			hBox.addChild(updateButton);
			
			BindingUtils.bindProperty(comlist, 'height', form, 'height');
		}
		
		// Add compartment
		private function addCom(event:MouseEvent):void {
			if (nameInput.text.length == 0) errorMsg.text = 'Please select a name.';
			else if (!nameInput.text.charAt(0).match(/[a-z]/i)) errorMsg.text = 'Compartment name must start with a letter.';
			else{
				for (var i:uint = 0; i < diagram.compartments.length; i++) {
					if (diagram.compartments.getItemAt(i).myName == nameInput.text) {
						errorMsg.text = 'Please select a unique name.';
						return;
					}
				}
				var compartment:Compartment = new Compartment(diagram, 
					nameInput.text, colorInput.selectedColor, membraneInput.selectedColor,
					phospholipidBodyInput.selectedColor,phospholipidOutlineInput.selectedColor,
					diagram.diagramWidth, 0, diagram.compartments[diagram.compartments.length-1]);
				clearInputs();
				comlist.selectedIndex = -1;
				checkButtonStatus();
			}
		}
		
		// Remove compartment
		private function removeCom(event:MouseEvent):void {
			if (comlist.selectedIndex == 0) errorMsg.text = 'At least one compartment must be defined.';			
			else{
				(comlist.selectedItem as Compartment).remove();
				clearInputs();
				checkButtonStatus();
			}
		}
		
		// Update compartment
		private function updateCom(event:MouseEvent):void {
			if (nameInput.text.length == 0) errorMsg.text = 'Please select a name.';
			else if (!nameInput.text.charAt(0).match(/[a-z]/i)) errorMsg.text = 'Compartment name must start with a letter.';
			else{
				for (var i:uint = 0; i < diagram.compartments.length; i++) {
					if (comlist.selectedIndex !=i && diagram.compartments.getItemAt(i).myName == nameInput.text) {
						errorMsg.text = 'Please select a unique name.';
						return;
					}
				}
				comlist.selectedItem.update(nameInput.text, colorInput.selectedColor, membraneInput.selectedColor, phospholipidBodyInput.selectedColor, phospholipidOutlineInput.selectedColor);
				clearInputs();
				comlist.selectedIndex = -1;
				checkButtonStatus();
			}
		}
		
		// Change event listener for DataGrid
		private function dgChangeHandler(event:ListEvent):void {
			currCompartment = comlist.selectedItem as Compartment;
			updateInputs();
		}
					
		private function updateInputs(event:CompartmentEvent = null):void {
			if (currCompartment != null) {
				nameInput.text = currCompartment.myName;
				colorInput.selectedColor = currCompartment.myColor;
				membraneInput.selectedColor = currCompartment.myMembraneColor;
				phospholipidBodyInput.selectedColor = currCompartment.myPhospholipidBodyColor;
				phospholipidOutlineInput.selectedColor = currCompartment.myPhospholipidOutlineColor;
				checkButtonStatus();
			}else clearInputs();			
		}
		
		public function clearInputs():void {
			nameInput.text = "";
			colorInput.selectedColor= 0;
			membraneInput.selectedColor = 0;
			phospholipidBodyInput.selectedColor = 0;
			phospholipidOutlineInput.selectedColor = 0;
			errorMsg.text = '';
			removeButton.enabled = false;
			updateButton.enabled = false;
		}
		
		private function checkButtonStatus():void {
			isRemoveButtonEnabled();
			isUpdateButtonEnabled();
		}
				
		private function isRemoveButtonEnabled():Boolean {
			removeButton.enabled = comlist.selectedItem != null && diagram.compartments.length > 1;
			return removeButton.enabled;
		}
		
		private function isUpdateButtonEnabled():Boolean {
			updateButton.enabled = comlist.selectedItem != null;
			return updateButton.enabled;
		}
	}
	
}