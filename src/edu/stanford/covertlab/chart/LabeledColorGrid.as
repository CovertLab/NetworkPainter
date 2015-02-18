package edu.stanford.covertlab.chart 
{
	import com.degrafa.GeometryGroup;
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.Surface;
	import com.degrafa.transform.Transform;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import mx.containers.Canvas;

	/**
	 * Displays color scale bar with labels.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/20/2009
	 */
	public class LabeledColorGrid extends Canvas
	{
		private var surface:Surface;
		private var gridGeometryGroup:GeometryGroup;
		private var rowLabelsGeometryGroup:GeometryGroup;
		private var colLabelsGeometryGroup:GeometryGroup;
		
		public function LabeledColorGrid()
		{						
			//properties
			clipContent = false;
			useHandCursor = false;
			buttonMode = false;
			
			//surface
			surface = new Surface();
			addChild(surface);
			
			//row, col labels
			colLabelsGeometryGroup = new GeometryGroup();
			colLabelsGeometryGroup.target = surface;
			surface.addChild(colLabelsGeometryGroup);

			rowLabelsGeometryGroup = new GeometryGroup();
			rowLabelsGeometryGroup.target = surface;
			surface.addChild(rowLabelsGeometryGroup);

			//geometry group
			gridGeometryGroup = new GeometryGroup();
			gridGeometryGroup.target = surface;
			surface.addChild(gridGeometryGroup);
		}
		
		public function update(nCol:uint, nRow:uint, cellW:uint, cellH:uint, colLabels:Array, rowLabels:Array, colors:Array):void {
			var i:uint;
			var line:Line;
			var w:Number = nCol * cellW;
			var h:Number = nRow * cellH;

			while (rowLabelsGeometryGroup.numChildren > 0) rowLabelsGeometryGroup.removeChildAt(0);
			while (colLabelsGeometryGroup.numChildren > 0) colLabelsGeometryGroup.removeChildAt(0);
			colLabelsGeometryGroup.x = 0;
			colLabelsGeometryGroup.y = -h - 2;
			rowLabelsGeometryGroup.x = w + 2;
			rowLabelsGeometryGroup.y = -h;
			var label:RasterText;
			var fill:SolidFill = new SolidFill(0x000000);

			for (i = 0; i < nCol; i++) {
				label = new RasterText();
				label.htmlText = colLabels[i];
				label.fontFamily = 'EmbeddedArial';
				label.fontSize = 10;
				label.fill = fill;
				label.autoSizeField = true;				
				label.x = 0;
				label.y = 0;

				label.transform = new Transform();
				label.transform.transformMatrix.rotate(-Math.PI/2);
  				label.transform.transformMatrix.translate(i * cellW, 0);

				colLabelsGeometryGroup.geometryCollection.addItem(label);				
			}
			for (i = 0; i < nRow; i++) {
				label = new RasterText();
				label.htmlText = rowLabels[i];
				label.fontFamily = 'EmbeddedArial';
				label.fontSize = 10;
				label.fill = fill;
				label.autoSizeField = true;
				label.x = 0;
				label.y = i * cellH;
				rowLabelsGeometryGroup.geometryCollection.addItem(label);
			}

			while (gridGeometryGroup.numChildren > 0) gridGeometryGroup.removeChildAt(0);
			var rect:RegularRectangle = new RegularRectangle(0, -h, w, h);
			rect.fill = new SolidFill(0xFFFFFF);
			gridGeometryGroup.geometryCollection.addItem(rect);
			for (i = 0; i <= nCol; i++){				
				line = new Line(i*cellW, -h, i*cellW, 0);
				line.stroke = new SolidStroke(0x000000);
				gridGeometryGroup.geometryCollection.addItem(line)
			}
			for (i = 0; i <= nRow; i++){
				line = new Line(0, -h + i*cellH, w, -h + i*cellH);
				line.stroke = new SolidStroke(0x000000);
				gridGeometryGroup.geometryCollection.addItem(line)
			}
		}		
	}
	
}