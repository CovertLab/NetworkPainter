package edu.stanford.covertlab.controls 
{
	import mx.containers.Box;
	import mx.controls.Text;
	import mx.managers.CursorManager;
	
	/**
	 * Displays stack of messages and controls busy cursor.
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu	 
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/2/2009
	 */
	public class StatusBar extends Box
	{
		private var messages:Array;
		private var text:Text;
		
		public function StatusBar() 
		{
			messages = new Array();
			visible = false;
			
			text = new Text();
			addChild(text);
		}
		
		public function addMessage(id:String, text:String):void {
			this.messages.push( { id:id, text:text } );
			this.text.text = text;
			this.visible = true;
			CursorManager.setBusyCursor();
		}
		
		public function removeMessage(id:String):void {
			for (var i:uint = 0; i < this.messages.length; i++) {
				if (this.messages[i].id == id) {
					this.messages.splice(i, 1);
					CursorManager.removeBusyCursor();
					if (i == this.messages.length) {
						if (i == 0) {
							this.text.text = '';
							this.visible = false;
						} else {
							this.text.text = this.messages[i - 1].text;
						}
					}
					break;
				}
			}
		}
	}	
}