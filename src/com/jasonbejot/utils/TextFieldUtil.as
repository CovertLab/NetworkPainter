package com.jasonbejot.utils
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 
	 * This is a utility class for whatever TextField ailments you may have.
	 * 
	 * @author Jason Bejot
	 * 
	 */
	public final class TextFieldUtil extends Object
	{
		// ---------------- //
		// --- embedded --- //
		// ---------------- //
		
		// the superscript font
		[Embed(source="../embedded/fonts.swf", fontName="GG Superscript")]
		public static const superscriptFont:Class;
		
		// the subscript font
		[Embed(source="../embedded/fonts.swf", fontName="GG Subscript")]
		public static const subscriptFont:Class;
		
		// --------------- //
		// --- methods --- //
		// --------------- //
		
		// constructor
		public function TextFieldUtil()
		{
			super();
		}
		
		/**
		 * 
		 * This is a recursive function that superscripts text and htmlText wrapped in [sup][/sup] tags.
		 * Since this form of superscripting is acheived by changing the TextFormat of superscripted text, this function will not work on TextFields that use a StyleSheet.
		 * 
		 * @param tf The TextField to perform the superscripting on.
		 * 
		 */
		public static function superscript(tf:TextField):void
		{
			var regExp:RegExp = /\[sup\](.*?)\[\/sup\]/i;
			var result:Object = regExp.exec(tf.text);
			
			if(result)
			{
				// rip out the tags and preserve all other text formatting
				tf.replaceText(result.index, result.index + result[0].length, result[1]);
				
				// actually superscript the text
				tf.setTextFormat(	new TextFormat(	"GG Superscript", 
													tf.defaultTextFormat.size, 
													tf.defaultTextFormat.color, 
													tf.defaultTextFormat.bold, 
													tf.defaultTextFormat.italic, 
													tf.defaultTextFormat.underline, 
													tf.defaultTextFormat.url, 
													tf.defaultTextFormat.target, 
													tf.defaultTextFormat.align, 
													tf.defaultTextFormat.leftMargin, 
													tf.defaultTextFormat.rightMargin, 
													tf.defaultTextFormat.indent, 
													tf.defaultTextFormat.leading), 
									result.index, 
									result.index + result[1].length);
				
				// do it again recursively
				TextFieldUtil.superscript(tf);
			}
		}
		
		/**
		 * 
		 * This is a recursive function that subscripts text and htmlText wrapped in [sub][/sub] tags.
		 * Since this form of subscripting is acheived by changing the TextFormat of subscripted text, this function will not work on TextFields that use a StyleSheet.
		 * 
		 * @param tf The TextField to perform the subscripting on.
		 * 
		 */
		public static function subscript(tf:TextField):void
		{
			var regExp:RegExp = /\[sub\](.*?)\[\/sub\]/i;
			var result:Object = regExp.exec(tf.text);
			
			if(result)
			{
				// rip out the tags and preserve all other text formatting
				tf.replaceText(result.index, result.index + result[0].length, result[1]);
				
				// actually superscript the text
				tf.setTextFormat(	new TextFormat(	"GG Subscript", 
													tf.defaultTextFormat.size, 
													tf.defaultTextFormat.color, 
													tf.defaultTextFormat.bold, 
													tf.defaultTextFormat.italic, 
													tf.defaultTextFormat.underline, 
													tf.defaultTextFormat.url, 
													tf.defaultTextFormat.target, 
													tf.defaultTextFormat.align, 
													tf.defaultTextFormat.leftMargin, 
													tf.defaultTextFormat.rightMargin, 
													tf.defaultTextFormat.indent, 
													tf.defaultTextFormat.leading), 
									result.index, 
									result.index + result[1].length);
				
				// do it again recursively
				TextFieldUtil.subscript(tf);
			}
		}
	}
}