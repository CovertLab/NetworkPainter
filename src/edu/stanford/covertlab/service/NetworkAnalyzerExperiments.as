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
		
		//flags
		private var queryingGetExperiments:Boolean = false;
		private var queryingSetExperiments:Boolean = false;
		
		//data
		public var result:Object;
		public var error:String;
		
		public function NetworkPainterExperiments() 
		{
			remoteObj = new RemoteObject(DESTINATION);
			remoteObj.source = SOURCE;
			
			remoteObj.getOperation("getExperiments").addEventListener(ResultEvent.RESULT, getExperimentsEnd);
			remoteObj.getOperation("getExperiments").addEventListener(FaultEvent.FAULT, getExperimentsFault);
			
			remoteObj.getOperation("setExperiments").addEventListener(ResultEvent.RESULT, setExperimentsEnd);
			remoteObj.getOperation("setExperiments").addEventListener(FaultEvent.FAULT, setExperimentsFault);
		}
		
		/****************************************************
		 * queries
		 * **************************************************/
		//experiments
		public function getExperiments(networkID:uint):void {
			remoteObj.getOperation("getExperiments").send(networkID);
			queryingGetExperiments = true;
			refreshBusyCursor();
		}
		
		private function getExperimentsEnd(event:ResultEvent):void {
			result = event.result;
			queryingGetExperiments = false;			
			refreshBusyCursor();
			dispatchEvent(new Event(GET_EXPERIMENTS));
		}
		
		private function getExperimentsFault(event:FaultEvent):void {			
			queryingGetExperiments = false;
			refreshBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}
		
		
		//averages
		public function setExperiments(networkID:uint, data:Object):void {				
			remoteObj.getOperation("setExperiments").send(networkID, data);
			queryingSetExperiments = true;
			refreshBusyCursor();
		}
		
		private function setExperimentsEnd(event:ResultEvent):void {
			queryingSetExperiments = false;
			refreshBusyCursor();
			dispatchEvent(new Event(SET_EXPERIMENTS));
		}
		
		private function setExperimentsFault(event:FaultEvent):void {			
			queryingSetExperiments = false;			
			refreshBusyCursor();
			dispatchEvent(new FaultEvent(FAULT, false, true, null, null, event.message));
		}

		
		/****************************************************
		 * busy cursor
		 * **************************************************/		
		private function refreshBusyCursor():void {
			if (queryingGetExperiments || queryingSetExperiments) CursorManager.setBusyCursor();
			else CursorManager.removeBusyCursor();
		}		
	}	
}