import main.control.FXManager;
import main.control.MouseControl;
import main.events.EditorEvent;

import mx.collections.ArrayCollection;

import org.flintparticles.common.actions.Action;
import org.flintparticles.common.actions.Age;
import org.flintparticles.twoD.actions.Move;
import org.flintparticles.twoD.actions.Rotate;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Constructor;

private var actionsList:ArrayCollection;
private var currentActions:ArrayCollection;
private var fxManager:FXManager;
private var mouseControl:MouseControl;

public function inits() : void
{
	fxManager = FXManager.getInstance();
	mouseControl = MouseControl.getInstance();
	actionsList = new ArrayCollection(["Accelerate", "AntiGravity", "Bounding Box", "Gravity Well"]);
	_mouseGroupCheck.daClickFunction = onMouseEnabled;
	
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
	mouseControl.addEventListener(EditorEvent.MOUSE_DONE, onMouseDone);
}

private function onUpdateReferences(e:EditorEvent) : void
{
	currentActions = fxManager.getActions();
	_actionsList.dataProvider = currentActions;
	_actionCombo.dataProvider = actionsList;	
}

public function updateReferences() : void
{
	_actionsList.dataProvider = fxManager.getActions();
}

private function onChooseAction() : void
{
	var choice:String = _actionCombo.selectedItem.toString();
	currentState = choice;
	if(choice == "Accelerate" || /gravity/i.test(choice)) _mouseGroupCheck.enabled = false;
	else if(_mouseGroupCheck.enableFlag) _mouseGroupCheck.enabled = true;
}

private function onAddAction() : void
{
	var choice:String = _actionCombo.selectedItem.toString();
	choice = choice.replace(/\s+/, "");
	var ci:ClassInfo;
	try{
		ci = ClassInfo.forName("org.flintparticles.common.actions." + choice);
	}
	catch(e:ReferenceError){};
	if(!ci){
		ci = ClassInfo.forName("org.flintparticles.twoD.actions." + choice);
	}
	var con:Constructor = ci.getConstructor();
	var numParams:int = con.parameters.length;
	var params:Array = [];
	for(var j:int = 1; j <= numParams; j++){
		params.push(this["_actionsParam" + j].value);
	}
	var action:Action = con.newInstance(params);
	params.unshift(ci.simpleName);
	fxManager.addAction(action, params);
}

private function onRemoveAction() : void
{
	var index:int = _actionsList.selectedIndex;
	if(index >= 0){ 
		var action:Action = currentActions[index] as Action;
		if(action is Age || action is Move || action is Rotate) return;
		fxManager.removeAction(index);
	}
}

private function onMouseEnabled() : void
{
	if(currentState == "Accelerate"){
		mouseControl.setObjectAndProperties([_actionsParam1, _actionsParam2], ["value", "value"]);
	}
	else if(currentState == "AntiGravity" || currentState == "Gravity Well"){
		mouseControl.setObjectAndProperties([_actionsParam2, _actionsParam3], ["value", "value"]);
	}
}

private function onMouseDone(e:EditorEvent) : void
{
	_mouseGroupCheck.clearAll();	//	!!!	centralize this
	if(!_mouseGroupCheck.selected) return;
	onAddAction();
}