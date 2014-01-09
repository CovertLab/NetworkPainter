package edu.stanford.covertlab.service 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	[Event(name = 'keggListPathways', type = "flash.events.Event")]
	[Event(name = 'keggGetPathway', type = "flash.events.Event")]
	[Event(name = 'keggFault', type = "flash.events.Event")]
	
	/**
	 * Provides three functions for importing pathways from the KEGG database via
	 * a KEGG AMFPHP object.
	 * <ul>
	 * <li>List of available pathways</li>
	 * <li>Import a specific pathway</li>
	 * <li>Get URL for a preview image of a pathway</li>
	 * </ul>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class KEGG extends EventDispatcher
	{		
		//remote object
		private var remoteObj:RemoteObject;
		
		//constants
		public static const KEGG_LISTPATHWAYS:String = 'keggListPathways';
		public static const KEGG_GETPATHWAY:String = 'keggGetPathway';
		public static const KEGG_FAULT:String = 'keggFault';
		public static const DESTINATION:String = "amfphp";
		public static const SOURCE:String = "KEGG.KEGG";		
		
		//flags
		private var listingPathways:Boolean = false;
		private var gettingPathway:Boolean = false;
	
		//data
		public var pathways:ArrayCollection;
		public var pathway:Object;
		public var error:String;
		
		public function KEGG() 
		{
			remoteObj = new RemoteObject(DESTINATION);
			remoteObj.source = SOURCE;
			
			remoteObj.getOperation("listPathways").addEventListener(ResultEvent.RESULT, listPathwaysEnd);
			remoteObj.getOperation("listPathways").addEventListener(FaultEvent.FAULT, listPathwaysFault);
			
			remoteObj.getOperation("getPathway").addEventListener(ResultEvent.RESULT, getPathwayEnd);
			remoteObj.getOperation("getPathway").addEventListener(FaultEvent.FAULT, getPathwayFault);
		}
		
		//list pathways
		public function listPathways():void {
			remoteObj.getOperation("listPathways").send();
			listingPathways = true;
			refreshBusyCursor();
		}
		
		private function listPathwaysEnd(event:ResultEvent):void {
			pathways = new ArrayCollection(event.result as Array);
			listingPathways = false;			
			refreshBusyCursor();
			dispatchEvent(new Event(KEGG_LISTPATHWAYS));
		}
		
		private function listPathwaysFault(event:FaultEvent):void {			
			listingPathways = false;
			refreshBusyCursor();
			dispatchEvent(new Event(KEGG_FAULT));
		}
		
		//get pathway
		public function getPathway(pathway:Object):void {
			remoteObj.getOperation("getPathway").send(pathway.id);
			gettingPathway = true;
			refreshBusyCursor();
		}
		
		private function getPathwayEnd(event:ResultEvent):void {
			pathway = event.result;
			gettingPathway = false;			
			refreshBusyCursor();
			dispatchEvent(new Event(KEGG_GETPATHWAY));
		}
		
		private function getPathwayFault(event:FaultEvent):void {
			gettingPathway = false;
			refreshBusyCursor();
			dispatchEvent(new Event(KEGG_FAULT));
		}
		
		//preview
		public function previewSource(pathway:Object):String {
			var org:String = pathway.id.match(/^[a-z]+/i)[0];
			return 'http://www.genome.jp/kegg/pathway/' + org + '/' + pathway.id + '.png';
		}
		
		/****************************************************
		 * busy cursor
		 * **************************************************/		
		private function refreshBusyCursor():void {
			if (listingPathways || gettingPathway) CursorManager.setBusyCursor();
			else CursorManager.removeBusyCursor();
		}
		
	}
	
}