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
	import d2hooks.GameFightStart;
	import d2hooks.GameFightTurnEnd;
	import d2hooks.OpeningContextMenu;
	import enums.ConfigEnum;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import managers.SpellManager;
	import types.CastedSpell;
	import ui.ConfigUI;
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
		private const includes:Array = [CooldownUI, ConfigUI];
		
		// Modules
		[Module (name="Ankama_ContextMenu")]
		public var modContextMenu : Object;
		
		[Module (name="Ankama_Common")]
		public var modCommon : Object;
		
		// Some constants
		private static const UI_NAME:String = "cooldown";
		private static const UI_INSTANCE_NAME:String = "cooldown";
		
		// APIs
		public var uiApi:UiApi;
		public var sysApi:SystemApi;
		public var fightApi:FightApi;
		public var dataApi:DataApi;
		
		// Some globals
		private var _spellManager:SpellManager;
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		public function main():void
		{
			_spellManager = new SpellManager();
			
			sysApi.addHook(OpeningContextMenu, onOpeningContextMenu);
			sysApi.addHook(GameFightEnd, onGameFightEnd);
			sysApi.addHook(GameFightLeave, onGameFightLeave);
			sysApi.addHook(FightEvent, onFightEvent);
			sysApi.addHook(GameFightTurnEnd, onGameFightTurnEnd);
			sysApi.addHook(GameFightStart, onGameFightStart);
			
			modCommon.addOptionItem("module_cooldown", "(M) Cooldown", "Options du module Cooldown", "Cooldown::config");
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
				if (cooldown < 2)
				{
					return;
				}
				
				var castedSpell:CastedSpell = new CastedSpell();
				
				castedSpell.fighterId = params[0];
				castedSpell.spellId = params[3];
				castedSpell.cooldown = cooldown;
				
				_spellManager.push(castedSpell);
				
				if (isLoadedUi())
				{
					getUiScript().update();
				}
			}
		}
		
		private function onGameFightTurnEnd(fighterId:int):void
		{
			for (var index:int = 0; index < _spellManager.length; index++)
			{
				if (_spellManager.at(index).fighterId != fighterId)
				{
					continue;
				}
				
				_spellManager.at(index).cooldown--;
				
				if (_spellManager.at(index).cooldown == -1)
				{
					_spellManager.removeAt(index);
				}
			}
			
			if (isLoadedUi())
			{
				getUiScript().update();
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
		
		private function onGameFightStart():void
		{
			if (sysApi.getData(ConfigEnum.OPEN_AUTO))
			{
				loadUi();
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
				uiApi.loadUi(UI_NAME, UI_INSTANCE_NAME, _spellManager);
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
		
		private function getUiScript():CooldownUI
		{
			return uiApi.getUi(UI_INSTANCE_NAME).uiClass;
		}
	}
}
