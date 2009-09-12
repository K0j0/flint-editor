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

import flash.filters.BitmapFilter;

import main.events.EditorEvent;
import main.model.FXManager;

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