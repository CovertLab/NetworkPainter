package edu.stanford.covertlab.service 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	[Event(name = 'networkPainterListNetworks', type = "flash.events.Event")]
	[Event(name = 'networkPainterGetNetworkDetails', type = "flash.events.Event")]
	[Event(name = 'networkPainterGetNetworkPermissions', type = "flash.events.Event")]
	[Event(name = 'networkPainterSaveAsNetwork', type = "flash.events.Event")]
	[Event(name = 'networkPainterUpdateNetwork', type = "flash.events.Event")]
	[Event(name = 'networkPainterSaveNetworkProperties', type = "flash.events.Event")]
	[Event(name = 'networkPainterLoadNetwork', type = "flash.events.Event")]
	[Event(name = 'networkPainterRenewNetworkLock', type = "flash.events.Event")]
	[Event(name = 'networkPainterClearNetworkLock', type = "flash.events.Event")]
	[Event(name = 'networkPainterDeleteNetwork', type = "flash.events.Event")]
	[Event(name = 'networkPainterFault', type = "flash.events.Event")]
	
	/**
	 * Provides functions for interacting with the NetworkPainter database via
	 * an AMFPHP class.
	 * <ul>
	 * <li>List networks available to a user</li>
	 * <li>Get details for a network, including preview image</li>
	 * <li>Get user permissions on a network</li>
	 * <li>Save a new network</li>
	 * <li>Update a network, including a png preview</li>
	 * <li>Save basic properties of a network</li>
	 * <li>Load a network</li>
	 * <li>Renew, clear network locks</li>
	 * <li>Delete a network</li>
	 * </ul>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class NetworkPainter extends EventDispatcher
	{
		//remote object
		private var remoteObj:RemoteObject;
		
		//constants		
		public static const LIST_NETWORKS:String = 'networkPainterListNetworks';
		public static const GET_NETWORK_DETAILS:String = 'networkPainterGetNetworkDetails';
		public static const GET_NETWORK_PERMISSIONS:String = 'networkPainterGetNetworkPermissions';
		public static const SAVE_AS_NETWORK:String = 'networkPainterSaveAsNetwork';
		public static const UPDATE_NETWORK:String = 'networkPainterUpdateNetwork';
		public static const SAVE_NETWORK_PROPERTIES:String = 'networkPainterSaveNetworkProperties';
		public static const LOAD_NETWORK:String = 'networkPainterLoadNetwork';
		public static const RENEW_NETWORK_LOCK:String = 'networkPainterRenewNetworkLock';
		public static const CLEAR_NETWORK_LOCK:String = 'networkPainterClearNetworkLock';
		public static const DELETE_NETWORK:String = 'networkPainterDeleteNetwork';
		public static const FAULT:String = 'networkPainterFault';
		public static const DESTINATION:String = "amfphp";
		public static const SOURCE:String = "NetworkPainter.NetworkPainter";		
		
		//data
		public var networks:ArrayCollection;
		public var networkDetails:Object;		
		public var networkPermissions:ArrayCollection;
		public var newNetworkId:uint;
		public var network:Object;
		public var preview:ByteArray;
		private var biomoleculestyles:ArrayCollection;
		private var compartments:ArrayCollection;
		private var biomolecules:ArrayCollection;
		private var edges:ArrayCollection;
		
		public function NetworkPainter() 
		{
			remoteObj = new RemoteObject(DESTINATION);
			remoteObj.source = SOURCE;
			
			remoteObj.getOperation("listNetworks").addEventListener(ResultEvent.RESULT, listNetworksEnd);
			remoteObj.getOperation("listNetworks").addEventListener(FaultEvent.FAULT, listNetworksFault);
			
			remoteObj.getOperation("getNetworkDetails").addEventListener(ResultEvent.RESULT, getNetworkDetailsEnd);
			remoteObj.getOperation("getNetworkDetails").addEventListener(FaultEvent.FAULT, getNetworkDetailsFault);
			
			remoteObj.getOperation("getNetworkPermissions").addEventListener(ResultEvent.RESULT, getNetworkPermissionsEnd);
			remoteObj.getOperation("getNetworkPermissions").addEventListener(FaultEvent.FAULT, getNetworkPermissionsFault);
			
			remoteObj.getOperation("saveAsNetwork").addEventListener(ResultEvent.RESULT, saveAsNetworkEnd);
			remoteObj.getOperation("saveAsNetwork").addEventListener(FaultEvent.FAULT, saveAsNetworkFault);
			
			remoteObj.getOperation("updateNetwork").addEventListener(ResultEvent.RESULT, updateNetworkEnd);
			remoteObj.getOperation("updateNetwork").addEventListener(FaultEvent.FAULT, updateNetworkFault);
			
			remoteObj.getOperation("saveNetworkProperties").addEventListener(ResultEvent.RESULT, saveNetworkPropertiesEnd);
			remoteObj.getOperation("saveNetworkProperties").addEventListener(FaultEvent.FAULT, saveNetworkPropertiesFault);
			
			remoteObj.getOperation("loadNetwork").addEventListener(ResultEvent.RESULT, loadNetworkEnd);
			remoteObj.getOperation("loadNetwork").addEventListener(FaultEvent.FAULT, loadNetworkFault);	
			
			remoteObj.getOperation("loadNetworkBiomoleculestyles").addEventListener(ResultEvent.RESULT, loadNetworkBiomoleculestylesEnd);
			remoteObj.getOperation("loadNetworkBiomoleculestyles").addEventListener(FaultEvent.FAULT, loadNetworkFault);
			
			remoteObj.getOperation("loadNetworkCompartments").addEventListener(ResultEvent.RESULT, loadNetworkCompartmentsEnd);
			remoteObj.getOperation("loadNetworkCompartments").addEventListener(FaultEvent.FAULT, loadNetworkFault);
			
			remoteObj.getOperation("loadNetworkBiomolecules").addEventListener(ResultEvent.RESULT, loadNetworkBiomoleculesEnd);
			remoteObj.getOperation("loadNetworkBiomolecules").addEventListener(FaultEvent.FAULT, loadNetworkFault);
			
			remoteObj.getOperation("loadNetworkEdges").addEventListener(ResultEvent.RESULT, loadNetworkEdgesEnd);
			remoteObj.getOperation("loadNetworkEdges").addEventListener(FaultEvent.FAULT, loadNetworkFault);
			
			remoteObj.getOperation("renewNetworkLock").addEventListener(ResultEvent.RESULT, renewNetworkLockEnd);
			remoteObj.getOperation("renewNetworkLock").addEventListener(FaultEvent.FAULT, renewNetworkLockFault);
			
			remoteObj.getOperation("clearNetworkLock").addEventListener(ResultEvent.RESULT, clearNetworkLockEnd);
			remoteObj.getOperation("clearNetworkLock").addEventListener(FaultEvent.FAULT, clearNetworkLockFault);
			
			remoteObj.getOperation("deleteNetwork").addEventListener(ResultEvent.RESULT, deleteNetworkEnd);
			remoteObj.getOperation("deleteNetwork").addEventListener(FaultEvent.FAULT, deleteNetworkFault);
		}
		
		//get allowed networks
		public function listNetworks(userid:uint):void {
			remoteObj.getOperation("listNetworks").send(userid);
			CursorManager.setBusyCursor();
		}
		
		private function listNetworksEnd(event:ResultEvent):void {
			networks = event.result as ArrayCollection;
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(LIST_NETWORKS));
		}
		
		private function listNetworksFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//get network details
		public function getNetworkDetails(userid:uint, networkid:uint):void {
			remoteObj.getOperation("getNetworkDetails").send(userid, networkid);
			CursorManager.setBusyCursor();
		}
		
		private function getNetworkDetailsEnd(event:ResultEvent):void {
			networkDetails = event.result;
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(GET_NETWORK_DETAILS));
		}
		
		private function getNetworkDetailsFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//get network permissions
		public function getNetworkPermissions(networkid:uint):void {
			remoteObj.getOperation("getNetworkPermissions").send(networkid);
			CursorManager.setBusyCursor();
		}
		
		private function getNetworkPermissionsEnd(event:ResultEvent):void {
			networkPermissions = event.result as ArrayCollection;
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(GET_NETWORK_PERMISSIONS));
		}
		
		private function getNetworkPermissionsFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//save network as
		public function saveAsNetwork(userid:uint, name:String, description:String, publicstatus:String, width:uint, height:uint, showPores:Boolean, 
		poreFillColor:uint, poreStrokeColor:uint, membraneHeight:Number, membraneCurvature:Number, minCompartmentHeight:Number, ranksep:uint, nodesep:uint, 
		animationFrameRate:Number, loopAnimation:uint, exportShowBiomoleculeSelectedHandles:Boolean, exportColorBiomoleculesByValue:Boolean, 
		exportAnimationFrameRate:Number, exportLoopAnimation:uint):void 
		{
			remoteObj.getOperation("saveAsNetwork").send(userid, name, description, publicstatus, width, height, showPores, 
				poreFillColor, poreStrokeColor, membraneHeight, membraneCurvature, minCompartmentHeight, ranksep, nodesep, 
				animationFrameRate, loopAnimation, exportShowBiomoleculeSelectedHandles, exportColorBiomoleculesByValue, 
				exportAnimationFrameRate, exportLoopAnimation);
			CursorManager.setBusyCursor();
		}
		
		private function saveAsNetworkEnd(event:ResultEvent):void {
			newNetworkId = event.result as uint;
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(SAVE_AS_NETWORK));
		}
		
		private function saveAsNetworkFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//update network
		public function updateNetwork(networkid:uint, userid:uint, network:Object, preview:ByteArray):void {
			remoteObj.getOperation("updateNetwork").send(networkid, userid, network, preview);
			CursorManager.setBusyCursor();
		}
		
		private function updateNetworkEnd(event:ResultEvent):void {
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(UPDATE_NETWORK));
		}
		
		private function updateNetworkFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//save network properties
		public function saveNetworkProperties(networkid:uint, name:String, description:String, publicStatus:String, networkPermissions:String, permissions:ArrayCollection):void {
			remoteObj.getOperation("saveNetworkProperties").send(networkid, name, description, publicStatus, networkPermissions, permissions);
			CursorManager.setBusyCursor();
		}
		
		private function saveNetworkPropertiesEnd(event:ResultEvent):void {
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(SAVE_NETWORK_PROPERTIES));
		}
		
		private function saveNetworkPropertiesFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//load network
		public function loadNetwork(userid:uint, networkid:uint):void {
			networkDetails = biomoleculestyles = compartments = biomolecules = edges = null;			
			remoteObj.getOperation("loadNetwork").send(userid, networkid);
			remoteObj.getOperation("loadNetworkBiomoleculestyles").send(userid, networkid);
			remoteObj.getOperation("loadNetworkCompartments").send(userid, networkid);
			remoteObj.getOperation("loadNetworkBiomolecules").send(userid, networkid);
			remoteObj.getOperation("loadNetworkEdges").send(userid, networkid);
			CursorManager.setBusyCursor();
		}
		
		private function loadNetworkEnd(event:ResultEvent):void {
			networkDetails = event.result as Object;
			assembleNetwork();
		}
		
		private function loadNetworkBiomoleculestylesEnd(event:ResultEvent):void {
			biomoleculestyles = event.result as ArrayCollection;
			assembleNetwork();
		}
		
		private function loadNetworkCompartmentsEnd(event:ResultEvent):void {
			compartments = event.result as ArrayCollection;
			assembleNetwork();
		}
		
		private function loadNetworkBiomoleculesEnd(event:ResultEvent):void {
			biomolecules = event.result as ArrayCollection;
			assembleNetwork();
		}
		
		private function loadNetworkEdgesEnd(event:ResultEvent):void {
			edges = event.result as ArrayCollection;
			assembleNetwork();
		}
		
		private function assembleNetwork():void {
			if (networkDetails != null && biomoleculestyles != null && compartments != null && biomolecules != null && edges != null) {
				network = networkDetails;
				network.biomoleculestyles = biomoleculestyles;
				network.compartments = compartments;
				network.biomolecules = biomolecules;
				network.edges = edges;
				CursorManager.removeBusyCursor();
				dispatchEvent(new Event(LOAD_NETWORK));
			}
		}
		
		private function loadNetworkFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//renew network lock
		public function renewNetworkLock(userid:uint,networkid:uint):void {
			remoteObj.getOperation("renewNetworkLock").send(userid, networkid);
			CursorManager.setBusyCursor();
		}
		
		private function renewNetworkLockEnd(event:ResultEvent):void {
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(RENEW_NETWORK_LOCK));
		}
		
		private function renewNetworkLockFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//clear network lock
		public function clearNetworkLock(networkid:uint):void {
			remoteObj.getOperation("clearNetworkLock").send(networkid);
			CursorManager.setBusyCursor();
		}
		
		private function clearNetworkLockEnd(event:ResultEvent):void {
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(CLEAR_NETWORK_LOCK));
		}
		
		private function clearNetworkLockFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		//delete network
		public function deleteNetwork(networkid:uint):void {
			remoteObj.getOperation("deleteNetwork").send(networkid);
			CursorManager.setBusyCursor();
		}
		
		private function deleteNetworkEnd(event:ResultEvent):void {
			CursorManager.removeBusyCursor();
			dispatchEvent(new Event(DELETE_NETWORK));
		}
		
		private function deleteNetworkFault(event:FaultEvent):void {			
			CursorManager.removeBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}		
	}
	
}