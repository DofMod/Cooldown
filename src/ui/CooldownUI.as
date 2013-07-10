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
	import flash.geom.Rectangle;
	import managers.SpellManager;
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
		private static const BANNER_HEIGHT:int = 160;
		private static const ALL_ID:int = -1000;
		private static const ALLIES_ID:int = -1001;
		private static const ENNEMIES_ID:int = -1002;
		
		// APIs
		public var sysApi:SystemApi;
		public var uiApi:UiApi;
		public var fightApi:FightApi;
		public var dataApi:DataApi;
		
		// Modules
		[Module (name="Ankama_Common")]
		public var modCommon : Object;
		
		// Components
		public var ctn_main:GraphicContainer;
		
		public var tx_background:GraphicContainer;
		
		public var grid_spell:Grid;
		
		public var cb_fighters:ComboBox;
		
		public var btn_close:ButtonContainer;
		public var btn_config:ButtonContainer;
		
		// Some globals
		private var _minNbLine:int;
		private var _maxNbLines:int;
		private var _lineHeight:int;
		
		private var _spellManager:SpellManager;
		
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
			_spellManager = params as SpellManager;
			
			_displayedInfos = new Array();
			_displayedFighter = new Array();
			
			_minNbLine = 3;
			_maxNbLines = 15;
			_lineHeight = this.uiApi.me().getConstant("line_height");
			
			initCombobox();
			initGrid();
			
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_PRESS); // Hack to disable the drag of the UI
			uiApi.addComponentHook(btn_close, ComponentHookList.ON_RELEASE);
			
			uiApi.addComponentHook(btn_config, ComponentHookList.ON_PRESS); // Hack to disable the drag of the UI
			uiApi.addComponentHook(btn_config, ComponentHookList.ON_RELEASE);
			
			uiApi.addComponentHook(cb_fighters, ComponentHookList.ON_SELECT_ITEM);
			
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_PRESS);
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_RELEASE);
			uiApi.addComponentHook(ctn_main, ComponentHookList.ON_RELEASE_OUTSIDE);
			
			sysApi.addHook(FightEvent, onFightEvent);
		}
		
		public function update():void
		{
			_displayedInfos = new Array();
			
			for each (var fighterId:int in _displayedFighter)
			{
				_displayedInfos.push(new Info(fighterId, fightApi.getFighterName(fighterId)));
				
				for each (var castedSpell:CastedSpell in _spellManager.all())
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
		 * Mouse press callback
		 * 
		 * @param	target
		 */
		public function onPress(target:Object):void
		{
			switch(target)
			{
				case ctn_main:
					dragUiStart();
					
					break;
			}
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
				case btn_config:
					modCommon.openOptionMenu(false, "module_cooldown");
					
					break;
				case ctn_main:
					dragUiStop();
					
					break;
				default:
					if (target.name.indexOf("btn_delete") != -1)
					{
						removeFighter(target.value);
					}
					
					break;
			}
		}
		
		/**
		 * Mouse release outside callback.
		 * 
		 * @param	target
		 */
		public function onReleaseOutside(target:Object) :  void
		{
			switch(target)
			{
				case ctn_main:
					dragUiStop();
					
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
					
					switch (component.value.id)
					{
						case ALL_ID:
						case ALLIES_ID:
						case ENNEMIES_ID:
							displayAllFighters(component.value.id);
							
							break;
						default:
							displayFighter(component.value.id);
							
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
					
					uiApi.addComponentHook(componentsRef.btn_delete, ComponentHookList.ON_PRESS); // Hack to disable the drag of the UI
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
			switch (eventName)
			{
				case FightEventEnum.FIGHTER_DEATH:
					initCombobox();
					
					removeFighter(params[0]);
					
					break
				case FightEventEnum.FIGHTER_SUMMONED:
					initCombobox();
					
					break;
				default:
					break;
			}
		}
		
		//::///////////////////////////////////////////////////////////
		//::// Private methods
		//::///////////////////////////////////////////////////////////
		
		private function initCombobox():void
		{
			var fighterNames:Array = [ { label:"[Tous]", id:ALL_ID }, { label:"[Alliés]", id:ALLIES_ID }, { label:"[Ennemis]", id:ENNEMIES_ID } ];
			for each (var fighterId:int in fightApi.getFighters())
			{
				if (fightApi.getFighterInformations(fighterId).isAlive)
				{
					fighterNames.push( { label:fightApi.getFighterName(fighterId), id:fighterId } );
				}
			}
			
			cb_fighters.dataProvider = fighterNames;
		}
		
		private function initGrid(infos:Array = null):void
		{
			if (!infos || infos.length <= _minNbLine)
			{
				grid_spell.height = _minNbLine * _lineHeight;
				tx_background.height = grid_spell.height + 75;
			}
			else if (infos.length > _maxNbLines)
			{
				grid_spell.height = _lineHeight * _maxNbLines;
				tx_background.height = grid_spell.height + 75;
			}
			else
			{
				grid_spell.height = _lineHeight * infos.length;
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
		
		private function dragUiStart() : void
		{
			ctn_main.startDrag(
					false,
					new Rectangle(
							0,
							0,
							uiApi.getStageWidth() - tx_background.width,
							uiApi.getStageHeight() - tx_background.height - BANNER_HEIGHT)
					);
		}
		
		private function dragUiStop() : void
		{
			ctn_main.stopDrag();
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
			
			for each (var castedSpell:CastedSpell in _spellManager.all())
			{
				if (castedSpell.fighterId == fighterId)
				{
					_displayedInfos.push(new Info(fighterId, dataApi.getSpellWrapper(castedSpell.spellId)["name"], true, castedSpell.cooldown));
				}
			}
			
			initGrid(_displayedInfos);
		}
		
		private function displayAllFighters(typeId:int = ALL_ID):void
		{
			_displayedFighter = new Array();
			_displayedInfos = new Array();
			
			var myTeam:String = fightApi.getFighterInformations(fightApi.getCurrentPlayedFighterId()).team;
			
			for each (var fighterId:int in fightApi.getFighters())
			{
				if (fightApi.getFighterInformations(fighterId).isAlive == false)
				{
					continue;
				}
				
				var hisTeam:String = fightApi.getFighterInformations(fighterId).team;
				
				switch (typeId)
				{
					case ALL_ID:
						displayFighter(fighterId);
						
						break;
					case ALLIES_ID:
						if (myTeam == hisTeam || (myTeam == null && hisTeam == "challenger"))
						{
							displayFighter(fighterId);
						}
						
						break;
					case ENNEMIES_ID:
						if ((myTeam != hisTeam && myTeam != null) || (myTeam == null && hisTeam == "defender"))
						{
							displayFighter(fighterId);
						}
						
						break;
					default:
						break;
				}
			}
		}
		
		private function removeFighter(fighterId:int):void
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
