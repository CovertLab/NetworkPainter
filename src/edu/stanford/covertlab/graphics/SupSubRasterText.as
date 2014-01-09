package edu.stanford.covertlab.graphics 
{
	import com.degrafa.geometry.RasterText;
	import com.degrafa.GeometryGroup;
	import com.degrafa.paint.SolidFill;
	import com.degrafa.paint.SolidStroke;
	import edu.stanford.covertlab.util.HTML;
	import mx.controls.Alert;
	
	/**
	 * Provides support for superscript, subscript, and Greek characters within Degrafa.
	 * <ol>
	 * <li>Replaces HTML entities with decimal notation</li>
	 * <li>Breaks up text into contigous normal, subscript, and superscript blocks</li>
	 * <li>Creates RasterText object for each block</li>
	 * <li>Adds RasterText objects to a geomerty group</li>
	 * </ol>
	 * 
	 * <p>Uses embedded Arial font.</p>
	 * 
	 * </ol>
	 * 
	 * @see edu.stanford.covertlab.util.HTML
	 * @see com.degrafa.geometry.RasterText
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class SupSubRasterText extends GeometryGroup
	{
		
		private var _text:String;
		private var _fontSize:Number;
		private var _textWidth:Number;
		private var _textHeight:Number;	
		
		public function SupSubRasterText(text:String='',fontSize:Number=10) 
		{
			super();
					
			this.text = text;
			this.fontSize = fontSize;
		}
		
		
		public function get text():String {
			return _text;
		}
		public function set text(value:String):void {
			if (_text != value) {
				_text = value;
				parseText();
			}			
		}
				
		public function get fontSize():Number {
			return _fontSize;
		}
		public function set fontSize(value:Number):void {
			if (_fontSize != value) {
				_fontSize = value;
				parseText();
			}
		}
				
		override public function get width():Number {
			return _textWidth;
		}
		
		override public function get height():Number {
			return fontSize + 4;
		}		
		
		private function parseText():void {		
			geometry = [];
			_textWidth = 0;
			_textHeight = 0;
						
			var text:String = HTML.entitiesToDecimal(this.text);
			var regExp:RegExp = /<su[pb]>(.*?)<\/su[pb]>/ig;
			var result:Object = regExp.exec(text);
			var lastIndex:uint = 0;
			
			if (!result) {
				newRasterText(text);
				lastIndex = text.length;
			}
					
			while (result) {					
				//before
				if(result.index-lastIndex>0) newRasterText(text.substr(lastIndex, result.index - lastIndex));
						
				//super/subscripted
				newRasterText(result[1], (result[0].substr(1, 3) == 'sup' ? 'EmbeddedArialSup' : 'EmbeddedArialSub'));
								
				lastIndex = result.index + result[0].length;
				result = regExp.exec(text);
			}
			
			//after
			if (!result && lastIndex < text.length) newRasterText(text.substr(lastIndex, text.length - lastIndex));
			
			_textWidth += 4;
		}
		
		private function newRasterText(text:String, fontFamily:String = 'EmbeddedArial'):void {			
			var rasterText:RasterText = new RasterText();
			rasterText.htmlText = text;
			
			rasterText.fontFamily = fontFamily;
			rasterText.fontSize = fontSize;					
			rasterText.fill = fill;
			rasterText.autoSizeField = true;
			rasterText.x = _textWidth;
			rasterText.preDraw();
			
			_textWidth += rasterText.width - 4;
			
			geometryCollection.addItem(rasterText);
		}
		
	}
	
}