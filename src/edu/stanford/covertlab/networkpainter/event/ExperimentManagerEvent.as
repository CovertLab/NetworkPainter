package edu.stanford.covertlab.networkpainter.event 
{
	import flash.events.Event;
	
	/**
	 * Event class for ExperimentManager. Defines 1 event. 
	 * <ul>
	 * <li>update experiment associations: dispatched when user uses ManageExperimentsWindow to edit 
	 *     associations and perturbations between a network and an experiment.</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.manager.ExperimentManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ExperimentManagerEvent extends Event
	{
		
		public function ExperimentManagerEvent(type:String)
		{
			super(type);
		}
		
		public static const EXPERIMENT_ASSOCIATIONS_UPDATED:String = "updateExperimentAssociations";
	}
	
}