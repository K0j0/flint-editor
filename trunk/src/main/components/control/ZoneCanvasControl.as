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

import flash.geom.Point;

import main.control.FXManager;
import main.control.MouseControl;
import main.events.EditorEvent;

import org.flintparticles.common.initializers.Initializer;
import org.flintparticles.twoD.initializers.Position;
import org.flintparticles.twoD.initializers.Velocity;
import org.flintparticles.twoD.zones.DiscSectorZone;
import org.flintparticles.twoD.zones.LineZone;
import org.flintparticles.twoD.zones.PointZone;
import org.flintparticles.twoD.zones.RectangleZone;
import org.flintparticles.twoD.zones.Zone2D;

private var fxManager:FXManager;
private var mouseControl:MouseControl;

public function init() : void
{
	fxManager = FXManager.getInstance();
	mouseControl = MouseControl.getInstance();
	_zoneCombo.dataProvider = ["DiscZone", "PointZone", "LineZone", "RectangleZone"];
	
	_groupCheckPoint1.daClickFunction = onUseMousePoint1;
	_groupCheckPoint2.daClickFunction = onUseMousePoint2;
	mouseControl.addEventListener(EditorEvent.MOUSE_DONE, onMouseDone);
}

private function onUseMousePoint1() : void
{
	mouseControl.setObjectAndProperties([_stepX, _stepY], ["value", "value"]);
}

private function onUseMousePoint2() : void
{
	mouseControl.setObjectAndProperties([_stepX2, _stepY2], ["value", "value"]);
}

private function onMouseDone(e:EditorEvent) : void
{
	if(!_groupCheckPoint1.selected && !_groupCheckPoint2.selected) return;
	_groupCheckPoint1.clearAll();
	onSetZone();
}

private function onChooseZone() : void
{
	var choice:String = _zoneCombo.selectedLabel;
	choice = choice.replace(/zone/i, "");
	currentState = choice;
}

private function onSelectZoneType() : void
{
	if(_posZone.selected){
		_posZone.enabled = false;
		_velZone.enabled = true;
	}
	else if(_velZone.selected){
		_posZone.enabled = true;
		_velZone.enabled = false;
	}
}

private function onSetZone() : void
{
	var zone:Zone2D;
	var params:Array = [];
	switch(currentState)
	{
		case "Disc" :
			var x:int = _stepX.value;
			var y:int = _stepY.value;
			var inner:int = _stepInner.value;
			var outer:int = _stepOuter.value;
			var angleCW:int = _stepCW.value;
			var angleCCW:int = _stepCCW.value;
			zone = new DiscSectorZone(new Point(x,y), outer, inner, angleCW, angleCCW);
			params = ["DiscSectorZone", "Point", x, y, outer, inner, angleCW, angleCCW];
		break;
		case "Point" :
			x = _stepX.value;
			y = _stepY.value;
			zone = new PointZone(new Point(x, y));
			params = ["PointZone", "Point", x, y];
		break;
		case "Line" :
			x = _stepX.value;
			y = _stepY.value;
			var x2:int = _stepX2.value;
			var y2:int = _stepY2.value;
			zone = new LineZone(new Point(x, y), new Point(x2, y2));
			params = ["LineZone", "Point", x, y, "Point", x2, y2];
		break;
		case "Rectangle" :
			var left:int = _left.value;
			var top:int = _top.value;
			var right:int = _right.value;
			var bottom:int = _bottom.value;
			zone = new RectangleZone(left, top, right, bottom);
			params = ["RectangleZone", left, top, right, bottom];
		break;
	}
	
	var initializer:Initializer;
	if(_posZone.selected){
		fxManager.removeInitializer("Position");
		initializer = new Position(zone);
		params.unshift("Position");
	}
	else{
		fxManager.removeInitializer("Velocity");
		initializer = new Velocity(zone);
		params.unshift("Velocity");
		_removeVel.enabled = true;
	}
	fxManager.addInitializer(initializer, params);
}

private function onRemoveVelocity() : void
{
	_removeVel.enabled = false;
	fxManager.removeInitializer("Velocity");
}