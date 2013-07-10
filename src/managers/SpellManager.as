package managers
{
	import types.CastedSpell;
	
	/**
	 * Track spell with cooldown.
	 * 
	 * @author Relena
	 */
	public class SpellManager
	{
		private var _castedSpells:Vector.<CastedSpell>;
		
		public function SpellManager()
		{
			_castedSpells = new Vector.<CastedSpell>();
		}
		
		public function push(castedSpell:CastedSpell):uint
		{
			return _castedSpells.push(castedSpell);
		}
		
		public function at(index:int):CastedSpell
		{
			return _castedSpells[index];
		}
		
		public function removeAt(index:int):void
		{
			_castedSpells.splice(index, 1);
		}
		
		public function get length():int
		{
			return _castedSpells.length;
		}
		
		public function all():Vector.<CastedSpell>
		{
			return _castedSpells;
		}
	}
}