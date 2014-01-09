package edu.stanford.covertlab.networkpainter.window 
{
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.controls.List;
	import mx.events.ListEvent;
	
	public class ManageExperimentsWindow_ChannelDataGridComboBox extends ComboBox
	{
		[Bindable] public var experimentsList:List;
		
		public function ManageExperimentsWindow_ChannelDataGridComboBox() 
		{
			editable = false;
			labelField = 'name';
			BindingUtils.bindSetter(setupListChangeListener, this, ['experimentsList']);
		}
		
		private function setupListChangeListener(list:List):void {
			if (list)
				list.addEventListener(ListEvent.CHANGE, updateExperiment);
			updateExperiment();
			
		}
		
		private function updateExperiment(evt:ListEvent = null):void {
			var experiment:Object = (experimentsList ? experimentsList.selectedItem : null);
			
			if (experiment)
				dataProvider = new ArrayCollection([{name:'None'}].concat(experiment.channels)); 
			else
				dataProvider = new ArrayCollection([{name:'None'}]);
		}
		
		override public function get value():Object {
			if (selectedIndex > 0) 
				return selectedItem;
			return null;
		}
		
		override public function set data(value:Object):void {  		
			super.data = value;
			if (value.tmpChannel == null) {
				selectedIndex = -1;
				return;
			}
			for (var i:uint = 0; i < dataProvider.length; i++) {			
				if (dataProvider[i].name == value.tmpChannel.name) {
					selectedIndex = i;
					return;
				}
			}
			selectedIndex = -1;
		}
	}
}