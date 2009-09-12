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
import main.utils.checkgroup.model.CheckBoxGroup;
import main.utils.checkgroup.views.MouseControl;

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
private var checkBoxGroup:CheckBoxGroup;
private var mouseControl:MouseControl;

public function inits() : void
{
	fxManager = FXManager.getInstance();
	checkBoxGroup = CheckBoxGroup.getInstance();
	mouseControl = MouseControl.getInstance();
	actionsList = new ArrayCollection(["Accelerate", "AntiGravity", "ApproachNeighbours", "BoundingBox",
										"Collide", "DeathSpeed", "Explosion", "Fade", "Friction", "GravityWell", "LinearDrag",
										"MatchRotateVelocity", "MinimumDistance", "MutualGravity", "QuadraticDrag", "RandomDrift",
										"RotationalFriction", "RotationalLinearDrag", "RotationalQuadraticDrag", "ScaleAll", 
										"SpeedLimit", "TargetRotateVelocity", "TurnTowardsPoint", "TweenPosition"]);
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
	if(choice == "Accelerate" || /gravity/i.test(choice)) _mouseGroupCheck.enableFlag = true;
	else if(_mouseGroupCheck.enableFlag) _mouseGroupCheck.enableFlag = false;
	checkBoxGroup.updateAll();
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
	if(!_mouseGroupCheck.selected) return;
	onAddAction();
}