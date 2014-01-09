package edu.stanford.covertlab.util
{
	/**
	 * Miscellaneous utility functions for converting between hexadecimal colors and RGB.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ColorUtils 
	{

		public static function hexToDec(hex:int):String {
			var rgb:Object = hexToRGB(hex);			
			return d2h(rgb.r) + d2h(rgb.g) + d2h(rgb.b);
		}
		
		public static function hexToRGB(hex:uint):Object {
			var r:int = hex >> 16;
			var tmpVal:int = hex ^ r << 16;
			var g:int = tmpVal >> 8;
			var b:int = tmpVal ^ g << 8;
			return { r:r, g:g, b:b };
		}
			
		public static function d2h( d:int ) : String {
			var c:Array = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' ];
			if( d> 255 ) d = 255;
			var l:int = d / 16;
			var r:int = d % 16;
			return c[l]+c[r];
		}
		
		public static function rgbToHex(r:uint, g:uint, b:uint):uint {
			return r << 16 | g << 8 | b;			
		}		
		
		//http://alienryderflex.com/hsp.html
		public static function brightness(hex:uint):uint {
			var rgb:Object = hexToRGB(hex);
			return Math.sqrt(0.241 * Math.pow(rgb.r, 2) +  0.691 * Math.pow(rgb.g, 2) + 0.068 * Math.pow(rgb.b, 2));
		}
	}
	
}