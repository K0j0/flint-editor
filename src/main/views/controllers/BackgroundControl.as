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

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
//import flash.filesystem.File;
import flash.net.URLRequest;

import main.utils.checkgroup.model.CheckBoxGroup;
import main.utils.checkgroup.views.MouseControl;

import mx.containers.Canvas;

private var bitmap:Bitmap;
private var canvas:Canvas;
private var canvasMask:Sprite = new Sprite();
private var mouseControl:MouseControl;

public function init(canvas:Canvas) : void
{
	this.canvas = canvas;
	canvas.opaqueBackground = 0x000000;
	
	canvasMask.graphics.beginFill(0xff0000);
	canvasMask.graphics.drawRect(0, 0, canvas.width, canvas.height);
	canvas.rawChildren.addChild(canvasMask);
	canvas.mask = canvasMask;
	
	mouseControl = MouseControl.getInstance();
	_groupCheckImgMove.daClickFunction = onMouseMove;
	_groupCheckImgMove.enableFlag = false;
}

private function onSetBGColor() : void
{
	canvas.opaqueBackground = _bgColor.selectedColor;
}

private function onLoadImage() : void
{
	/* 
	var file:File = new File();
	file.browseForOpen("Choose Image");
	file.addEventListener(Event.SELECT, onSelectFile);
	file.addEventListener(Event.CANCEL, onCancel);
	 */
}

private function onSelectFile(e:Event) : void
{
	trace("Nice Choice!");
	var url:URLRequest = new URLRequest(e.target.url);
	var loader:Loader = new Loader();
	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
	loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
	loader.load(url);
}

private function onCancel(e:Event) : void
{
	trace("Image Load Cancelled");
}

private function onImageLoaded(e:Event) : void 
{
	bitmap = e.target.content;
	canvas.rawChildren.addChildAt(bitmap,0);
	bitmap.mask = canvasMask;
	_groupCheckImgMove.enabled = true;
	_loadImage.enabled = false;
	_unloadImage.enabled = true;
	_groupCheckImgMove.enableFlag = true;
	
	trace("Image successfully loaded");
}

private function onIOError(e:IOErrorEvent) : void
{
	trace("IO Error!!!");
}

private function onUnloadImage() : void
{
	canvas.rawChildren.removeChildAt(0);
	_loadImage.enabled = true;
	_unloadImage.enabled = false;
	_groupCheckImgMove.enableFlag = false;
	
	if(_groupCheckImgMove.selected){
		_groupCheckImgMove.selected = false;
		var checkBoxGroup:CheckBoxGroup = CheckBoxGroup.getInstance();
		checkBoxGroup.update(_groupCheckImgMove);
	}
	_groupCheckImgMove.enabled = false;
}

private function onMouseMove() : void
{
	mouseControl.setObjectAndProperties([bitmap, bitmap], ["x", "y"]);
}