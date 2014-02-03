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
	
	[Event(name = 'getExperiments', type = "flash.events.Event")]
	[Event(name = 'setExperiments', type = "flash.events.Event")]
	[Event(name = 'fault', type = "flash.events.Event")]
	
	/**
	 * Provides functions for interacting with CytoBank through a CytoBank AMFPHP object. Provides 4 functions
	 * <ul>
	 * <li>list experiments available to a user (retrieves basic annotation plus lists of channels and conditions)</li>
	 * <li>full annotation of an experiment (channels, conditions, dosages, individuals, populations, timepoints)</li>
	 * <li>list of statistics (one of medians, arc sinh medians, 95th percentile, etc) for an experiment 
	 *     for each combination of channel, condition, dosage, individual, population,  and timepoint</li>
	 * <li>1D distribution of a channel for a condition, dosage, individual, population, and timepoint</li>
	 * </ul>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class NetworkPainterExperiments extends EventDispatcher
	{
		//constants
		public static const GET_EXPERIMENTS:String = 'getExperiments';
		public static const SET_EXPERIMENTS:String = 'setExperiments';
		public static const FAULT:String = 'fault';
		
		public static const DESTINATION:String = "amfphp";
		public static const SOURCE:String = "NetworkPainter.NetworkPainter";
		
		//remote object
		private var remoteObj:RemoteObject;
		
		//data
		public var result:Object;
		public var error:String;
		
		//status bar
		private var statusBar:StatusBar;
		
		public function NetworkPainterExperiments() 
		{
			remoteObj = new RemoteObject(DESTINATION);
			remoteObj.source = SOURCE;
			
			remoteObj.getOperation("getExperiments").addEventListener(ResultEvent.RESULT, getExperimentsEnd);
			remoteObj.getOperation("getExperiments").addEventListener(FaultEvent.FAULT, getExperimentsFault);
			
			remoteObj.getOperation("setExperiments").addEventListener(ResultEvent.RESULT, setExperimentsEnd);
			remoteObj.getOperation("setExperiments").addEventListener(FaultEvent.FAULT, setExperimentsFault);
			
			statusBar = Application.application.statusBar;
		}
		
		/****************************************************
		 * queries
		 * **************************************************/
		//experiments
		public function getExperiments(networkID:uint):void {
			remoteObj.getOperation("getExperiments").send(networkID);
			statusBar.addMessage('getExperiments', 'Listing experiments ...');
		}
		
		private function getExperimentsEnd(event:ResultEvent):void {
			result = event.result;
			statusBar.removeMessage('getExperiments');
			dispatchEvent(new Event(GET_EXPERIMENTS));
		}
		
		private function getExperimentsFault(event:FaultEvent):void {			
			statusBar.removeMessage('getExperiments');
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		
		//averages
		public function setExperiments(networkID:uint, data:Object):void {				
			remoteObj.getOperation("setExperiments").send(networkID, data);
			statusBar.addMessage('setExperiments', 'Saving experiment ...');
		}
		
		private function setExperimentsEnd(event:ResultEvent):void {
			statusBar.removeMessage('setExperiments');
			dispatchEvent(new Event(SET_EXPERIMENTS));
		}
		
		private function setExperimentsFault(event:FaultEvent):void {			
			statusBar.removeMessage('setExperiments');
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
	}	
}