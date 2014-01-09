package edu.stanford.covertlab.networkpainter.window 
{
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.controls.List;

	public class ManageExperimentsWindow_ActivityDataGridComboBox extends ComboBox
	{
		public function ManageExperimentsWindow_ActivityDataGridComboBox() {
			editable = false;
			labelField = 'name';
			dataProvider = new ArrayCollection([ { name:'None' }, { name:'On' }, { name:'Off' } ]);		
		}
		
		override public function get value():Object {
			if (selectedIndex > 0) 
				return selectedItem;
			return null;
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			if (data.tmpActivity == null) {
				selectedIndex = -1;
				return;
			}
			switch(data.tmpActivity.name) {
				case 'On':selectedIndex = 1; break;
				case 'Off': selectedIndex = 2; break;
				default: selectedIndex = -1; break;			
			}
		}
	}
}