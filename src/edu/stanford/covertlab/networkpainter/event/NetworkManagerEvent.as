package edu.stanford.covertlab.networkpainter.event 
{
	import flash.events.Event;
	
	/**
	 * Event class for NetworkManager. Defines three events.
	 * <ul>
	 * <li>network new: dispatched when a new network is created</li>
	 * <li>network loaded: dispatched when a network is loaded from the database</li>
	 * <li>network saved: dispatched when a network is saved to the database</li>
	 * <li>get network datails: dispatch when a network details request finishes</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class NetworkManagerEvent extends Event
	{
		public var networkid:uint;
		
		public function NetworkManagerEvent(type:String, networkid:uint=0)
		{
			super(type);
			this.networkid = networkid;
		}
		
		public static const NETWORK_NEW:String = "networkManagerNetworkNew";
		public static const NETWORK_LOADED:String = "networkManagerNetworkLoaded";
		public static const NETWORK_SAVED:String = "networkManagerNetworkSaved";
		public static const GET_NETWORK_DETAILS:String = "networkManagerGetNetworkDetails";
	}
	
}