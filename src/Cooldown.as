package
{
	import d2api.DataApi;
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2data.ContextMenuData;
	import d2enums.FightEventEnum;
	import d2hooks.FightEvent;
	import d2hooks.GameFightEnd;
	import d2hooks.GameFightLeave;
	import d2hooks.GameFightTurnEnd;
	import d2hooks.OpeningContextMenu;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import types.CastedSpell;
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
		public var fightApi:FightApi;
		public var dataApi:DataApi;
		
		// Some globals
		private var _castedSpells:Vector.<CastedSpell>;
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			_castedSpells = new Vector.<CastedSpell>();
			
			sysApi.addHook(OpeningContextMenu, onOpeningContextMenu);
			sysApi.addHook(GameFightEnd, onGameFightEnd);
			sysApi.addHook(GameFightLeave, onGameFightLeave);
			sysApi.addHook(FightEvent, onFightEvent);
			sysApi.addHook(GameFightTurnEnd, onGameFightTurnEnd);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * FightEvent callback.
		 *
		 * @param	eventName	Name of the current event.
		 * @param	params		Parameters of the current event.
		 * @param	targetList	(not used).
		 */
		private function onFightEvent(eventName:String, params:Object, targetList:Object = null):void
		{
			if (eventName == FightEventEnum.FIGHTER_CASTED_SPELL)
			{
				var cooldown:int = dataApi.getSpellWrapper(params[3], params[4])["minCastInterval"];
				if (cooldown == 0)
				{
					return;
				}
				
				var castedSpell:CastedSpell = new CastedSpell();
				
				castedSpell.fighterId = params[0];
				castedSpell.spellId = params[3];
				castedSpell.cooldown = cooldown;
				
				_castedSpells.push(castedSpell);
			}
		}
		
		private function onGameFightTurnEnd(fighterId:int):void
		{
			for (var index:int = 0; index < _castedSpells.length; index++)
			{
				if (_castedSpells[index].fighterId != fighterId)
				{
					continue;
				}
				
				_castedSpells[index].cooldown--;
				
				if (_castedSpells[index].cooldown == -1)
				{
					_castedSpells.splice(index, 1);
				}
			}
		}
		
		private function onOpeningContextMenu(data:Object):void
		{
			if (data && (data is ContextMenuData))
			{
				var menuData:ContextMenuData = data as ContextMenuData;
				if (data.makerName == "fightWorld")
				{
					// createContextMenuItemObject(label, callback, callbackArgs, disabled, childs, selected, ...)
					var item1:* = modContextMenu.createContextMenuItemObject("Cooldown", cooldownCallback, null, false, null, isLoadedUi());
					
					appendToItemModule((data as ContextMenuData), item1);
				}
			}
		}
		
		private function onGameFightEnd(result:Object):void
		{
			unloadUi();
		}
		
		private function onGameFightLeave(fighterId:int):void
		{
			if (fightApi.getCurrentPlayedFighterId() == fighterId)
			{
				unloadUi();
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
			if (isLoadedUi())
			{
				unloadUi();
			}
			else
			{
				loadUi();
			}
		}
		
		private function loadUi():void
		{
			if (uiApi.getUi(UI_INSTANCE_NAME) == null && sysApi.isFightContext())
			{
				uiApi.loadUi(UI_NAME, UI_INSTANCE_NAME);
			}
		}
		
		private function unloadUi():void
		{
			if (uiApi.getUi(UI_INSTANCE_NAME) != null)
			{
				uiApi.unloadUi(UI_INSTANCE_NAME);
			}
		}
		
		private function isLoadedUi():Boolean
		{
			return uiApi.getUi(UI_INSTANCE_NAME) != null;
		}
	}
}
