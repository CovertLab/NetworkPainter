package edu.stanford.covertlab.controls 
{
	import edu.stanford.covertlab.util.HTML;
	import mx.controls.TextInput;
	import mx.controls.TileList;
	import mx.core.ClassFactory;
	
	/**
	 * Visual keyboard for entering Greek characters into a text box.
	 * 
	 * @see edu.stanford.covertlab.util.HTML
	 * 
	 * @author Ed Chen, chened@stanford.edu
	 * @author Jonathan Karr, jkarr@stanford.edu	 
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/2/2009
	 */
	public class GreekKeyboard extends TileList
	{
		public var textInput:TextInput;
		
		public function GreekKeyboard(textInput:TextInput) 
		{			
			this.textInput = textInput;
			
			setStyle("horizontalAlign", "left");
			setStyle('direction', 'horizontal');
			setStyle('direction', 'horizontal');
			setStyle('paddingTop', 0);
			setStyle('paddingBottom', 0);
			setStyle('paddingLeft', 0);
			setStyle('paddingRight', 0);
			setStyle('rollOverColor', 0xFFFFFF);
			setStyle('selectionColor', 0xFFFFFF);
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'off';		
			
			dataProvider = HTML.GREEK_CHARACTERS;
			itemRenderer = new ClassFactory(GreekCharacterTileListItemRenderer);
			(itemRenderer as ClassFactory).properties = { textInput:textInput };
		}
		
	}
	
}

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import mx.containers.Box;
import mx.controls.Label;
import mx.controls.TextInput;

class GreekCharacterTileListItemRenderer extends Box
{
	private var _textInput:TextInput;
	private var key:Label;
	private var lowerCase:Boolean;
	private var capslock:Boolean;
	private var shift:Boolean;
	
	public function GreekCharacterTileListItemRenderer() {
		buttonMode = true;
		height = width = 16;
		setStyle('cornerRadius', 3);
		setStyle('paddingTop', 2);
		setStyle('paddingBottom', 2);
		setStyle('paddingLeft', 2);
		setStyle('paddingRight', 2);	
		setStyle('horizontalAlign', 'center');
		setStyle('verticalAlign', 'middle');
		
		key = new Label();
		key.setStyle('textDecoration', 'underline');
		addChild(key);
				
		lowerCase = true;
		capslock = false;
		shift = false;
		
		addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		addEventListener(MouseEvent.CLICK, insertChar);
	}
	
	public function get textInput():TextInput {
		return _textInput;
	}
	
	public function set textInput(value:TextInput):void {
		_textInput = value;
		textInput.parentApplication.addEventListener(KeyboardEvent.KEY_DOWN, setCase);
		textInput.parentApplication.addEventListener(KeyboardEvent.KEY_UP, unsetCase);
	}
	
	private function mouseOverHandler(event:MouseEvent):void {
		setStyle('backgroundColor', 0xB2E1FF);
		setStyle('borderStyle', 'solid');
	}
	
	private function mouseOutHandler(event:MouseEvent):void {
		setStyle('backgroundColor', 0xFFFFFF);
		setStyle('borderStyle', 'none');
	}
	
	private function mouseDownHandler(event:MouseEvent):void {
		setStyle('backgroundColor', 0x7FCEFF);
	}
	
	private function mouseUpHandler(event:MouseEvent):void {
		setStyle('backgroundColor', 0xB2E1FF);
	}
	
	override public function set data(value:Object):void {
		super.data = value;		
		if (data) {
			if (lowerCase) key.htmlText = '&#' + data.lowerCase + ';';
			else key.htmlText = '&#' + data.upperCase + ';';			
		}
	}
	
	private function setCase(event:KeyboardEvent):void {
		if (event.keyCode == Keyboard.CAPS_LOCK) capslock = !capslock;
		shift = shift || event.keyCode == Keyboard.SHIFT;
		
		lowerCase = (!capslock && !shift) || (capslock && shift);
		if (lowerCase) key.htmlText = '&#' + data.lowerCase + ';';
		else key.htmlText = '&#' + data.upperCase + ';';
	}
	
	private function unsetCase(event:KeyboardEvent):void {
		shift = shift && event.keyCode != Keyboard.SHIFT;
		
		lowerCase = (!capslock && !shift) || (capslock && shift);
		if (lowerCase) key.htmlText = '&#' + data.lowerCase + ';';
		else key.htmlText = '&#' + data.upperCase + ';';
	}
	
	private function insertChar(event:MouseEvent):void {
		if (lowerCase) textInput.text += '&' + data.entity.toLowerCase() + ';';
		else textInput.text += '&' + data.entity + ';';
	}
}