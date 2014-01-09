package edu.stanford.covertlab.graphics.shape 
{
	
	import com.degrafa.core.IGraphicsFill;
	import com.degrafa.core.IGraphicsStroke;
	import com.degrafa.geometry.Ellipse;
	import com.degrafa.geometry.Path;
	import com.degrafa.geometry.segment.ClosePath;
	import com.degrafa.geometry.segment.CubicBezierTo;
	import com.degrafa.geometry.segment.EllipticalArcTo;
	import com.degrafa.geometry.segment.HorizontalLineTo;
	import com.degrafa.geometry.segment.LineTo;
	import com.degrafa.geometry.segment.MoveTo;
	import com.degrafa.geometry.segment.QuadraticBezierTo;
	import com.degrafa.geometry.segment.VerticalLineTo;
	import com.degrafa.GraphicPoint;
	import com.degrafa.transform.MatrixTransform;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Base class for complex shapes.
	 * 
	 * @see ATPaseShape
	 * @see CentrosomeShape
	 * @see DNAShape
	 * @see EndoplasmicReticulumShape
	 * @see FlagellumShape
	 * @see GolgiShape
	 * @see IgShape
	 * @see IonChannelShape
	 * @see MitochondrionShape
	 * @see PassTransmembraneReceptorShape
	 * @see PoreShape
	 * @see YReceptorShape
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ComplexShapeBase extends ShapeBase
	{
		
		public function ComplexShapeBase(size:Number, strokeColor:uint, fillColor:uint) 
		{
			super(size, strokeColor, fillColor);			
		}
		
		protected function translateScale(size:Number, svgBounds:Rectangle, svgScale:Array = null):void {			
			var tx:Number = -(svgBounds.x + svgBounds.width / 2);
			var ty:Number = -(svgBounds.y + svgBounds.height / 2);
			var scale:Number = 2 * size / Math.max(svgBounds.width, svgBounds.height);
			var scaleX:Number;
			var scaleY:Number;
			if(svgScale==null){
				scaleX = scale;
				scaleY = scale;
			}else {
				scaleX = scale * svgScale[0];
				scaleY = scale * svgScale[1];
			}
			var i:uint;
			var j:uint;
			
			for (i = 0; i < geometry.length; i++) {
				if (geometry[i] is Ellipse) {
					geometry[i].x = (geometry[i].x + tx - geometry[i].width) * scaleX;
					geometry[i].y = (geometry[i].y + ty - geometry[i].height) * scaleY;
					geometry[i].width *= 2 * scaleX;
					geometry[i].height *= 2 * scaleY;
				}else if (geometry[i] is Path) {
					if (geometry[i].fill != null && !(geometry[i].segments[geometry[i].segments.length - 1] is ClosePath)) {
						geometry[i].segments.push(new ClosePath());
					}
					for (j = 0; j < geometry[i].segments.length; j++) {
						if(geometry[i].segments[j].coordinateType=='absolute'){
							if (geometry[i].segments[j] is ClosePath) {							
							}else if (geometry[i].segments[j] is CubicBezierTo) {
								geometry[i].segments[j].x = translateScalePoint(geometry[i].segments[j].x, tx, scaleX);
								geometry[i].segments[j].y = translateScalePoint(geometry[i].segments[j].y, ty, scaleY);
								geometry[i].segments[j].cx = translateScalePoint(geometry[i].segments[j].cx, tx, scaleX);
								geometry[i].segments[j].cy = translateScalePoint(geometry[i].segments[j].cy, ty, scaleY);
								geometry[i].segments[j].cx1 = translateScalePoint(geometry[i].segments[j].cx1, tx, scaleX);
								geometry[i].segments[j].cy1 = translateScalePoint(geometry[i].segments[j].cy1, ty, scaleY);
							}else if (geometry[i].segments[j] is EllipticalArcTo) {
								geometry[i].segments[j].x = translateScalePoint(geometry[i].segments[j].x, tx, scaleX);
								geometry[i].segments[j].y = translateScalePoint(geometry[i].segments[j].y, ty, scaleY);
								geometry[i].segments[j].rx *= scale;
								geometry[i].segments[j].ry *= scale;
							}else if (geometry[i].segments[j] is HorizontalLineTo) {
								geometry[i].segments[j].x = translateScalePoint(geometry[i].segments[j].x, tx, scaleX);
							}else if (geometry[i].segments[j] is LineTo) {
								geometry[i].segments[j].x = translateScalePoint(geometry[i].segments[j].x, tx, scaleX);
								geometry[i].segments[j].y = translateScalePoint(geometry[i].segments[j].y, ty, scaleY);
							}else if (geometry[i].segments[j] is MoveTo) {
								geometry[i].segments[j].x = translateScalePoint(geometry[i].segments[j].x, tx, scaleX);
								geometry[i].segments[j].y = translateScalePoint(geometry[i].segments[j].y, ty, scaleY);
							}else if (geometry[i].segments[j] is QuadraticBezierTo) {
								geometry[i].segments[j].x = translateScalePoint(geometry[i].segments[j].x, tx, scaleX);
								geometry[i].segments[j].y = translateScalePoint(geometry[i].segments[j].y, ty, scaleY);
								geometry[i].segments[j].cx = translateScalePoint(geometry[i].segments[j].cx, tx, scaleX);
								geometry[i].segments[j].cy = translateScalePoint(geometry[i].segments[j].cy, ty, scaleY);
							}else if (geometry[i].segments[j] is VerticalLineTo) {
								geometry[i].segments[j].y = translateScalePoint(geometry[i].segments[j].y, ty, scaleY);
							}
						}else {
							if (geometry[i].segments[j] is ClosePath) {							
							}else if (geometry[i].segments[j] is CubicBezierTo) {
								geometry[i].segments[j].x *= scaleX;
								geometry[i].segments[j].y *= scaleY;
								geometry[i].segments[j].cx *= scaleX;
								geometry[i].segments[j].cy *= scaleY;
								geometry[i].segments[j].cx1 *= scaleX;
								geometry[i].segments[j].cy1 *= scaleY;
							}else if (geometry[i].segments[j] is EllipticalArcTo) {
								geometry[i].segments[j].x *= scaleX;
								geometry[i].segments[j].y *= scaleY;
								geometry[i].segments[j].rx *= scaleX;
								geometry[i].segments[j].ry *= scaleY;
							}else if (geometry[i].segments[j] is HorizontalLineTo) {
								geometry[i].segments[j].x *= scaleX;
							}else if (geometry[i].segments[j] is LineTo) {
								geometry[i].segments[j].x *= scaleX;
								geometry[i].segments[j].y *= scaleY;
							}else if (geometry[i].segments[j] is MoveTo) {
								geometry[i].segments[j].x *= scaleX;
								geometry[i].segments[j].y *= scaleY;
							}else if (geometry[i].segments[j] is QuadraticBezierTo) {
								geometry[i].segments[j].x *= scaleX;
								geometry[i].segments[j].y *= scaleY;
								geometry[i].segments[j].cx *= scaleX;
								geometry[i].segments[j].cy *= scaleY;
							}else if (geometry[i].segments[j] is VerticalLineTo) {
								geometry[i].segments[j].y *= scaleY;
							}
						}
					}
				}
			}
		}
		
		protected function translateScalePoint(x:Number, tx:Number, scale:Number):Number {
			return (x + tx) * scale;
		}
	}	
}