package edu.stanford.covertlab.chart  
{

	import edu.stanford.covertlab.chart.Chart;
	import mx.containers.TitleWindow;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	
	/**
	 * TitleWindow containing a chart.
	 * 
	 * @see Chart
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class ChartWindow extends TitleWindow
	{		
	
		public function ChartWindow(title:String,chart:Chart) 
		{			
			//set properties
			this.title = title;			
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, close);
			height = 500;
			width = 500;
			
			//heatmap
			addChild(chart);
		}		
		
		/******************************************************
		 * opening, closing
		 * ****************************************************/		
		public function open():void {
			//PopUpManager.addPopUp(this, parentApplication, false);
			//PopUpManager.centerPopUp(this);
		}
		 
		public function close(event:CloseEvent=null):void {			
			PopUpManager.removePopUp(this);
		}	
	}
	
}