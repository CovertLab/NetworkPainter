package edu.stanford.covertlab.networkpainter.viewer
{
	import mx.containers.Form;
	import mx.containers.FormHeading;
	import mx.containers.FormItem;
	import mx.containers.TitleWindow;
	import mx.controls.Text;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp window displaying meta data about the network and experiment loaded
	 * into the viewer.
	 * <ul>
	 * <li>Application name, version, release data</li>
	 * <li>Creation date</li>
	 * <li>Network properties</li>
	 * <li>Experiment annotation -- channels, conditions, dosages, individuals, timepoints, populations</li>
	 * <li>Biomolecule-channel and biomolecule-condition associations</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.Viewer
	 * @see edu.stanford.covertlab.networkpainter.data.AboutData
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AboutWindow extends TitleWindow
	{
	
		private var application:Application;
		
		public function AboutWindow(application:Application, aboutData:Object, network:Object, experiment:Object, measurement:Object)		
		{
			var form:Form;
			var formHeading:FormHeading;
			var formItem:FormItem;
			var newText:Text;
			var biomoleculesAxis:String = '';
			var animationAxis:String = '';
			var comparisonXAxis:String = '';
			var comparisonYAxis:String = '';
			var i:uint;
			var arr:Array;
			
			this.application = application;
			
			//properties
			title = aboutData.applicationName + ' Viewer';
			showCloseButton = true;
			setStyle('horizontalAlign', 'center');
			setStyle('verticalAlign', 'center');
			setStyle('paddingBottom', 6);
			width = 600;
			addEventListener(CloseEvent.CLOSE, close);
			
			form = new Form();
			form.percentWidth = 100;
			form.styleName='TitleWindowForm';
			addChild(form);
			

			//format axis labels
			arr = [];
			for (i = 0; i < experiment[network.biomoleculeAxis.toLowerCase()].length; i++) {
				arr.push(experiment[network.biomoleculeAxis.toLowerCase()][i].name);
			}
			biomoleculesAxis = network.biomoleculeAxis + ' (' + arr.join(', ') + ')';
			
			arr = [];
			for (i = 0; i < experiment[network.animationAxis.toLowerCase()].length; i++) {
				arr.push(experiment[network.animationAxis.toLowerCase()][i].name);
			}
			animationAxis = network.animationAxis + ' (' + arr.join(', ') + ')';
			
			arr = [];
			for (i = 0; i < experiment[network.comparisonXAxis.toLowerCase()].length; i++) {
				arr.push(experiment[network.comparisonXAxis.toLowerCase()][i].name);
			}
			comparisonXAxis = network.comparisonXAxis + ' (' + arr.join(', ') + ')';
			
			arr = [];
			for (i = 0; i < experiment[network.comparisonXAxis.toLowerCase()].length; i++) {
				arr.push(experiment[network.comparisonYAxis.toLowerCase()][i].name);
			}
			comparisonYAxis = network.comparisonYAxis + ' (' + arr.join(', ') + ')';
			
						
			//network
			formHeading = new FormHeading();
			formHeading.label = 'Network';
			form.addChild(formHeading);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = 'Name';		
			newText = new Text();
			newText.text = network.name;
			newText.percentWidth = 100;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = 'Description';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = network.description;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName = 'TitleWindowFormItem';
			formItem.label = 'Owner';			
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = network.owner;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			//experiment
			formHeading = new FormHeading();
			formHeading.setStyle('paddingTop', 8);
			formHeading.label = 'Experiment';
			form.addChild(formHeading);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';			
			formItem.label = 'Name';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = experiment.name;
			formItem.addChild(newText);
			form.addChild(formItem);						
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';
			formItem.label = 'Biomolecule Axis';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = biomoleculesAxis;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';
			formItem.label = 'Animation Axis';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = animationAxis;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';
			formItem.label = 'Comparison X-Axis';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = comparisonXAxis;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';
			formItem.label = 'Comparison Y-Axis';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = comparisonYAxis;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			//About
			formHeading = new FormHeading();
			formHeading.setStyle('paddingTop', 8);
			formHeading.label = aboutData.applicationName;
			form.addChild(formHeading);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';
			formItem.label = 'Generated By';
			newText = new Text();
			newText.percentWidth = 100;
			newText.htmlText = aboutData.applicationName + ', <a href="' + aboutData.url + '">' + aboutData.url + '</a>';;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';
			formItem.label = 'Generated';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = network.generated;
			formItem.addChild(newText);
			form.addChild(formItem);
			
			formItem = new FormItem();
			formItem.percentWidth = 100;
			formItem.styleName='TitleWindowFormItem';
			formItem.label = 'Version';
			newText = new Text();
			newText.percentWidth = 100;
			newText.text = aboutData.version;
			formItem.addChild(newText);
			form.addChild(formItem);			
		}
		
		public function open():void {
			PopUpManager.addPopUp(this, application, false);
			PopUpManager.centerPopUp(this);
		}
 
		private function close(event:CloseEvent):void{
		  PopUpManager.removePopUp(this);
		}
		
	}
	
}