package edu.stanford.covertlab.diagram.toolbar 
{
	import flexlib.containers.Docker;
	import edu.stanford.covertlab.diagram.core.Diagram;
	
	/**
	 * Docker for dockable toolbars -- animation, control, and new biomlecule, biomolecules style, and compartment toolbars.
	 * 
	 * @see ToolBar
	 * @see flexlib.containers.Docker
	 * 
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class DiagramToolBarDocker extends Docker
	{
		protected var diagram:Diagram;
		
		public var controlbar:ControlToolBar;
		public var componentbar:NewComponentToolBar;
		public var stylebar:NewBiomoleculeToolBar;
		public var animationbar:AnimationToolBar;
		
		public function DiagramToolBarDocker(diagram:Diagram) 
		{			
			this.diagram = diagram;
						
			controlbar = new ControlToolBar(diagram);
			componentbar= new NewComponentToolBar(diagram);
			stylebar = new NewBiomoleculeToolBar(diagram);
			animationbar = new AnimationToolBar(diagram);
			animationbar.initialPosition = "bottom";
			
			addChild(controlbar);
			addChild(componentbar);
			addChild(stylebar);
			addChild(animationbar);
		}
	}
	
}