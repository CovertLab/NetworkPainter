package info.webtoolkit
{
	
	/**
	*
	*  UTF-8 data encode / decode
	*  http://www.webtoolkit.info/actionscript-utf8.html
	*  Converted to AS3 by Jonathan Karr, jkarr@stanford.edu 3/23/2009
	*
	**/
	public class UTF8 
	{
		
		public static function encode(string:String):String {
			if (string == null) return '';
			
			var utftext:String = "";
 
			for (var n:uint = 0; n < string.length; n++) {
	 
				var c:uint = string.charCodeAt(n);
	 
				if (c < 128) {
					utftext += String.fromCharCode(c);
				}
				else if((c > 127) && (c < 2048)) {
					utftext += String.fromCharCode((c >> 6) | 192);
					utftext += String.fromCharCode((c & 63) | 128);
				}
				else {
					utftext += String.fromCharCode((c >> 12) | 224);
					utftext += String.fromCharCode(((c >> 6) & 63) | 128);
					utftext += String.fromCharCode((c & 63) | 128);
				}
	 
			}
	 
			return utftext;
		}
		
		public static function decode(utftext:String):String {
			if (utftext == null) return '';
			
			var string:String = "";
			var i:uint = 0;
			var c:uint = 0;
			var c1:uint = 0;
			var c2:uint = 0;
			var c3:uint = 0;
	 
			while ( i < utftext.length ) {
	 
				c = utftext.charCodeAt(i);
	 
				if (c < 128) {
					string += String.fromCharCode(c);
					i++;
				}
				else if((c > 191) && (c < 224)) {
					c2 = utftext.charCodeAt(i+1);
					string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
					i += 2;
				}
				else {
					c2 = utftext.charCodeAt(i+1);
					c3 = utftext.charCodeAt(i+2);
					string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
					i += 3;
				}
	 
			}
	 
			return string;
		}
		
		
		
	}
	
}