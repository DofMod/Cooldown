package
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2data.ContextMenuData;
	import d2hooks.OpeningContextMenu;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import ui.CooldownUI;
	
	/**
	 * Main module class (entry point).
	 * 
	 * @author Relena
	 */
	public class Cooldown extends Sprite
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// UI include
		private const includes:Array = [CooldownUI];
		
		// Modules
		[Module (name="Ankama_ContextMenu")]
		public var modContextMenu : Object;
		
		// Some constants
		private static const UI_NAME:String = "cooldown";
		private static const UI_INSTANCE_NAME:String = "cooldown";
		
		// APIs
		public var uiApi:UiApi;
		public var sysApi:SystemApi;
		
		// Some globals
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			sysApi.addHook(OpeningContextMenu, onOpeningContextMenu);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		private function onOpeningContextMenu(data:Object):void
		{
			if (data && (data is ContextMenuData))
			{
				var menuData:ContextMenuData = data as ContextMenuData;
				if (data.makerName == "fightWorld")
				{
					var item1:* = modContextMenu.createContextMenuItemObject("Cooldown", cooldownCallback);
					
					appendToItemModule((data as ContextMenuData), item1);
				}
			}
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		private function appendToItemModule(data:ContextMenuData, ... items):void
		{
			var itemModule:* = null;
			
			for each (var item:*in data.content)
			{
				if (getQualifiedClassName(item) == "contextMenu::ContextMenuItem")
				{
					if (item.label == "Modules")
					{
						itemModule = item;
						break;
					}
				}
			}
			
			if (itemModule == null)
			{
				itemModule = modContextMenu.createContextMenuItemObject("Modules");
				
				data.content.push(itemModule);
			}
			
			if (itemModule.child == null)
			{
				itemModule.child = new Array();
			}
			
			itemModule.child = itemModule.child.concat(items);
		}
		
		private function cooldownCallback():void
		{
			if (uiApi.getUi(UI_INSTANCE_NAME) == null)
			{
				uiApi.loadUi(UI_NAME, UI_INSTANCE_NAME);
			}
		}
	}
}
