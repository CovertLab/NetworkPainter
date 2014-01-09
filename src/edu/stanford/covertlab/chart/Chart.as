package edu.stanford.covertlab.chart 
{
	import com.degrafa.geometry.Line;
	import com.degrafa.geometry.Polygon;
	import com.degrafa.geometry.Polyline;
	import com.degrafa.geometry.RasterText;
	import com.degrafa.geometry.RegularRectangle;
	import com.degrafa.GeometryGroup;
	import com.degrafa.GraphicPoint;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import com.degrafa.Surface;
	import com.degrafa.transform.MatrixTransform;
	import com.degrafa.transform.Transform;
	import edu.stanford.covertlab.colormap.Colormap;
	import edu.stanford.covertlab.graphics.renderablerepeater.ColorBar;
	import edu.stanford.covertlab.graphics.renderablerepeater.ColorGrid;	
	import edu.stanford.covertlab.graphics.SupSubRasterText;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.events.ToolTipEvent;
	import mx.managers.ToolTipManager;
	
	/**
	 * Simple charting class.
	 * 
	 * <p>Supports the following chart types:
	 * <ul>
	 * <li>area</li>
	 * <li>bar</li>
	 * <li>heatmap (displays color scale to right of heatmap)</li>
	 * <li>histogram</li>
	 * <li>line</li>
	 * </ul>
	 * </p>
	 * 
	 * <p>Supports the following axes scales
	 * <ul>
	 * <li>linear</li>
	 * <li>log</li>
	 * <li>arc sinh</li>
	 * </ul>
	 * </p>
	 * 
	 * <p>Heatmap, bar, and histogram chart types trigger tooltip events.</p>
	 * 
	 * <p>Can be embedded in any UIComponent. For example can be embedded inside a TitleWindow
	 * and used as a tool tip.</p>
	 * 
	 * @see ChartWindow
	 * @see ChartToolTip
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	
	public class Chart extends Canvas
	{
		
		private var _chartType:String;
		private var _xAxis:Object;
		private var _yAxis:Object;
		private var _chartData:Array;
		private var _colormap:String;
		private var _colormapScale:Array;
		private var _axisFontSize:int;
		private var _tickFontSize:int;
		private var _createToolTip:Function;
		
		public function Chart(chartType:String = '', xAxis:Object = null, yAxis:Object = null, chartData:Array = null, 
			colormap:String = '', colormapScale:Array = null, 
			axisFontSize:int = 12, tickFontSize:int = 8,
			createToolTip:Function = null)
		{

			updateProperties(chartType, xAxis, yAxis, chartData, colormap, colormapScale, axisFontSize, tickFontSize, createToolTip);
			
			//canvas
			percentWidth = 100;
			percentHeight = 100;
			
			//surface
			surface.percentWidth = 100;
			surface.percentHeight = 100;
			addChild(surface);
			
			//axes, data
			surface.addChild(xAxisGeometryGroup);
			surface.addChild(yAxisGeometryGroup);
			surface.addChild(dataGeometryGroup);
			
			//color scale
			surface.addChild(colorScaleGeometryGroup);
			surface.addChild(colorScaleLabelsGeometryGroup);
					
			//resize
			BindingUtils.bindSetter(layoutChart, this, 'width');
			BindingUtils.bindSetter(layoutChart, this, 'height');
			
			//tool tips
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		/************************************************
		* setters, getters
		* **********************************************/
		public function updateProperties(chartType:String = '', xAxis:Object = null, yAxis:Object = null, chartData:Array = null, 
			colormap:String = '', colormapScale:Array = null, 
			axisFontSize:int = 12, tickFontSize:int = 8,
			createToolTip:Function = null):void {
				_chartType = chartType;				
				_xAxis = xAxis;
				_yAxis = yAxis;			
				_chartData = chartData;
				_colormap = colormap;
				_colormapScale = colormapScale;
				_axisFontSize = axisFontSize;
				_tickFontSize = tickFontSize;			
				this.createToolTip = createToolTip;
				
				setupXAxis();
				setupYAxis();
				layoutChart();
				
		}
		
		public function get chartType():String {
			return _chartType;
		}
		
		public function set chartType(value:String):void {
			if (_chartType != value) {
				_chartType = value;
				setupXAxis();
				setupYAxis();
				layoutChart();
			}
		}
		
		public function get xAxis():Object {
			return _xAxis;
		}
		public function set xAxis(value:Object):void {
			_xAxis = value;
			setupXAxis();
			layoutChart();
		}
		
		public function get yAxis():Object {
			return _yAxis;
		}
		public function set yAxis(value:Object):void {
			_yAxis = value;		
			setupYAxis();
			layoutChart();
		}
		
		public function get chartData():Array {
			return _chartData;
		}
		public function set chartData(value:Array):void {
			if (_chartData == null || _chartData.length != value.length) {
				_chartData = value;
				if (xAxis != null) setupXAxis();
				if (yAxis != null) setupYAxis();
				layoutChart();
			}else {
				_chartData = value;
				refreshData();
			}
		}
		
		public function get colormap():String {
			return _colormap;
		}
		public function set colormap(value:String):void {
			if (_colormap != value) {
				_colormap = value;
				refreshColorScale();
				refreshData();
			}			
		}
		
		public function get colormapScale():Array {
			return _colormapScale;
		}
		public function set colormapScale(value:Array):void {
			_colormapScale = value;
			refreshColorScale();
			layoutChart();
		}
		
		public function get axisFontSize():int {
			return _axisFontSize;
		}
		public function set axisFontSize(value:int):void {
			if (_axisFontSize != value) {
				_axisFontSize = value;
				layoutChart();
			}			
		}
		
		public function get tickFontSize():int {
			return _tickFontSize;
		}
		public function set tickFontSize(value:int):void {
			if (_tickFontSize != value) {
				_tickFontSize = value;
				layoutChart();
			}			
		}
		
		public function get createToolTip():Function {
			return _createToolTip;
		}
		public function set createToolTip(value:Function):void {
			//remove old event listener
			if (createToolTip != null) removeEventListener(ToolTipEvent.TOOL_TIP_CREATE, createToolTip);
			
			_createToolTip = value;
			
			//add new event listener
			if (createToolTip != null) addEventListener(ToolTipEvent.TOOL_TIP_CREATE, createToolTip);
		}
		
		/************************************************
		* chart types
		* **********************************************/		
		//TODO: implement histogram chart type
		public static const CHARTTYPE_AREA:String = 'area';
		public static const CHARTTYPE_BAR:String = 'bar';
		public static const CHARTTYPE_HEATMAP:String = 'heatmap';
		public static const CHARTTYPE_HISTOGRAM:String = 'histogram';
		public static const CHARTTYPE_LINE:String = 'line';
		
		/************************************************
		* scales
		* **********************************************/
		//TODO: implement log, arcsinh scale
		//TODO: implement better automatic axis scaling
		public static const SCALE_LINEAR:String = 'linear';
		public static const SCALE_LOG:String = 'linear';
		public static const SCALE_ARCSINH:String = 'linear';
		
		private function setupXAxis():void {
			var i:uint;
			var min:Number=0;
			var max:Number=-Infinity;
			if (chartType == '' || chartData == null) return;
			
			switch(chartType) {
				case CHARTTYPE_AREA:
				case CHARTTYPE_BAR:
				case CHARTTYPE_LINE:				
					if (!xAxis['lim']){
						for (i = 0; i < chartData.length; i++) {
							min = Math.min(min, chartData[i].x);
							max = Math.max(max, chartData[i].x);
						}
						xAxis.lim = [min, max];
					}else {
						min = xAxis.lim[0];
						max = xAxis.lim[1];
					}
					xAxis.lim[0] -= 0.5;
					xAxis.lim[1] += 0.5;
					
					xAxis.tickLabels = [];
					for (i = min; i <= max; i += (max - min) / 5) {
						xAxis.tickLabels.push(i);
					}
					
					xAxisLocation = 'B';
					xAxisVisible = true;
					break;
				case CHARTTYPE_HEATMAP:
					if (!xAxis['tickLabels']) {
						xAxis.tickLabels = [];
						for (i = 0; i < chartData[0].length; i++) xAxis.tickLabels.push(i.toString());
					}
					
					xAxisLocation = 'T';
					xAxisVisible = false;
					break;
			}
		}
		
		private function setupYAxis():void {
			var i:uint;
			var min:Number=0;
			var max:Number=-Infinity;
			if (chartType == '' || chartData == null) return;
			
			switch(chartType) {
				case CHARTTYPE_AREA:
				case CHARTTYPE_BAR:
				case CHARTTYPE_LINE:				
					if (!yAxis['lim']){
						for (i = 0; i < chartData.length; i++) {
							min = Math.min(min, chartData[i].y);
							max = Math.max(max, chartData[i].y);
						}
						yAxis.lim = [min, max];
					}
					
					yAxis.tickLabels = [];
					for (i = min; i <= max; i += (max - min) / 5) {
						yAxis.tickLabels.push(i);
					}
					
					yAxisLocation = 'L';
					yAxisVisible = true;
					yAxisRotateTickLabels = false;
					break;
				case CHARTTYPE_HEATMAP:
					if (!yAxis['tickLabels']) {
						yAxis.tickLabels = [];
						for (i = 0; i < chartData.length; i++) yAxis.tickLabels.push(i.toString());
					}
					
					yAxisLocation = 'L';
					yAxisVisible = false;
					yAxisRotateTickLabels = true;
					break;
			}
		}
		
		
		/************************************************
		* display
		* **********************************************/
		private var surface:Surface = new Surface();
		private var xAxisGeometryGroup:GeometryGroup = new GeometryGroup();
		private var yAxisGeometryGroup:GeometryGroup = new GeometryGroup();
		private var dataGeometryGroup:GeometryGroup = new GeometryGroup();
		private var colorScaleGeometryGroup:GeometryGroup = new GeometryGroup();
		private var colorScaleLabelsGeometryGroup:GeometryGroup = new GeometryGroup();
		
		private var chartPadding:int = 2;
				
		private var xAxisLocation:String;
		private var yAxisLocation:String;
		private var xAxisVisible:Boolean;
		private var yAxisVisible:Boolean;
		private var yAxisRotateTickLabels:Boolean;
		private var colorScaleVisible:Boolean;
		
		private var xAxisLabelY:int;
		private var yAxisLabelX:int=-3;
		private var chartX:Number;
		private var chartY:Number;
		private var chartW:Number;
		private var chartH:Number;
		private var colorScaleX:Number;
		private var colorScaleY:Number;
		private var colorScaleW:Number=20;
		private var colorScaleH:Number;
		private var colorScaleGap:int=20;
		
		public function layoutChart(value:*= null):void {
			var i:uint;
			var j:uint;
			var newRasterText:RasterText;
			var newLine:Line;
			
			if (chartType == '' || xAxis == null || yAxis == null || chartData == null) return;
			
			//vertical layout
			if(xAxisLocation=='B') {
				xAxisLabelY = height-axisFontSize;
				chartY = 0;
				chartH = height - chartY - 2 * axisFontSize;
			}else{
				xAxisLabelY = -3;
				chartY = xAxisLabelY + 2 * axisFontSize;
				chartH = height - chartY;					
			}
			colorScaleY = chartY;
			colorScaleH = chartH;
			
			//colorscale
			refreshColorScale();
			
			//horizontal layout
			chartX = yAxisLabelX + 2 * axisFontSize;
			chartW = (colorScaleVisible ? colorScaleX-colorScaleGap : width) - chartX;
			
			//x axis
			xAxisGeometryGroup.geometry = [];
			
			if(xAxisVisible){
				newLine = new Line(chartX - chartPadding, chartY + chartH + chartPadding, chartX + chartW + 2 * chartPadding, chartY + chartH + chartPadding);
				newLine.stroke = new SolidStroke(0x000000);
				xAxisGeometryGroup.geometryCollection.addItem(newLine);
			}
	
			newRasterText = new RasterText();
			newRasterText.autoSizeField = true;
			newRasterText.text = xAxis.name;
			newRasterText.fontSize = axisFontSize;			
			newRasterText.fontFamily = 'EmbeddedArial';
			newRasterText.x = chartX + chartW / 2 - newRasterText.width / 2;
			newRasterText.y = xAxisLabelY;
			xAxisGeometryGroup.geometryCollection.addItem(newRasterText);
			
			for (i = 0; i < xAxis.tickLabels.length; i++) {
				newRasterText = new RasterText();
				newRasterText.autoSizeField = true;
				newRasterText.text = xAxis.tickLabels[i];
				newRasterText.fontSize = tickFontSize;				
				newRasterText.fontFamily = 'EmbeddedArial';
				if(xAxisLocation=='B') {
					newRasterText.x = chartX + chartW * (xAxis.tickLabels[i] - xAxis.lim[0]) / (xAxis.lim[1] - xAxis.lim[0]) - newRasterText.width / 2;
					newRasterText.y = xAxisLabelY - tickFontSize;						
				}else{
					newRasterText.x = chartX + (1 / 2 + i) * chartW / xAxis.tickLabels.length - newRasterText.width / 2;
					newRasterText.y = xAxisLabelY + axisFontSize + chartPadding;				
				}
				xAxisGeometryGroup.geometryCollection.addItem(newRasterText);				
			}			
			
			//y axis
			yAxisGeometryGroup.geometry = [];
			
			if (yAxisVisible) {
				newLine = new Line(chartX - chartPadding, chartY - chartPadding, chartX - chartPadding, chartY + chartH + 2 * chartPadding);
				newLine.stroke = new SolidStroke(0x000000);
				yAxisGeometryGroup.geometryCollection.addItem(newLine);
			}
			
			newRasterText = new RasterText();
			newRasterText.autoSizeField = true;
			newRasterText.text = yAxis.name;			
			newRasterText.fontSize = axisFontSize;			
			newRasterText.fontFamily = 'EmbeddedArial';
			newRasterText.transform = new MatrixTransform();			
			newRasterText.transform.transformMatrix.rotate( -Math.PI / 2);
			newRasterText.transform.transformMatrix.tx = yAxisLabelX-2*chartPadding;
			newRasterText.transform.transformMatrix.ty = chartY + chartH / 2 + newRasterText.width / 2;
			yAxisGeometryGroup.geometryCollection.addItem(newRasterText);
			
			for (i = 0; i < yAxis.tickLabels.length; i++) {
				newRasterText = new RasterText();
				newRasterText.autoSizeField = true;
				newRasterText.text = yAxis.tickLabels[i];
				newRasterText.fontSize = tickFontSize;
				newRasterText.fontFamily = 'EmbeddedArial';
				if(yAxisRotateTickLabels){
					newRasterText.transform = new Transform();
					newRasterText.transform.transformMatrix.rotate( -Math.PI/2);
					newRasterText.transform.transformMatrix.translate(yAxisLabelX+axisFontSize+chartPadding,chartY + (1 / 2 + i) * chartH / yAxis.tickLabels.length + newRasterText.width / 2);
				}else {
					newRasterText.x = chartX - newRasterText.width - 2*chartPadding;
					newRasterText.y = chartY + chartH - chartH * (yAxis.tickLabels[i] - yAxis.lim[0]) / (yAxis.lim[1] - yAxis.lim[0]) - newRasterText.height / 2;
				}
				yAxisGeometryGroup.geometryCollection.addItem(newRasterText);
			}
			
			//data
			refreshData();
		}
		
		public function refreshData():void {
			dataGeometryGroup.geometry = [];
			if (chartType == '' || xAxis == null || yAxis == null || chartData == null) return;
			if (chartData.length == 0) return;
			
			var colors:Array;
			var i:uint;
			var j:uint;
			var newColorGrid:ColorGrid;
			var newRegularRectangle:RegularRectangle;
			var newPolyline:Polyline;
			var newPolygon:Polygon;
			var barW:Number;
			var barH:Number;
			var points:Array = [];
						
			
			switch(chartType){
				case CHARTTYPE_BAR:
					barW = chartW / (xAxis.lim[1] - xAxis.lim[0] + 1);
					for (i = 0; i < chartData.length; i++) {
						barH = chartH * (chartData[i].y-yAxis.lim[0])/(yAxis.lim[1]-yAxis.lim[0]);
						newRegularRectangle = new RegularRectangle(
							chartX + chartW*(chartData[i].x - xAxis.lim[0]) / (xAxis.lim[1] - xAxis.lim[0]) - barW / 2, 
							chartY + chartH - barH, barW, barH);							
						newRegularRectangle.stroke = new SolidStroke(0xFFFFFF);
						newRegularRectangle.fill = new SolidFill(0x000000);
						dataGeometryGroup.geometryCollection.addItem(newRegularRectangle);
					}
					break;
				case CHARTTYPE_HEATMAP:
					if (chartData[0]==null) return;
					colors = [];
					for (i = 0; i < chartData.length; i++) {
						for (j = 0; j < chartData[i].length; j++) {
							colors.push(Colormap.scale(colormap,chartData[i][j]));
						}
					}
					newColorGrid = new ColorGrid(chartX, chartY, chartW, chartH, chartData.length, chartData[0].length, colors);
					newColorGrid.stroke = new SolidStroke(0x000000);
					dataGeometryGroup.geometryCollection.addItem(newColorGrid);
					break;
				case CHARTTYPE_LINE:
					for (i = 0; i < chartData.length; i++) {
						points.push(new GraphicPoint(
							chartX + chartW * (chartData[i].x - xAxis.lim[0]) / (xAxis.lim[1] - xAxis.lim[0]),
							chartY + chartH - chartH * (chartData[i].y - yAxis.lim[0]) / (yAxis.lim[1] - yAxis.lim[0])));							
					}
					newPolyline = new Polyline(points);
					newPolyline.stroke = new SolidStroke(0x000000);
					dataGeometryGroup.geometryCollection.addItem(newPolyline);
					break;
				case CHARTTYPE_AREA:
					points.push(new GraphicPoint(
						chartX + chartW * (chartData[0].x - xAxis.lim[0]) / (xAxis.lim[1] - xAxis.lim[0]),
						chartY + chartH - chartH * (0 - yAxis.lim[0]) / (yAxis.lim[1] - yAxis.lim[0])));
					for (i = 0; i < chartData.length; i++) {
						points.push(new GraphicPoint(
							chartX + chartW * (chartData[i].x - xAxis.lim[0]) / (xAxis.lim[1] - xAxis.lim[0]),
							chartY + chartH - chartH * (chartData[i].y - yAxis.lim[0]) / (yAxis.lim[1] - yAxis.lim[0])));							
					}
					points.push(new GraphicPoint(
						chartX + chartW * (chartData[chartData.length-1].x - xAxis.lim[0]) / (xAxis.lim[1] - xAxis.lim[0]),
						chartY + chartH - chartH * (0 - yAxis.lim[0]) / (yAxis.lim[1] - yAxis.lim[0])));
						
					newPolygon = new Polygon(points);
					newPolygon.fill = new SolidFill(0x000000);
					dataGeometryGroup.geometryCollection.addItem(newPolygon);
					break;
			}
		}
		
		public function refreshColorScale():void {
			if (colormapScale == null) return;
			
			var i:uint;
			
			colorScaleGeometryGroup.geometry = [];
			colorScaleLabelsGeometryGroup.geometry = [];
			while(colorScaleLabelsGeometryGroup.numChildren>0) colorScaleLabelsGeometryGroup.removeChildAt(0);
			
			switch(chartType) {
				case CHARTTYPE_AREA:
				case CHARTTYPE_BAR:
				case CHARTTYPE_LINE:
					colorScaleVisible=false;
					return;
			}
			colorScaleVisible = true;
			
			//labels
			var newRasterText:SupSubRasterText;
			var tmp:Array;
			var colorScaleLabelW:Number = 0;
			for (i = 0; i<colormapScale.length; i++ ) {				
				newRasterText = new SupSubRasterText();
				tmp = colormapScale[i].toPrecision(3).split('e');
				newRasterText.text = tmp[0] + (tmp.length > 1 ? '<sup>' + tmp[1].replace('+','') + '</sup>' : '');
				newRasterText.fontSize = tickFontSize;
				newRasterText.x = 0;
				newRasterText.y = colorScaleY + (colormapScale.length - i - 1) * colorScaleH / (colormapScale.length -1) - tickFontSize;
				newRasterText.target = colorScaleLabelsGeometryGroup;
				colorScaleLabelsGeometryGroup.addChild(newRasterText);
				colorScaleLabelW = Math.max(colorScaleLabelW, newRasterText.width);
			}
			var colorScaleLabelX:Number = width - colorScaleLabelW;
			colorScaleLabelsGeometryGroup.x = colorScaleLabelX;
			
			//scale
			colorScaleX = colorScaleLabelX - colorScaleW - chartPadding;
			var colors:Array = [];
			for (i = 0; i < 100; i++) colors.push(Colormap.scale(colormap,i / (100 - 1)));
			var colorScale:ColorBar = new ColorBar(colorScaleX, colorScaleY, colorScaleW, colorScaleH, colors.length, colors.reverse());
			colorScale.stroke = new SolidStroke(0x000000);
			colorScaleGeometryGroup.geometryCollection.addItem(colorScale);
		}
		
		/******************************************************
		 * mouse move
		 * ****************************************************/
		public var toolTipTarget:Object;
		
		private function mouseMoveHandler(event:MouseEvent):void {
			if (chartData == null || chartData.length == 0) return;
			
			var toolTipX:int;
			var toolTipY:int;
			var hoverCol:int;
			var hoverRow:int;
			var pt:Point;
			
			toolTipTarget = null;
			
			//get mouse coordinates in local frame
			pt = surface.globalToLocal(new Point(event.stageX, event.stageY));
			
			//determine which data point triggered mouse event
			switch(chartType) {
				case CHARTTYPE_BAR:
					if (0) {
						toolTipX = 0;
						toolTipY = 0;
					}else {
						toolTipTarget = null;
					}
					break;
				case CHARTTYPE_HEATMAP:				
					if (pt.x<chartX || pt.x>chartX+chartW) hoverCol=-1;			
					else hoverCol = Math.floor((pt.x-chartX) / (chartW / chartData[0].length));
				
					if (pt.y<chartY || pt.y>chartY+chartH) hoverRow=-1;
					else hoverRow = Math.floor((pt.y - chartY) / (chartH / chartData.length));
					
					if (hoverRow > -1 && hoverCol > -1) {
						toolTipTarget = { hoverRow:hoverRow, hoverCol:hoverCol };
						toolTipX =chartX + (hoverCol + 1) * chartW / chartData[0].length
						toolTipY =	chartY + (hoverRow + 1 / 2) * chartH / chartData.length
					}
					break;			
				case CHARTTYPE_AREA:
				case CHARTTYPE_LINE:
					//TODO: implement tooltip for area, line plots
					break;
			}
			
			//update tool tip position
			if (toolTipTarget!=null) {
				toolTip = ' ';
				if (ToolTipManager.currentToolTip != null) {
					pt = this.localToGlobal(new Point(toolTipX,toolTipY));
					ToolTipManager.currentToolTip.x = pt.x;
					ToolTipManager.currentToolTip.y = pt.y;
				}
			}else {
				toolTip = '';					
			}
		}
		
	}
	
}