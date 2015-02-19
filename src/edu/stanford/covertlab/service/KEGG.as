package edu.stanford.covertlab.service 
{
	import edu.stanford.covertlab.controls.StatusBar;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
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
		public static const SOURCE:String = "KEGG";		
			
		//data
		public var pathways:ArrayCollection;
		public var pathway:Object;
		public var error:String;
		
		//status bar
		private var statusBar:StatusBar;
		
		public function KEGG() 
		{
			remoteObj = new RemoteObject(DESTINATION);
			remoteObj.source = SOURCE;
			
			remoteObj.getOperation("listPathways").addEventListener(ResultEvent.RESULT, listPathwaysEnd);
			remoteObj.getOperation("listPathways").addEventListener(FaultEvent.FAULT, listPathwaysFault);
			
			remoteObj.getOperation("getPathway").addEventListener(ResultEvent.RESULT, getPathwayEnd);
			remoteObj.getOperation("getPathway").addEventListener(FaultEvent.FAULT, getPathwayFault);
			
			statusBar = Application.application.statusBar;
		}
		
		//list pathways
		public function listPathways():void {
			remoteObj.getOperation("listPathways").send();		
			statusBar.addMessage('listKegg', 'Retrieving list of KEGG pathways ...');			
		}
		
		private function listPathwaysEnd(event:ResultEvent):void {
			pathways = new ArrayCollection(event.result as Array);			
			statusBar.removeMessage('listKegg');			
			dispatchEvent(new Event(KEGG_LISTPATHWAYS));
		}
		
		private function listPathwaysFault(event:FaultEvent):void {			
			statusBar.removeMessage('listKegg');
			dispatchEvent(new Event(KEGG_FAULT));
		}
		
		//get pathway
		public function getPathway(pathway:Object):void {
			remoteObj.getOperation("getPathway").send(pathway.id);
			statusBar.addMessage('getKegg', 'Retrieving KEGG pathway ...');
		}
		
		private function getPathwayEnd(event:ResultEvent):void {
			pathway = event.result;
			statusBar.removeMessage('getKegg');
			dispatchEvent(new Event(KEGG_GETPATHWAY));
		}
		
		private function getPathwayFault(event:FaultEvent):void {
			statusBar.removeMessage('getKegg');
			dispatchEvent(new Event(KEGG_FAULT));
		}
		
		//preview
		public function previewSource(pathway:Object):String {
			return 'services/amfphp/Amfphp/Services/KEGG-cache/' + pathway.id + '.thumb-250x250.png';
		}		
	}
	
}