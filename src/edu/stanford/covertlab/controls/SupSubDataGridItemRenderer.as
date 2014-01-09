package edu.stanford.covertlab.controls 
{
	import edu.stanford.covertlab.util.HTML;
	import flash.text.StyleSheet;
	import mx.controls.TextArea;
	
	/**
	 * DataGridItemRender which supports HTML-like text markup.
	 * <ul>
	 * <li>subscript, superscript using embedded fonts</li>
	 * <li>Greek characters using HTML entities</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.util.HTML
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class SupSubDataGridItemRenderer extends TextArea
	{	
		public function SupSubDataGridItemRenderer() 
		{        
			super();
			
			setStyle('backgroundAlpha', 0);
			setStyle('borderStyle', 'none');
			setStyle('paddingTop', 0);
			setStyle('paddingBottom', 0);
			setStyle('paddingLeft', 4);
			setStyle('paddingRight', 4);
			setStyle('disabledColor', 0x0B333C);
			height = 14;
			selectable = false;
			editable = false;
			enabled = false;
			
			if(this.styleSheet == null) this.styleSheet = new StyleSheet();
			this.styleSheet.setStyle("sup", { display: "inline", fontFamily: "EmbeddedArialSup", fontWeight:"normal"});
	       	this.styleSheet.setStyle("sub", { display: "inline", fontFamily: "EmbeddedArialSub", fontWeight:"normal"});
	    }
		
	
		override public function set data(value:Object):void {			
			super.data = value;
			htmlText = HTML.entitiesToDecimal(value.myLabel);
		}
	}
	
}