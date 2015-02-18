package edu.stanford.covertlab.networkpainter.manager 
{
	import br.com.stimuli.string.printf;
	import com.adobe.serialization.json.JSON;
	import com.degrafa.core.collections.DisplayObjectCollection;
	import com.degrafa.core.Measure;
	import com.degrafa.triggers.EventTrigger;
	import edu.stanford.covertlab.analysis.HierarchicalClustering;
	import edu.stanford.covertlab.chart.ColorScale;
	import edu.stanford.covertlab.colormap.Colormap;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.manager.UserManager;
	import edu.stanford.covertlab.networkpainter.event.ExperimentManagerEvent;
	import edu.stanford.covertlab.networkpainter.event.NetworkManagerEvent;	
	import edu.stanford.covertlab.networkpainter.simulation.BooleanSimulation;
	import edu.stanford.covertlab.networkpainter.window.ConfigureAxesWindow;
	import edu.stanford.covertlab.networkpainter.window.ManageExperimentsWindow;
	import edu.stanford.covertlab.service.NetworkPainterExperiments;
	import edu.stanford.covertlab.util.ArrayMathUtils;
	import edu.stanford.covertlab.util.AS2MXML;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.controls.MenuBar;
	import mx.controls.menuClasses.MenuBarItem;
	import mx.core.Application;
	import mx.rpc.events.FaultEvent;
	import phi.db.Query;
	import phi.interfaces.IDatabase;
	import phi.interfaces.IQuery;
	
	/**
	 * Handles several experiment-related operations.
	 * <ul>
	 * <li>load list of CytoBank experiments available to a user, and 
	 *     display in ManageExperimentWindow</li>
	 * <li>associate biomolecules in the current network with conditions and channels
	 *     in experiments</li>
	 * <li>maintain list of experiments associated with the current network
	 *   <ul>
	 *   <li>display list in main menu</li>
	 *   <li>highlight associated experiments in ManageExperimentsWindow</li>
	 *   </ul></li>
	 * <li>fetch experiment statistics (median, arcsinh median, 95th percentile, etc)
	 *     from CytoBank</li>
	 * <li>normalize, scale statistics</li>
	 * <li>multidensional clustering, optimal leaf ordering of experiment dimensions</li>
	 * <li>link experiment dimensions (channels, conditions, dosages, individuals, populations, 
	 *     timepoints) to display dimensions (biomolecules, animation, comparison-x,y)
	 *     in the ConfigureAxesWindow</li>
	 * <li>Select normalization, scaling, statistics, dynamic range parameters in 
	 *     ConfigureAxesWindow</li>
	 * <li>Load experimental data into Diagram</li>
	 * <li>Load experimental data into HeatmapWindow, display 1D channel distribution
	 *     chart tool tips</li>
	 * <li>save experiment associations to database</li>
	 * <li>save axes, normalization scaling preferences to database</li>
	 * <li>export experiment
	 *   <ul>
	 *   <li>animation: gif, pdf, mxml for compilation to swf</li>
	 *   <li>simulation: m</li>
	 *   </ul></li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.window.ManageExperimentsWindow
	 * @see edu.stanford.covertlab.networkpainter.window.ConfigureAxesWindow
	 * @see edu.stanford.covertlab.analysis.HierarchicalClustering
	 * @see edu.stanford.covertlab.util.AS2MXML
	 * @see edu.stanford.covertlab.util.AS2XML
	 * @see edu.stanford.covertlab.networkpainter.simulation.BooleanSimulation
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ExperimentManager extends EventDispatcher
	{
		
		public var application:Application;
		private var userManager:UserManager;
		private var networkManager:NetworkManager;
		public var diagram:Diagram;
		private var networkPainter:NetworkPainterExperiments;	
		
		//windows
		public var manageExperimentsWindow:ManageExperimentsWindow;
		public var configureAxesWindow:ConfigureAxesWindow;
		
		//color scale
		[Bindable] public var colorScale:ColorScale;
		
		//file reference
		private var exportFileReference:FileReference;
		
		//experiment
		[Bindable] public var experiments:ArrayCollection;
		
		//axes
		[Bindable] public var biomoleculeAxis:String;
		[Bindable] public var animationAxis:String;
		[Bindable] public var comparisonXAxis:String;
		[Bindable] public var comparisonYAxis:String;
		[Bindable] public var channelAxis:String;
		[Bindable] public var conditionAxis:String;
		[Bindable] public var dosageAxis:String;
		[Bindable] public var individualAxis:String;
		[Bindable] public var populationAxis:String;
		[Bindable] public var timepointAxis:String;
		
		//controls
		[Bindable] public var biomoleculeAxisControl:String;
		[Bindable] public var animationAxisControl:String;
		[Bindable] public var comparisonXAxisControl:String;
		[Bindable] public var comparisonYAxisControl:String;
		
		//scales
		[Bindable] public var equation:String;
		[Bindable] public var dynamicRange:Number;
		[Bindable] public var colormap:String;
		
		//clustering
		[Bindable] public var clusterComparisonXAxis:Boolean;
		[Bindable] public var clusterComparisonYAxis:Boolean;		
		[Bindable] public var optimalLeafOrder:Boolean;
		[Bindable] public var distanceMetric:String;
		[Bindable] public var linkage:String;
				
		//constants
		public static const DIMENSIONS:ArrayCollection = new ArrayCollection([ 
			{ name:'' },
			{ name:'Biomolecule' },
			{ name:'Animation' },
			{ name:'Comparison-X' },
			{ name:'Comparison-Y' }]);
		public static const EQUATIONS:ArrayCollection = new ArrayCollection([ 
			{ name:'Difference' }, 
			{ name:'Log 10 ratio' }, 
			{ name:'Raw' } ]);
		public static const CONTROLS:ArrayCollection = new ArrayCollection([ 
			{name:'None' },
			{name:'First' },
			{name:'Last' },
			{name:'Minimum' },
			{name:'Maximum' },
			{name:'Mean' },
			{name:'Median' }
			]);
		
		public function ExperimentManager(application:Application, userManager:UserManager, networkManager:NetworkManager, diagram:Diagram, db:IDatabase) 
		{
			this.application = application;
			this.userManager = userManager;
			this.networkManager = networkManager;
			this.diagram = diagram;
			
			this.experiments = new ArrayCollection();
			
			var sort:Sort = new Sort();
			sort.fields = [new SortField('name', true)];
			this.experiments.sort = sort;
			
			//bind network new, load, save events
			networkManager.addEventListener(NetworkManagerEvent.NETWORK_NEW, clearExperiments);
			networkManager.addEventListener(NetworkManagerEvent.NETWORK_LOADED, getExperiments);
			networkManager.addEventListener(NetworkManagerEvent.NETWORK_SAVED, setExperiments);
		
			//experiment database interaction
			networkPainter = new NetworkPainterExperiments();
			networkPainter.addEventListener(NetworkPainterExperiments.GET_EXPERIMENTS, getExperimentsHandler);
			networkPainter.addEventListener(NetworkPainterExperiments.SET_EXPERIMENTS, setExperimentsHandler);
			networkPainter.addEventListener(NetworkPainterExperiments.FAULT, networkPainterErrorHandler);
			
			//windows
			manageExperimentsWindow = new ManageExperimentsWindow(this, diagram);
			configureAxesWindow = new ConfigureAxesWindow(this);
			
			//color scale
			colorScale = new ColorScale(colormap, [ -1, 0, 1], 20, 200);
			colorScale.x = diagram.width - colorScale.width - 10;
			colorScale.y = 25;
			diagram.addChild(colorScale);
			BindingUtils.bindProperty(colorScale, 'colormap', this, 'colormap');
			BindingUtils.bindProperty(diagram, 'colormap', this, 'colormap');
			
			//file reference
			exportFileReference = new FileReference();
		}
		
		/***********************************************************
		 * reseting
		 * *********************************************************/
		public function clearExperiments(evt:NetworkManagerEvent = null):void {
			//associations, experiments
			experiments.removeAll();
			manageExperimentsWindow.setSelectedExperiment();
						
			//axes
			setAxes(
				//dimensions
				'Biomolecule', 'Comparison-X', '', 'Comparison-Y', '', 'Animation', 
				
				//controls
				'None', 'First', 'None', 'None', 
				
				//scales
				'Difference', NaN, Colormap.CYTOBANK_BLUE_YELLOW, 
				
				//clustering
				false, false, 
				true, HierarchicalClustering.DISTANCE_METRIC_EUCLIDEAN, HierarchicalClustering.LINKAGE_AVERAGE);
				
			if (diagram.animationPlaying)
				diagram.stopAnimation();
			diagram.clearMeasurement();
		}
		
		/***********************************************************
		 * get experiments
		 * *********************************************************/

		private function getExperiments(event:Event):void {
			networkPainter.getExperiments(networkManager.id);
		}
		
		private function getExperimentsHandler(event:Event):void {
			var r:Object = networkPainter.result;
			fromObject(r);
			
			//update config window
			autoPlayExperiment();
		}
		
		private function setExperiments(event:Event):void {
			networkPainter.setExperiments(networkManager.id, toObject());
		}
		
		private function setExperimentsHandler(event:Event):void {			
		}
		
		/**
		 * Auto setup experiment on login. If network id is specified in flash vars after loading network,
		 * <ul>
		 * <li>If experiment id is also specified in flash vars, and experiment is associated, load experiment</li>
		 * <li>If experiment id is also specified, but experiment is not associated, open manage experiments window and select the experiment</li>
		 * <li>If experiment id is not specified, do nothing</li>
		 * </ul>
		 */
		private function autoPlayExperiment():void {			
			if (Application.application.parameters['experimentid'] != '') {
				var experimentId:uint = parseInt(Application.application.parameters['experimentid']);
				manageExperimentsWindow.setSelectedExperiment(experimentId);
				animateExperiment(experiments[experimentId] as Object);
			}
			
			Application.application.parameters['experimentid'] = '';
		}
		
		/***********************************************************
		 * axes
		 * *********************************************************/
		public function setAxes(
			channelAxis:String, conditionAxis:String, dosageAxis:String, individualAxis:String, populationAxis:String, timepointAxis:String,
			biomoleculeAxisControl:String, animationAxisControl:String, comparisonXAxisControl:String, comparisonYAxisControl:String,
			equation:String, dynamicRange:Number, colormap:String, 
			clusterComparisonXAxis:Boolean, clusterComparisonYAxis:Boolean, 
			optimalLeafOrder:Boolean, distanceMetric:String, linkage:String):void {
				
			this.channelAxis = channelAxis;
			this.conditionAxis = conditionAxis;
			this.dosageAxis = dosageAxis;
			this.individualAxis = individualAxis;
			this.populationAxis = populationAxis;
			this.timepointAxis = timepointAxis;
			
			this.biomoleculeAxisControl = biomoleculeAxisControl;
			this.animationAxisControl = animationAxisControl;
			this.comparisonXAxisControl = comparisonXAxisControl;
			this.comparisonYAxisControl = comparisonYAxisControl;			
			
			this.equation = equation;			
			this.dynamicRange = dynamicRange;
			this.colormap = colormap;
		
			this.clusterComparisonXAxis = clusterComparisonXAxis;
			this.clusterComparisonYAxis = clusterComparisonYAxis;
			this.optimalLeafOrder = optimalLeafOrder;
			this.distanceMetric = distanceMetric;
			this.linkage = linkage;
			
			setDiagramAxesFromExperimentAxes();
						
			if (diagram.animationPlaying && manageExperimentsWindow.experimentsList.selectedItem) {
				animateExperiment(manageExperimentsWindow.experimentsList.selectedItem, false);
			}
		}
		
		private function setDiagramAxesFromExperimentAxes():void {
			switch(channelAxis) {
				case 'Biomolecule': biomoleculeAxis = 'Channels'; break;
				case 'Animation': animationAxis = 'Channels'; break;
				case 'Comparison-X': comparisonXAxis = 'Channels'; break; 
				case 'Comparison-Y': comparisonYAxis = 'Channels'; break;
			}
			
			switch(conditionAxis) {
				case 'Biomolecule': biomoleculeAxis = 'Conditions'; break;
				case 'Animation': animationAxis = 'Conditions'; break;
				case 'Comparison-X': comparisonXAxis = 'Conditions'; break; 
				case 'Comparison-Y': comparisonYAxis = 'Conditions'; break;
			}
			
			switch(dosageAxis) {
				case 'Biomolecule': biomoleculeAxis = 'Dosages'; break;
				case 'Animation': animationAxis = 'Dosages'; break;
				case 'Comparison-X': comparisonXAxis = 'Dosages'; break; 
				case 'Comparison-Y': comparisonYAxis = 'Dosages'; break;
			}			
			
			switch(individualAxis) {
				case 'Biomolecule': biomoleculeAxis = 'Individuals'; break;
				case 'Animation': animationAxis = 'Individuals'; break;
				case 'Comparison-X': comparisonXAxis = 'Individuals'; break; 
				case 'Comparison-Y': comparisonYAxis = 'Individuals'; break;
			}
			
			switch(populationAxis) {
				case 'Biomolecule': biomoleculeAxis = 'Populations'; break;
				case 'Animation': animationAxis = 'Populations'; break;
				case 'Comparison-X': comparisonXAxis = 'Populations'; break; 
				case 'Comparison-Y': comparisonYAxis = 'Populations'; break;
			}
			
			switch(timepointAxis) {
				case 'Biomolecule': biomoleculeAxis = 'Timepoints'; break;
				case 'Animation': animationAxis = 'Timepoints'; break;
				case 'Comparison-X': comparisonXAxis = 'Timepoints'; break; 
				case 'Comparison-Y': comparisonYAxis = 'Timepoints'; break;
			}
		}
		
		public function animateExperiment(experiment:Object, play:Boolean = true):void {
			var tmp:Array = reshapeScaleClusterStatistics(experiment);
			diagram.loadMeasurement(tmp[1], 
				experiment[animationAxis.toLowerCase()], experiment[comparisonXAxis.toLowerCase()], experiment[comparisonYAxis.toLowerCase()], 
				tmp[0]);
			
			if (play && !diagram.animationPlaying) {
				diagram.playPauseAnimation();
			}
		}
		
		/*************************************************************
		 * reshaping, scaling, clustering/optimal leaf order
		 ************************************************************/	
		//1. reshape, merge panels
		//2. average over unplotted dimensions
		//3. compute control values
		//4. apply equation
		//5. scale to range
		//6. cluster
		private function reshapeScaleClusterStatistics(experiment:Object):Array {	
			var tmp:Array;
			var i:int;
			var j:int;
			var k:int;
			var l:int;
			
			var channels:Array = [];
			var conditions:Array = [];
			var dosages:Array = [];
			var individuals:Array = [];
			var populations:Array = [];
			var timepoints:Array = [];
			for (i = 0; i < experiment.channels.length; i++) channels.push(experiment.channels[i].name);
			for (i = 0; i < experiment.conditions.length; i++) conditions.push(experiment.conditions[i].name);
			for (i = 0; i < experiment.dosages.length; i++) dosages.push(experiment.dosages[i].name);
			for (i = 0; i < experiment.individuals.length; i++) individuals.push(experiment.individuals[i].name);
			for (i = 0; i < experiment.populations.length; i++) populations.push(experiment.populations[i].name);
			for (i = 0; i < experiment.timepoints.length; i++) timepoints.push(experiment.timepoints[i].name);
			
			//setup array for holding reshaped data
			var reshapedStatistics:Array = [];
			var controlValue:Array = [];
			for (i = 0; i < experiment[biomoleculeAxis.toLowerCase()].length + experiment.perturbations.length; i++) {
				reshapedStatistics.push([]);
				controlValue.push([]);
				for (j = 0; j < experiment[animationAxis.toLowerCase()].length; j++) {
					reshapedStatistics[i].push([]);
					controlValue[i].push([]);
					for (k = 0; k < experiment[comparisonXAxis.toLowerCase()].length; k++) {
						reshapedStatistics[i][j].push([]);
						controlValue[i][j].push([]);
						for (l = 0; l < experiment[comparisonYAxis.toLowerCase()].length; l++) {
							reshapedStatistics[i][j][k].push([]);
							controlValue[i][j][k].push([]);
						}
					}
				}
			}
			
			var biomoleculeAssociations:Array = [];
			for (i = 0; i < experiment.associations.length; i++) {
				biomoleculeAssociations.push( { 
					measurementIdx: channels.indexOf(experiment.associations[i].channel),
					biomolecule: experiment.associations[i].biomolecule
					} );
			}
			for (i = 0; i < experiment.perturbations.length; i++) {
				biomoleculeAssociations.push( { 
					measurementIdx: experiment.channels.length + i, 
					biomolecule: experiment.perturbations[i].biomolecule
					} );
			}
			
			var associatedMeasurements:Array = [];
			for (i = 0; i < reshapedStatistics.length; i++)
				associatedMeasurements.push(false);
			for (i = 0; i < biomoleculeAssociations.length; i++)
				associatedMeasurements[biomoleculeAssociations[i].measurementIdx] = true;
			
			//reshape, merge panels			
			var statistics:Array = experiment.statistics;
			for (var idx:uint = 0; idx < statistics.length; idx++) {
				i = j = k = l = -1;
				
				switch(biomoleculeAxis) {
					case 'Channels': i = channels.indexOf(statistics[idx].channel); break;
					case 'Conditions': i = conditions.indexOf(statistics[idx].condition); break;
					case 'Dosages': i = dosages.indexOf(statistics[idx].dosage); break;
					case 'Individuals': i = individuals.indexOf(statistics[idx].individual); break;
					case 'Populations': i = populations.indexOf(statistics[idx].population); break;
					case 'Timepoints': i = timepoints.indexOf(statistics[idx].timepoint); break;
				}
				
				switch(animationAxis) {
					case 'Channels': j = channels.indexOf(statistics[idx].channel); break;
					case 'Conditions': j = conditions.indexOf(statistics[idx].condition); break;
					case 'Dosages': j = dosages.indexOf(statistics[idx].dosage); break;
					case 'Individuals': j = individuals.indexOf(statistics[idx].individual); break;
					case 'Populations': j = populations.indexOf(statistics[idx].population); break;
					case 'Timepoints': j = timepoints.indexOf(statistics[idx].timepoint); break;
				}
				
				switch(comparisonXAxis) {
					case 'Channels': k = channels.indexOf(statistics[idx].channel); break;
					case 'Conditions': k = conditions.indexOf(statistics[idx].condition); break;
					case 'Dosages': k = dosages.indexOf(statistics[idx].dosage); break;
					case 'Individuals': k = individuals.indexOf(statistics[idx].individual); break;
					case 'Populations': k = populations.indexOf(statistics[idx].population); break;
					case 'Timepoints': k = timepoints.indexOf(statistics[idx].timepoint); break;
				}
				
				switch(comparisonYAxis) {
					case 'Channels': l = channels.indexOf(statistics[idx].channel); break;
					case 'Conditions': l = conditions.indexOf(statistics[idx].condition); break;
					case 'Dosages': l = dosages.indexOf(statistics[idx].dosage); break;
					case 'Individuals': l = individuals.indexOf(statistics[idx].individual); break;
					case 'Populations': l = populations.indexOf(statistics[idx].population); break;
					case 'Timepoints': l = timepoints.indexOf(statistics[idx].timepoint); break;
				}
				
				if (i == -1 || j == -1 || k == -1 || l == -1)
					continue;
							
				reshapedStatistics[i][j][k][l].push(statistics[idx].value);
			}
			
			//perturbations
			for (i = 0; i < experiment.perturbations.length; i++) {
				for (j = 0; j < experiment[animationAxis.toLowerCase()].length; j++) {
					for (k = 0; k < experiment[comparisonXAxis.toLowerCase()].length; k++) {
						var pFlag:Boolean = (comparisonXAxis == 'Conditions' && experiment.conditions[k].name == experiment.perturbations[i].condition);						
						for (l = 0; l < experiment[comparisonYAxis.toLowerCase()].length; l++) {
							pFlag = pFlag || (comparisonYAxis == 'Conditions' && experiment.conditions[l].name == experiment.perturbations[i].condition);
							if (pFlag)
							{
								var i2:uint = i + experiment[biomoleculeAxis.toLowerCase()].length;
								reshapedStatistics[i2][j][k][l].push(experiment.perturbations[i].activity == 'On' ? 1 : 0);
							}
						}
					}
				}
			}				
			
			//average
			for (i = 0; i < reshapedStatistics.length; i++) {
				for (j = 0; j < reshapedStatistics[i].length; j++) {
					for (k = 0; k < reshapedStatistics[i][j].length; k++) {
						for (l = 0; l < reshapedStatistics[i][j][k].length; l++) {
							controlValue[i][j][k][l] = reshapedStatistics[i][j][k][l] = ArrayMathUtils.mean(reshapedStatistics[i][j][k][l]);
						}
					}
				}
			}
			
			//compute control values
			controlValue = computeControlValues(controlValue);
			
			//apply equation
			var max:Number = -Infinity;
			var min:Number = Infinity;
			for (i = 0; i < experiment[biomoleculeAxis.toLowerCase()].length; i++) {				
				for (j = 0; j < experiment[animationAxis.toLowerCase()].length; j++) {
					for (k = 0; k < experiment[comparisonXAxis.toLowerCase()].length; k++) {
						for (l = 0; l < experiment[comparisonYAxis.toLowerCase()].length; l++) {
							if (isNaN(reshapedStatistics[i][j][k][l]))
								continue;
							
							switch(equation) {
								case 'Difference': 
									reshapedStatistics[i][j][k][l] = reshapedStatistics[i][j][k][l] - controlValue[i][j][k][l];
									break;
								case 'Log 10 ratio':
									reshapedStatistics[i][j][k][l] = Math.log(reshapedStatistics[i][j][k][l] / controlValue[i][j][k][l]) * Math.LOG10E;
									break;
								case 'Log 2 ratio':
									reshapedStatistics[i][j][k][l] = Math.log(reshapedStatistics[i][j][k][l] / controlValue[i][j][k][l]) * Math.LOG2E;
									break;
								case 'Ratio':
									reshapedStatistics[i][j][k][l] = reshapedStatistics[i][j][k][l] / controlValue[i][j][k][l];									
									break;
								case 'Fold Change':
									//TODO: how does fold change differ from ratio?
									reshapedStatistics[i][j][k][l] = Math.log(reshapedStatistics[i][j][k][l] / controlValue[i][j][k][l]) * Math.LOG10E;
									if (reshapedStatistics[i][j][k][l] < 1) reshapedStatistics[i][j][k][l] = -1 / reshapedStatistics[i][j][k][l];
									break;
								case 'No Equation':
								case 'Raw':
								default:									
									break;
							}
							
							if (associatedMeasurements[i] && !isNaN(reshapedStatistics[i][j][k][l])) {
								min = Math.min(min, reshapedStatistics[i][j][k][l]);
								max = Math.max(max, reshapedStatistics[i][j][k][l]);
							}
						}
					}
				}
			}
			
			//calculate range
			var range:Number;
			
			if (!isNaN(dynamicRange) && dynamicRange > 0) 
				range = dynamicRange;
			else 
				range = Math.max(Math.abs(min), Math.abs(max), Math.pow(10, -6));
			
			colorScale.scale = [ -range, 0, range]; 
			
			//scale to range
			for (i = 0; i < experiment[biomoleculeAxis.toLowerCase()].length; i++) {
				for (j = 0; j < experiment[animationAxis.toLowerCase()].length; j++) {
					for (k = 0; k < experiment[comparisonXAxis.toLowerCase()].length; k++) {
						for (l = 0; l < experiment[comparisonYAxis.toLowerCase()].length; l++) {
							if (isNaN(reshapedStatistics[i][j][k][l]))
								continue;
								
							switch(equation) {
								case 'Fold Change':
									reshapedStatistics[i][j][k][l] = (Math.max(Math.min(reshapedStatistics[i][j][k][l], range), -range) + range) / (2 * (range - 1));
									break;
								case 'Difference':
								case 'Log 10 ratio':
								case 'Log 2 ratio':
								case 'Ratio':								
								case 'No Equation':
								case 'Raw':
								default:
									reshapedStatistics[i][j][k][l] = (Math.max(Math.min(reshapedStatistics[i][j][k][l], range), -range) + range) / (2 * range);
									break;
							}							
						}
					}
				}
			}
								
			//cluster/optimal leaf order			
			if (clusterComparisonXAxis && (comparisonXAxis == 'Channels' || comparisonXAxis == 'Conditions' ||  comparisonXAxis == 'Dosages' || 
			comparisonXAxis == 'Individuals' || comparisonXAxis == 'Populations' || comparisonXAxis == 'Timepoints')) 
			{
				tmp = cluster_ComparisonXAxis(reshapedStatistics, experiment);
				reshapedStatistics = tmp[0];
			}
				
			if (clusterComparisonYAxis && (comparisonYAxis == 'Channels' || comparisonYAxis == 'Conditions' ||  comparisonYAxis == 'Dosages' || 
			comparisonYAxis == 'Individuals' || comparisonYAxis == 'Populations' || comparisonYAxis == 'Timepoints')) 				
			{
				tmp = cluster_ComparisonYAxis(reshapedStatistics, experiment);
				reshapedStatistics = tmp[0];
			}
			
			return [reshapedStatistics, biomoleculeAssociations];
		}
		
		
		private function computeControlValues(control:Array):Array {
			return computeControlValues_biomoleculeAxis(
						computeControlValues_animationAxis(
							computeControlValues_comparisonXAxis(
								computeControlValues_comparisonYAxis(control))));
		}
		
		private function computeControlValues_biomoleculeAxis(measurement:Array):Array {
			if (biomoleculeAxisControl == 'None') return measurement;
			
			var controlValue:Number;
			var cnt:uint;
			var arr:Array;
			var i:int;
			for (var j:uint = 0; j < measurement[0].length; j++) {
				for (var k:uint = 0; k < measurement[0][j].length; k++) {
					for (var l:uint = 0; l < measurement[0][j][k].length; l++) {
						switch(biomoleculeAxisControl) {
							case 'First':
								controlValue = NaN;
								for (i = 0; i < measurement.length; i++) {
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Last':
								controlValue = NaN;
								for (i = measurement.length - 1; i >= 0; i--) {
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Min':
								controlValue = Infinity;
								for (i = 0; i < measurement.length; i++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.min(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Max':
								controlValue = -Infinity;
								for (i = 0; i < measurement.length; i++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.max(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Mean':
								controlValue = cnt = 0;
								for (i = 0; i < measurement.length; i++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue += measurement[i][j][k][l];
									cnt++;
								}
								controlValue = (cnt > 0 ? controlValue / cnt : NaN);
								break;
							case 'Median':
								arr = [];
								for (i = 0; i < measurement.length; i++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									arr.push(measurement[i][j][k][l]);
								}
								controlValue = ArrayMathUtils.median(arr);
								break;
						}
						
						for (i = 0; i < measurement.length; i++) {
							measurement[i][j][k][l] = controlValue;
						}
					}
				}
			}
			
			return measurement;
		}
		
		private function computeControlValues_animationAxis(measurement:Array):Array {
			if (animationAxisControl == 'None') 
				return measurement;
			
			var controlValue:Number;
			var cnt:uint;
			var arr:Array;
			var j:int;
			for (var i:uint = 0; i < measurement.length; i++) {
				for (var k:uint = 0; k < measurement[i][0].length; k++) {
					for (var l:uint = 0; l < measurement[i][0][k].length; l++) {
						switch(animationAxisControl) {
							case 'First':
								controlValue = NaN;
								for (j = 0; j < measurement[i].length; j++) {
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Last':
								controlValue = NaN;
								for (j = measurement[i].length - 1; j >= 0; j--) {
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Min':
								controlValue = Infinity;
								for (j = 0; j < measurement[i].length; j++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.min(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Max':
								controlValue = -Infinity;
								for (j = 0; j < measurement[i].length; j++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.max(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Mean':
								controlValue = cnt = 0;
								for (j = 0; j < measurement[i].length; j++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue += measurement[i][j][k][l];
									cnt++;
								}
								controlValue = (cnt > 0 ? controlValue / cnt : NaN);
								break;
							case 'Median':
								arr = [];
								for (j = 0; j < measurement[i].length; j++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									arr.push(measurement[i][j][k][l]);
								}
								controlValue = ArrayMathUtils.median(arr);
								break;
						}
						
						for (j = 0; j < measurement[i].length; j++) {
							measurement[i][j][k][l] = controlValue;
						}
					}
				}
			}
			
			return measurement;
		}
		
		private function computeControlValues_comparisonXAxis(measurement:Array):Array {
			if (comparisonXAxisControl == 'None') return measurement;
			
			var controlValue:Number;
			var cnt:uint;
			var arr:Array;
			var k:int;
			for (var i:uint = 0; i < measurement.length; i++) {
				for (var j:uint = 0; j < measurement[i].length; j++) {
					for (var l:uint = 0; l < measurement[i][j][0].length; l++) {
						switch(comparisonXAxisControl) {
							case 'First':
								controlValue = NaN;
								for (k = 0; k < measurement[i][j].length; k++) {
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Last':
								controlValue = NaN;
								for (k = measurement[i][j].length - 1; k >= 0; k--) {
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Min':
								controlValue = Infinity;
								for (k = 0; k < measurement[i][j].length; k++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.min(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Max':
								controlValue = -Infinity;
								for (k = 0; k < measurement[i][j].length; k++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.max(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Mean':
								controlValue = cnt = 0;
								for (k = 0; k < measurement[i][j].length; k++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue += measurement[i][j][k][l];
									cnt++;
								}
								controlValue = (cnt > 0 ? controlValue / cnt : NaN);
								break;
							case 'Median':
								arr = [];
								for (k = 0; k < measurement[i][j].length; k++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									arr.push(measurement[i][j][k][l]);
								}
								controlValue = ArrayMathUtils.median(arr);
								break;
						}
						
						for (k = 0; k < measurement[i][j].length; k++) {
							measurement[i][j][k][l] = controlValue;
						}
					}
				}
			}
			
			return measurement;
		}
		
		private function computeControlValues_comparisonYAxis(measurement:Array):Array {
			if (comparisonYAxisControl == 'None') return measurement;
			
			var controlValue:Number;
			var cnt:uint;
			var arr:Array;
			var l:int;
			for (var i:uint = 0; i < measurement.length; i++) {
				for (var j:uint = 0; j < measurement[i].length; j++) {
					for (var k:uint = 0; k < measurement[i][j].length; k++) {
						switch(comparisonYAxisControl) {
							case 'First':
								controlValue = NaN;
								for (l = 0; l < measurement[i][j][k].length; l++) {
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Last':
								controlValue = NaN;
								for (l = measurement[i][j][k].length - 1; l >= 0; l--) {									
									if (!isNaN(measurement[i][j][k][l])) {
										controlValue = measurement[i][j][k][l];
										break;
									}
								}
								break;
							case 'Min':
								controlValue = Infinity;
								for (l = 0; l < measurement[i][j][k].length; l++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.min(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Max':
								controlValue = -Infinity;
								for (l = 0; l < measurement[i][j][k].length; l++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue = Math.max(controlValue, measurement[i][j][k][l]);
								}
								break;
							case 'Mean':
								controlValue = cnt = 0;
								for (l = 0; l < measurement[i][j][k].length; l++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									controlValue += measurement[i][j][k][l];
									cnt++;
								}
								controlValue = (cnt > 0 ? controlValue / cnt : NaN);
								break;
							case 'Median':
								arr = [];
								for (l = 0; l < measurement[i][j][k].length; l++) {
									if (isNaN(measurement[i][j][k][l])) continue;
									arr.push(measurement[i][j][k][l]);
								}
								controlValue = ArrayMathUtils.median(arr);
								break;
						}
						
						for (l = 0; l < measurement[i][j][k].length; l++) {
							measurement[i][j][k][l] = controlValue;
						}
					}
				}
			}
			
			return measurement;
		}
				
		private function cluster_ComparisonXAxis(measurement:Array, experiment:Object):Array {
			var axisOrder:Array;
			if (comparisonXAxis == 'Timepoints') {
				//sort timepoint dimension
				var orderedTimepoints:Array = experiment.timepoints.sort(timepointComparator, Array.CASEINSENSITIVE);
				axisOrder = [];
				for (var idx:uint = 0; idx < experiment.timepoints.length; idx++) {
					axisOrder.push(orderedTimepoints.indexOf(experiment.timepoints[idx]));
				}
			}else {
				//compute distance matrix
				var distance:Array=[];
				var vector1:Array;
				var vector2:Array;
				var len:uint = measurement.length * measurement[0].length * measurement[0][0][0].length;
				for (var k1:uint = 0; k1 < measurement[0][0].length; k1++) {
					distance.push([]);
					for (var k2:uint = 0; k2 < k1; k2++) {
						distance[k1].push(0);
						vector1 = [];
						vector2 = [];
						for (var i:uint = 0; i < measurement.length; i++) {
							for (var j:uint = 0; j < measurement[i].length; j++) {
								for (var l:uint = 0; l < measurement[i][j][k1].length; l++) {
									if (isNaN(measurement[i][j][k1][l]) || isNaN(measurement[i][j][k2][l])) continue;
									vector1.push(measurement[i][j][k1][l]);
									vector2.push(measurement[i][j][k2][l]);
								}
							}
						}
						distance[k1][k2] = HierarchicalClustering.pairwiseDistance(vector1, vector2, distanceMetric);
					}
				}
				
				//cluster
				var result:Object = HierarchicalClustering.cluster(distance, linkage, optimalLeafOrder);
				axisOrder = result.leafOrder;
			}
			
			//order axis
			var axis:ArrayCollection = new ArrayCollection();
			for (idx = 0; idx < axisOrder.length; idx++) {
				axis.addItem(experiment[comparisonXAxis.toLowerCase()][axisOrder[idx]]);
			}
			experiment[comparisonXAxis.toLowerCase()] = axis;
			
			//order measurement
			var orderedMeasurement:Array = [];
			for (i = 0; i < measurement.length; i++) {
				orderedMeasurement.push([]);
				for (j = 0; j < measurement[i].length; j++) {
					orderedMeasurement[i].push([]);
					for (idx = 0; idx < axisOrder.length; idx++) {
						orderedMeasurement[i][j].push(measurement[i][j][axisOrder[idx]]);
					}
				}
			}
			
			return [orderedMeasurement, axisOrder];
		}
		
		private function cluster_ComparisonYAxis(measurement:Array, experiment:Object):Array {
			var axisOrder:Array;
			if (comparisonYAxis == 'Timepoints') {
				//sort timepoint dimension
				var orderedTimepoints:Array = experiment.timepoints.sort(timepointComparator, Array.CASEINSENSITIVE);
				axisOrder = [];
				for (var idx:uint = 0; idx < experiment.timepoints.length; idx++) {
					axisOrder.push(orderedTimepoints.indexOf(experiment.timepoints[idx]));
				}
			}else {
				//compute distance matrix
				var distance:Array=[];
				var vector1:Array;
				var vector2:Array;
				var len:uint = measurement.length * measurement[0].length * measurement[0][0].length;
				for (var l1:uint = 0; l1 < measurement[0][0][0].length; l1++) {
					distance.push([]);
					for (var l2:uint = 0; l2 < l1; l2++) {
						distance[l1].push(0);
						vector1 = [];
						vector2 = [];
						for (var i:uint = 0; i < measurement.length; i++) {
							for (var j:uint = 0; j < measurement[i].length; j++) {
								for (var k:uint = 0; k < measurement[i][j].length; k++) {
									if (isNaN(measurement[i][j][k][l1]) || isNaN(measurement[i][j][k][l2])) continue;
									vector1.push(measurement[i][j][k][l1]);
									vector2.push(measurement[i][j][k][l2]);
								}
							}
						}
						distance[l1][l2] = HierarchicalClustering.pairwiseDistance(vector1, vector2, distanceMetric);
					}
				}
				
				//cluster
				var result:Object = HierarchicalClustering.cluster(distance, linkage, optimalLeafOrder);
				axisOrder = result.leafOrder;
			}
			
			//order axis
			var axis:ArrayCollection = new ArrayCollection();
			for (idx = 0; idx < axisOrder.length; idx++) {
				axis.addItem(experiment[comparisonYAxis.toLowerCase()][axisOrder[idx]]);
			}
			experiment[comparisonYAxis.toLowerCase()] = axis;
			
			//order measurement
			var orderedMeasurement:Array = [];
			for (i = 0; i < measurement.length; i++) {
				orderedMeasurement.push([]);
				for (j = 0; j < measurement[i].length; j++) {
					orderedMeasurement[i].push([]);
					for (k = 0; k < measurement[i][j].length; k++) {
						orderedMeasurement[i][j].push([]);
						for (idx = 0; idx < axisOrder.length; idx++) {
							orderedMeasurement[i][j][k].push(measurement[i][j][k][axisOrder[idx]]);
						}
					}
				}
			}
			
			return [orderedMeasurement, axisOrder];
		}
		
		/********************************************************************
		 * natural sorting
		 * *****************************************************************/
		private function timepointComparator(timepoint1:Object, timepoint2:Object):int {
			var pattern:RegExp = /^(\d*\.*\d*) *?(y|yr|year|years|d|day|days|h|hr|hour|hours|m|min|minute|minutes|s|sec|second|seconds|ms|millisecond|milliseconds)$/i;
			var result1:Object = pattern.exec(timepoint1.name);
			if (!result1 || result1[1].length == 0) return 1;
			
			var result2:Object = pattern.exec(timepoint2.name);
			if (!result2 || result2[1].length == 0) return -1;

			var time1:Number = parseFloat(result1[1]);
			switch(result1[2].toLowerCase()) {
				case 'y':
				case 'yr':
				case 'year':
				case 'years':
					time1 *= 1000*60*60*24*365;
					break;
				case 'd':
				case 'day':
				case 'days':
					time1 *= 1000*60*60*24;
					break;
				case 'h':
				case 'hr':
				case 'hour':
				case 'hours':
					time1 *= 1000*60*60;
					break;
				case 'm':
				case 'min':
				case 'minute':
				case 'minutes':
					time1 *= 1000*60;
					break;
				case 's':
				case 'sec':
				case 'second':
				case 'seconds':
					time1 *= 1000;
					break;
				case 'ms':
				case 'millisecond':
				case 'milliseconds':
					break;
				default:
					return 1;
			}
			
			var time2:Number = parseFloat(result2[1]);
			switch(result2[2].toLowerCase()) {
				case 'y':
				case 'yr':
				case 'year':
				case 'years':
					time2 *= 1000*60*60*24*365;
					break;
				case 'd':
				case 'day':
				case 'days':
					time2 *= 1000*60*60*24;
					break;
				case 'h':
				case 'hr':
				case 'hour':
				case 'hours':
					time2 *= 1000*60*60;
					break;
				case 'm':
				case 'min':
				case 'minute':
				case 'minutes':
					time2 *= 1000*60;
					break;
				case 's':
				case 'sec':
				case 'second':
				case 'seconds':
					time2 *= 1000;
					break;
				case 'ms':
				case 'millisecond':
				case 'milliseconds':
					break;
				default:
					return -1;
			}
			
			if (time1 < time2) return -1;
			else if (time1 > time2) return 1;
			return 0;
		}
		
		/********************************************************************
		 * exporting
		 * *****************************************************************/
		
		public function exportExperiment(format:String):void {
			var fileData:*;
			var now:Date = new Date();
			var metaData:Object = {
				creator:application['aboutData'].applicationName,
				timestamp:now.toLocaleDateString() + ' ' + now.toLocaleTimeString(),
				title:(networkManager.name == '' ? application['aboutData'].applicationName : networkManager.name), 
				author:networkManager.owner, 
				subject:networkManager.description };
			var experiment:Object = manageExperimentsWindow.getSelectedExperiment();
			
			var fileName:String = metaData.title as String;
			var extension:String = format;
			switch(format) {
				case 'svg':
					extension = 'zip';
				case 'gif':
				case 'pdf':
					fileData = diagram.renderAnimation(format, metaData);
					break;
				case 'swf':
					compileAnimation(metaData);
					return;
				case 'booleansimulation':
					fileData = BooleanSimulation.generateSimulation(
						(experiment != null ? experiment.timepoints : []), 
						diagram.generateNetwork().biomolecules, 
						(experiment != null ? experiment.conditions : []),
						(experiment != null ? experiment.perturbations : []),
						metaData);
					fileName = fileName.replace(/\W/g, '_');
					extension = 'm';
					break;
			}
			exportFileReference.save(fileData, fileName + '.' + extension);
		}
		
		private function compileAnimation(metaData:Object):void {
			var urlVariables:URLVariables = new URLVariables();
			
			//metadata
			urlVariables.name = metaData.title;
			urlVariables.diagramWidth = diagram.diagramWidth;
			urlVariables.diagramHeight = diagram.diagramHeight;
			
			//network
			var network:Object = networkManager.toObject();
			urlVariables.network = JSON.encode(network);
			
			//experiment
			var experiment:Object = manageExperimentsWindow.getSelectedExperiment();
			var tmp:Array = reshapeScaleClusterStatistics(experiment);
			var biomoleculeAssociations:Array = [];
			for (var i:uint = 0; i < tmp[1].length; i++) {
				biomoleculeAssociations.push({
					biomoleculeid: diagram.biomolecules.getItemIndex(tmp[1][i].biomolecule as Biomolecule),
					measurementIdx: tmp[1][i].measurementIdx
					});
			}
			urlVariables.experiment = JSON.encode({
				biomoleculeAssociations: biomoleculeAssociations, 
				animationAxis: experiment[animationAxis.toLowerCase()], 
				comparisonXAxis: experiment[comparisonXAxis.toLowerCase()], 
				comparisonYAxis: experiment[comparisonYAxis.toLowerCase()], 
				measurement: tmp[0] 
				});
			
			//color scale
			urlVariables.colorScale = colorScale.render('svg');			
			urlVariables.colorScaleWidth = colorScale.getBounds(colorScale).width;
			
			//url request
			var urlRequest:URLRequest = new URLRequest('services/animationCompiler.php');
			urlRequest.method = 'POST';
			urlRequest.data = urlVariables;
						
			var fileReference:FileReference = new FileReference();
			exportFileReference.download(urlRequest, metaData.title + '.zip');
		}
		
		public function exportColorScale(format:String):void {
			var fileData:*;
			var now:Date = new Date();
			var metaData:Object = {
				creator:application['aboutData'].applicationName, 				
				timestamp:now.toLocaleDateString() + ' ' + now.toLocaleTimeString(),				
				title:(networkManager.name == '' ? application['aboutData'].applicationName : networkManager.name) + ' Color Scale', 				
				author:networkManager.owner, 				
				subject:networkManager.description };
			var fileName:String = (networkManager.name == '' ? application['aboutData'].applicationName : networkManager.name) + '.ColorScale';
			
			switch(format) {
				case 'gif':
				case 'jpg':
				case 'png':		
				case 'svg':
					fileData = colorScale.render(format, metaData);
					break;
				case 'pdf':
				case 'ps':
				case 'eps':				
					colorScale.rasterize(format, metaData, fileName);
					return;
			}
						
			exportFileReference.save(fileData, fileName + '.' + format);
		}
		
		public function toObject():Object {
			var experiments:Array = [];
			for (var i:uint = 0; i < this.experiments.length; i++) {
				var experiment:Object = {
					'name': this.experiments[i].name,
					'channels': [],
					'conditions': [],
					'dosages': [],
					'individuals': [],
					'populations': [],
					'timepoints': [],
					'statistics': [],
					'associations': [],
					'perturbations': []
				};
				
				var j:uint;
				for (j = 0; j < this.experiments[i].channels.length; j++)
					experiment.channels.push( { name: this.experiments[i].channels[j].name } );
				for (j = 0; j < this.experiments[i].conditions.length; j++)
					experiment.conditions.push( { name: this.experiments[i].conditions[j].name } );
				for (j = 0; j < this.experiments[i].dosages.length; j++)
					experiment.dosages.push( { name: this.experiments[i].dosages[j].name } );
				for (j = 0; j < this.experiments[i].individuals.length; j++)
					experiment.individuals.push( { name: this.experiments[i].individuals[j].name } );
				for (j = 0; j < this.experiments[i].populations.length; j++)
					experiment.populations.push( { name: this.experiments[i].populations[j].name } );
				for (j = 0; j < this.experiments[i].timepoints.length; j++)
					experiment.timepoints.push( { name: this.experiments[i].timepoints[j].name } );
					
				for (j = 0; j < this.experiments[i].statistics.length; j++)
					experiment.statistics.push( { 
						channel: this.experiments[i].statistics[j].channel,
						condition: this.experiments[i].statistics[j].condition,
						dosage: this.experiments[i].statistics[j].dosage,
						individual: this.experiments[i].statistics[j].individual,
						population: this.experiments[i].statistics[j].population,
						timepoint: this.experiments[i].statistics[j].timepoint,
						value: this.experiments[i].statistics[j].value
						} );
						
				for (j = 0; j < this.experiments[i].associations.length; j++)
					experiment.associations.push( { 
						channel: this.experiments[i].associations[j].channel, 
						biomoleculeid: diagram.biomolecules.getItemIndex(this.experiments[i].associations[j].biomolecule)
						} );
				for (j = 0; j < this.experiments[i].perturbations.length; j++)
					experiment.perturbations.push( { 
						condition: this.experiments[i].perturbations[j].condition, 
						activity: this.experiments[i].perturbations[j].activity, 
						biomoleculeid: diagram.biomolecules.getItemIndex(this.experiments[i].perturbations[j].biomolecule)
						} );
				
				experiments.push(experiment);
			}
			
			return {
				//associations, experiments
				experiments: experiments,
				
				//dimensions
				channelAxis: channelAxis,
				conditionAxis: conditionAxis,
				dosageAxis: dosageAxis,
				individualAxis: individualAxis,
				populationAxis: populationAxis,
				timepointAxis: timepointAxis,
				
				//controls
				biomoleculeAxisControl: biomoleculeAxisControl,
				animationAxisControl: animationAxisControl,
				comparisonXAxisControl: comparisonXAxisControl,
				comparisonYAxisControl: comparisonYAxisControl,
				
				//scales
				equation: equation,
				dynamicRange: dynamicRange,
				colormap: colormap,
				
				//clustering
				clusterComparisonXAxis: clusterComparisonXAxis,
				clusterComparisonYAxis: clusterComparisonYAxis,
				optimalLeafOrder: optimalLeafOrder,
				distanceMetric: distanceMetric,
				linkage: linkage
			};
		}
		
		/********************************************************************
		 * importing
		 * *****************************************************************/		
		public function fromObject(o:Object):void {			
			var i:uint, j:uint;
			
			//clean up
			clearExperiments();
			
			//experiments
			for (i = 0; i < o.experiments.length; i++) {
				importExperiment(o.experiments[i], true);
			}
			
			//axes
			setAxes(
				//dimensions
				o.channelAxis, o.conditionAxis, o.dosageAxis, o.individualAxis, o.populationAxis, o.timepointAxis,
			
				//controls
				o.biomoleculeAxisControl, o.animationAxisControl, o.comparisonXAxisControl, o.comparisonYAxisControl,
			
				//scales
				o.equation, o.dynamicRange, o.colormap, 
			
				//clustering
				o.clusterComparisonXAxis, o.clusterComparisonYAxis, 
				o.optimalLeafOrder, o.distanceMetric, o.linkage);		
		}
		
		public function importExperiment(experiment:Object, importPerturbations:Boolean = false):void {
			var i:int = 0;
			
			experiment['id'] = 0;
			
			if (!(experiment['name'] is String) || experiment['name'] == '')
				throw new Error("Name undefined.");
				
			if (!(experiment['channels'] is Array))
				throw new Error("Channels undefined.");
			var channelNames:Array = [];
			for (i = 0; i < experiment.channels.length; i++) {
				if (!(experiment.channels[i]['name'] is String) || experiment.channels[i]['name'] == '')
					throw new Error("Channels must be named.");
				channelNames.push(experiment.channels[i].name);
			}
				
			if (!(experiment['conditions'] is Array))
				throw new Error("Conditions undefined.");
			var conditionNames:Array = [];
			for (i = 0; i < experiment.conditions.length; i++) {
				if (!(experiment.conditions[i]['name'] is String) || experiment.conditions[i]['name'] == '')
					throw new Error("Channels must be named.");
				conditionNames.push(experiment.conditions[i].name);
			}
			
			if (!(experiment['dosages'] is Array))
				throw new Error("Dosages undefined.");
			var dosageNames:Array = [];
			for (i = 0; i < experiment.dosages.length; i++) {
				if (!(experiment.dosages[i]['name'] is String) || experiment.dosages[i]['name'] == '')
					throw new Error("Channels must be named.");
				dosageNames.push(experiment.dosages[i].name);
			}
			
			if (!(experiment['individuals'] is Array))
				throw new Error("Individuals undefined.");
			var individualNames:Array = [];
			for (i = 0; i < experiment.individuals.length; i++) {
				if (!(experiment.individuals[i]['name'] is String) || experiment.individuals[i]['name'] == '')
					throw new Error("Channels must be named.");
				individualNames.push(experiment.individuals[i].name);
			}
			
			if (!(experiment['populations'] is Array))
				throw new Error("Populations undefined.");
			var populationNames:Array = [];
			for (i = 0; i < experiment.populations.length; i++) {
				if (!(experiment.populations[i]['name'] is String) || experiment.populations[i]['name'] == '')
					throw new Error("Channels must be named.");
				populationNames.push(experiment.populations[i].name);
			}
			
			if (!(experiment['timepoints'] is Array))
				throw new Error("Timepoints undefined.");
			var timepointNames:Array = [];
			for (i = 0; i < experiment.timepoints.length; i++) {
				if (!(experiment.timepoints[i]['name'] is String) || experiment.timepoints[i]['name'] == '')
					throw new Error("Channels must be named.");
				timepointNames.push(experiment.timepoints[i].name);
			}
			
			if (!(experiment['statistics'] is Array))
				throw new Error("Statistics undefined.");
			for (i = 0; i < experiment.statistics.length; i++) {
				if (!(experiment.statistics[i]['channel'] is String) || channelNames.indexOf(experiment.statistics[i].channel) == -1 )
					throw new Error("Statistics must have channels.");
				if (!(experiment.statistics[i]['condition'] is String) || conditionNames.indexOf(experiment.statistics[i].condition) == -1 )
					throw new Error("Statistics must have conditions.");
				if (!(experiment.statistics[i]['dosage'] is String) || dosageNames.indexOf(experiment.statistics[i].dosage) == -1 )
					throw new Error("Statistics must have dosages.");
				if (!(experiment.statistics[i]['individual'] is String) || individualNames.indexOf(experiment.statistics[i].individual) == -1 )
					throw new Error("Statistics must have individuals.");
				if (!(experiment.statistics[i]['population'] is String) || populationNames.indexOf(experiment.statistics[i].population) == -1 )
					throw new Error("Statistics must have populations.");
				if (!(experiment.statistics[i]['timepoint'] is String) || timepointNames.indexOf(experiment.statistics[i].timepoint) == -1 )
					throw new Error("Statistics must have timepoints.");
				if (!(experiment.statistics[i]['value'] is Number) || isNaN(experiment.statistics[i].value))
					throw new Error("Statistics must have numeric values.");
			}
			
			if (!importPerturbations) {
				experiment['associations'] = [];
				experiment['perturbations'] = [];
			}
			if (!(experiment['associations'] is Array))
				throw new Error("Associations undefined.");
			if (!(experiment['perturbations'] is Array))
				throw new Error("Perturbations undefined.");
			for (i = 0; i < experiment.associations.length; i++) {
				if (channelNames.indexOf(experiment.associations[i]['channel']) == -1)
					throw new Error("Associations must have channels.");
				if (experiment.associations[i]['biomoleculeid'] < 0 || experiment.associations[i]['biomoleculeid'] >= diagram.biomolecules.length)
					throw new Error("Associations must have biomolecules.");
				experiment.associations[i]['biomolecule'] = diagram.biomolecules.getItemAt(experiment.associations[i]['biomoleculeid']);
			}
			for (i = 0; i < experiment.perturbations.length; i++) {
				if (conditionNames.indexOf(experiment.perturbations[i]['condition']) == -1)
					throw new Error("Perturbations must have conditions.");
				if (['On', 'Off'].indexOf(experiment.perturbations[i]['activity']) == -1)
					throw new Error("Perturbations must have activities.");
				if (experiment.perturbations[i]['biomoleculeid'] < 0 || experiment.perturbations[i]['biomoleculeid'] >= diagram.biomolecules.length)
					throw new Error("Perturbations must have biomolecules.");
				experiment.perturbations[i]['biomolecule'] = diagram.biomolecules.getItemAt(experiment.perturbations[i]['biomoleculeid']);
			}
				
			experiments.addItem(experiment);
		}
		
		/********************************************************************
		 * error handlers
		 * *****************************************************************/
		private function networkPainterErrorHandler(event:FaultEvent):void {
			Alert.show('Please retry last action. ' + event.message.toString(), 'Database Error.');
		}
	}	
}