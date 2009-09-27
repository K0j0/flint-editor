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

import main.events.EditorEvent;
import main.model.FXDescriptor;
import main.model.FXManager;

import mx.collections.ArrayCollection;

import org.flintparticles.common.counters.Counter;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Constructor;

private var fxManager:FXManager;
private var desc:FXDescriptor;
private var counterName:String;
private var counterList:ArrayCollection = new ArrayCollection(["Blast", "PerformanceAdjusted", "Pulse", "Random", "SineCounter", "Steady", "TimePeriod"]);

public function init() : void
{
	_counterCombo.dataProvider = counterList;
	_counterCombo.selectedIndex = 5;
	fxManager = FXManager._instance;
	desc = FXDescriptor._instance;
	
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
}

private function onUpdateReferences(e:EditorEvent = null) : void
{
	var counter:XML = desc.effect.emitter[desc.emitterIndex].counter.*[0];
	var params:Array = [counter.name().toString()];
	for each(var node:XML in counter.children()){
		params.push(Number(node.toString()))
	}
//	fxManager.getCounterInfo();
	counterName = params.shift();
	currentState = counterName;
	
	var len:int = counterList.length;
	for(var j:int = 0; j < len; j++){
		if(counterList[j] == counterName){
			_counterCombo.selectedIndex = j;
			break;
		}
	}
	
	len = params.length;	
	for(j = 1; j <= len; j++){
		this["_paramStep" + j].value = params[j-1];
	}
}

private function onSelectCounter() : void
{
	var name:String = _counterCombo.selectedItem.toString();
	currentState = name;
	if(name == counterName) onUpdateReferences();
	else{
		for(var j:int = 1; j <= 3; j++){
			this["_paramStep" + j].value = 0;
		}
	}
}

private function onSetCounter() : void
{
	counterName = _counterCombo.selectedItem.toString();
	counterName = counterName.replace(/\s+/, "");
	var ci:ClassInfo = ClassInfo.forName("org.flintparticles.common.counters." + counterName);
	var con:Constructor = ci.getConstructor();
	
	var params:Array = [];
	var len:int = con.parameters.length;
	for(var j:int = 1; j <= len; j++){
		if(this.contains(this["_paramStep" + j])) params.push(this["_paramStep" + j].value);
	}
	var counter:Counter = con.newInstance(params);
	params.unshift(counterName);
	fxManager.setCounter(counter, params);
}