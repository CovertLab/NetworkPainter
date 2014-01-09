/*
Copyright (c) 2008 Ryan Phelan
    http://www.rphelan.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package com.rphelan.controls.menuClasses
{	
	import com.rphelan.utils.KeyUtils;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * 	The Accelerator class represents an accelerator key combination
	 * 	which is usually used as a keyboard short cut in an application.
	 */
	public class Accelerator
	{
		/**
		 * 	Indicates if the accelerator uses the alt key modifier
		 */
		private var _altKey:Boolean;

		/**
		 * 	Array of keyCodes that (along with alt/ctrl/shift modifiers)
		 * 	can trigger this accelerator
		 */
		private var _keyCodes:Array;
		
		/**
		 * 	Indicates if the accelerator uses the control key modifier
		 */
		private var _ctrlKey:Boolean;
		
		/**
		 * 	Optional data payload to associate with the accelerator
		 */
		private var _data:Object;
		private var _click:Object;
		
		
		/**
		 * 	Indicates if the accelerator uses the shift key modifier
		 */
		private var _shiftKey:Boolean;		
	
		/**
		 * 	Constructor
		 */
		public function Accelerator( keyCodes:Array = null, 
										ctrlKey:Boolean = false, 
										shiftKey:Boolean = false, 
										altKey:Boolean = false, 
										data:Object = null,
										click:Object=null)
		{
			_keyCodes = keyCodes;
			_ctrlKey = ctrlKey;
			_shiftKey = shiftKey;
			_altKey = altKey;
			_data = data;
			_click = click;
		}
		
		/**
		 * 	Checks to see if a given KeyboardEvent matches this accelerator
		 * 
		 * 	@param event A KeyboardEvent such as KEY_UP or KEY_DOWN
		 * 	@return whether the event matches this accelerator
		 */
		public function test( event:KeyboardEvent ):Boolean
		{
			if( event.ctrlKey == _ctrlKey 
					&& event.altKey == _altKey 
					&& event.shiftKey == _shiftKey )
			{
				for each( var code:uint in _keyCodes )
				{
					if( code == event.keyCode )
						return true;
				}
			}
			
			return false;
		}
		
		/**
		 * 	Creates an accelerator from a string (e.g. Ctrl+Shift+S)
		 * 
		 * 	@param str The accelerator string
		 * 	@return an instance of the Accelerator class
		 */
		public static function fromString( str:String ):Accelerator
		{
			var rVal:Accelerator = new Accelerator();
			
			// before splitting the string by '+' we have to
			// distinguish + keys from + delimiters
			str = str.replace("++", "+[PLUS]");
			
			// break the string into its component parts
			var components:Array = str.split("+");
			for each( var component:String in components )
			{
				if( component == "[PLUS]" ) // special case
					rVal.keyCodes = KeyUtils.keyCodesFromString("+");
				else if( component == KeyUtils.ALT )
					rVal.altKey = true;
				else if( component == KeyUtils.BACKSPACE )
					rVal.keyCode = Keyboard.BACKSPACE;
				else if( component == KeyUtils.CAPS_LOCK )
					rVal.keyCode = Keyboard.CAPS_LOCK;
				else if( component == KeyUtils.CONTROL )
					rVal.ctrlKey = true;
				else if( component == KeyUtils.DELETE )
					rVal.keyCode = Keyboard.DELETE;
				else if( component == KeyUtils.DOWN )
					rVal.keyCode = Keyboard.DOWN;
				else if( component == KeyUtils.END )
					rVal.keyCode = Keyboard.END;
				else if( component == KeyUtils.ENTER )
					rVal.keyCode = Keyboard.ENTER;
				else if( component == KeyUtils.ESCAPE )
					rVal.keyCode = Keyboard.ESCAPE;
				else if( component == KeyUtils.F1 )
					rVal.keyCode = Keyboard.F1;
				else if( component == KeyUtils.F10 )
					rVal.keyCode = Keyboard.F10;
				else if( component == KeyUtils.F11 )
					rVal.keyCode = Keyboard.F11;
				else if( component == KeyUtils.F12 )
					rVal.keyCode = Keyboard.F12;
				else if( component == KeyUtils.F2 )
					rVal.keyCode = Keyboard.F2;
				else if( component == KeyUtils.F3 )
					rVal.keyCode = Keyboard.F3;
				else if( component == KeyUtils.F4 )
					rVal.keyCode = Keyboard.F4;
				else if( component == KeyUtils.F5 )
					rVal.keyCode = Keyboard.F5;
				else if( component == KeyUtils.F6 )
					rVal.keyCode = Keyboard.F6;
				else if( component == KeyUtils.F7 )
					rVal.keyCode = Keyboard.F7;
				else if( component == KeyUtils.F8 )
					rVal.keyCode = Keyboard.F8;
				else if( component == KeyUtils.F9 )
					rVal.keyCode = Keyboard.F9;
				else if( component == KeyUtils.HOME )
					rVal.keyCode = Keyboard.HOME;
				else if( component == KeyUtils.INSERT )
					rVal.keyCode = Keyboard.INSERT;
				else if( component == KeyUtils.LEFT )
					rVal.keyCode = Keyboard.LEFT;
				else if( component == KeyUtils.PAGE_DOWN )
					rVal.keyCode = Keyboard.PAGE_DOWN;
				else if( component == KeyUtils.PAGE_UP )
					rVal.keyCode = Keyboard.PAGE_UP;
				else if( component == KeyUtils.RIGHT )
					rVal.keyCode = Keyboard.RIGHT;
				else if( component == KeyUtils.SHIFT )
					rVal.shiftKey = true;
				else if( component == KeyUtils.TAB )
					rVal.keyCode = Keyboard.TAB;
				else if( component == KeyUtils.UP )
					rVal.keyCode = Keyboard.UP;
				else 
				{
					rVal.keyCodes = KeyUtils.keyCodesFromString(component);
				}
			}
			
			return rVal;
		}
		
		/**
		 * 	@return a string representing this accelerator
		 */
		public function toString():String
		{
			var rVal:String = "";
			
			// add in modifiers first
			if( _altKey )
				rVal = appendKey( rVal, KeyUtils.ALT );
			if( _ctrlKey )
				rVal = appendKey( rVal, KeyUtils.CONTROL );
			if( _shiftKey )
				rVal = appendKey( rVal, KeyUtils.SHIFT );
			
			// add the key char
			var keyCode:uint = _keyCodes && _keyCodes.length ? _keyCodes[0] : 0;				
			if( keyCode == Keyboard.BACKSPACE )
				rVal = appendKey( rVal, KeyUtils.BACKSPACE );
			else if( keyCode == Keyboard.CAPS_LOCK )
				rVal = appendKey( rVal, KeyUtils.CAPS_LOCK );
			else if( keyCode == Keyboard.DELETE )
				rVal = appendKey( rVal, KeyUtils.DELETE );
			else if( keyCode == Keyboard.DOWN )
				rVal = appendKey( rVal, KeyUtils.DOWN );
			else if( keyCode == Keyboard.END )
				rVal = appendKey( rVal, KeyUtils.END );
			else if( keyCode == Keyboard.ENTER )
				rVal = appendKey( rVal, KeyUtils.ENTER );
			else if( keyCode == Keyboard.ESCAPE )
				rVal = appendKey( rVal, KeyUtils.ESCAPE );
			else if( keyCode == Keyboard.F1 )
				rVal = appendKey( rVal, KeyUtils.F1 );
			else if( keyCode == Keyboard.F10 )
				rVal = appendKey( rVal, KeyUtils.F10 );
			else if( keyCode == Keyboard.F11 )
				rVal = appendKey( rVal, KeyUtils.F11 );
			else if( keyCode == Keyboard.F12 )
				rVal = appendKey( rVal, KeyUtils.F12 );
			else if( keyCode == Keyboard.F2 )
				rVal = appendKey( rVal, KeyUtils.F2 );
			else if( keyCode == Keyboard.F3 )
				rVal = appendKey( rVal, KeyUtils.F3 );
			else if( keyCode == Keyboard.F4 )
				rVal = appendKey( rVal, KeyUtils.F4 );
			else if( keyCode == Keyboard.F5 )
				rVal = appendKey( rVal, KeyUtils.F5 );
			else if( keyCode == Keyboard.F6 )
				rVal = appendKey( rVal, KeyUtils.F6 );
			else if( keyCode == Keyboard.F7 )
				rVal = appendKey( rVal, KeyUtils.F7 );
			else if( keyCode == Keyboard.F8 )
				rVal = appendKey( rVal, KeyUtils.F8 );
			else if( keyCode == Keyboard.F9 )
				rVal = appendKey( rVal, KeyUtils.F9 );
			else if( keyCode == Keyboard.HOME )
				rVal = appendKey( rVal, KeyUtils.HOME );
			else if( keyCode == Keyboard.INSERT )
				rVal = appendKey( rVal, KeyUtils.INSERT );
			else if( keyCode == Keyboard.LEFT )
				rVal = appendKey( rVal, KeyUtils.LEFT );
			else if( keyCode == Keyboard.PAGE_DOWN )
				rVal = appendKey( rVal, KeyUtils.PAGE_DOWN );
			else if( keyCode == Keyboard.PAGE_UP )
				rVal = appendKey( rVal, KeyUtils.PAGE_UP );
			else if( keyCode == Keyboard.RIGHT )
				rVal = appendKey( rVal, KeyUtils.RIGHT );
			else if( keyCode == Keyboard.TAB )
				rVal = appendKey( rVal, KeyUtils.TAB );
			else if( keyCode == Keyboard.UP )
				rVal = appendKey( rVal, KeyUtils.UP );
			else 
			{
				rVal  = appendKey( rVal, KeyUtils.stringFromKeyCode( keyCode ) );
			}			
			
			return rVal;
		}
		
		/**
		 * 	Used by toString() to build an accelerator string 
		 * 	with '+' delimiters
		 */
		private function appendKey( str:String, key:String ):String
		{
			return str == "" ? key : str + "+" + key;
		}
		
		public function get altKey():Boolean
		{
			return _altKey;
		}
		public function set altKey( b:Boolean ):void
		{
			_altKey = b;
		}
		
		public function get keyCodes():Array
		{
			return _keyCodes;
		}
		public function set keyCodes( codes:Array ):void
		{
			_keyCodes = codes;
		}
		
		public function set keyCode( code:uint ):void
		{
			_keyCodes = [code];
		}

		public function get ctrlKey():Boolean
		{
			return _ctrlKey;
		}
		public function set ctrlKey( b:Boolean ):void
		{
			_ctrlKey = b;
		}
		
		public function get data():Object
		{
			return _data;
		}
		public function set data( obj:Object ):void
		{
			_data = obj;
		}
		
		public function get click():Object
		{
			return _click;
		}
		public function set click( obj:Object ):void
		{
			_click = obj;
		}
		
		public function get shiftKey():Boolean
		{
			return _shiftKey;
		}
		public function set shiftKey( b:Boolean ):void
		{
			_shiftKey = b;
		}
	}
}