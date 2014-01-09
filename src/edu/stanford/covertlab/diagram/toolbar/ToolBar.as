package edu.stanford.covertlab.diagram.toolbar
{
	import edu.stanford.covertlab.diagram.core.Diagram;
	import flash.events.MouseEvent;
	import flexlib.containers.DockableToolBar;
	import mx.binding.utils.BindingUtils;
	import mx.containers.Box;
	import mx.controls.Image;
	import mx.effects.Fade;
	import mx.effects.Move;
	
	/**
	 * Base dockable toolbar class. Used for the animation, control, and new compartment, style, and biomolecule toolbars.
	 * 
	 * @see AnimationToolBar
	 * @see ControlToolBar
	 * @see NewBiomoleculeToolBar
	 * @see NewComponentToolBar
	 * @see ToolBarButton
	 * @see flexlib.containers.DockableToolBar
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ToolBar extends DockableToolBar
	{
		[Embed(source="../../image/dragStrip.png")]
		private var myDragStripClass:Class;
		private var myDragStrip:Image;
		
		public var moveEffect:Move;
		public var fadeEffect:Fade;
		[Bindable] protected var diagram:Diagram;
		
		public function ToolBar(diagram:Diagram) 
		{
			this.diagram = diagram;
			
			setStyle('dragStripIcon', myDragStripClass);
			myDragStrip = new Image();
			myDragStrip.source = myDragStripClass;			
			
			moveEffect = new Move();
			moveEffect.duration = 375;
			
			fadeEffect = new Fade();
			fadeEffect.duration = 375;
			
			setStyle('addedEffect', fadeEffect);
		}				
		
		override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			if (myDragStrip && unscaledWidth < myDragStrip.getExplicitOrMeasuredWidth())
				return;
			styleName = isDocked ? 'docked' : 'undocked';
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		
		override protected function updateFloatingStatus(event:MouseEvent):void
		{
			super.updateFloatingStatus(event);
			if (floatingWindow != null) {
				floatingWindow.styleName = 'popedup'; // what purpose does this serve?
				floatingWindow.setStyle('removedEffect', fadeEffect);
				floatingWindow.setStyle('moveEffect', moveEffect);
			}
		}

		
		
	}
}