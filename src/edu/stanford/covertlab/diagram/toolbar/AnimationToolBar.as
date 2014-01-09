package edu.stanford.covertlab.diagram.toolbar 
{
	import edu.stanford.covertlab.diagram.core.Diagram;
	import mx.binding.utils.BindingUtils;
	
	/**
	 * Toolbar which animation play, pause, and stop controls and an animation timeline.
	 * 
	 * @see AnimationBar
	 * @see ToolBar
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class AnimationToolBar extends ToolBar
	{
		public var animationBar:AnimationBar;
		
		public function AnimationToolBar(diagram:Diagram) 
		{		
			super(diagram);
			
			label = 'Animation';
			animationBar = new AnimationBar(diagram, false);
			addChild(animationBar);
		}
		
		
	}
	
}