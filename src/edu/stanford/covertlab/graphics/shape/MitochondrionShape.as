﻿package edu.stanford.covertlab.graphics.shape 
{
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Path;
	import com.degrafa.GraphicPoint;
	import flash.geom.Rectangle;
	
	/**
	 * Draws a mitochondrion.
	 * 
	 * <p>
	 * <img src="../../../../../../src/edu/stanford/covertlab/graphics/shape/png/mitochondrion.png" />
	 * </p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class MitochondrionShape extends ComplexShapeBase
	{
		
		public function MitochondrionShape(size:Number, strokeColor:uint, fillColor:uint)
		{
			var path:Path;
			var ellipse:Ellipse;
			
			super(size, strokeColor, fillColor);
			
			var bounds:Rectangle = new Rectangle(0, 0, 280, 126);
			
			ellipse = new Ellipse(140,63,140,63);
			ellipse.stroke = stroke;
			ellipse.fill = fill;
			geometryCollection.addItem(ellipse);

			path = new Path('M 8.5728477,58.951807 '+
				'C 9.8172879,46.744626 33.470039,16.22386 67.076448,18.891566 '+
				'C 78.775191,19.973567 71.534917,57.935917 79.518382,78.301582 '+
				'C 81.696748,81.685911 87.655361,82.295874 87.891257,78.525463 '+
				'C 89.08361,58.29264 86.793825,38.243667 91.362563,18.317722 '+
				'C 94.336784,8.4987389 137.62765,10.650285 143.71911,15.268102 '+
				'C 154.32353,26.876218 136.60325,80.874539 150.15744,86.009316 '+
				'C 158.3925,88.619095 151.38829,16.941544 151.58987,11.472922 '+
				'C 152.21755,2.5314499 212.08348,8.2716376 211.21724,23.895295 '+
				'C 210.53297,35.64177 207.39193,55.677829 210.53255,58.108434 '+
				'C 215.92277,61.541588 208.25202,32.466954 220.61608,23.697489 '+
				'C 224.20552,22.090971 227.55319,27.412053 239.40506,32.189918 '+
				'C 252.63417,38.353112 258.48,42.080931 246.7062,70.087963 '+
				'C 245.1751,73.215239 252.01109,73.123235 253.6511,70.498203 '+
				'C 256.3278,64.205964 255.33079,49.653811 265.24096,55.156627 '+
				'C 273.1648,60.854078 265.3779,72.064563 263.13253,79.192771 '+
				'C 258.21677,92.721733 234.28062,103.25443 230.24096,98.168675 '+
				'C 222.27633,85.036181 228.53408,59.530375 231.02347,45.236117 '+ 
				'C 230.31921,41.433153 223.94397,44.434045 223.56353,49.716 '+
				'C 220.38508,66.79101 216.74699,80.73362 216.74699,98.168675 '+
				'C 217.06938,111.66766 186.32614,116.59247 182.16867,111.66265 '+
				'C 176.53664,102.30976 181.71007,81.925925 175.42169,80.457831 '+
				'C 172.01976,79.607349 166.9423,90.190116 166.9423,92.273757 '+
				'C 166.77898,99.241564 167.1234,104.0783 167.40964,111.24096 '+
				'C 167.83843,120.09172 125.81537,118.56472 125.41268,112.40387 '+
				'C 123.69415,93.379492 123.9759,74.241942 123.9759,55.156627 '+
				'C 123.9437,50.690289 118.17287,36.283842 115.12048,44.192771 '+
				'C 106.50802,65.081095 110.12009,93.749708 104.15663,115.18831 '+
				'C 101.31598,124.14961 75.055676,111.48981 69.291391,109.61944 '+
				'C 65.594022,108.18701 65.241892,75.238918 64.713697,69.756991 '+
				'C 64.160137,64.011821 64.212804,46.068413 62.679168,41.973481 '+
				'C 59.232212,33.262213 51.843164,32.116637 51.0154,53.937215 '+
				'C 50.47704,66.835469 56.426234,104.81356 47.650603,101.96386 '+
				'C 32.405843,97.936335 7.462466,82.804825 8.5728477,58.951807 '+
				'z');
			path.stroke = stroke;
			geometryCollection.addItem(path);
						
			translateScale(size, bounds, [2, 2]);
			
			labelOffsetY = 2.0 * bounds.height * size / Math.max(bounds.width, bounds.height) + 5;
		}
		
		override public function port(theta:Number, sense:Boolean):GraphicPoint {
			return new GraphicPoint(size * Math.sin(theta), 63 / 140 * size * Math.cos(theta));
		}
		
	}
	
}