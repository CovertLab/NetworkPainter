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

package com.rphelan.utils
{
	/**
	 * 	KeyUtils provides methods for converting back 
	 * 	and forth between Strings and keyCodes.
	 */
	public class KeyUtils
	{
		/**
		 * 	The keyCode for a given char or string is its index
		 * 	into the _keyCodes array.
		 */
		private static var _keyCodes:Array;
		
		/**
		 * 	The following constants provide string representations of
		 *	keys that cannot be represented by a single character
		 */
		static public const ALT:String = "Alt";
		static public const BACKSPACE:String = "Bksp";
		static public const CAPS_LOCK:String = "Caps Lock";
		static public const CONTROL:String = "Ctrl";
		static public const DELETE:String = "Del";
		static public const DOWN:String = "Down";
		static public const END:String = "End";
		static public const ENTER:String = "Enter";
		static public const ESCAPE:String = "Esc";
		static public const F1:String = "F1";
		static public const F10:String = "F10";
		static public const F11:String = "F11";
		static public const F12:String = "F12";
		static public const F2:String = "F2";
		static public const F3:String = "F3";
		static public const F4:String = "F4";
		static public const F5:String = "F5";
		static public const F6:String = "F6";
		static public const F7:String = "F7";
		static public const F8:String = "F8";
		static public const F9:String = "F9";
		static public const HOME:String = "Home";
		static public const INSERT:String = "Insert";
		static public const LEFT:String = "Left";
		static public const NUM_LOCK:String = "NumLock";
		static public const PAGE_DOWN:String = "PgDn";
		static public const PAGE_UP:String = "PgUp";
		static public const PAUSE:String = "Pause";
		static public const RIGHT:String = "Right";
		static public const SCROLL_LOCK:String = "ScrollLock";
		static public const SHIFT:String = "Shift";
		static public const TAB:String = "Tab";
		static public const UNDEFINED:String = "undefined";
		static public const UP:String = "Up";
		static public const WINDOWS_KEY:String = "WinKey";
		
		/**
		 * 	Constructor.
		 */
		public function KeyUtils() {}
		
		/**
		 * 	Converts a keyCode to a string
		 * 
		 * 	@param keyCode
		 * 	@return the string representation of the key for a given keyCode
		 */
		public static function stringFromKeyCode( keyCode:uint ):String
		{
			if( !_keyCodes )
				generateKeyCodeChars();
			
			return _keyCodes[keyCode];
		}
		
		/**
		 * 	Converts a string to an array of keyCodes for keys that could 
		 * 	produce the character represented by the char parameter
		 * 
		 * 	@param char Either a key char or KeyUtils constant
		 * 	@return array of keyCodes that could produce the char
		 */
		public static function keyCodesFromString( char:String ):Array
		{
			if( !_keyCodes )
				generateKeyCodeChars();
			
			// a value in _keyCodes could be a single char, KeyUtils constant,
			// or an array of single chars, KeyUtils constants, or both
				
			var rVal:Array = [];			
			for( var i:uint = 0; i < _keyCodes.length; ++i )
			{
				if( _keyCodes[i] is Array )
				{
					for( var j:uint = 0; j < _keyCodes[i].length; ++j )
					{
						if( _keyCodes[i][j] == char )
							rVal.push( i );
					}
				}
				else if( _keyCodes[i] == char )
					rVal.push( i );
			}
			
			return rVal;
		}
		
		/**
		 * 	Populate the _keyCodes array with appropriate values.
		 * 	This function only needs to be called once.
		 * 
		 * 	Great resource:  http://people.uncw.edu/tompkinsj/112/FlashActionScript/keyCodes.htm
		 */
		private static function generateKeyCodeChars():void
		{
			var i:uint;
			_keyCodes = new Array();
			// 0-7
			insertUndefined( _keyCodes, 7 );
			// 8
			_keyCodes[8] = BACKSPACE;
			// 9
			_keyCodes[9] = TAB;
			// 10-12
			insertUndefined( _keyCodes, 3 );
			// 13
			_keyCodes[13] = ENTER;
			// 14-15
			insertUndefined( _keyCodes, 2 );
			//16
			_keyCodes[16] = SHIFT;
			// 17-20	
			_keyCodes.push(CONTROL, ALT, PAUSE, CAPS_LOCK);	
			// 21-26	
			insertUndefined( _keyCodes, 6 );
			// 27
			_keyCodes[27] = ESCAPE;
			// 28-31
			insertUndefined( _keyCodes, 4 );
			// 32-40
			_keyCodes.push(' ', PAGE_UP, PAGE_DOWN, END, HOME, LEFT, UP, RIGHT, DOWN);
			// 41-44
			insertUndefined( _keyCodes, 4 );
			// 45
			_keyCodes[45] = INSERT;
			// 46
			_keyCodes[46] = DELETE;
			// 47
			_keyCodes[47] = UNDEFINED;
			// 48-57
			_keyCodes.push(['0', ')'], ['1', '!'], ['2', '@'], ['3', '#'], ['4', '$'], ['5', '%'], ['6', '^'], ['7', '&'], ['8', '*'], ['9', '(']);
			// 58-64
			insertUndefined( _keyCodes, 7 );
			// 65-91
			_keyCodes.push('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', WINDOWS_KEY);
			// 92-95
			insertUndefined( _keyCodes, 4 );
			// 96-123
			_keyCodes.push('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '+', UNDEFINED, '-', '.', '/', F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12);
			// 124-143
			insertUndefined( _keyCodes, 20 );
			// 144
			_keyCodes[144] = NUM_LOCK;
			// 145
			_keyCodes[145] = SCROLL_LOCK;
			// 146-185
			insertUndefined( _keyCodes, 40 );
			// 186-192
			_keyCodes.push([';', ':'], ['=', '+'], [', ', '<'], ['-', '_'], ['.', '>'], ['/', '?'], ['`', '~']);
			// 193-218
			insertUndefined( _keyCodes, 26 );
			// 219-222
			_keyCodes.push(['[', '{'], ['\\', '|'], [']', '}'], ["'", '"']);
		}
		
		/**
		 * 	Helper function for generateKeyCodeChars()
		 * 	Inserts a given number of UNDEFINEDs into the array
		 * 
		 * 	@param ary The array to modify
		 * 	@param number The number of UNDEFINEDs to insert
		 */
		private static function insertUndefined( ary:Array, number:uint ):void
		{
			for( var i:uint = number; i; --i ) 
				ary.push(UNDEFINED);
		}
	}
}