package ui
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2components.Grid;
	import d2enums.ComponentHookList;
	
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
		
		// Components
		public var grid_spell:Grid;
		
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
			grid_spell.dataProvider = [];
			
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
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
		
		/**
		 * Unload the UI.
		 */
		private function unloadUI():void
		{
			uiApi.unloadUi(uiApi.me().name);
		}
	}
}
