package edu.stanford.covertlab.service 
{
	import edu.stanford.covertlab.controls.StatusBar;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	[Event(name = 'reactomeListPathways', type = "flash.events.Event")]
	[Event(name = 'reactomeGetPathway', type = "flash.events.Event")]
	[Event(name = 'reactomeFault', type = "flash.events.Event")]
	
	/**
	 * Provides three functions for importing pathways from the Reactome database via
	 * a Reactome AMFPHP object.
	 * <ul>
	 * <li>List of available pathways</li>
	 * <li>Import a specific pathway</li>
	 * <li>Get URL for a preview image of a pathway (always returns null because no previews
	 *     available; implemented for symmetry with KEGG class)</li>
	 * </ul>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Reactome extends EventDispatcher
	{		
		//remote object
		private var remoteObj:RemoteObject;
		
		//constants
		public static const REACTOME_LISTPATHWAYS:String = 'reactomeListPathways';
		public static const REACTOME_GETPATHWAY:String = 'reactomeGetPathway';
		public static const REACTOME_FAULT:String = 'reactomeFault';
		public static const DESTINATION:String = "amfphp";
		public static const SOURCE:String = "Reactome.Reactome";		
		
		//data
		public var pathways:ArrayCollection;
		public var pathway:Object;
		public var error:String;
		
		//status bar
		private var statusBar:StatusBar;
		
		public function Reactome() 
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
			statusBar.addMessage('listReactome', 'Listing Reactome pathways ...');
		}
		
		private function listPathwaysEnd(event:ResultEvent):void {
			pathways = new ArrayCollection(event.result as Array);
			statusBar.removeMessage('listReactome');
			dispatchEvent(new Event(REACTOME_LISTPATHWAYS));
		}
		
		private function listPathwaysFault(event:FaultEvent):void {			
			statusBar.removeMessage('listReactome');
			dispatchEvent(new Event(REACTOME_FAULT));
		}
		
		//get pathway
		public function getPathway(pathway:Object):void {
			remoteObj.getOperation("getPathway").send(pathway.id);
			statusBar.addMessage('getReactome', 'Getting Reactome pathway ...');
		}
		
		private function getPathwayEnd(event:ResultEvent):void {
			pathway = event.result;
			statusBar.removeMessage('getReactome');
			dispatchEvent(new Event(REACTOME_GETPATHWAY));
		}
		
		private function getPathwayFault(event:FaultEvent):void {			
			statusBar.removeMessage('getReactome');
			dispatchEvent(new Event(REACTOME_FAULT));
		}
		
		//preview
		public function previewSource(pathway:Object):String {
			return null;
		}
	}
	
}