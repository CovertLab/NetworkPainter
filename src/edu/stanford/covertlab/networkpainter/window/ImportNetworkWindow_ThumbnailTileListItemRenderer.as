package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.controls.ThumbnailTileListItemRenderer;
	import mx.events.ToolTipEvent;
	
	/**
	 * Thumbnails in ImportNetworkWindow. Displays pathway preview thumbnail and pathway name.
	 * Mouse over displays tool tip with pathway details.
	 * 
	 * @see ImportNetworkWindow
	 * @see ImportNetworkWindow_ThumbnailTileListItemRenderer
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class ImportNetworkWindow_ThumbnailTileListItemRenderer extends ThumbnailTileListItemRenderer 
	{
		
		private var _importNetworkWindow:ImportNetworkWindow;
		
		public function ImportNetworkWindow_ThumbnailTileListItemRenderer() 
		{
			super();
		}
		
		public function get importNetworkWindow():ImportNetworkWindow {
			return _importNetworkWindow;
		}
		
		public function set importNetworkWindow(value:ImportNetworkWindow):void {
			if (importNetworkWindow != value) {
				if (data && !importNetworkWindow) {
					var source:String = value.previewSource(data);
					if (source) image.source = 'services/phpThumb/phpThumb.php?src=' + source + '&w=' + image.width + '&h=' + image.height;
					else image.source = null;
				}
				_importNetworkWindow = value;
			}
		}
		
		override public function set data(value:Object):void {
			if(data!=value){
				super.data = value;
				nameLabel.text = value.name;
				toolTip = value.name;				
				
				if (importNetworkWindow) {
					var source:String = importNetworkWindow.previewSource(data);
					if (source) image.source = 'services/phpThumb/phpThumb.php?src=' + source + '&w=' + image.width + '&h=' + image.height;
					else image.source = null;
				}
			}
		}
		
		override protected function createToolTip(event:ToolTipEvent):void {
			event.toolTip = new ImportNetworkWindow_ThumbnailTileListToolTip(data);
		}
		
	}
	
}