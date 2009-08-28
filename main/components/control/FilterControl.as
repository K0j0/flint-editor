
import flash.filters.BitmapFilter;

import main.control.FXManager;
import main.events.EditorEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Constructor;


private var fxManager:FXManager;
private var filterList:ArrayCollection = new ArrayCollection([]);

public function init() : void
{
	fxManager = FXManager.getInstance();
	_filterCombo.dataProvider = ["Blur", "Glow"];
	
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
}

private function onUpdateReferences(e:EditorEvent = null) : void
{
	filterList = fxManager.getFilters();
	_filterList.dataProvider = filterList;
	_removeFilter.enabled = filterList.length > 0 ? true : false;
}

private function onChooseFilter() : void
{
	var choice:String = _filterCombo.selectedItem.toString();
	currentState = choice;	
}

private function onChooseColor() : void
{
	_filterParam1.value = _glowColor.selectedColor;
}

private function onAddFilter() : void
{
	var choice:String = _filterCombo.selectedItem.toString();	
	var ci:ClassInfo;
	try{
		ci = ClassInfo.forName("flash.filters." + choice + "Filter");
	}
	catch(e:ReferenceError){Alert.show("Error Finding Bitmap");};
	var con:Constructor = ci.getConstructor();
	var numParams:int = con.parameters.length;
	var params:Array = [];
	for(var j:int = 1; j <= numParams; j++){
		params.push(this["_filterParam" + j].value);
	}
	var filter:BitmapFilter = con.newInstance(params);
	params.unshift(ci.simpleName);
	fxManager.addFilter(filter, params);
	onUpdateReferences();
}

private function onRemoveFilter() : void
{
	var index:int = _filterList.selectedIndex;
	fxManager.removeFilter(index);
	onUpdateReferences();
}