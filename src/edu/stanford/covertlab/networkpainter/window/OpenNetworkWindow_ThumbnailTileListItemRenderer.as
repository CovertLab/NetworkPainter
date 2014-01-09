package edu.stanford.covertlab.networkpainter.window 
{
	import edu.stanford.covertlab.controls.ThumbnailTileListItemRenderer;
	import edu.stanford.covertlab.networkpainter.event.NetworkManagerEvent;
	import edu.stanford.covertlab.networkpainter.manager.NetworkManager;
	import mx.events.ToolTipEvent;
	
	/**
	 * Thumbnails in OpenNetworkWindow. Displays network preview thumbnail and network name.
	 * Mouse over displays tool tip with network details.
	 * 
	 * @see OpenNetworkWindow
	 * @see OpenNetworkWindow_ThumbnailTileListItemRenderer
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class OpenNetworkWindow_ThumbnailTileListItemRenderer extends ThumbnailTileListItemRenderer
	{
		private var _networkManager:NetworkManager;
		private var details:Object;
		
		public function OpenNetworkWindow_ThumbnailTileListItemRenderer()
		{
			super();
		}
		
		public function get networkManager():NetworkManager {
			return _networkManager;
		}
		public function set networkManager(value:NetworkManager):void {
			if (networkManager != value) {
				if (networkManager) networkManager.removeEventListener(NetworkManagerEvent.GET_NETWORK_DETAILS, showNetworkDetailsEnd);
				value.addEventListener(NetworkManagerEvent.GET_NETWORK_DETAILS, showNetworkDetailsEnd);
				if (data && !networkManager) value.getNetworkDetails(data.id);
				_networkManager = value;
			}
		}
		
		private function showNetworkDetailsEnd(event:NetworkManagerEvent):void {
			if (!networkManager || !data || networkManager.networkDetails.id != data.id) return;
			
			details = { 
				name:networkManager.networkDetails.name,
				description:networkManager.networkDetails.description,
				permissions:networkManager.networkDetails.permissions,
				publicstatus:networkManager.networkDetails.publicstatus,
				owner:networkManager.networkDetails.owner,
				creation:networkManager.networkDetails.creation,
				lastsave:networkManager.networkDetails.lastsave,				
				lockuser:networkManager.networkDetails.lockuser };
			image.source = networkManager.networkDetails.preview;
		}
		
		override public function set data(value:Object):void {
			if(data!=value){
				super.data = value;
				nameLabel.text = value.name;
				toolTip = value.name;
				
				if (networkManager) networkManager.getNetworkDetails(data.id);
			}
		}
		
		override protected function createToolTip(event:ToolTipEvent):void {
			if (details) event.toolTip = new OpenNetworkWindow_ThumbnailTileListToolTip(details);
		}
	}
}

