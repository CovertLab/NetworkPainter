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
    import flash.text.TextFormat;
    
    import mx.controls.Label;
    import mx.controls.listClasses.ListData;
    import mx.controls.menuClasses.MenuItemRenderer;
    import mx.controls.menuClasses.MenuListData;

	/**
	 *  The AcceleratorMenuItemRenderer class modifies the 
	 * 	default MenuItemRenderer to add 'accelerator' labels.
	 * 
	 * @see com.rphelan.controls.AcceleratorMenuBar
	 * @see mx.controls.menuClasses.MenuItemRenderer
	 */
    public class AcceleratorMenuItemRenderer extends MenuItemRenderer
    {
    	
    	private var _shortCut:String;
    	
    	/**
    	 * 	Constructor.
    	 */
        public function AcceleratorMenuItemRenderer()
        {
            super();
        }
        
        /**
		 *  @private
		 */
        override protected function commitProperties():void
		{
			super.commitProperties();
			
			// Set the text of the accelerator label to the value provided in 'data'
			if( icon && icon is Label )
			{ 
				var accelerator:String = ""; 
				if( data )
				{
					if( data.@accelerator )
						accelerator = data.@accelerator;
					else if( data.accelerator )
						accelerator = data.accelerator;
				}
				
				Label(icon).text = accelerator;
			}
		}

         /**
		 *  @private
		 */
        override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
        {
			super.updateDisplayList( unscaledWidth, unscaledHeight );

			// Override some of MenuItemRenderer's layout logic to place the accelerator label
         	// on the right side of the menu label (this is consistent with Windows and Mac menus)
         	
			var iconWidth:Number = MenuListData(listData).maxMeasuredIconWidth;
			var typeIconWidth:Number = MenuListData(listData).maxMeasuredTypeIconWidth;
			var branchIconWidth:Number = MenuListData(listData).maxMeasuredBranchIconWidth;
			var useTwoColumns:Boolean = MenuListData(listData).useTwoColumns;
			
			var leftMargin:Number = Math.max(getStyle("leftIconGap"), typeIconWidth);
			var rightMargin:Number = Math.max(getStyle("rightIconGap"), iconWidth + branchIconWidth);
			
			var right:Number = unscaledWidth - (rightMargin - (iconWidth + branchIconWidth))/2

			// layout from left to right:  typeIcon, label, icon, branchIcon
			if (typeIcon)
			{
				typeIcon.x = (leftMargin - typeIcon.measuredWidth)/2;
				typeIcon.setActualSize(typeIcon.measuredWidth, typeIcon.measuredHeight);
			}
			if (icon)
			{
				icon.x = right - branchIconWidth - iconWidth;
				icon.setActualSize(icon.measuredWidth, icon.measuredHeight);
			}			
			if (branchIcon)
			{
				branchIcon.x = right - branchIconWidth;
				branchIcon.setActualSize(branchIcon.measuredWidth, branchIcon.measuredHeight);
			}			

			label.x = leftMargin;		
			label.setActualSize(unscaledWidth - leftMargin - rightMargin,
								label.getExplicitOrMeasuredHeight());
			
			
			// modify the text formatting to use windows style underlines on ctrl and letter
			// underline any character preceded by a '&'
			if( super.data) 
			{
			    if( ListData(super.listData) )
			    {
			        var str_label:String = ListData(super.listData).label;
			        var underlinePosition:int = str_label.indexOf("&");
			        if( underlinePosition >= 0 )
			        {
			            label.text = label.text.replace("&", "");
			        	_shortCut = label.text.charAt(underlinePosition);
			        	
			            var format:TextFormat = new TextFormat();
			            format.underline = true;
			            label.setTextFormat(format, underlinePosition, underlinePosition+1 );
			        }
			    }
			}           
        }
        
        public function get shortCut():String
        {
        	return _shortCut ? _shortCut : '';
        }
    }
}