package ui
{
	import d2api.DataApi;
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.ComboBox;
	import d2components.Grid;
	import d2enums.ComponentHookList;
	import d2enums.SelectMethodEnum;
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
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var fightApi:FightApi;
		public var dataApi:DataApi;
		
		// Components
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
						_displayedInfos.push(new Info(fighterId, dataApi.getSpellWrapper(castedSpell.spellId)["name"], castedSpell.cooldown));
					}
				}
			}
			
			grid_spell.dataProvider = _displayedInfos;
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
		 */
		public function updateEntry(data:Object, componentsRef:Object, selected:Boolean) : void
		{
			if (data)
			{
				componentsRef.lbl_name.text = data.label;
				componentsRef.lbl_cooldown.text = data.cooldown;
			}
			else
			{
				componentsRef.lbl_name.text = "";
				componentsRef.lbl_cooldown.text = "";
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
		
		private function initGrid():void
		{
			grid_spell.dataProvider = [];
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
			
			grid_spell.dataProvider = _displayedInfos;
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
	public var cooldown:int;
	
	function Info(fighterId:int, label:String, cooldown:int = 0)
	{
		this.fighterId = fighterId;
		this.label = label;
		this.cooldown = cooldown;
	}
}
