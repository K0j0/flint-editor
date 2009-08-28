
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

import main.control.FXManager;
import main.events.EditorEvent;

import mx.collections.ArrayCollection;
import mx.events.ListEvent;

import org.flintparticles.twoD.renderers.BitmapRenderer;

private var fxManager:FXManager;
private var renderer:BitmapRenderer;
private var bitmap:Bitmap;
private var bitmaps:Array;
private var bitmapNames:ArrayCollection;
private var imgIndex:int = -1;
[Bindable]
private var selectedImage:String = "n/a";
private var blendModesArray:Array = [];

public function init() : void
{
	fxManager = FXManager.getInstance();
	
	_imagesList.dataProvider = bitmapNames;
	_rendererBlendCombo.dataProvider = ["add", "alpha", "darken", "difference", 
		"erase", "hardlight", "invert", "layer", "lighten", "multiply", "normal", 
		"overlay", "screen", "subtract"];
	_imageBlendMode.dataProvider = ["add", "alpha", "darken", "difference", 
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
		
	_imagesList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onDoubleClickImagesList);
	_imagesList.addEventListener(ListEvent.ITEM_EDIT_END, onChangeImageName);
	_imagesList.addEventListener(ListEvent.CHANGE, onSelectImage);
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
}

private function onUpdateReferences(e:EditorEvent) : void
{
	renderer = fxManager.getRenderer();
	bitmaps = fxManager.getBitmaps();
	bitmapNames = fxManager.getBitmapNames();
	_imagesList.dataProvider = bitmapNames;
	_removeImage.enabled = bitmaps.length > 1 ? true : false;
}

private function onSelectRenderer(type:String) : void
{
	if(type == "bitmap"){
		_radioBitmap.enabled = false;
		_radioPixel.enabled = true;
		currentState = "bitmap";
		if(bitmapNames.length == 0) onAddImage();
		else{
			fxManager.setEffect("bitmap");
		}
	}
	else if(type == "pixel") {
		_radioBitmap.enabled = true;
		_radioPixel.enabled = false;
		currentState = "pixel";
		fxManager.setEffect("pixel");
	}
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
	var name:String = e.itemRenderer.data.toString();
	fxManager.changeImageName(name, index);
	_imagesList.editable = false;
}

private function onSelectImage(e:ListEvent) : void
{
	imgIndex = e.rowIndex;
	bitmap = bitmaps[imgIndex];
	selectedImage = bitmapNames[imgIndex];
	_imageBlendMode.selectedIndex = blendModesArray[bitmaps[imgIndex].blendMode];
}

private function onChooseBlendMode() : void
{
	var blendMode:String = _rendererBlendCombo.selectedItem.toString();
	renderer.blendMode = blendMode;
	fxManager.setRendererBlendMode(blendMode);
	trace("Blend Mode chosen... " + blendMode);
}

private function onChooseImageBlendMode() : void
{
	var blendMode:String = _imageBlendMode.selectedItem.toString();
	if(bitmap) bitmap.blendMode = blendMode;
	trace("Image " + _imagesList.selectedIndex + " blendmode is " + blendMode);
}

private function onAddImage() : void
{
	var file:File = new File();
	file.browseForOpen("Choose Image");
	file.addEventListener(Event.SELECT, onSelectFile);
	file.addEventListener(Event.CANCEL, onCancel);
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
		onSelectRenderer("pixel");
	}
}

private function onImageLoaded(e:Event) : void 
{
	var bitmap:Bitmap = e.target.content;
	bitmapNames.addItem("bitmap");
	fxManager.addImage(bitmap);
	trace("Image successfully loaded");
}

private function onIOError(e:IOErrorEvent) : void
{
	trace("IO Error!!!");
	_radioBitmap.selected = false;
	_radioPixel.selected = true;
	fxManager.setEffect("pixel");
}