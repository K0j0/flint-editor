package main.control
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import main.components.GroupCheckBox;
	
	import mx.controls.CheckBox;

	public class CheckBoxGroup extends EventDispatcher
	{
		private static var instance:CheckBoxGroup;
		private var group:Array = [];
		
		public function CheckBoxGroup(privateClass:PrivateClass, target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getInstance() : CheckBoxGroup
		{
			if(!instance)
			{
				instance = new CheckBoxGroup(new PrivateClass());
			}
			return instance;
		}
		
		public function addCheckBox(checkBox:CheckBox) : void
		{
			group.push(checkBox);
		}
		
		public function update(currentCheckBox:CheckBox) : void
		{
			for each(var checkBox:GroupCheckBox in group){
				if(checkBox == currentCheckBox) continue;
				checkBox.selected = false;
				if(currentCheckBox.selected) checkBox.enabled = false;
				else if(checkBox.enableFlag) checkBox.enabled = true;				
			}
		}
		
		public function clearAll() : void
		{
			for each(var checkBox:GroupCheckBox in group){
				checkBox.selected = false;
				if(checkBox.enableFlag) checkBox.enabled = true;
			}
		}
	}
}

class PrivateClass
{
	public function PrivateClass() {}
}