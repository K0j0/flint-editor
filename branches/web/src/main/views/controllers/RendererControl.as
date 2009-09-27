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
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

import main.events.EditorEvent;
import main.model.FXDescriptor;
import main.model.FXManager;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.ListEvent;

import org.flintparticles.common.renderers.Renderer;
import org.flintparticles.twoD.renderers.BitmapRenderer;
import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
import org.flintparticles.twoD.renderers.PixelRenderer;

[Embed (source="../assets/Moon-icon.png")]
private var imgClass:Class;
private var img:Bitmap = new imgClass();

private var fxManager:FXManager;
private var desc:FXDescriptor;
private var renderer:Renderer;
private var selectedImage:Object = {bitmap:null, index:0};
private var bitmaps:Array;
private var bitmapNames:ArrayCollection = new ArrayCollection([]);
private var imgIndex:int = -1;
[Bindable]
private var selectedImageName:String = "n/a";
private var blendModesArray:Array = [];
private var displayObjectsArray:Array = [];
private var lastState:String;

public function init() : void
{
	fxManager = FXManager._instance;
	desc = FXDescriptor._instance;
	_displayObjectComboBox.dataProvider = ["Dot", "Line", "RadialDot", "Rect", "Star"];
	_imagesList.dataProvider = bitmapNames;
	_rendererBlendCombo.dataProvider = ["add", "alpha", "darken", "difference", 
		"erase", "hardlight", "invert", "layer", "lighten", "multiply", "normal", 
		"overlay", "screen", "subtract"];
	_imageBlendMode.dataProvider = _displayObjectBlendMode.dataProvider = ["add", "alpha", "darken", "difference", 
		"erase", "hardlight", "invert", "layer", "lighten", "multiply", "normal", 
		"overlay", "screen", "subtract"];
	_rendererBlendCombo.selectedIndex = _imageBlendMode.selectedIndex = 10;
	blendModesArray["add"] = 0;
	blendModesArray["alpha"] = 1;
	blendModesArray["darken"] = 2;
	blendModesArray["difference"] = 3;
	blendModesArray["erase"] = 4;
	blendModesArray["hardlight"] = 5;
	blendModesArray["invert"] = 6;
	blendModesArray["layer"] = 7;
	blendModesArray["lighten"] = 8;
	blendModesArray["multiply"] = 9;
	blendModesArray["normal"] = 10;
	blendModesArray["overlay"] = 11;
	blendModesArray["screen"] = 12;
	blendModesArray["subtract"] = 13;
	
	displayObjectsArray["Dot"] = 0;
	displayObjectsArray["Line"] = 1;
	displayObjectsArray["RadialDot"] = 2;
	displayObjectsArray["Rect"] = 3;
	displayObjectsArray["Star"] = 4;
		
	_imagesList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onDoubleClickImagesList);
	_imagesList.addEventListener(ListEvent.ITEM_EDIT_END, onChangeImageName);
	_imagesList.addEventListener(ListEvent.CHANGE, onSelectImage);
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
}

private function onUpdateReferences(e:EditorEvent = null) : void
{
	renderer = fxManager.getRenderer();
	
	var type:String;
	if(renderer is PixelRenderer) type = "pixel";
	else if(renderer is DisplayObjectRenderer){ 
		type = "displayObject";
		var displayObjectInfo:XMLList = desc.effect.emitter[desc.emitterIndex]..ImageClass;
		var params:Array = [];
		for each(var node:XML in displayObjectInfo.children()){
			params.push(node.toString());
		}
		var blendMode:String = params.pop().toString();
		_displayObjectBlendMode.selectedIndex = blendModesArray[blendMode];
		var color:uint = Number(params.pop());
		_displayObjectColor.selectedColor = color;
		var name:String = params.shift().toString();
		_displayObjectComboBox.selectedIndex = displayObjectsArray[name];
		var val:Number = Number(params.shift());
		_displayObjectProp1.value = val;
		if(name == "Rect") _displayObjectProp2.value = Number(params[0]);
	}
	else{	//	bitmap renderer 
		type = "bitmap";
		if(bitmaps != fxManager.getBitmaps()){
			bitmaps = fxManager.getBitmaps();
			bitmapNames = fxManager.getBitmapNames();
			if(bitmaps.length > 0){
				selectedImage.bitmap = bitmaps[0];
				selectedImageName = bitmapNames[0];
			}
		}
		_imagesList.dataProvider = bitmapNames;
		_removeImage.enabled = bitmaps.length > 1 ? true : false;
	}
	onChooseRendererState(type);
}

private function onChooseRendererState(state:String) : void
{
	lastState = currentState;
	if(state == "bitmap"){
		currentState = "bitmap";
		_radioDisplayObject.enabled = true;
		_radioBitmap.selected = true;
		_radioBitmap.enabled = false;
		_radioPixel.enabled = true;
	}
	else if(state == "displayObject"){
		currentState = _displayObjectComboBox.selectedItem as String;
		_radioDisplayObject.selected = true;
		_radioDisplayObject.enabled = false;
		_radioPixel.enabled = true;
		_radioBitmap.enabled = true;
	}
	else if(state == "pixel") {
		currentState = "pixel";
		_radioDisplayObject.enabled = true;
		_radioBitmap.enabled = true;
		_radioPixel.selected = true;
		_radioPixel.enabled = false;
	}
}

private function onSelectRenderer(type:String) : void
{
	onChooseRendererState(type);
	if(type == "bitmap" && bitmapNames.length == 0) fxManager.addImage(img, "../assets/Moon-icon.png");
	else fxManager.setEffect(type);
}

private function onSelectDisplayObject() : void
{
	var displayObject:String = _displayObjectComboBox.selectedItem as String;
	currentState = displayObject;
	onUpdateDisplayObject();
}

private function onUpdateDisplayObject() : void
{
	var params:Array = [currentState, _displayObjectProp1.value, _displayObjectColor.selectedColor, _displayObjectBlendMode.selectedItem];
	if(currentState == "Rect") params.splice(1, 0, _displayObjectProp2.value);
	fxManager.changeDisplayObject(params);
}

private function onRemoveImage() : void
{
	if(imgIndex >= 0){
		fxManager.removeImage(imgIndex);
		bitmapNames.removeItemAt(imgIndex);
	}
}

private function onDoubleClickImagesList(e:ListEvent) : void
{
	_imagesList.editable = true;
	_imagesList.editedItemPosition = {columnIndex:0, rowIndex:e.rowIndex};
}

private function onChangeImageName(e:ListEvent) : void
{
	var index:int = e.rowIndex;
	var name:String = e.target.itemEditorInstance.text;
	fxManager.changeImageName(name, index);
	selectedImageName = bitmapNames[index];
	_imagesList.editable = false;
}

private function onSelectImage(e:ListEvent) : void
{
	imgIndex = e.rowIndex;
	selectedImage.bitmap = bitmaps[imgIndex];
	selectedImage.index = imgIndex;
	selectedImageName = bitmapNames[imgIndex];
	_imageBlendMode.selectedIndex = blendModesArray[bitmaps[imgIndex].blendMode];
}

private function onChooseBlendMode() : void
{
	var blendMode:String = _rendererBlendCombo.selectedItem.toString();
	BitmapRenderer(renderer).blendMode = blendMode;
	fxManager.setRendererBlendMode(blendMode);
	trace("Blend Mode chosen... " + blendMode);
}

private function onChooseImageBlendMode() : void
{
	if(renderer is DisplayObjectRenderer) onUpdateDisplayObject();
	else{
		var blendMode:String = _imageBlendMode.selectedItem.toString();
		if(selectedImage.bitmap) fxManager.changeImageBlendMode(selectedImage.index, blendMode);
		trace("Image " + selectedImage.index + " blendmode is " + blendMode);
	}
}

private function onAddImage() : void
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
	if(bitmapNames.length == 0){
		_radioBitmap.selected = false;
		_radioPixel.selected = true;
		if(lastState == "pixel") onSelectRenderer("pixel");
		else{
			currentState = lastState;
			onSelectRenderer("displayObject");
		}
	}
}

private function onImageLoaded(e:Event) : void 
{
	var bitmap:Bitmap = e.target.content;
	fxManager.addImage(bitmap, e.target.url);
	trace("Image successfully loaded");
}

private function onIOError(e:IOErrorEvent) : void
{
	Alert.show("IO Error\n\n" + e.text);
	_radioBitmap.selected = false;
	_radioPixel.selected = true;
	if(lastState == "pixel") onSelectRenderer("pixel");
	else{
		currentState = lastState;
		onSelectRenderer("displayObject");
	}
}