package edu.stanford.covertlab.networkpainter.window 
{
	import br.com.stimuli.string.printf;
	import edu.stanford.covertlab.analysis.HierarchicalClustering;
	import edu.stanford.covertlab.colormap.Colormap;
	import edu.stanford.covertlab.networkpainter.manager.ExperimentManager;
	import flash.events.Event;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.Accordion;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window for selecting.
	 * <ol>
	 * <li>Experiment to be displayed in each diagram axis -- biomolecule, 
	 *     animation, comparison-x, and comparison-y</li>
	 * <li>Scaling, normalizing, statistics, dynamic range for an experiment
	 *   <ul>
	 *   <li>equation: difference, ratio, fold change, log ratio, none</li>
	 *   <li>control: one of first, last, median, mean, minimum, maximum, none</li>
	 *       for each of biomolecule, animation, and comparison-x,y axes</li>
	 *   <li>statistics: mean, median, arcsinh medians, 95th percentile</li>
	 *   <ul></li>
	 * </ol>
	 * 
	 * <p>Preferences loaded from and saved to ExperimentManager. ExperimentManager
	 * also controls default values.</p>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.ExperimentManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ConfigureAxesWindow extends TitleWindow
	{
		private var experimentManager:ExperimentManager;
		
		private var channelAxis:ComboBox;
		private var conditionAxis:ComboBox;
		private var dosageAxis:ComboBox;
		private var individualAxis:ComboBox;
		private var populationAxis:ComboBox;
		private var timepointAxis:ComboBox;
		
		private var equation:ComboBox;
		private var biomoleculeAxisControl:ComboBox;
		private var animationAxisControl:ComboBox;
		private var comparisonXAxisControl:ComboBox;
		private var comparisonYAxisControl:ComboBox;
		private var dynamicRange:TextInput;
		private var colormap:ComboBox;

		private var clusterComparisonXAxis:CheckBox;
		private var clusterComparisonYAxis:CheckBox;
		private var optimalLeafOrder:CheckBox;
		private var distanceMetric:ComboBox;
		private var linkage:ComboBox;		
		
		private var errorMsg:Text;
		
		public function ConfigureAxesWindow(experimentManager:ExperimentManager) 
		{
			var accordion:Accordion;
			var form:Form;
			var formItem:FormItem;
			var controlBar:ControlBar;
			
			this.experimentManager = experimentManager;
			
			title = 'Configure Axes';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//accordion
			accordion = new Accordion();
			accordion.width = 260;
			accordion.height = 192;
			accordion.styleName = 'TitleWindowAccordion';
			addChild(accordion);
			
			//dimensions
			form = new Form();
			form.percentWidth = 100;
			form.percentHeight = 100;
			form.setStyle('paddingTop', 4);
			form.setStyle('paddingBottom', 2);
			form.setStyle('paddingLeft', 0);
			form.setStyle('paddingRight', 4);
			form.label = 'Dimensions';
			form.styleName = 'TitleWindowForm';
			accordion.addChild(form);
			
			formItem = new FormItem();			
			formItem.percentWidth = 100;
			formItem.label = 'Channel Axis';
			formItem.styleName = 'TitleWindowFormItem';
			channelAxis = new ComboBox();
			channelAxis.editable = false;
			channelAxis.percentWidth = 100;
			channelAxis.height = 14;
			channelAxis.styleName = 'TitleWindowComboBox';
			channelAxis.dataProvider = ExperimentManager.DIMENSIONS;
			channelAxis.labelField = 'name';
			channelAxis.enabled = false;
			channelAxis.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(channelAxisSetter, experimentManager, 'channelAxis');
			formItem.addChild(channelAxis);
			form.addChild(formItem);
			
			formItem = new FormItem();	
			formItem.percentWidth = 100;
			formItem.label = 'Condition Axis';
			formItem.styleName = 'TitleWindowFormItem';
			conditionAxis = new ComboBox();
			conditionAxis.editable = false;
			conditionAxis.percentWidth = 100;
			conditionAxis.height = 14;
			conditionAxis.styleName = 'TitleWindowComboBox';
			conditionAxis.dataProvider = ExperimentManager.DIMENSIONS;
			conditionAxis.labelField = 'name';
			conditionAxis.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(conditionAxisSetter, experimentManager, 'conditionAxis');
			formItem.addChild(conditionAxis);
			form.addChild(formItem);
			
			formItem = new FormItem();	
			formItem.percentWidth = 100;
			formItem.label = 'Dosage Axis';
			formItem.styleName = 'TitleWindowFormItem';
			dosageAxis = new ComboBox();
			dosageAxis.editable = false;
			dosageAxis.percentWidth = 100;
			dosageAxis.height = 14;
			dosageAxis.styleName = 'TitleWindowComboBox';
			dosageAxis.dataProvider = ExperimentManager.DIMENSIONS;
			dosageAxis.labelField = 'name';
			dosageAxis.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(dosageAxisSetter, experimentManager, 'dosageAxis');
			formItem.addChild(dosageAxis);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.percentWidth = 100;
			formItem.label = 'Individual Axis';
			formItem.styleName = 'TitleWindowFormItem';
			individualAxis = new ComboBox();
			individualAxis.editable = false;
			individualAxis.percentWidth = 100;
			individualAxis.height = 14;
			individualAxis.styleName = 'TitleWindowComboBox';
			individualAxis.dataProvider = ExperimentManager.DIMENSIONS;
			individualAxis.labelField = 'name';
			individualAxis.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(individualAxisSetter, experimentManager,'individualAxis');
			formItem.addChild(individualAxis);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.label = 'Population Axis';
			formItem.styleName = 'TitleWindowFormItem';
			populationAxis = new ComboBox();
			populationAxis.editable = false;
			populationAxis.percentWidth = 100;
			populationAxis.height = 14;
			populationAxis.styleName = 'TitleWindowComboBox';
			populationAxis.dataProvider = ExperimentManager.DIMENSIONS;
			populationAxis.labelField = 'name';
			populationAxis.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(populationAxisSetter, experimentManager,'populationAxis');
			formItem.addChild(populationAxis);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.label = 'Timepoint Axis';
			formItem.styleName = 'TitleWindowFormItem';
			timepointAxis = new ComboBox();
			timepointAxis.enabled = false;
			timepointAxis.editable = false;
			timepointAxis.percentWidth = 100;
			timepointAxis.height = 14;
			timepointAxis.styleName = 'TitleWindowComboBox';
			timepointAxis.dataProvider = ExperimentManager.DIMENSIONS;
			timepointAxis.labelField = 'name';
			timepointAxis.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(timepointAxisSetter, experimentManager,'timepointAxis');
			formItem.addChild(timepointAxis);
			form.addChild(formItem);	
			
			//scale
			form = new Form();
			form.percentWidth = 100;
			form.percentHeight = 100;
			form.setStyle('paddingTop', 4);
			form.setStyle('paddingBottom', 2);
			form.setStyle('paddingLeft', 0);
			form.setStyle('paddingRight', 4);
			form.label = 'Scale';
			form.styleName = 'TitleWindowForm';
			accordion.addChild(form);		
			
			formItem = new FormItem();			
			formItem.label = 'Equation';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			equation = new ComboBox();
			equation.editable = false;
			equation.percentWidth = 100;
			equation.height = 14;
			equation.styleName = 'TitleWindowComboBox';
			equation.dataProvider = ExperimentManager.EQUATIONS;
			equation.labelField = 'name';
			equation.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(equationSetter, experimentManager,'equation');
			formItem.addChild(equation);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Biomolecule Control';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			biomoleculeAxisControl = new ComboBox();
			biomoleculeAxisControl.editable = false;
			biomoleculeAxisControl.percentWidth = 100;
			biomoleculeAxisControl.height = 14;
			biomoleculeAxisControl.styleName = 'TitleWindowComboBox';
			biomoleculeAxisControl.dataProvider = ExperimentManager.CONTROLS;
			biomoleculeAxisControl.labelField = 'name';
			biomoleculeAxisControl.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(biomoleculeAxisControlSetter, experimentManager,'biomoleculeAxisControl');
			formItem.addChild(biomoleculeAxisControl);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Animation Control';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			animationAxisControl = new ComboBox();
			animationAxisControl.editable = false;
			animationAxisControl.percentWidth = 100;
			animationAxisControl.height = 14;
			animationAxisControl.styleName = 'TitleWindowComboBox';
			animationAxisControl.dataProvider = ExperimentManager.CONTROLS;
			animationAxisControl.labelField = 'name';
			animationAxisControl.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(animationAxisControlSetter, experimentManager,'animationAxisControl');
			formItem.addChild(animationAxisControl);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Comparison-X Control';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			comparisonXAxisControl = new ComboBox();
			comparisonXAxisControl.editable = false;
			comparisonXAxisControl.percentWidth = 100;
			comparisonXAxisControl.height = 14;
			comparisonXAxisControl.styleName = 'TitleWindowComboBox';
			comparisonXAxisControl.dataProvider = ExperimentManager.CONTROLS;
			comparisonXAxisControl.labelField = 'name';
			comparisonXAxisControl.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(comparisonXAxisControlSetter, experimentManager,'comparisonXAxisControl');
			formItem.addChild(comparisonXAxisControl);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Comparison-Y Control';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			comparisonYAxisControl = new ComboBox();
			comparisonYAxisControl.editable = false;
			comparisonYAxisControl.percentWidth = 100;
			comparisonYAxisControl.height = 14;
			comparisonYAxisControl.styleName = 'TitleWindowComboBox';
			comparisonYAxisControl.dataProvider = ExperimentManager.CONTROLS;
			comparisonYAxisControl.labelField = 'name';
			comparisonYAxisControl.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(comparisonYAxisControlSetter, experimentManager,'comparisonYAxisControl');
			formItem.addChild(comparisonYAxisControl);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Dynamic Range';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			dynamicRange = new TextInput();
			dynamicRange.restrict = '0-9.';
			dynamicRange.percentWidth = 100;
			dynamicRange.height = 14;
			dynamicRange.styleName = 'TitleWindowTextInput';		
			dynamicRange.addEventListener(Event.CHANGE, save);
			BindingUtils.bindSetter(function(value:Number):void { dynamicRange.text = (isNaN(value) ? '' : value.toString()); }, experimentManager, 'dynamicRange');
			formItem.addChild(dynamicRange);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Colormap';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			colormap = new ComboBox();
			colormap.percentWidth = 100;
			colormap.height = 14;
			colormap.styleName = 'TitleWindowComboBox';		
			colormap.dataProvider = Colormap.COLORMAPS;
			colormap.labelField = 'name';
			colormap.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(colormapSetter, experimentManager,'colormap');
			formItem.addChild(colormap);
			form.addChild(formItem);
							
			//scale
			form = new Form();
			form.percentWidth = 100;
			form.percentHeight = 100;
			form.setStyle('paddingTop', 4);
			form.setStyle('paddingBottom', 2);
			form.setStyle('paddingLeft', 0);
			form.setStyle('paddingRight', 4);
			form.label = 'Clustering';
			form.styleName = 'TitleWindowForm';
			accordion.addChild(form);
			
			formItem = new FormItem();			
			formItem.label = 'Comparison-X Axis';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			clusterComparisonXAxis = new CheckBox();
			clusterComparisonXAxis.addEventListener(Event.CHANGE, save);
			BindingUtils.bindProperty(clusterComparisonXAxis, 'selected', experimentManager, 'clusterComparisonXAxis');
			formItem.addChild(clusterComparisonXAxis);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Comparison-Y Axis';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			clusterComparisonYAxis = new CheckBox();
			clusterComparisonYAxis.addEventListener(Event.CHANGE, save);
			BindingUtils.bindProperty(clusterComparisonYAxis, 'selected', experimentManager, 'clusterComparisonYAxis');
			formItem.addChild(clusterComparisonYAxis);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Optimal Leaf Order';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			optimalLeafOrder = new CheckBox();
			optimalLeafOrder.addEventListener(Event.CHANGE, save);
			BindingUtils.bindProperty(optimalLeafOrder, 'selected', experimentManager, 'optimalLeafOrder');
			formItem.addChild(optimalLeafOrder);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Distance Metric';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			distanceMetric = new ComboBox();
			distanceMetric.percentWidth = 100;
			distanceMetric.height = 14;
			distanceMetric.styleName = 'TitleWindowComboBox';		
			distanceMetric.dataProvider = HierarchicalClustering.DISTANCE_METRICS;
			distanceMetric.labelField = 'name';
			distanceMetric.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(distanceMetricSetter, experimentManager,'distanceMetric');
			formItem.addChild(distanceMetric);
			form.addChild(formItem);
			
			formItem = new FormItem();			
			formItem.label = 'Linkage';
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			linkage = new ComboBox();
			linkage.percentWidth = 100;
			linkage.height = 14;
			linkage.styleName = 'TitleWindowComboBox';		
			linkage.dataProvider = HierarchicalClustering.LINKAGES;
			linkage.labelField = 'name';
			linkage.addEventListener(ListEvent.CHANGE, save);
			BindingUtils.bindSetter(linkageSetter, experimentManager, 'linkage');
			formItem.addChild(linkage);
			form.addChild(formItem);
			
			//control bar
			controlBar = new ControlBar();
			addChild(controlBar);
			
			errorMsg = new Text();
			errorMsg.percentWidth = 100;
			errorMsg.setStyle('color', 0xFF0000);
			errorMsg.setStyle('fontWeight', 'bold');
			controlBar.addChild(errorMsg);			
		}
		
		/********************************************************************
		 * save
		 * *****************************************************************/
		private function channelAxisSetter(value:String):void {
			for (var i:uint = 0; i < channelAxis.dataProvider.length; i++) {
				if (value == channelAxis.dataProvider[i].name) {
					channelAxis.selectedIndex = i;
					return;
				}
			}
			channelAxis.selectedIndex = 0;
		}
		
		private function conditionAxisSetter(value:String):void {
			for (var i:uint = 0; i < conditionAxis.dataProvider.length; i++) {
				if (value == conditionAxis.dataProvider[i].name) {
					conditionAxis.selectedIndex = i;
					return;
				}
			}
			conditionAxis.selectedIndex = 0;
		} 
		
		private function dosageAxisSetter(value:String):void {
			for (var i:uint = 0; i < dosageAxis.dataProvider.length; i++) {
				if (value == dosageAxis.dataProvider[i].name) {
					dosageAxis.selectedIndex = i;
					return;
				}
			}
			dosageAxis.selectedIndex = 0;
		}
		
		private function individualAxisSetter(value:String):void {
			for (var i:uint = 0; i < individualAxis.dataProvider.length; i++) {
				if (value == individualAxis.dataProvider[i].name) {
					individualAxis.selectedIndex = i;
					return;
				}
			}
			individualAxis.selectedIndex = 0;
		}
		
		private function populationAxisSetter(value:String):void {
			for (var i:uint = 0; i < populationAxis.dataProvider.length; i++) {
				if (value == populationAxis.dataProvider[i].name) {
					populationAxis.selectedIndex = i;
					return;
				}
			}
			populationAxis.selectedIndex = 0;
		}
		
		private function timepointAxisSetter(value:String):void {
			for (var i:uint = 0; i < timepointAxis.dataProvider.length; i++) {
				if (value == timepointAxis.dataProvider[i].name) {
					timepointAxis.selectedIndex = i;
					return;
				}
			}
			timepointAxis.selectedIndex = 0;
		}
		
		private function equationSetter(value:String):void {
			for (var i:uint = 0; i < ExperimentManager.EQUATIONS.length; i++) {
				if (value == ExperimentManager.EQUATIONS[i].name) {
					equation.selectedIndex = i;
					break;
				}
			}
		}
		
		private function biomoleculeAxisControlSetter(value:String):void {
			for (var i:uint = 0; i < ExperimentManager.CONTROLS.length; i++) {
				if (value == ExperimentManager.CONTROLS[i].name) {
					biomoleculeAxisControl.selectedIndex = i;
					break;
				}
			}
		}
		
		private function animationAxisControlSetter(value:String):void {
			for (var i:uint = 0; i < ExperimentManager.CONTROLS.length; i++) {
				if (value == ExperimentManager.CONTROLS[i].name) {
					animationAxisControl.selectedIndex = i;
					break;
				}
			}
		}
		
		private function comparisonXAxisControlSetter(value:String):void {
			for (var i:uint = 0; i < ExperimentManager.CONTROLS.length; i++) {
				if (value == ExperimentManager.CONTROLS[i].name) {
					comparisonXAxisControl.selectedIndex = i;
					break;
				}
			}
		}
		
		private function comparisonYAxisControlSetter(value:String):void {
			for (var i:uint = 0; i < ExperimentManager.CONTROLS.length; i++) {
				if (value == ExperimentManager.CONTROLS[i].name) {
					comparisonYAxisControl.selectedIndex = i;
					break;
				}
			}
		}
		
		private function colormapSetter(value:String):void {
			for (var i:uint = 0; i < Colormap.COLORMAPS.length; i++) {
				if (value == Colormap.COLORMAPS[i].name) {
					colormap.selectedIndex = i;
					break;
				}
			}
		}
		
		private function distanceMetricSetter(value:String):void {
			for (var i:uint = 0; i < HierarchicalClustering.DISTANCE_METRICS.length; i++) {
				if (value == HierarchicalClustering.DISTANCE_METRICS[i].name) {
					distanceMetric.selectedIndex = i;
					break;
				}
			}
		}
		
		private function linkageSetter(value:String):void {
			for (var i:uint = 0; i < HierarchicalClustering.LINKAGES.length; i++) {
				if (value == HierarchicalClustering.LINKAGES[i].name) {
					linkage.selectedIndex = i;
					break;
				}
			}
		}
		
		/********************************************************************
		 * save
		 * *****************************************************************/
		private function save(event:Event):void {
			var key:String;
			
			errorMsg.text = '';
						
			var dims:Object = {
				channel: channelAxis,
				condition: conditionAxis,
				dosage: dosageAxis,
				individual: individualAxis,
				population: populationAxis,
				timepoint: timepointAxis
			}
			
			//error check axis assignments
			for (var i:uint = 1; i < ExperimentManager.DIMENSIONS.length; i++) {
				var cnt:uint = 0;
				for (key in dims)
					cnt += dims[key].selectedIndex == i;
				if (cnt == 0) {
					errorMsg.text += 'Please select assign a ' + ExperimentManager.DIMENSIONS[i].name + ' axis.';
				}else if (cnt > 1) {
					if (ExperimentManager.DIMENSIONS[i].name == 'Biomolecule') {
						errorMsg.text += 'Biomolecules must be assigned to the channel axis.';
					} else if (ExperimentManager.DIMENSIONS[i].name == 'Animation') {
						errorMsg.text += 'Animation must be assigned to the timepoint axis.';
					} else{
						for (key in dims) {
							if (experimentManager[key + 'Axis'] == ExperimentManager.DIMENSIONS[i].name)
								this[key + 'AxisSetter']('');
						}
					}
				}
			}
			
			//revert changes
			if (errorMsg.text != '') {
				for (key in dims) {
					this[key + 'AxisSetter'](experimentManager[key + 'Axis']);
				}
				return;
			}
			
			//save changes
			experimentManager.setAxes(
				channelAxis.selectedItem.name, conditionAxis.selectedItem.name, dosageAxis.selectedItem.name, 
				individualAxis.selectedItem.name, populationAxis.selectedItem.name, timepointAxis.selectedItem.name, 
				biomoleculeAxisControl.selectedItem.name, animationAxisControl.selectedItem.name, comparisonXAxisControl.selectedItem.name, comparisonYAxisControl.selectedItem.name, 
				equation.selectedItem.name, (dynamicRange.text == '' ? NaN : parseFloat(dynamicRange.text)), colormap.selectedItem.name, 
				clusterComparisonXAxis.selected, clusterComparisonYAxis.selected, 
				optimalLeafOrder.selected, distanceMetric.selectedItem.name, linkage.selectedItem.name);
		}
		
		/********************************************************************
		 * open, close
		 * *****************************************************************/
		public function open():void {
			PopUpManager.addPopUp(this, experimentManager.application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function close(event:CloseEvent = null):void {
			PopUpManager.removePopUp(this);
		}		
	}	
}