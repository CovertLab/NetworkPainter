package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.controls.ThumbnailTileListToolTip;
	import mx.containers.FormItem;
	import mx.controls.Label;
	
	/**
	 * Tooltip for thumbnails in ImportNetworkWindow.
	 * 
	 * @see ImportNetworkWindow
	 * @see ImportNetworkWindow_ThumbnailTileListItemRenderer
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class ImportNetworkWindow_ThumbnailTileListToolTip extends ThumbnailTileListToolTip
	{
		
		public function ImportNetworkWindow_ThumbnailTileListToolTip(pathway:Object) 		
		{
			var formItem:FormItem;
			var label:Label;
			
			super();
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Category';
			label = new Label();
			label.percentWidth = 100;
			label.text = pathway.category;
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Name';
			label = new Label();
			label.percentWidth = 100;
			label.maxHeight = 45;
			label.text = pathway.name;
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Last Updated';
			label = new Label();
			label.percentWidth = 100;
			label.maxHeight = 45;
			label.text = pathway.lastUpdated;
			formItem.addChild(label);
			addChild(formItem);
		}
		
	}
	
}