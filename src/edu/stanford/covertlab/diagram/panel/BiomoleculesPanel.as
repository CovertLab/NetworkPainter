package edu.stanford.covertlab.diagram.panel 
{		
	
	import edu.stanford.covertlab.controls.GreekKeyboard;
	import edu.stanford.covertlab.controls.SupSubDataGridItemRenderer;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.BiomoleculeStyle;
	import edu.stanford.covertlab.diagram.core.Compartment;
	import edu.stanford.covertlab.diagram.core.CompartmentBase;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.event.BiomoleculeEvent;
	import edu.stanford.covertlab.util.HTML;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.Spacer;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.events.ListEvent;
	
	/**
	 * Form-based user interface for creating, editing, and deleting biomolecules.
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Biomolecule
	 * @see edu.stanford.covertlab.control.GreekKeyboard
	 * 
	 * @author Ed Chen, chened@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu	 
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class BiomoleculesPanel extends Panel
	{
		private var biolist:List;
		private var form:Form;
		private var nameInput:TextInput;
		private var labelInput:TextInput;		
		private var compartmentInput:ComboBox;
		private var regulationInput:TextInput;
		private var styleInput:ComboBox;
		private var commentsInput:TextArea;
		private var errorMsg:Text;
		private var addButton:Button;
		private var removeButton:Button;
		private var updateButton:Button;
		private var dataGrid:DataGrid;
		private var currBiomolecule:Biomolecule;
		[Bindable] public var diagram:Diagram;
		
		public function BiomoleculesPanel() 
		{
			var hBox:HBox;
			var vBox:VBox;
			var buttonBox:HBox;
			var formItem:FormItem;
			var dataGridColumns:Array = [];
			var dataGridColumn:DataGridColumn;
			var greekKeyboard:GreekKeyboard;
			
			//style
			title = 'Biomolecules';
			styleName = 'MainTab';
			layout = 'vertical';
			setStyle('verticalGap', 10);
			
			//setup children
			hBox = new HBox(); // top box that has the list and the form
			addChild(hBox);
			hBox.percentWidth = 100;
			
			biolist = new List();
			biolist.rowHeight = 14;
			biolist.percentWidth = 100;
			biolist.labelField = 'myName';
			biolist.addEventListener(ListEvent.CHANGE, dgChangeHandler);
			BindingUtils.bindProperty(biolist, 'dataProvider', this, ['diagram', 'biomolecules']);
			hBox.addChild(biolist);
			
			vBox = new VBox(); // the box that has the form and buttons
			hBox.addChild(vBox);
			vBox.setStyle('verticalGap', 4);
			form = new Form();
			form.percentWidth = 100;
			BindingUtils.bindProperty(biolist, 'height', form,'height');
			form.setStyle('borderStyle', 'solid');
			vBox.addChild(form);
			
			formItem = new FormItem();
			formItem.label = 'Name';
			nameInput = new TextInput();
			nameInput.width = 200;
			nameInput.restrict = 'a-zA-Z0-9_';
			nameInput.maxChars = 255;
			formItem.addChild(nameInput);			
			form.addChild(formItem);			

			formItem = new FormItem();
			formItem.label = 'Label';
			labelInput = new TextInput();
			labelInput.width = 200;
			labelInput.restrict = '\u0020-\u007E';
			labelInput.maxChars = 255;
			formItem.addChild(labelInput);			
			form.addChild(formItem);
						
			formItem = new FormItem();
			formItem.percentWidth = 100;			
			greekKeyboard = new GreekKeyboard(labelInput);
			greekKeyboard.width = 200;
			greekKeyboard.rowCount = 2;
			formItem.addChild(greekKeyboard);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Compartment';
			compartmentInput = new ComboBox();
			compartmentInput.width = 200;
			compartmentInput.labelField = 'myName';
			BindingUtils.bindProperty(compartmentInput, 'dataProvider', this,['diagram', 'compartmentsAndMembranes']);			
			formItem.addChild(compartmentInput);			
			form.addChild(formItem);
						
			formItem = new FormItem();
			formItem.label = 'Regulation';
			regulationInput = new TextInput();
			regulationInput.width = 200;
			regulationInput.maxChars = 255;
			regulationInput.restrict = 'a-zA-Z0-9_|&(!\) ';
			formItem.addChild(regulationInput);			
			form.addChild(formItem);
						
			formItem = new FormItem();
			formItem.label = 'Style';
			styleInput = new ComboBox();
			styleInput.width = 200;
			styleInput.labelField = 'myName';
			BindingUtils.bindProperty(styleInput, 'dataProvider', this,['diagram', 'biomoleculestyles']);
			formItem.addChild(styleInput);			
			form.addChild(formItem);
						
			formItem = new FormItem();
			formItem.label = 'Comments';
			commentsInput = new TextArea();
			commentsInput.maxChars = 65535;
			commentsInput.width = 200;
			commentsInput.height = 50;
			commentsInput.restrict='\u0020-\u007E';
			formItem.addChild(commentsInput);	
			form.addChild(formItem);
			
			errorMsg = new Text();
			errorMsg.percentWidth = 100;
			errorMsg.text = "";
			errorMsg.setStyle("color", 0xff0000);
			errorMsg.setStyle("fontWeight", "bold");
			form.addChild(errorMsg);
			
			buttonBox = new HBox(); 
			buttonBox.setStyle("horizontalAlign", "center");
			buttonBox.percentWidth = 100;
			vBox.addChild(buttonBox);
			
			addButton = new Button();
			addButton.label = 'Add New';
			addButton.width = 90;
			addButton.addEventListener(MouseEvent.CLICK, addBiomolecule);
			buttonBox.addChild(addButton);			
			
			removeButton = new Button();
			removeButton.enabled = false;
			removeButton.label = 'Remove';
			removeButton.width = 90;
			removeButton.addEventListener(MouseEvent.CLICK, removeBiomolecule);
			buttonBox.addChild(removeButton);			
			
			updateButton = new Button();
			updateButton.enabled = false;
			updateButton.label = 'Update';
			updateButton.width = 90;
			updateButton.addEventListener(MouseEvent.CLICK, updateBiomolecule);			
			buttonBox.addChild(updateButton);
			
			dataGrid = new DataGrid();
			dataGrid.percentWidth = 100;
			dataGrid.percentHeight = 100;
			dataGrid.editable = false;
			dataGrid.rowHeight = 14;
			dataGrid.headerHeight = 14;
			BindingUtils.bindProperty(dataGrid, 'dataProvider', this,['diagram', 'biomolecules']);
			addChild(dataGrid);
					
			dataGridColumn = new DataGridColumn();
			dataGridColumn.dataField = 'myName';
			dataGridColumn.headerText = 'Name';
			dataGridColumn.sortable = false;
			dataGridColumns.push(dataGridColumn);			
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.dataField = 'myLabel';
			dataGridColumn.headerText = 'Label';
			dataGridColumn.itemRenderer = new ClassFactory(SupSubDataGridItemRenderer);
			dataGridColumn.sortable = false;
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.dataField = 'myCompartment';
			dataGridColumn.headerText = 'Compartment';
			dataGridColumn.sortable = false;
			dataGridColumn.labelFunction = function(item:Object, col:DataGridColumn):String {
				if (item.myCompartment) return item.myCompartment.myName;
				else return '';	};
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.dataField = 'myRegulation';
			dataGridColumn.headerText = 'Regulation';
			dataGridColumn.sortable = false;
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.dataField = 'myStyle';			
			dataGridColumn.headerText = 'Style';
			dataGridColumn.sortable = false;
			dataGridColumn.labelFunction = function(item:Object, col:DataGridColumn):String {
				if (item.myStyle) return item.myStyle.myName;
				else return ''; };
			dataGridColumns.push(dataGridColumn);
			
			dataGrid.columns = dataGridColumns;
		}	
				
		// Add biomolecule
		private function addBiomolecule(event:MouseEvent):void {
			var htmlError:String = HTML.validate(labelInput.text);
			if (htmlError!=null) errorMsg.text = 'Please enter a valid label. '+htmlError;
			else if (nameInput.text.length == 0) errorMsg.text = "Please select a name.";
			else if (!nameInput.text.charAt(0).match(/[a-z]/i)) errorMsg.text = 'Biomolecule name must start with a letter.';
			else if (compartmentInput.selectedItem == null) errorMsg.text = "Please select a compartment.";
			else if (styleInput.selectedItem == null) errorMsg.text = "Please select a style.";
			else if (!Biomolecule.validateRegulation(regulationInput.text,diagram)) errorMsg.text = "Please check the syntax of the regulation.";
			else {
				for (var i:uint = 0; i < diagram.biomolecules.length; i++) {
					if (diagram.biomolecules.getItemAt(i).myName == nameInput.text) {
						errorMsg.text = "Biomolecules with the same name are not allowed.";
						return;
					}
				}
				
				new Biomolecule(diagram, compartmentInput.selectedItem as CompartmentBase, styleInput.selectedItem as BiomoleculeStyle, 
					0, 0, nameInput.text, labelInput.text, regulationInput.text, commentsInput.text);
						
				clearInputs();
				biolist.selectedIndex = -1;
				checkButtonStatus();
			}
		}
		
		// Remove biomolecule
		private function removeBiomolecule(event:MouseEvent):void {
			(biolist.selectedItem as Biomolecule).remove();
			clearInputs();
			checkButtonStatus();
		}
		
		// Update biomolecule
		private function updateBiomolecule(event:MouseEvent):void {
			var htmlError:String = HTML.validate(labelInput.text);
			if(htmlError!=null) errorMsg.text = 'Please enter a valid label. '+htmlError;
			else if (nameInput.text.length == 0) errorMsg.text = "Please select a name.";
			else if (!nameInput.text.charAt(0).match(/[a-z]/i)) errorMsg.text = 'Biomolecule name must start with a letter.';
			else if (compartmentInput.selectedItem == null) errorMsg.text = "Please select a compartment.";
			else if (styleInput.selectedItem == null) errorMsg.text = "Please select a style.";
			else if (!Biomolecule.validateRegulation(regulationInput.text,diagram)) errorMsg.text = "Please check the syntax of the regulation.";
			else{
				for (var i:uint = 0; i < diagram.biomolecules.length; i++) {
					if (diagram.biomolecules[i] == biolist.selectedItem) continue;
					if (diagram.biomolecules.getItemAt(i).myName == nameInput.text) {
						errorMsg.text = "Biomolecules with the same name are not allowed.";
						return;
					}
				}
				
				biolist.selectedItem.update(nameInput.text, labelInput.text, regulationInput.text, compartmentInput.selectedItem, styleInput.selectedItem, commentsInput.text);
				clearInputs();
				biolist.selectedIndex = -1;
			}
		}		
		
		// Change event listener for DataGrid
		private function dgChangeHandler(event:ListEvent):void {
			currBiomolecule = biolist.selectedItem as Biomolecule;
			updateInputs();
		}
							
		private function updateInputs(event:BiomoleculeEvent = null):void {
			if(currBiomolecule!=null){
				nameInput.text = currBiomolecule.myName;
				labelInput.text = currBiomolecule.myLabel;
				compartmentInput.selectedItem = currBiomolecule.myCompartment;
				regulationInput.text = currBiomolecule.myRegulation;
				styleInput.selectedItem = currBiomolecule.myStyle;
				commentsInput.text = currBiomolecule.myComments;
				checkButtonStatus();
			}else clearInputs();
			
		}
		
		public function clearInputs():void {
			nameInput.text = "";
			labelInput.text = "";
			compartmentInput.selectedIndex = -1;
			regulationInput.text = "";
			styleInput.selectedIndex = -1;
			commentsInput.text = '';
			errorMsg.text = "";
			removeButton.enabled = false;
			updateButton.enabled = false;
		}
		
		private function checkButtonStatus():void {
			isRemoveButtonEnabled();
			isUpdateButtonEnabled();
		}
		
		private function isRemoveButtonEnabled():Boolean {
			removeButton.enabled = biolist.selectedItem != null;
			return removeButton.enabled;
		}
		
		private function isUpdateButtonEnabled():Boolean {
			updateButton.enabled = biolist.selectedItem != null;
			return updateButton.enabled;
		}

	}
	
}