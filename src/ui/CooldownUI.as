package ui
{
	import d2api.DataApi;
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.ComboBox;
	import d2components.GraphicContainer;
	import d2components.Grid;
	import d2enums.ComponentHookList;
	import d2enums.FightEventEnum;
	import d2enums.SelectMethodEnum;
	import d2hooks.FightEvent;
	import types.CastedSpell;
	
	/**
	 * Main ui class.
	 * 
	 * @author Relena
	 */
	public class CooldownUI
	{
		//::///////////////////////////////////////////////////////////
		//::// Variables
		//::///////////////////////////////////////////////////////////
		
		// Some constants
		private static const LINE_EMPTY:String = "line_empty";
		private static const LINE_SPELL:String = "line_spell";
		private static const LINE_FIGHTER:String = "line_fighter";
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var fightApi:FightApi;
		public var dataApi:DataApi;
		
		// Components
		public var tx_background:GraphicContainer;
		
		public var grid_spell:Grid;
		
		public var cb_fighters:ComboBox;
		
		public var btn_close:ButtonContainer;
		public var btn_config:ButtonContainer;
		
		// Some globals
		private var _displayedInfos:Array;
		private var _displayedFighter:Array;
		
		//::///////////////////////////////////////////////////////////
		//::// Public methods
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Main ui function (entry point).
		 * 
		 * @param	params
		 */
		public function main(params:Object):void
		{
			_displayedInfos = new Array();
			_displayedFighter = new Array();
			
			initCombobox();
			initGrid();
			
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(cb_fighters, ComponentHookList.ON_SELECT_ITEM);
			
			sysApi.addHook(FightEvent, onFightEvent);
		}
		
		public function update(castedSpells:Vector.<CastedSpell>):void
		{
			_displayedInfos = new Array();
			
			for each (var fighterId:int in _displayedFighter)
			{
				_displayedInfos.push(new Info(fighterId, fightApi.getFighterName(fighterId)));
				
				for each (var castedSpell:CastedSpell in castedSpells)
				{
					if (castedSpell.fighterId == fighterId)
					{
						_displayedInfos.push(new Info(fighterId, dataApi.getSpellWrapper(castedSpell.spellId)["name"], true, castedSpell.cooldown));
					}
				}
			}
			
			initGrid(_displayedInfos);
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Events
		//::///////////////////////////////////////////////////////////
		
		/**
		 * Mouse rooover callback.
		 * 
		 * @param	target
		 */
		public function onRollOver(target:Object):void
		{
			switch (target)
			{
				default:
					break;
			}
		}
		
		/**
		 * Mouse rollout callback.
		 * 
		 * @param	target
		 */
		public function onRollOut(target:Object):void
		{
			uiApi.hideTooltip();
		}
		
		/**
		 * Mouse release callback.
		 * 
		 * @param	target
		 */
		public function onRelease(target:Object):void
		{
			switch (target)
			{
				case btn_close:
					unloadUI();
					
					break;
				default:
					if (target.name.indexOf("btn_delete") != -1)
					{
						hideFighter(target.value);
					}
					
					break;
			}
		}
		
		public function onSelectItem(component:Object, selectMethod:uint, isNewSelection:Boolean) : void
		{
			switch(component)
			{
				case cb_fighters:
					if (selectMethod != SelectMethodEnum.CLICK)
					{
						break;
					}
					
					if (component.value.id)
					{
						displayFighter(component.value.id);
					}
					else
					{
						displayAllFighters();
					}
					
					break;
				default:
					break;
			}
		}
		
		/**
		 * Update grid line.
		 * 
		 * @param	data	Data associated to the grid line.
		 * @param	componentsRef	Link to the components of the grid line.
		 * @param	selected	Is the line selected ?
		 * @param	param4	(no idea what is that)
		 */
		public function updateEntry(data:Object, componentsRef:Object, selected:Boolean, param4:uint) : void
		{
			switch (getLineType(data, param4))
			{
				case LINE_SPELL:
					componentsRef.lbl_name.text = data.label;
					componentsRef.lbl_cooldown.text = data.cooldown;
					
					break;
				case LINE_FIGHTER:
					componentsRef.lbl_name.text = data.label;
					
					componentsRef.btn_delete.value = data.fighterId;
					
					uiApi.addComponentHook(componentsRef.btn_delete, ComponentHookList.ON_RELEASE);
					
					break;
			}
		}
		
		public function getDataLength(param1:Object, param2:Boolean):int
		{
			sysApi.log(8, "datalenght: " + param1 + ", " + param2);
			
			return 11;
		}
		
		/**
		 * Select the containe to display in the grid line.
		 * 
		 * @param	data	Data of the line (Info).
		 * @param	param2	(no idea what is that).
		 * @return	The name of the container use.
		 */
		public function getLineType(data:Object, param2:uint):String
		{
			if (!data)
			{
				return LINE_EMPTY;
			}
			else if (data.isSpell)
			{
				return LINE_SPELL;
			}
			else
			{
				return LINE_FIGHTER;
			}
		}
		
		/**
		 * FightEvent callback.
		 *
		 * @param	eventName	Name of the current event.
		 * @param	params		Parameters of the current event.
		 * @param	targetList	(not used).
		 */
		private function onFightEvent(eventName:String, params:Object, targetList:Object = null):void
		{
			if (eventName == FightEventEnum.FIGHTER_DEATH || eventName == FightEventEnum.FIGHTER_SUMMONED)
			{
				initCombobox();
			}
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		private function initCombobox():void
		{
			var fighterNames:Array = [{label:"[All]", id:0}];
			for each (var fighterId:int in fightApi.getFighters())
			{
				fighterNames.push({label:fightApi.getFighterName(fighterId), id:fighterId});
			}
			
			cb_fighters.dataProvider = fighterNames;
		}
		
		private function initGrid(infos:Array = null):void
		{
			if (!infos || infos.length <= 3)
			{
				grid_spell.height = 90;
				tx_background.height = grid_spell.height + 75;
			}
			else if (infos.length > 15)
			{
				grid_spell.height = 30 * 15;
				tx_background.height = grid_spell.height + 75;
			}
			else
			{
				grid_spell.height = 30 * infos.length;
				tx_background.height = grid_spell.height + 75;
			}
			
			if (infos)
			{
				grid_spell.dataProvider = infos;
			}
			else
			{
				grid_spell.dataProvider = [];
			}
		}
		
		private function displayFighter(fighterId:int):void
		{
			for each (var id:int in _displayedFighter)
			{
				if (id == fighterId)
				{
					return;
				}
			}
			
			_displayedFighter.push(fighterId);
			_displayedInfos.push(new Info(fighterId, fightApi.getFighterName(fighterId)));
			
			initGrid(_displayedInfos);
		}
		
		private function displayAllFighters():void
		{
			_displayedFighter = new Array();
			_displayedInfos = new Array();
			
			for each (var fighterId:int in fightApi.getFighters())
			{
				displayFighter(fighterId);
			}
		}
		
		private function hideFighter(fighterId:int):void
		{
			_displayedFighter.splice(_displayedFighter.indexOf(fighterId), 1);
			
			for (var index:int = 0; index < _displayedInfos.length; index++)
			{
				if (_displayedInfos[index].fighterId == fighterId)
				{
					_displayedInfos.splice(index, 1);
					
					index--;
				}
			}
			
			initGrid(_displayedInfos);
		}
		
		/**
		 * Unload the UI.
		 */
		private function unloadUI():void
		{
			uiApi.unloadUi(uiApi.me().name);
		}
	}
}

class Info {
	public var fighterId:int;
	public var label:String;
	public var isSpell:Boolean;
	public var cooldown:int;
	
	function Info(fighterId:int, label:String, isSpell:Boolean = false,  cooldown:int = 0)
	{
		this.fighterId = fighterId;
		this.label = label;
		this.isSpell = isSpell;
		this.cooldown = cooldown;
	}
}
