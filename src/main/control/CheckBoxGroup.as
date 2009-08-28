/**
 *   Copyright (C) <2009>  <Kojo Kumah>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
		
		public function updateAll() : void
		{
			for each(var checkBox:GroupCheckBox in group){
				checkBox.selected = false;
				if(checkBox.enableFlag) checkBox.enabled = true;
				else if(!checkBox.enableFlag) checkBox.enabled = false;
			}
		}
	}
}

class PrivateClass
{
	public function PrivateClass() {}
}