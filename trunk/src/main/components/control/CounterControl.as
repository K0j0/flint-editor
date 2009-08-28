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

import main.control.FXManager;

import mx.collections.ArrayCollection;

import org.flintparticles.common.counters.Counter;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Constructor;

private var fxManager:FXManager;
private var counterList:ArrayCollection = new ArrayCollection(["Blast", "Performance Adjusted", "Pulse", "Random", "Sine Counter", "Steady", "Time Period"]);

public function init() : void
{
	_counterCombo.dataProvider = counterList;
	_counterCombo.selectedIndex = 5;
	fxManager = FXManager.getInstance();
}

private function onSelectCounter() : void
{
	var name:String = _counterCombo.selectedItem.toString();
	currentState = name;
}

private function onSetCounter() : void
{
	var name:String = _counterCombo.selectedItem.toString();
	name = name.replace(/\s+/, "");
	var ci:ClassInfo = ClassInfo.forName("org.flintparticles.common.counters." + name);
	var con:Constructor = ci.getConstructor();
	
	var params:Array = [];
	var len:int = con.parameters.length;
	for(var j:int = 1; j <= len; j++){
		if(this.contains(this["_paramStep" + j])) params.push(this["_paramStep" + j].value);
	}
	var counter:Counter = con.newInstance(params);
	params.unshift(name);
	fxManager.setCounter(counter, params);
}