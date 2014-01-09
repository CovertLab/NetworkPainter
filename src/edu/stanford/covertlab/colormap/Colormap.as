package edu.stanford.covertlab.colormap 
{
	
	import edu.stanford.covertlab.util.ColorUtils;
	import mx.collections.ArrayCollection;
	
	/**
	 * Converts real numbers on the scale [0,1] to a color using one of several color maps.
	 * 
	 * <p>Values are truncated to the range [0,1]. <code>NaN</code> values are displayed in a special color 
	 * for each colormap:
	 * <ul>
	 * <li>CytoBank Blue-Yellow (default) -  red</li>
	 * <li>Blue-Yellow - red</li>
	 * <li>Red-Green - white</li>
	 * </ul></p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class Colormap 
	{
	
		public static const BLUE_YELLOW:String = 'Blue-Yellow';		
		public static const CYTOBANK_BLUE_YELLOW:String = 'CytoBank Blue-Yellow';
		public static const GREEN_RED:String = 'Green-Red';
		public static const GREY:String = 'Grey';		
		
		public static const COLORMAPS:ArrayCollection = new ArrayCollection([
			{name:BLUE_YELLOW },
			{name:CYTOBANK_BLUE_YELLOW },
			{name:GREEN_RED },
			{name:GREY}]);
		
		public static function scale(colormap:String, value:Number):Number {
			value = Math.max(0, Math.min(1, value));
			var color:Number=0;
			switch(colormap) {				
				//blue-black-yellow
				case BLUE_YELLOW:
					//undefined
					if (isNaN(value)) color = NaN;
					
					//otherwise
					else if (value < 0.5) color = ColorUtils.rgbToHex(0, 0, 2 * (0.5 - value) * 255);
					else color = ColorUtils.rgbToHex(2 * (value - 0.5) * 255, 2 * (value - 0.5) * 255, 0);
					break;
				//red-black-green
				case GREEN_RED:
					//undefined
					if (isNaN(value)) color = NaN;
					
					//otherwise
					else if (value < 0.5) color = ColorUtils.rgbToHex(0, 2 * (0.5 - value) * 255, 0);
					else color = ColorUtils.rgbToHex(2 * (value - 0.5) * 255, 0, 0);
					break;
				//Grey
				case GREY:
					//undefined
					if (isNaN(value)) color = NaN;
					
					//otherwise					
					else color = ColorUtils.rgbToHex(value * 255, value * 255, value * 255);
					break;
				//white-blue-black-yellow-white
				case CYTOBANK_BLUE_YELLOW:
				default:
					//undefined
					if (isNaN(value)) color = NaN;
					
					//otherwise
					else if (value < 0.25) color = ColorUtils.rgbToHex(4 * (0.25 - value) * 255, 4 * (0.25 - value) * 255, 255);
					else if (value < 0.5) color = ColorUtils.rgbToHex(0, 0, 4 * (0.5-value) * 255);
					else if (value < 0.75) color = ColorUtils.rgbToHex(4 * (value - 0.5) * 255, 4 * (value - 0.5) * 255, 0);
					else color = ColorUtils.rgbToHex(255, 255, 4 * (value - 0.75) * 200);
					break;
			}
			return color;
		}
		
	}
	
}