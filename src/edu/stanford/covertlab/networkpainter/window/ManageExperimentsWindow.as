package edu.stanford.covertlab.networkpainter.window 
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONParseError;
	import edu.stanford.covertlab.diagram.core.Biomolecule;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.networkpainter.manager.ExperimentManager;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.containers.Accordion;
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.List;
	import mx.controls.Text;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	import org.adm.runtime.ModeCheck;
	
	/**
	 * PopUp window which allows the user to specify experimentally observed channels
	 * a biomolecule in the current network correspond to, as well as what the
	 * experimentally applied conditions corresponded to in terms of biomolecules.
	 * 
	 * <p>Data is loaded from and saved to the ExperimentManager.</p>
	 * 
	 * <p>Associated experiments appear in bold in the experiment list on the left side
	 * of this window. The right side displays an accordion with two datagrids for
	 * specifying biomolecule-condition and biomolecule-channel associations.</p>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.ExperimentManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ManageExperimentsWindow extends TitleWindow
	{
		private var manager:ExperimentManager;
		private var diagram:Diagram;
		
		[Bindable] public var experimentsList:List;
		private var addExperimentButton:Button;
		private var deleteExperimentButton:Button;
		private var playExperimentButton:Button;
		
		private var perturbationsAndAssociationsVBox:VBox;
		private var perturbationsDataGrid:DataGrid;
		private var associationsDataGrid:DataGrid;
		
		private var errorMsg:Text;
		
		private var importFileReference:FileReference;
		
		public function ManageExperimentsWindow(manager:ExperimentManager, diagram:Diagram) 
		{
			var controlBar:ControlBar;
			var list:List;
			var accordion:Accordion;			
			var vBox:VBox;
			var dataGrid:DataGrid;
			var dataGridColumns:Array;
			var dataGridColumn:DataGridColumn;
			var hBox:HBox;
			var button:Button;
			var cf:ClassFactory;
			
			this.manager = manager;
			this.diagram = diagram;
			
			//style
			title = 'Manage Experiments';
			layout = 'horizontal';
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			
			//experiments list
			vBox = new VBox();
			vBox.percentHeight = 100;
			vBox.width = 200;
			vBox.setStyle('verticalGap', 4);
			addChild(vBox);
			
			experimentsList = new List();
			experimentsList.rowHeight = 14;
			experimentsList.styleName = 'TitleWindowList';
			experimentsList.labelField = 'name';
			experimentsList.percentHeight = 100;
			experimentsList.percentWidth = 100;
			experimentsList.addEventListener(ListEvent.CHANGE, editExperiment);
			BindingUtils.bindSetter(function(value:ArrayCollection):void {
				experimentsList.dataProvider = value;
			}, manager, 'experiments');
			vBox.addChild(experimentsList);
			
			hBox = new HBox();
			hBox.percentWidth = 100;
			hBox.setStyle('horizontalAlign', 'center');
			hBox.setStyle('horizontalGap', 10);
			vBox.addChild(hBox);
					
			addExperimentButton = new Button();
			addExperimentButton.styleName = 'TitleWindowButton';
			addExperimentButton.height = 16;
			addExperimentButton.label = 'Add';
			addExperimentButton.addEventListener(MouseEvent.CLICK, addExperiment);
			hBox.addChild(addExperimentButton);
			
			deleteExperimentButton = new Button();
			deleteExperimentButton.styleName = 'TitleWindowButton';
			deleteExperimentButton.height = 16;
			deleteExperimentButton.label = 'Delete';
			deleteExperimentButton.addEventListener(MouseEvent.CLICK, deleteExperiment);
			hBox.addChild(deleteExperimentButton);		
			
			playExperimentButton = new Button();
			playExperimentButton.styleName = 'TitleWindowButton';
			playExperimentButton.height = 16;
			playExperimentButton.label = 'Select';
			playExperimentButton.addEventListener(MouseEvent.CLICK, playExperiment);
			hBox.addChild(playExperimentButton);
			
			//main VBox
			perturbationsAndAssociationsVBox = new VBox();
			perturbationsAndAssociationsVBox.setStyle('verticalGap', 4);
			perturbationsAndAssociationsVBox.enabled = false;
			addChild(perturbationsAndAssociationsVBox);
			
			//accordion
			accordion = new Accordion();
			accordion.width = 250;
			accordion.height = 200;
			accordion.styleName = 'TitleWindowAccordion';
			perturbationsAndAssociationsVBox.addChild(accordion);
			
			//conditions
			vBox = new VBox();
			vBox.label = 'Condition-Biomolecule Perturbations';
			vBox.percentWidth = 100;
			vBox.percentHeight = 100;
			vBox.setStyle('verticalGap', 4);
			accordion.addChild(vBox);
			
			perturbationsDataGrid = new DataGrid();
			perturbationsDataGrid.styleName = 'TitleWindowDataGrid';
			perturbationsDataGrid.rowHeight = 14;
			perturbationsDataGrid.headerHeight = 14;
			perturbationsDataGrid.percentWidth = 100;
			perturbationsDataGrid.percentHeight = 100;
			perturbationsDataGrid.editable = true;
			perturbationsDataGrid.sortableColumns = false;
			BindingUtils.bindProperty(perturbationsDataGrid, 'dataProvider', diagram, 'biomolecules');
			vBox.addChild(perturbationsDataGrid);
			dataGridColumns = [];			
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Biomolecule';
			dataGridColumn.dataField = 'myName';
			dataGridColumn.editable = false;
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Condition';
			dataGridColumn.dataField = 'tmpCondition';
			dataGridColumn.editorDataField = 'value';
			dataGridColumn.labelFunction = ConditionLabel;			
			cf = new ClassFactory(ManageExperimentsWindow_ConditionDataGridComboBox);
			cf.properties = {experimentsList:experimentsList};
			dataGridColumn.itemEditor = cf;
			dataGridColumns.push(dataGridColumn);
					
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Activity';
			dataGridColumn.dataField = 'tmpActivity';
			dataGridColumn.editorDataField = 'value';
			dataGridColumn.labelFunction = ActivityLabel;
			dataGridColumn.itemEditor = new ClassFactory(ManageExperimentsWindow_ActivityDataGridComboBox);
			dataGridColumns.push(dataGridColumn);
			
			perturbationsDataGrid.columns = dataGridColumns;
			
			
			//channels
			vBox = new VBox();
			vBox.label = 'Channel-Biomolecule Associations';
			vBox.percentWidth = 100;
			vBox.percentHeight = 100;
			accordion.addChild(vBox);
			
			associationsDataGrid = new DataGrid();
			associationsDataGrid.styleName = 'TitleWindowDataGrid';
			associationsDataGrid.rowHeight = 14;
			associationsDataGrid.headerHeight = 14;
			associationsDataGrid.percentWidth = 100;
			associationsDataGrid.percentHeight = 100;
			associationsDataGrid.editable = true;
			associationsDataGrid.sortableColumns = false;
			BindingUtils.bindProperty(associationsDataGrid, 'dataProvider', diagram, 'biomolecules');
			vBox.addChild(associationsDataGrid);
			dataGridColumns = [];	
	
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Biomolecule';
			dataGridColumn.dataField = 'myName';
			dataGridColumn.editable = false;
			dataGridColumns.push(dataGridColumn);
			
			dataGridColumn = new DataGridColumn();
			dataGridColumn.headerText = 'Channel';
			dataGridColumn.dataField = 'tmpChannel';
			dataGridColumn.editorDataField = 'value';
			dataGridColumn.labelFunction = ChannelLabel;
			cf = new ClassFactory(ManageExperimentsWindow_ChannelDataGridComboBox);
			cf.properties = {experimentsList:experimentsList};
			dataGridColumn.itemEditor = cf;
			dataGridColumns.push(dataGridColumn);
			
			associationsDataGrid.columns = dataGridColumns;
			
			//update button
			hBox = new HBox();
			hBox.percentWidth = 100;
			perturbationsAndAssociationsVBox.addChild(hBox);
			
			errorMsg = new Text();
			errorMsg.percentWidth = 100;
			errorMsg.setStyle('color', 0xFF0000);
			errorMsg.setStyle('fontWeight', 'bold');
			hBox.addChild(errorMsg);
			
			button = new Button();
			button.styleName = 'TitleWindowButton';
			button.height = 16;
			button.label = 'Update';
			button.addEventListener(MouseEvent.CLICK, saveExperiment);
			hBox.addChild(button);
			
			//add experiment
			importFileReference = new FileReference();
			importFileReference.addEventListener(Event.SELECT, addExperimentSelectHandler);
			importFileReference.addEventListener(Event.COMPLETE, addExperimentCompleteHandler);
		}
		
		private function BiomoleculeLabel(item:Object, col:DataGridColumn):String {
			if (item == null) 
				return '';
			return item.myName;	
		}
		
		private function ActivityLabel(item:Object, col:DataGridColumn):String {
			if (item == null) return '';
			if (item.tmpActivity == null) 
				return '';
			return item.tmpActivity.name;
		}
		
		private function ChannelLabel(item:Object, col:DataGridColumn):String {
			if (item == null) 
				return '';
			if (item.tmpChannel == null) 
				return '';
			return item.tmpChannel.name;
		}
		
		private function ConditionLabel(item:Object, col:DataGridColumn):String {
			if (item == null) 
				return '';
			if (item.tmpCondition == null) 
				return '';
			return item.tmpCondition.name;
		}
		
		public function getSelectedExperiment():Object {
			return experimentsList.selectedItem;
		}
		
		public function setSelectedExperiment(idx:int = -1):void {
			experimentsList.selectedIndex = idx;
			experimentsList.dispatchEvent(new ListEvent(ListEvent.CHANGE));
		}
		
		private function playExperiment(evt:MouseEvent):void {
			var experiment:Object = experimentsList.selectedItem;
			
			if (experiment != null)
				manager.animateExperiment(experiment);
		}
		
		private function addExperiment(evt:MouseEvent):void {
			importFileReference.browse([new FileFilter(Application.application['aboutData'].applicationName + " experiments (*.json)", "*.json")]);
		}
		private function addExperimentSelectHandler(evt:Event):void {
			importFileReference.load();
		}
		private function addExperimentCompleteHandler(evt:Event):void {
			var i:uint;
			
			try {
				var experiment:Object = JSON.decode(importFileReference.data.readUTFBytes(importFileReference.data.length));
				manager.importExperiment(experiment);				
			} catch (err:Error) {
				if (ModeCheck.isDebugBuild()) {
					trace(err.message);
				}
				Alert.show('Unable to parse experiment.', 'Invalid experiment');
			}
		}
		
		private function deleteExperiment(evt:MouseEvent):void {
			if (experimentsList.selectedIndex == -1)
				return;
				
			//remove experiment			
			(experimentsList.dataProvider as ArrayCollection).removeItemAt(experimentsList.selectedIndex);
			experimentsList.selectedIndex = -1;
			experimentsList.dispatchEvent(new ListEvent(ListEvent.CHANGE));
			
			//stop animation if playing
			if (diagram.animationPlaying) {
				diagram.stopAnimation();
				diagram.clearMeasurement();
			}
		}
		
		private function editExperiment(evt:ListEvent):void {
			var i:uint;
			var b:Biomolecule;
			
			//disable buttons
			deleteExperimentButton.enabled = false;
			playExperimentButton.enabled = false;
			perturbationsAndAssociationsVBox.enabled = false;
			
			//clear tmp information stored in biomolecules
			for (i = 0; i < diagram.biomolecules.length; i++) {
				b = diagram.biomolecules[i] as Biomolecule;
				b.tmpChannel = null;
				b.tmpCondition = null;
				b.tmpActivity = null;
				diagram.biomolecules.itemUpdated(b);
			}
			
			//stop animation if playing
			if (diagram.animationPlaying) {
				diagram.stopAnimation();
				diagram.clearMeasurement();
			}
			
			//return if no experiment selected
			var experiment:Object = experimentsList.selectedItem;			
			if (experiment == null) {
				return;
			}
			
			//enable buttons
			deleteExperimentButton.enabled = true;
			playExperimentButton.enabled = true;
			perturbationsAndAssociationsVBox.enabled = true;
			
			//perturbations
			for (i = 0; i < experiment.perturbations.length; i++) {
				var p:Object = experiment.perturbations[i];
				if (p == null)
					continue;
					
				b = p.biomolecule as Biomolecule;
				b.tmpCondition = { name:p.condition };
				b.tmpActivity = { name:p.activity };
				diagram.biomolecules.itemUpdated(b);
			}
			for (i = 0; i < experiment.associations.length; i++) {
				var a:Object = experiment.associations[i];
				if (a == null)
					continue;
					
				b = a.biomolecule as Biomolecule;
				b.tmpChannel = { name:a.channel };
				diagram.biomolecules.itemUpdated(b);
			}
		}
		
		private function saveExperiment(event:MouseEvent):void {
			var experiment:Object = experimentsList.selectedItem;
			if (experiment == null) {				
				return;
			}
			
			var perturbations:Array = [];
			var associations:Array = [];

			//error check perturbations
			for (var i:uint = 0; i < diagram.biomolecules.length; i++) {
				if ((diagram.biomolecules[i].tmpCondition == null) && 
					(diagram.biomolecules[i].tmpActivity != null)) {
					errorMsg.text = 'Please select the condition of the "' + diagram.biomolecules[i].myName + '" perturbation.';
					return;
				}
				if (diagram.biomolecules[i].tmpCondition != null) {
					if(diagram.biomolecules[i].tmpActivity == null) {
						errorMsg.text = 'Please select the activity of the "' + diagram.biomolecules[i].myName + '" perturbation.';
						return;
					}else {
						perturbations.push( {
							biomolecule:diagram.biomolecules[i],
							condition:diagram.biomolecules[i].tmpCondition.name,
							activity:diagram.biomolecules[i].tmpActivity.name
							} );
					}
				}				
			}
			
			//error check associations
			for (i = 0; i < diagram.biomolecules.length; i++) {
				if (diagram.biomolecules[i].tmpChannel != null && diagram.biomolecules[i].tmpChannel.name != 'None') {
					associations.push( {
						biomolecule:diagram.biomolecules[i],
						channel: diagram.biomolecules[i].tmpChannel.name 
						} );
				}
			}
			
			errorMsg.text = '';
			
			//save associations, perturbations
			experiment.perturbations = perturbations;
			experiment.associations = associations;
			if (diagram.animationPlaying)
				manager.animateExperiment(experiment);
		}
			
		public function open():void {
			PopUpManager.addPopUp(this, this.manager.application, false);
			PopUpManager.centerPopUp(this);
		}
		
		private function close(event:CloseEvent = null):void {
			PopUpManager.removePopUp(this);
		}
	}	
}