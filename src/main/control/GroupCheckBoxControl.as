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

import flash.events.MouseEvent;

import main.control.CheckBoxGroup;

private var clickFunction:Function;
private var checkBoxGroup:CheckBoxGroup;
public var enableFlag:Boolean = true;

private function init() : void
{
	checkBoxGroup = CheckBoxGroup.getInstance();
	checkBoxGroup.addCheckBox(this);
	
	addEventListener(MouseEvent.CLICK, onClick);
}

public function set daClickFunction(value:Function) : void
{
	clickFunction = value;
}

private function onClick(e:MouseEvent) : void
{
	checkBoxGroup.update(this);	
	clickFunction.call(this);
}

public function clearAll() : void
{
	checkBoxGroup.clearAll();
}