package edu.stanford.covertlab.diagram.window 
{
	import edu.stanford.covertlab.controls.ToolBarButton;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.BiomoleculeStyle;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.toolbar.ToolBar;
	import flash.events.MouseEvent;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.skins.halo.ComboBoxArrowSkin;
	
	/**
	 * PopUp window user interface for editing a biomolecule style.
	 * 
	 * @see edu.stanford.covertlab.diagram.core.BiomoleculeStyle
	 * 
	 * @author Ed Chen, chened@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class EditBiomoleculeStyleWindow extends TitleWindow
	{
		[Bindable] private var diagram:Diagram;
		
		private var nameInput:TextInput;
		private var shapeInput:ComboBox;
		private var colorInput:ColorPicker;
		private var outlineInput:ColorPicker;
		private var errorMsg:Text;		
		private var biomoleculeStyle:BiomoleculeStyle;
		
		[Embed(source = '../../image/biomolecule.png')] private var myIcon:Class;
		
		public function EditBiomoleculeStyleWindow(diagram:Diagram, biomoleculeStyle:BiomoleculeStyle = null)
		{			
			
			this.diagram = diagram;
			this.biomoleculeStyle = biomoleculeStyle;
			
			//set properties
			titleIcon = myIcon;
			if (biomoleculeStyle) {
				if (!diagram.editingEnabled) title = biomoleculeStyle.myName;
				else title = 'Editing ' + biomoleculeStyle.myName;
			}else title = 'Add New Biomolecule Style';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);			
			
			var form:Form = new Form();
			form.enabled = diagram.editingEnabled;
			if (!diagram.editingEnabled) form.setStyle('disabledOverlayAlpha', 0);
			form.styleName = 'TitleWindowForm';
			addChild(form);			
			
			var nameFormItem:FormItem = new FormItem();
			nameFormItem.label = "Name";
			nameFormItem.styleName = 'TitleWindowFormItem';
			nameFormItem.required = true;
			form.addChild(nameFormItem);
			
			nameInput = new TextInput();
			nameInput.width = 200;
			nameInput.restrict = "a-zA-z0-9_";
			nameInput.maxChars = 255;
			nameInput.height = 14;
			nameInput.styleName = 'TitleWindowTextInput';
			nameFormItem.addChild(nameInput);
			
			var shapeFormItem:FormItem = new FormItem();
			shapeFormItem.label = "Shape"
			shapeFormItem.styleName = 'TitleWindowFormItem';
			shapeFormItem.required = true;
			form.addChild(shapeFormItem);
			
			shapeInput = new ComboBox();		
			shapeInput.labelField = 'name';
			shapeInput.dataProvider = Biomolecule.BIOMOLECULE_SHAPES;
			shapeInput.width = 200;
			shapeInput.height = 14;
			shapeInput.styleName = 'TitleWindowComboBox';
			shapeFormItem.addChild(shapeInput);
			form.addChild(shapeFormItem);
			
			var colorFormItem:FormItem = new FormItem();
			colorFormItem.label = 'Color';
			colorFormItem.styleName = 'TitleWindowFormItem';
			colorFormItem.required = true;
			
			colorInput = new ColorPicker();
			colorInput.styleName = 'TitleWindowColorPicker';
			colorInput.showTextField = true;
			colorFormItem.addChild(colorInput);
			form.addChild(colorFormItem);
			
			var spacer:Spacer = new Spacer();
			spacer.height = 8;
			form.addChild(spacer);
				
			var outlineFormItem:FormItem = new FormItem();
			outlineFormItem.label = 'Outline Color';			
			outlineFormItem.styleName = 'TitleWindowFormItem';
			outlineFormItem.required = true;
			
			outlineInput = new ColorPicker();		
			outlineInput.styleName = 'TitleWindowColorPicker';
			outlineInput.showTextField = true;
			outlineFormItem.addChild(outlineInput);
			form.addChild(outlineFormItem);
			
			errorMsg = new Text();
			errorMsg.styleName = 'ErrorMsg';
			errorMsg.percentWidth = 100;
			errorMsg.visible = false;
			errorMsg.height = 14;
			
			if(diagram.editingEnabled){
				var controlBar:ControlBar = new ControlBar();
				addChild(controlBar);
				
				controlBar.addChild(errorMsg);
				
				var updateButton:ToolBarButton = new ToolBarButton();
				if(biomoleculeStyle){
					updateButton.label = "Update";
				} else {
					updateButton.label = "Add";
				}
				updateButton.height = 16;
				updateButton.styleName = 'TitleWindowButton';
				updateButton.addEventListener(MouseEvent.CLICK, validate);
				controlBar.addChild(updateButton);								
			}else {
				form.addChild(errorMsg);
			}
			formHandler();
			
		}
		
		private function formHandler():void {
			if (!biomoleculeStyle) return;
			
			nameInput.text = biomoleculeStyle.myName;
			for (var i:uint = 0; i < Biomolecule.BIOMOLECULE_SHAPES.length; i++) {
				if (Biomolecule.BIOMOLECULE_SHAPES[i].name == biomoleculeStyle.myShape) {
					shapeInput.selectedIndex = i;
				}
			}
			colorInput.selectedColor = biomoleculeStyle.myColor;
			outlineInput.selectedColor = biomoleculeStyle.myOutline;
		}
		
		
		private function validate(event:MouseEvent):void {
			if (nameInput.text.length == 0) {
				errorMsg.text = "Please select a name.";
				errorMsg.visible = true;
				return;
			}
			
			if (!nameInput.text.charAt(0).match(/[a-z]/i)) {
				errorMsg.text = 'Style name must start with a letter.';
				errorMsg.visible = true;
				return;
			}
			
			if (shapeInput.selectedItem == null) {
				errorMsg.text = "Please select a shape.";
				errorMsg.visible = true;
				return;
			}
			
			for (var i:uint = 0; i < diagram.biomoleculestyles.length; i++) {
				if (diagram.biomoleculestyles.getItemAt(i) == biomoleculeStyle) continue;
				if (diagram.biomoleculestyles.getItemAt(i).myName == nameInput.text) {
					errorMsg.text = "Please select a unique name.";
					errorMsg.visible = true;
					return;
				}
			}
								
			if (biomoleculeStyle) {
				biomoleculeStyle.update(nameInput.text, shapeInput.selectedItem.name, colorInput.selectedColor, outlineInput.selectedColor);
			}else {					
				new BiomoleculeStyle(diagram, nameInput.text, shapeInput.selectedItem.name, colorInput.selectedColor, outlineInput.selectedColor);
			}
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}	
		
		/******************************************************
		* opening, closing
		******************************************************/		
		public function open():void {
			PopUpManager.addPopUp(this, diagram, true);
			PopUpManager.centerPopUp(this);
		}
				
		public function close(event:CloseEvent):void {			
			PopUpManager.removePopUp(this);
		}	
	}
	
}