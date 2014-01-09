package edu.stanford.covertlab.graphics.renderablerepeater 
{
	import com.degrafa.geometry.repeaters.Repeater;
	
	/**
	 * Exposes object stack of a degrafa repeater so that it can be accessed by the renderers.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class RenderableRepeater extends Repeater
	{
		
		public function RenderableRepeater() 
		{
			super();
		}
		
		/**
		* An Array of geometry objects that make up this repeater. 
		**/
		protected var objectStack:Array=[];			
				
		//expose object stack
		public function getObjectStack():Array {
			return objectStack;
		}
	}
	
}