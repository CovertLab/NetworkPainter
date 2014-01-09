package edu.stanford.covertlab.util 
{
	
	/**
	 * Defines four mathematical operations for arrays.
	 * <ul>
	 * <li>mean</li>
	 * <li>median</li>
	 * <li>min</li>
	 * <li>max</li>
	 * </ul>
	 * 
	 * <p>Each methods operates over non-NaN values and return NaN if the array is empty.</p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ArrayMathUtils 
	{
		
		//averages finite elements of an array
		public static function mean(arr:Array):Number {
			if (arr.length == 0)
				return NaN;
			
			var sum:Number = 0;
			var cnt:Number = 0;
			for (var i:uint = 0; i < arr.length; i++) {
				if (isNaN(arr[i]))
					continue;
				sum += arr[i];
				cnt++;
			}
			return (cnt > 0 ? sum / cnt : NaN);
		}
		
		public static function median(arr:Array):Number {			
			if (arr.length == 0) return NaN;
			arr=arr.filter(function(value:Number):Boolean { return !isNaN(value); } );
			arr.sort();			
			if ((arr.length % 2) == 1) return arr[(arr.length - 1) / 2];
			return (arr[arr.length / 2 - 1] + arr[arr.length / 2]) / 2;
		}

		public static function min(arr:Array):Number {
			if (arr.length == 0) return NaN;
			var min:Number = Infinity;
			for (var i:uint = 0; i < arr.length; i++) {
				if (isNaN(arr[i])) continue;
				min = Math.min(min, arr[i]);
			}
			return min;
		}
		
		public static function max(arr:Array):Number {
			if (arr.length == 0) return NaN;
			var max:Number = -Infinity;
			for (var i:uint = 0; i < arr.length; i++) {
				if (isNaN(arr[i])) continue;
				max = Math.max(max, arr[i]);
			}
			return max;
		}
		
	}
	
}