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
import main.model.FXManager;

import mx.collections.ArrayCollection;
import mx.events.ListEvent;

private var fxManager:FXManager;
private var emittersList:ArrayCollection = new ArrayCollection([]);
private var emitterNames:ArrayCollection;
[Bindable]
private var selectedEmitter:String = "emitter";
private var index:int;

public function init() : void
{
	fxManager = FXManager._instance;
	
	_emittersList.addEventListener(ListEvent.CHANGE, onSelectEmitter);
	_emittersList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onDoubleClickEmitter);
	_emittersList.addEventListener(ListEvent.ITEM_EDIT_END, onChangeEmitterName);
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
}

private function onUpdateReferences(e:EditorEvent = null) : void
{
	emitterNames = fxManager.getEmitterNames();
	var selectedIndex:int = _emittersList.selectedIndex;
	_emittersList.dataProvider = emitterNames;
	if(selectedIndex >= 0) _emittersList.selectedIndex = selectedIndex;
	
	if(emitterNames.length > 0){
		if(index == emitterNames.length) index--;
		selectedEmitter = emitterNames[index];
	}
}
private function onAddEmitter() : void
{
	fxManager.addEmitter();
	fxManager.refresh();
	if(_emittersList.dataProvider.length > 1) _removeBtn.enabled = true;
}

private function onRemoveEmitter() : void
{
	fxManager.removeEmitter(index);
	if(_emittersList.dataProvider.length == 1) _removeBtn.enabled = false;
}

private function onSelectEmitter(e:ListEvent) : void
{
	index = _emittersList.selectedIndex;
	selectedEmitter = e.itemRenderer.data.toString();
	fxManager.selectEmitter(e.rowIndex);
}

private function onDoubleClickEmitter(e:ListEvent) : void
{
	_emittersList.editable = true;
	_emittersList.editedItemPosition = {columnIndex:0, rowIndex:e.rowIndex};
}

private function onChangeEmitterName(e:ListEvent) : void
{
	selectedEmitter = _emittersList.itemEditorInstance["text"];
	var index:int = e.rowIndex;
	fxManager.changeEmitterNames(selectedEmitter, index);
	_emittersList.editable = false;
}