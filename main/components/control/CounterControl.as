
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