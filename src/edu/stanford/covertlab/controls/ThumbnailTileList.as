package edu.stanford.covertlab.controls 
{
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.TileList;
	
	/**
	 * Thumbnails tile list.
	 * 
	 * @see ThumbnailTileListItemRender
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 4/21/2009
	 */
	public class ThumbnailTileList extends TileList
	{
		
		public function ThumbnailTileList() 		
		{

			super();
			
			columnCount = 4;
			rowCount = 3;
			rowHeight = 150;
			columnWidth = 150;			
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'on';
			setStyle('borderStyle', 'solid');
			setStyle('rollOverColor', 0xFFFFFF);
			setStyle('selectionColor', 0xFFFFFF);
		}
		
		override protected function selectItem(item:IListItemRenderer, shiftKey:Boolean, ctrlKey:Boolean, transition:Boolean = true):Boolean {
			var itemRenderer:ThumbnailTileListItemRenderer;
			
			if (selectedItem) itemRenderer = UIDToItemRenderer(itemToUID(selectedItem)) as ThumbnailTileListItemRenderer;
			if (itemRenderer) itemRenderer.selected = false;
			
			var result:Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
			if (item) (item as ThumbnailTileListItemRenderer).selected = true;
			
			return result;
		}
		
		override public function set selectedIndex(value:int):void {
			var itemRenderer:ThumbnailTileListItemRenderer;
			
			if (selectedIndex > -1) itemRenderer = UIDToItemRenderer(itemToUID(selectedItem)) as ThumbnailTileListItemRenderer;
			if (itemRenderer) itemRenderer.selected = false;
			
			super.selectedIndex = value;
			
			if (selectedIndex > -1) itemRenderer = UIDToItemRenderer(itemToUID(selectedItem)) as ThumbnailTileListItemRenderer;
			if (itemRenderer) itemRenderer.selected = false;
		}
		
		override public function set selectedItem(value:Object):void {
			var itemRenderer:ThumbnailTileListItemRenderer;
			
			if (selectedIndex > -1) itemRenderer = UIDToItemRenderer(itemToUID(selectedItem)) as ThumbnailTileListItemRenderer;
			if (itemRenderer) itemRenderer.selected = false;
			
			super.selectedItem = value;			
			
			if (selectedIndex > -1) itemRenderer = UIDToItemRenderer(itemToUID(selectedItem)) as ThumbnailTileListItemRenderer;
			if (itemRenderer) itemRenderer.selected = false;
		}
		
	}
	
}