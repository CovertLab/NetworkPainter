package edu.stanford.covertlab.diagram.panel 
{
	import edu.stanford.covertlab.diagram.core.BiomoleculeStyle;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.event.BiomoleculeStyleEvent;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	import mx.binding.utils.BindingUtils;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.events.ListEvent;
	
	/**
	 * Form-based user interface for creating, editing, and deleting biomolecule styles.
	 * 
	 * @see edu.stanford.covertlab.diagram.core.BiomoleculeStyle
	 * 
	 * @author Ed Chen, chened@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu	 
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class StylesPanel extends Panel
	{
		
		[Bindable] public var diagram:Diagram;
		private var stylelist:List;
		private var nameInput:TextInput;		
		private var shapeInput:ComboBox;
		private var colorInput:ColorPicker;		
		private var outlineInput:ColorPicker;
		private var errorMsg:Text;
		private var addButton:Button;
		private var removeButton:Button;
		private var updateButton:Button;
		private var currStyle:BiomoleculeStyle;
		
		public function StylesPanel() 
		{
			var vBox:VBox;
			var hBox:HBox;
			var colorsBox:VBox;
			var buttonBox:HBox;
			var form:Form;
			var formItem:FormItem;
			var label:Label;

			//style
			title = 'Biomolecule Styles';
			styleName = 'MainTab';
			layout = 'horizontal';
			
			//setup children
			stylelist = new List();
			stylelist.rowHeight = 14;
			stylelist.percentWidth = 100;		
			stylelist.labelField = 'myName';
			stylelist.addEventListener(ListEvent.CHANGE, dgChangeHandler);
			BindingUtils.bindProperty(stylelist, 'dataProvider', this, ['diagram', 'biomoleculestyles']);
			addChild(stylelist);						
			
			vBox = new VBox(); // for form and buttons
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
			nameInput.maxChars = 255;
			nameInput.restrict = '0-9A-Za-z_';
			nameInput.width = 200;
			formItem.addChild(nameInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Shape';
			shapeInput = new ComboBox();		
			shapeInput.labelField = 'name';
			shapeInput.dataProvider = Biomolecule.BIOMOLECULE_SHAPES;
			shapeInput.width = 200;
			formItem.addChild(shapeInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Colors';
			form.addChild(formItem);
			
			colorsBox = new VBox();
			colorsBox.setStyle('verticalGap', 2);
			colorsBox.percentWidth = 100;
			formItem.addChild(colorsBox);
			
			hBox = new HBox();
			hBox.setStyle('verticalAlign', 'middle');
			hBox.setStyle('horizontalGap', 2);
			colorInput = new ColorPicker();
			colorInput.setStyle('paddingRight', 0);
			colorInput.showTextField = true;
			hBox.addChild(colorInput);
			label = new Label();			
			label.text = 'Color';
			hBox.addChild(label);
			colorsBox.addChild(hBox);
			
			hBox = new HBox();
			hBox.setStyle('verticalAlign', 'middle');
			hBox.setStyle('horizontalGap', 2);
			outlineInput = new ColorPicker();
			outlineInput.setStyle('paddingRight', 0);
			outlineInput.showTextField = true;
			hBox.addChild(outlineInput);
			label = new Label();			
			label.text = 'Outline';
			hBox.addChild(label);
			colorsBox.addChild(hBox);
			
			errorMsg = new Text();
			errorMsg.percentWidth = 100;
			errorMsg.text = "";
			errorMsg.setStyle("color", 0xff0000);
			errorMsg.setStyle("fontWeight", "bold");
			form.addChild(errorMsg);
			
			buttonBox = new HBox();
			buttonBox.percentWidth = 100;
			buttonBox.setStyle("horizontalAlign", "center");
			vBox.addChild(buttonBox);
			
			addButton = new Button();
			addButton.width = 90;
			addButton.label = 'Add New';
			addButton.addEventListener(MouseEvent.CLICK, addStyle);
			buttonBox.addChild(addButton);
			
			removeButton = new Button();
			removeButton.width = 90;
			removeButton.label = 'Remove';
			removeButton.enabled = false;
			removeButton.addEventListener(MouseEvent.CLICK, removeStyle);
			buttonBox.addChild(removeButton);
			
			updateButton = new Button();
			updateButton.width = 90;
			updateButton.label = 'Update';
			updateButton.enabled = false;
			updateButton.addEventListener(MouseEvent.CLICK, updateStyle);
			buttonBox.addChild(updateButton);
			
			BindingUtils.bindProperty(stylelist, 'height', form, 'height');
		}
		
		// Add style
		private function addStyle(event:MouseEvent):void {
			if (nameInput.text.length == 0) errorMsg.text = 'Please select a name.';
			else if (!nameInput.text.charAt(0).match(/[a-z]/i)) errorMsg.text = 'Style name must start with a letter.';
			else if (shapeInput.selectedItem == null) errorMsg.text = 'Please select a shape.';
			else{
				for (var i:uint = 0; i < diagram.biomoleculestyles.length; i++) {
					if (diagram.biomoleculestyles.getItemAt(i).myName == nameInput.text) {
						errorMsg.text = 'Error: Duplicate name!';
						return;
					}
				}
				new BiomoleculeStyle(diagram, nameInput.text, shapeInput.selectedItem.name, colorInput.selectedColor, outlineInput.selectedColor);
				clearInputs();
				stylelist.selectedIndex = -1;
				checkButtonStatus();
			}
		}
		
		// Update style
		private function updateStyle(event:MouseEvent):void {
			if (nameInput.text.length == 0) errorMsg.text = 'Please select a name.';
			else if (!nameInput.text.charAt(0).match(/[a-z]/i)) errorMsg.text = 'Style name must start with a letter.';
			else if (shapeInput.selectedItem == null) errorMsg.text='Please select a shape.';
			else{
				for (var i:uint = 0; i < diagram.biomoleculestyles.length; i++) {
					if (diagram.biomoleculestyles[i] == stylelist.selectedItem) continue;					
					if (diagram.biomoleculestyles.getItemAt(i).myName == nameInput.text) {
						errorMsg.text='Please select a unique name.';
						return;
					}
				}
				stylelist.selectedItem.update(
					nameInput.text, 
					shapeInput.selectedItem.name, 
					colorInput.selectedColor, 
					outlineInput.selectedColor);
				clearInputs();
				stylelist.selectedIndex = -1;
				checkButtonStatus();				
			}
		}
		
		// Remove style
		private function removeStyle(event:MouseEvent):void {
			var biomoleculeStyle:BiomoleculeStyle = stylelist.selectedItem as BiomoleculeStyle;
			biomoleculeStyle.remove();
			clearInputs();
			checkButtonStatus();
		}
		
		// Change event listener for DataGrid
		private function dgChangeHandler(event:ListEvent):void {
			if (currStyle != null) currStyle.removeEventListener(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_UPDATE, updateInputs);
			currStyle = stylelist.selectedItem as BiomoleculeStyle;
			if (currStyle != null) currStyle.addEventListener(BiomoleculeStyleEvent.BIOMOLECULE_STYLE_UPDATE, updateInputs);
			updateInputs();
		}
		
		private function updateInputs(event:BiomoleculeStyleEvent=null):void {
			if (currStyle != null) {
				nameInput.text = currStyle.myName;
				for (var i:uint = 0; i < Biomolecule.BIOMOLECULE_SHAPES.length; i++) {
					if (Biomolecule.BIOMOLECULE_SHAPES[i].name == currStyle.myShape) shapeInput.selectedIndex = i;
				}
				colorInput.selectedColor = currStyle.myColor;
				outlineInput.selectedColor = currStyle.myOutline;
				checkButtonStatus();
			}else clearInputs();			
		}
		
		public function clearInputs():void {
			nameInput.text = "";
			shapeInput.selectedIndex = -1;
			colorInput.selectedColor= 0;
			outlineInput.selectedColor = 0;
			errorMsg.text = '';
			removeButton.enabled = false;
			updateButton.enabled = false;
		}
		
		private function checkButtonStatus():void {
			isRemoveButtonEnabled();
			isUpdateButtonEnabled();
		}
		
		private function isRemoveButtonEnabled():Boolean {
			removeButton.enabled = stylelist.selectedItem != null && stylelist.dataProvider.length > 1;
			return removeButton.enabled;
		}
		
		private function isUpdateButtonEnabled():Boolean {
			updateButton.enabled = stylelist.selectedItem != null;
			return updateButton.enabled;
		}
	}
	
}