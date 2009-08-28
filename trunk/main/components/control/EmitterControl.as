
import main.control.FXManager;
import main.events.EditorEvent;

import mx.collections.ArrayCollection;
import mx.events.ListEvent;

private var fxManager:FXManager
private var emittersList:ArrayCollection = new ArrayCollection([]);
private var emitterNames:ArrayCollection;
[Bindable]
private var selectedEmitter:String = "emitter";
private var index:int;

public function init() : void
{
	fxManager = FXManager.getInstance();
	
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