package edu.stanford.covertlab.diagram.panel 
{
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.Panel;
	import mx.containers.TabNavigator;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.HSlider;
	import mx.controls.NumericStepper;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.validators.NumberValidator;
	
	/**
	 * Provides user interface for edit several advanced properties of a diagram.
	 * <ul>
	 * <li>Diagram width, height</li>
	 * <li>Toggle display of pores</li>
	 * <li>Horizontal, vertical spacing of biomolecules in auto layout</li>
	 * <li>Animation frame rate, number of repetitions</li>
	 * <li>Toggle display of biomolecule select handles, experiment colors on export</li>
	 * <li>Exported animation frame rate, number of repetitions</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.diagram.core.Diagram
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AdvancedOptionsPanel extends Panel
	{
		//diagram
		[Bindable] public var diagram:Diagram;
		
		//graphics
		private var diagramWidthInput:TextInput;
		private var diagramHeightInput:TextInput;
		private var showPoresInput:CheckBox;
		private var poreFillColor:ColorPicker;
		private var poreStrokeColor:ColorPicker;
		
		//layout
		private var ranksepInput:TextInput;
		private var nodesepInput:TextInput;
		
		//animation
		private var animationLoopInput:CheckBox;
		private var frameRateInput:HSlider;
		
		//export
		private var showSelectHandlesInput:CheckBox;
		private var colorBiomoleculesByValue:CheckBox;
		private var exportFrameRateInput:HSlider;
		private var exportAnimationLoopInput:CheckBox;
		
		//errors
		private var errorMsg:Text;
		
		public function AdvancedOptionsPanel()
		{
			var tabNavigator:TabNavigator;
			var form:Form;
			var formItem:FormItem;
			var controlBar:ControlBar;
			var button:Button;
						
			//style
			title = 'Advanced Options';
			
			//tab navigator
			tabNavigator = new TabNavigator();
			tabNavigator.percentHeight = 100;
			tabNavigator.percentWidth = 100;
			addChild(tabNavigator);
			
			//Display options
			form = new Form();
			form.percentWidth = 100;
			form.label = 'Graphics';			
			tabNavigator.addChild(form);
			
			formItem = new FormItem();
			formItem.label = 'Diagram Width';
			formItem.toolTip = 'Width of network diagram in pixels';
			diagramWidthInput = new TextInput();
			diagramWidthInput.restrict = '0-9';
			diagramWidthInput.width = 100;
			diagramWidthInput.addEventListener(FocusEvent.FOCUS_OUT, validateDiagramWidth);
			BindingUtils.bindProperty(diagramWidthInput, 'text', this, ['diagram', 'diagramWidth']);
			formItem.addChild(diagramWidthInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Diagram Height';
			formItem.toolTip = 'Height of diagram in pixels';
			diagramHeightInput = new TextInput();
			diagramHeightInput.restrict = '0-9';
			diagramHeightInput.width = 100;
			diagramHeightInput.addEventListener(FocusEvent.FOCUS_OUT, validateDiagramHeight);
			BindingUtils.bindProperty(diagramHeightInput, 'text', this, ['diagram', 'diagramHeight']);
			formItem.addChild(diagramHeightInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Show Pores';			
			showPoresInput = new CheckBox();
			BindingUtils.bindProperty(showPoresInput, 'selected', this, ['diagram', 'showPores']);
			formItem.addChild(showPoresInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Pore Fill';
			formItem.toolTip = 'Fill color of pores';
			poreFillColor = new ColorPicker();
			BindingUtils.bindProperty(poreFillColor, 'selectedColor', this, ['diagram', 'poreFillColor']);
			formItem.addChild(poreFillColor);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Pore Stroke';
			formItem.toolTip = 'Stroke color of pores';
			poreStrokeColor = new ColorPicker();
			BindingUtils.bindProperty(poreStrokeColor, 'selectedColor', this, ['diagram', 'poreStrokeColor']);
			formItem.addChild(poreStrokeColor);
			form.addChild(formItem);
			
			//Automatic graph layout options
			form = new Form();
			form.percentWidth = 100;
			form.label = 'Layout';
			tabNavigator.addChild(form);

			formItem = new FormItem();
			formItem.label = 'Vertical Separation';
			formItem.toolTip = 'Vertical separation between biomolecules in pixels';
			ranksepInput = new TextInput();
			ranksepInput.restrict = '0-9';
			ranksepInput.width = 100;
			ranksepInput.addEventListener(FocusEvent.FOCUS_OUT, validateRankSep);
			BindingUtils.bindProperty(ranksepInput, 'text', this, ['diagram', 'ranksep']);
			formItem.addChild(ranksepInput);
			form.addChild(formItem);

			formItem = new FormItem();
			formItem.label = 'Horizontal Separation';
			formItem.toolTip = 'Horizontal separation between biomolecules in pixels';
			nodesepInput = new TextInput();
			nodesepInput.restrict = '0-9';
			nodesepInput.width = 100;
			nodesepInput.addEventListener(FocusEvent.FOCUS_OUT, validateNodeSep);
			BindingUtils.bindProperty(nodesepInput, 'text', this, ['diagram', 'nodesep']);
			formItem.addChild(nodesepInput);
			form.addChild(formItem);
						
			//animation options
			form = new Form();
			form.label = 'Animation';
			tabNavigator.addChild(form);
			
			formItem = new FormItem();
			formItem.label = 'Frame Rate';
			formItem.toolTip = 'Animation frame rate (fpm)';			
			frameRateInput = new HSlider();
			frameRateInput.minimum = 1;
			frameRateInput.maximum = 100;
			BindingUtils.bindProperty(frameRateInput, 'value', this, ['diagram', 'animationFrameRate']);
			frameRateInput.snapInterval = 1;
			frameRateInput.width = 100;
			formItem.addChild(frameRateInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Loop';
			animationLoopInput = new CheckBox();
			BindingUtils.bindProperty(animationLoopInput, 'selected', this, ['diagram', 'loopAnimation']);			
			formItem.addChild(animationLoopInput);
			form.addChild(formItem);
			
			//export options
			form = new Form();
			form.percentWidth = 100;
			form.label = 'Export';
			tabNavigator.addChild(form);

			formItem = new FormItem();
			formItem.label = 'Show Biomolecule Selected Handles';
			showSelectHandlesInput = new CheckBox();
			BindingUtils.bindProperty(showSelectHandlesInput, 'selected', this, ['diagram', 'exportShowBiomoleculeSelectedHandles']);
			formItem.addChild(showSelectHandlesInput);			
			form.addChild(formItem);

			formItem = new FormItem();
			formItem.label = 'Color Biomolecules By Value';
			colorBiomoleculesByValue = new CheckBox();
			BindingUtils.bindProperty(colorBiomoleculesByValue, 'selected', this, ['diagram', 'exportColorBiomoleculesByValue']);
			formItem.addChild(colorBiomoleculesByValue);			
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Frame Rate';
			formItem.toolTip = 'Animation frame rate (fpm)';			
			exportFrameRateInput = new HSlider();
			exportFrameRateInput.minimum = 1;
			exportFrameRateInput.maximum = 100;
			BindingUtils.bindProperty(exportFrameRateInput, 'value', this, ['diagram', 'exportAnimationFrameRate']);
			exportFrameRateInput.snapInterval = 1;
			exportFrameRateInput.width = 100;
			formItem.addChild(exportFrameRateInput);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.label = 'Loop';
			exportAnimationLoopInput = new CheckBox();
			BindingUtils.bindProperty(exportAnimationLoopInput, 'selected', this, ['diagram', 'exportLoopAnimation']);			
			formItem.addChild(exportAnimationLoopInput);
			form.addChild(formItem);
			
			
			//control bar
			controlBar = new ControlBar();
			addChild(controlBar);
			
			errorMsg = new Text();
			errorMsg.percentWidth = 100;
			errorMsg.setStyle('color', 0xFF0000);
			errorMsg.setStyle('fontWeight', 'bold');
			controlBar.addChild(errorMsg);
						
			//save button
			button = new Button();
			button.label = 'Save';
			button.addEventListener(MouseEvent.CLICK, save);
			controlBar.addChild(button);
		}
		
		/*********************************************************
		 * save
		 * ******************************************************/;
		
		private function save(event:MouseEvent):void {
			if (!(validateDiagramWidth() && validateDiagramHeight() && validateRankSep() && validateNodeSep())) {
				errorMsg.text = 'Please correct errors and retry.';
				return;
			}
			errorMsg.text = '';
			
			diagram.updateAdvancedOptions(parseInt(diagramWidthInput.text), parseInt(diagramHeightInput.text),			
				showPoresInput.selected, poreFillColor.selectedColor, poreStrokeColor.selectedColor,			
				parseInt(ranksepInput.text), parseInt(nodesepInput.text), 						
				animationLoopInput.selected, frameRateInput.value,			
				showSelectHandlesInput.selected, colorBiomoleculesByValue.selected, exportFrameRateInput.value, exportAnimationLoopInput.selected);
		}
		
		/*********************************************************
		 * validators
		 * ******************************************************/;
		
		private function validateDiagramWidth(event:FocusEvent=null):Boolean {
			if (parseInt(diagramWidthInput.text) < 100) {
				diagramWidthInput.setStyle('borderColor', 0xFF0000);
				diagramWidthInput.errorString = 'Diagram width must be at least 100 pixels.';
				return false;
			}
			
			diagramWidthInput.setStyle('borderColor', 0xB7BABC);
			diagramWidthInput.errorString = '';
			return true;
		}
		
		private function validateDiagramHeight(event:FocusEvent = null):Boolean {
			if (parseInt(diagramHeightInput.text) < 100) {
				diagramHeightInput.setStyle('borderColor', 0xFF0000);
				diagramHeightInput.errorString = 'Diagram height must be at least 100 pixels.';
				return false;
			}
			
			diagramHeightInput.setStyle('borderColor', 0xB7BABC);
			diagramHeightInput.errorString = '';
			return true;
		}
		
		private function validateRankSep(event:FocusEvent=null):Boolean {
			if (parseInt(ranksepInput.text) > parseInt(diagramHeightInput.text) / 5) {				
				ranksepInput.setStyle('borderColor', 0xFF0000);
				ranksepInput.errorString = 'Vertical separation must less than 20% of diagram height.';
				return false;
			}
			
			ranksepInput.setStyle('borderColor', 0xB7BABC);
			ranksepInput.errorString = '';
			return true;
		}
		
		private function validateNodeSep(event:FocusEvent=null):Boolean {
			if (parseInt(nodesepInput.text) > parseInt(diagramWidthInput.text) / 5) {				
				nodesepInput.setStyle('borderColor', 0xFF0000);
				nodesepInput.errorString = 'Horizontal separation must be less than 20% of diagram width.';
				return false;
			}
			
			nodesepInput.setStyle('borderColor', 0xB7BABC);
			nodesepInput.errorString = '';
			return true;
		}
	}
	
}