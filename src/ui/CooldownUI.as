package ui
{
	import d2api.FightApi;
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.ComboBox;
	import d2components.Grid;
	import d2enums.ComponentHookList;
	import d2enums.SelectMethodEnum;
	
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
		
		// Components
		public var grid_spell:Grid;
		
		public var cb_fighters:ComboBox;
		
		public var btn_close:ButtonContainer;
		public var btn_config:ButtonContainer;
		
		// Some globals
		
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
			initCombobox();
			
			grid_spell.dataProvider = [];
			
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(cb_fighters, ComponentHookList.ON_SELECT_ITEM);
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
					if (selectMethod != SelectMethodEnum.CLICK || !isNewSelection)
					{
						break;
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
		public function updateEntry(data:*, componentsRef:*, selected:Boolean) : void
		{
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
		
		/**
		 * Unload the UI.
		 */
		private function unloadUI():void
		{
			uiApi.unloadUi(uiApi.me().name);
		}
	}
}
