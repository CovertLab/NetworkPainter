package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.controls.ThumbnailTileListToolTip;
	import mx.containers.FormItem;
	import mx.controls.Label;
	import mx.controls.Text;
	
	/**
	 * Tooltip for thumbnails in OpenNetworkWindow.
	 * 
	 * @see OpenNetworkWindow
	 * @see OpenNetworkWindow_ThumbnailTileListItemRenderer
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class OpenNetworkWindow_ThumbnailTileListToolTip extends ThumbnailTileListToolTip
	{
		
		public function OpenNetworkWindow_ThumbnailTileListToolTip(network:Object)
		{		
			var formItem:FormItem;
			var text:Text;
			var label:Label;
			
			super();
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Name';
			label = new Label();
			label.percentWidth = 100;
			label.text = network.name;
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Description';
			text = new Text();
			text.percentWidth = 100;
			text.maxHeight = 45;
			text.text = network.description;
			formItem.addChild(text);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Permissions';
			label = new Label();
			label.percentWidth = 100;
			switch(network.permissions) {
				case 'o':label.text = 'Owner'; break;
				case 'w':label.text = 'Write'; break;
				case 'r':label.text = 'Read'; break;
			}
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Public?';
			label = new Label();
			label.percentWidth = 100;
			label.text = network.publicstatus;
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Owner';
			label = new Label();
			label.percentWidth = 100;
			label.text = network.owner;
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Creation';
			label = new Label();
			label.percentWidth = 100;
			label.text = network.creation;
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Last Save';
			label = new Label();
			label.percentWidth = 100;
			label.text = network.lastsave;
			formItem.addChild(label);
			addChild(formItem);
			
			formItem = new FormItem();
			formItem.styleName = 'TitleWindowFormItem';
			formItem.percentWidth = 100;
			formItem.label = 'Locked User';
			label = new Label();
			label.percentWidth = 100;
			label.text = network.lockuser;
			formItem.addChild(label);
			addChild(formItem);
		}
		
	}
	
}