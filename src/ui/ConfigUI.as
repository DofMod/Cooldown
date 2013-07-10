package ui
{
	import d2api.SystemApi;
	import d2api.UiApi;
	import d2components.ButtonContainer;
	import d2enums.ComponentHookList;
	import enums.ConfigEnum;
	
	/**
	 * @author Relena
	 */
	public class ConfigUI
	{
		//::////////////////////////////////////////////////////////////////////
		//::// Properties
		//::////////////////////////////////////////////////////////////////////
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		
		// Components
		public var btn_open_auto:ButtonContainer;
		
		//::////////////////////////////////////////////////////////////////////
		//::// Public Methods
		//::////////////////////////////////////////////////////////////////////
		
		public function main(params:Object):void
		{
			btn_open_auto.selected = sysApi.getData(ConfigEnum.OPEN_AUTO);
			
			uiApi.addComponentHook(btn_open_auto, ComponentHookList.ON_RELEASE);
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Events
		//::////////////////////////////////////////////////////////////////////
		
		public function onRelease(target:Object):void
		{
			switch(target)
			{
				case btn_open_auto:
					sysApi.setData(ConfigEnum.OPEN_AUTO, target.selected);
					
					break;
				default:
					break;
			}
		}
		
		//::////////////////////////////////////////////////////////////////////
		//::// Private Methods
		//::////////////////////////////////////////////////////////////////////
	}
}