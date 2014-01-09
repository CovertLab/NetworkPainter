package edu.stanford.covertlab.chart  
{
	import com.monkeypatches.blog.kyleq.MyPanelSkin;
	import edu.stanford.covertlab.chart.Chart;
	import mx.containers.Panel;
	import mx.core.IToolTip;
	
	/**
	 * ToolTip containing a chart.
	 * 
	 * @see Chart
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ChartToolTip extends Panel implements IToolTip
	{
		
		public function ChartToolTip(title:String,chart:Chart) 
		{
			
			//style
			width = 200;
			height = 150;
			alpha = 1.0;
			setStyle('borderThickness', 2);
			setStyle('backgroundColor', 0xFFFFFF);
			setStyle('dropShadowEnabled', true);
			setStyle('borderColor', 0x000000);
			setStyle('borderStyle', 'solid');			
			setStyle('borderSkin', MyPanelSkin);
			
			//properties
			this.title = title;
			
			//chart
			this.addChild(chart);
		}
		
		/************************************************
		* implement IToolTip
		* **********************************************/
		public var _text:String='';
		public function get text():String {
			return _text;			
		}
		public function set text(value:String):void {}
		
	}
	
}