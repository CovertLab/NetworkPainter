package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.chart.Chart;
	import edu.stanford.covertlab.chart.ChartToolTip;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.networkpainter.manager.ExperimentManager;
	import mx.collections.ArrayCollection;
	import mx.containers.ControlBar;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.ComboBox;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.events.ToolTipEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window displaying an experiment in the form of a heatmap.
	 * Heatmap x-dimension: animation dimension (typically timepoints).
	 * Heatmap y-dimension: biomolecule dimension (typically channels).
	 * A color scale is shown at the right. Additionally below the heatmap
	 * there are two comboboxes for selecting which value of the comparison-x
	 * and comparison-y dimensions to display in the heatmap.
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.ExperimentManager
	 * @see edu.stanford.covertlab.chart.Chart
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class HeatmapWindow extends TitleWindow
	{
		private var experimentManager:ExperimentManager;
		private var heatmap:Chart;
		private var _colormap:String;
		public var heatmapData:Array;
		public var viewthrough:Chart;
		private var comparisonXFormItem:FormItem;
		private var comparisonYFormItem:FormItem;
		private var comparisonX:ComboBox;
		private var comparisonY:ComboBox;
		
		public function HeatmapWindow(experimentManager:ExperimentManager) 
		{
			var controlBar:ControlBar;
			var form:Form;
			
			this.experimentManager = experimentManager;
			
			title = 'Heatmap';
			height = 500;
			width = 500;
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//heatmap
			heatmap = new Chart(Chart.CHARTTYPE_HEATMAP);
			addChild(heatmap);
			
			//viewthrough
			viewthrough=new Chart(Chart.CHARTTYPE_AREA, 
				{name: 'Intensity', scale:Chart.SCALE_LINEAR }, 
				{name: 'Frequency', scale:Chart.SCALE_LINEAR });
			
			//control bar
			controlBar = new ControlBar();
			addChild(controlBar);
			
			form = new Form();			
			form.styleName = 'TitleWindowForm';
			form.setStyle('layout', 'horizontal');
			form.setStyle('horizontalAlign', 'center');
			form.percentWidth = 100;
			controlBar.addChild(form);
			
			comparisonXFormItem = new FormItem();
			comparisonXFormItem.styleName = 'TitleWindowFormItem';
			form.addChild(comparisonXFormItem);	
			comparisonX = new ComboBox();			
			comparisonX.width = 150;
			comparisonX.height = 14;
			comparisonX.styleName = 'TitleWindowComboBox';
			comparisonX.labelField = 'name';
			comparisonXFormItem.addChild(comparisonX);
			comparisonX.addEventListener(ListEvent.CHANGE, updateData);
			
			comparisonYFormItem = new FormItem();
			comparisonYFormItem.styleName = 'TitleWindowFormItem';
			form.addChild(comparisonYFormItem);			
			comparisonY = new ComboBox();
			comparisonY.width = 150;
			comparisonY.height = 14;
			comparisonY.styleName = 'TitleWindowComboBox';
			comparisonY.labelField = 'name';
			comparisonYFormItem.addChild(comparisonY);
			comparisonY.addEventListener(ListEvent.CHANGE, updateData);
		}
		
		/********************************************************************
		 * getters, setter
		 * *****************************************************************/
		
		public function get colormap():String {
			return _colormap;
		}		
		public function set colormap(value:String):void {
			if (_colormap != value) {
				_colormap = value;
				heatmap.colormap = value;
			}			
		}
		
		/********************************************************************
		 * heatmap
		 * *****************************************************************/
		
		public function update():void {
			var biomoleculeAxisTickLabels:Array = [];
			var animationAxisTickLabels:Array = [];						
			var experiment:Object = experimentManager.experiment;
			var measurement:Array = experimentManager.measurementAndPerturbation;
			var colormapScale:Array = [-experimentManager.range, 0, experimentManager.range];
			
			if (experiment == null || measurement == null ) {
				heatmap.updateProperties(Chart.CHARTTYPE_HEATMAP,				
					{ name:experimentManager.animationAxis, tickLabels:[] }, 
					{ name:'Biomolecules', tickLabels:[] }, 
					[], colormap, [], 16, 12, 
					null);
				return;
			}
			
			comparisonXFormItem.label = experimentManager.comparisonXAxis;
			comparisonX.dataProvider = experimentManager.experiment[experimentManager.comparisonXAxis.toLowerCase()];
			comparisonX.selectedIndex = 0;			
			
			comparisonYFormItem.label = experimentManager.comparisonYAxis;
			comparisonY.dataProvider = experimentManager.experiment[experimentManager.comparisonYAxis.toLowerCase()];
			comparisonY.selectedIndex = 0;
			
			var heatmapData:Array = updateData();

			for (var i:uint = 0; i < measurement.length; i++) {
				if (i >= experiment.associationsAndPerturbations.length) continue;				
				if (!experimentManager.diagram.biomolecules.contains(experiment.associationsAndPerturbations[i].biomolecule)) continue;				
				biomoleculeAxisTickLabels.push(experiment.associationsAndPerturbations[i].biomolecule.myName);				
			}
			
			for (i = 0; i < experiment[experimentManager.animationAxis.toLowerCase()].length; i++){
				animationAxisTickLabels.push(experiment[experimentManager.animationAxis.toLowerCase()][i].name);
			}
			
			heatmap.updateProperties(Chart.CHARTTYPE_HEATMAP,				
				{ name:experimentManager.animationAxis, tickLabels:animationAxisTickLabels }, 
				{ name:'Biomolecules', tickLabels:biomoleculeAxisTickLabels }, 
				heatmapData, colormap, colormapScale, 16, 12, 
				createHeatmapViewThrough);
		}
		
		private function updateData(event:ListEvent = null):Array {		
			var heatmapData:Array = [];
			var experiment:Object = experimentManager.experiment;
			var measurement:Array = experimentManager.measurementAndPerturbation;
			
			if (experiment == null || measurement == null ) {
				heatmap.updateProperties(Chart.CHARTTYPE_HEATMAP,				
					{ name:experimentManager.animationAxis, tickLabels:[] }, 
					{ name:'Biomolecules', tickLabels:[] }, 
					[], colormap, [], 16, 12, 
					null);
				return [];
			}
			
			for (var i:uint = 0; i < measurement.length; i++) {
				if (i >= experiment.associationsAndPerturbations.length) continue;
				if (!experimentManager.diagram.biomolecules.contains(experiment.associationsAndPerturbations[i].biomolecule)) continue;
				var data:Array = [];
				for (var j:uint = 0; j < measurement[i].length; j++) {
					data.push(measurement[experiment.associationsAndPerturbations[i].channelid][j][comparisonX.selectedIndex][comparisonY.selectedIndex]);
				}
				heatmapData.push(data);
			}
			heatmap.chartData = heatmapData;
			
			return heatmapData;
		}
		
		private function createHeatmapViewThrough(event:ToolTipEvent):void {
			experimentManager.loadHeatmapViewthroughData(heatmap.toolTipTarget.hoverRow, heatmap.toolTipTarget.hoverCol, comparisonX.selectedIndex, comparisonY.selectedIndex);
			event.toolTip = new ChartToolTip('Heatmap View Through', viewthrough);
		}
		
		/********************************************************************
		 * open, close
		 * *****************************************************************/
		
		public function open():void {
			PopUpManager.addPopUp(this, experimentManager.application, false);
			PopUpManager.centerPopUp(this);
		}
		
		public function close(event:CloseEvent = null):void {			
			PopUpManager.removePopUp(this);
		}
		
	}
	
}