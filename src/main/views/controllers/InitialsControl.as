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

import org.flintparticles.common.actions.Action;
import org.flintparticles.common.actions.Age;
import org.flintparticles.common.initializers.AlphaInit;
import org.flintparticles.common.initializers.CollisionRadiusInit;
import org.flintparticles.common.initializers.ColorInit;
import org.flintparticles.common.initializers.Lifetime;
import org.flintparticles.common.initializers.MassInit;
import org.flintparticles.common.initializers.ScaleImageInit;
import org.flintparticles.twoD.actions.Rotate;
import org.flintparticles.twoD.initializers.RotateVelocity;
import org.flintparticles.twoD.initializers.Rotation;

private var fxManager:FXManager;
private var initializers:Array;

public function init() : void
{
	fxManager = FXManager.getInstance();
	
	fxManager.addEventListener(EditorEvent.RENDERER_SWITCH, onRendererSwitch);
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
}

private function onRendererSwitch(e:EditorEvent) : void
{
	var renderer:String = e.text1;	
	if(renderer == "pixel") currentState = "pixel";
	else currentState = "notPixel";
	onUpdateReferences();
}

private function onUpdateReferences(e:EditorEvent = null) : void
{
	initializers = fxManager.getInitializers();	
	//	update alpha
	var alphaInit:AlphaInit = initializers["AlphaInit"];
	if(alphaInit){
		_alphaMin.value = alphaInit.minAlpha;
		_alphaMax.value = alphaInit.maxAlpha;
	}
	//	update color
	var colorInit:ColorInit = initializers["ColorInit"];
	if(colorInit){
		_color1.selectedColor = colorInit.minColor;
		_color2.selectedColor = colorInit.maxColor;
	}
	//	update lifetime
	var lifeTime:Lifetime = initializers["Lifetime"];
	if(lifeTime){
		_ageMin.value = lifeTime.minLifetime;
		_ageMax.value = lifeTime.maxLifetime;
	}
	//	update rotation
	var rotation:Rotation = initializers["Rotation"];
	if(rotation){
		_rotationMin.value = rotation.minAngle;
		_rotationMax.value = rotation.maxAngle;
	}
	//	update rotate velocity
	var actions:ArrayCollection = fxManager.getActions();
	_rotateVelCheckBox.selected = false;
	for each(var a:Action in actions){
		if(a is Rotate){
			var rotateVelocity:RotateVelocity = initializers["RotateVelocity"];
			if(rotateVelocity){
				_rotateVelMin.value = rotateVelocity.minAngVelocity;
				_rotateVelMax.value = rotateVelocity.maxAngVelocity;
				_rotateVelCheckBox.selected = true;
			}
			break;			
		}
	}
	//	update scale
	var scaleImageInit:ScaleImageInit = initializers["ScaleImageInit"];
	if(scaleImageInit){
		_scaleMin.value = scaleImageInit.minScale;
		_scaleMax.value = scaleImageInit.maxScale;
	}
	//	update mass
	var massInit:MassInit = initializers["MassInit"];
	if(massInit){
		_mass.value = massInit.mass;
	}
	//	update collision radius
	var collisionRadiusInit:CollisionRadiusInit = initializers["CollisionRadiusInit"];
	if(collisionRadiusInit){
		_collisionRadius.value = collisionRadiusInit.radius;
	}
}

private function onChangeAge() : void
{
	var lifeTime:Lifetime = initializers["Lifetime"];
	var min:Number = _ageMin.value; 
	var max:Number = _ageMax.value;
	lifeTime.minLifetime = min;
	lifeTime.maxLifetime = max;
	fxManager.updateInitializer("Lifetime", ["Lifetime", min, max]);
}

private function onSetAge() : void
{
	//	Lifetime initializer needs Age action
	if(_ageCheckBox.selected){ 
		fxManager.addAction(new Age(), ["Age"]);
		var min:Number = _ageMin.value;
		var max:Number = _ageMax.value;
		var lifeTime:Lifetime = new Lifetime(min, max);
		fxManager.addInitializer(lifeTime, ["Lifetime", min, max]);
		initializers = fxManager.getInitializers();
		_ageMin.enabled = true;
		_ageMax.enabled = true;
	}
	else{
		fxManager.removeInitializer("Lifetime");
		var actions:ArrayCollection = fxManager.getActions();
		for(var j:int = 0; j < actions.length; j++){
			if(actions[j] is Age){
				fxManager.removeAction(j);
				break;
			}
		}
		_ageMin.enabled = false;
		_ageMax.enabled = false;
	}
}

private function onSetAlpha() : void
{
	if(_alphaCheckBox.selected){
		var min:Number = _alphaMin.value;
		var max:Number = _alphaMax.value;
		var alphaInit:AlphaInit = new AlphaInit(min, max);
		fxManager.addInitializer(alphaInit, ["AlphaInit", min, max]);
		initializers = fxManager.getInitializers();
		_alphaMin.enabled = true;
		_alphaMax.enabled = true;
	}
	else{
		fxManager.removeInitializer("AlphaInit");
		_alphaMin.enabled = false;
		_alphaMax.enabled = false;
	}
}

private function onChangeAlpha() : void
{
	var alphaInit:AlphaInit = initializers["AlphaInit"];
	var min:Number = _alphaMin.value;
	var max:Number = _alphaMax.value;
	alphaInit.minAlpha = min;
	alphaInit.maxAlpha = max;
	fxManager.updateInitializer("AlphaInit", ["AlphaInit", min, max]);
}

private function onChangeColor() : void
{
	var colorInit:ColorInit = initializers["ColorInit"];
	var color1:uint = _color1.selectedColor | 0xff000000;
	var color2:uint = _color2.selectedColor | 0xff000000;
	colorInit.minColor = color1;
	colorInit.maxColor = color2;
	fxManager.updateInitializer("ColorInit", ["ColorInit", color1, color2]);
}

private function onChangeRotateVelocity() : void
{
	var rotateVelocity:RotateVelocity = initializers["RotateVelocity"];
	var min:int = _rotateVelMin.value;
	var max:int = _rotateVelMax.value;
	rotateVelocity.minAngVelocity = min;
	rotateVelocity.maxAngVelocity = max;
	fxManager.updateInitializer("RotateVelocity", ["RotateVelocity", min, max]);
}

private function onSetRotateVelocity() : void
{
	//	RotateVelocity needs Rotate action	
	if(_rotateVelCheckBox.selected){ 
		var min:Number = _rotateVelMin.value;
		var max:Number = _rotateVelMax.value;
		var rotateVelocity:RotateVelocity = new RotateVelocity(min, max);
		fxManager.addAction(new Rotate(), ["Rotate"]);
		fxManager.addInitializer(rotateVelocity, ["RotateVelocity", min, max]);
		initializers = fxManager.getInitializers();
		_rotateVelMin.enabled = true;
		_rotateVelMax.enabled = true;
	}
	else{
		var actions:ArrayCollection = fxManager.getActions();
		for(var j:int = 0; j < actions.length; j++){
			if(actions[j] is Rotate){
				fxManager.removeAction(j);
				break;
			}
		}
		_rotateVelMin.enabled = false;
		_rotateVelMax.enabled = false;
	}
}

private function onSetRotation() : void
{
	if(_rotationCheckBox.selected){
		var min:Number = _rotationMin.value;
		var max:Number = _rotationMax.value;
		var rotation:Rotation = new Rotation(min, max);
		fxManager.addInitializer(rotation, ["Rotation", min, max]);
		initializers = fxManager.getInitializers();
		_rotationMin.enabled = true;
		_rotationMax.enabled = true;
	}
	else{
		fxManager.removeInitializer("Rotation");
		_rotationMin.enabled = false;
		_rotationMax.enabled = false;
	}
}

private function onChangeRotation() : void
{
	var rotation:Rotation = initializers["Rotation"];
	var min:int = _rotationMin.value * Math.PI / 180;
	var max:int = _rotationMax.value * Math.PI / 180;
	rotation.minAngle = min;
	rotation.maxAngle = max;
	fxManager.updateInitializer("Rotation", ["Rotation", min, max]);
}

private function onSetScale() : void
{
	if(_scaleCheckBoxs.selected){
		var min:Number = _scaleMin.value;
		var max:Number = _scaleMax.value;
		var scaleImageInit:ScaleImageInit = new ScaleImageInit(min, max);
		fxManager.addInitializer(scaleImageInit, ["ScaleImageInit", min, max]);
		initializers = fxManager.getInitializers();
		_scaleMin.enabled = true;
		_scaleMax.enabled = true;
	}
	else{
		fxManager.removeInitializer("ScaleImageInit");
		_scaleMin.enabled = false;
		_scaleMax.enabled = false;
	}
}

private function onChangeScale() : void
{
	var scale:ScaleImageInit = initializers["ScaleImageInit"];
	var min:Number = _scaleMin.value;
	var max:Number = _scaleMax.value;
	scale.minScale = min;
	scale.maxScale = max;
	fxManager.updateInitializer("ScaleImageInit", ["ScaleImageInit", min, max]);
}

private function onSetMassAndCollisionRadius() : void
{
	if(_massAndCollisionRadiusCheckBox.selected){
		var mass:int = _mass.value;
		var radius:int = _collisionRadius.value;
		var massInit:MassInit = new MassInit(mass);
		var collisionRadiusInit:CollisionRadiusInit = new CollisionRadiusInit(radius);
		fxManager.addInitializer(massInit, ["MassInit", mass]);
		fxManager.addInitializer(collisionRadiusInit, ["CollisionRadiusInit", radius]);
		initializers = fxManager.getInitializers();
		_mass.enabled = true;
		_collisionRadius.enabled = true;
	}
	else{
		fxManager.removeInitializer("MassInit");
		fxManager.removeInitializer("CollisionRadiusInit");
		_mass.enabled = false;
		_collisionRadius.enabled = false;
	}
}

private function onChangeMass() : void
{
	var massInit:MassInit = initializers["MassInit"];
	var mass:int = _mass.value;
	massInit.mass = mass;
	fxManager.updateInitializer("MassInit", ["MassInit", mass]);
}

private function onChangeCollisionRadius() : void
{
	var collisionRadiusInit:CollisionRadiusInit = initializers["CollisionRadiusInit"];
	var collisionRadius:int = _collisionRadius.value;
	collisionRadiusInit.radius = collisionRadius;
	fxManager.updateInitializer("CollisionRadiusInit", ["CollisionRadiusInit", collisionRadius]);
}