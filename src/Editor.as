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
import main.model.FXDescriptor;
import main.model.FXManager;
import main.utils.checkgroup.views.MouseControl;
import main.views.ClassTextCanvas;

import mx.containers.Canvas;
import mx.events.MenuEvent;

import org.flintparticles.common.renderers.Renderer;
import org.flintparticles.twoD.renderers.DisplayObjectRenderer;

//private var currentFile:File = new File();
private var fxManager:FXManager;
private var desc:FXDescriptor;
private var renderer:Renderer;
private var classText:ClassTextCanvas = new ClassTextCanvas();
private var menuXML:XML = 
									<application>
										<File label="File">
											<menuItem label="Save" enabled="false"/>
											<menuItem label="Save As" enabled="false"/>
											<menuItem label="Load" enabled="false"/>
											<menuItem label="Generate Class"/>
										</File>
										<Effect label="Effect">
											<menuItem label="Pause"/>
											<menuItem label="Refresh"/>
										</Effect>
									</application>;

private function init() : void
{
	trace("Lez go");
	_mainCanvas.scrollRect = new Rectangle(0,0, _mainCanvas.width, _mainCanvas.height);

	_appMenuBar.showRoot = false;
	_appMenuBar.dataProvider = menuXML;
	_appMenuBar.addEventListener(MenuEvent.ITEM_CLICK, onSelectMenu);

	var mouseControl:MouseControl = MouseControl.getInstance();
	mouseControl.canvas = _mainCanvas;
	desc = FXDescriptor._instance
	fxManager = FXManager._instance;
	fxManager.addEventListener(EditorEvent.RENDERER_SWITCH, onRendererSwitch);
	fxManager.addEventListener(EditorEvent.UPDATE_REFERENCES, onUpdateReferences);
	fxManager.initialize(this, desc);	
}

private function onReady(e:EditorEvent) : void
{	
	onUpdateReferences();
	fxManager.restartEffect();
}

private function onUpdateReferences(e:EditorEvent = null) : void
{
	renderer = fxManager.getRenderer();
	_mainCanvas.rawChildren.addChild(renderer as DisplayObject);
}

private function onRendererSwitch(e:EditorEvent) : void
{
	if(renderer is DisplayObjectRenderer){
		if(acfTab.contains(Filters)) acfTab.removeChild(Filters);
	}
	else{
		acfTab.addChild(Filters);
	}
}

public function get canvas () : Canvas
{
	return _mainCanvas;
}

private function onSelectMenu(e:MenuEvent) : void
{
	var choice:String = e.label;
	trace(choice);
	switch(e.label)
	{
		case "Save" :
			onSave();
		break;
		case "Save As" :
			onSaveAs();
		break;
		case "Load" :
			onLoad();
		break;
		case "Generate Class" :
			onGenerateClass();
		break;
		case "trace" :
			trace(desc.effect);
		break;
		case "Pause" :
			fxManager.pause();
		break;
		case "Refresh" :
			fxManager.refresh();
		break;
	} 
}

private function onSave() : void
{	
	/* 
	var bytes:ByteArray = desc.generateBytes();	
	var stream:FileStream = new FileStream();
	stream.open(currentFile, FileMode.WRITE);
	stream.writeBytes(bytes);
	stream.close();	
	 */
}

private function onSaveAs() : void
{	
	/* 
	var bytes:ByteArray = desc.generateBytes();
	currentFile.browseForSave("Save Effect");
	currentFile.addEventListener(Event.SELECT, saveData);
	
	function saveData(e:Event) : void {
		var pattern:RegExp = /\.particle/;
		if(!pattern.test(currentFile.url)) currentFile.url += ".particle";
		
		var stream:FileStream = new FileStream();
		stream.open(currentFile, FileMode.WRITE);
		stream.writeBytes(bytes);
		stream.close();
		menuXML.File.menuItem[1].@enabled = true;
	}
	 */
}

private function onLoad() : void
{
	/* 
	var file:File = new File();
	file.browseForOpen("Open Effect", [new FileFilter("particle effects", "*.particle")]);
	file.addEventListener(Event.SELECT, loadData);
	
	function loadData(e:Event) : void {
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		var type:String = stream.readUTFBytes(1);
		fxManager.clearEffect();
		
		if(type == "p"){
			var effect:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
			desc.effectLoaded("pixel", effect);
			fxManager.generateEffect("pixel");
			trace(effect);
		}
		else if(type == "d"){
			effect = XML(stream.readUTFBytes(stream.bytesAvailable));
			desc.effectLoaded("displayObject", effect);
			fxManager.generateEffect("displayObject");
			trace(effect);
		}
		else if(type == "b"){	
			var len:int = stream.readInt();
			effect = XML(stream.readUTFBytes(len));
			desc.effectLoaded("bitmap", effect);
			
			var bytes:ByteArray = new ByteArray();
			stream.readBytes(bytes);
			fxManager.generateEffect("bitmap");
			fxManager.generateImages(bytes);
			trace(effect);
		}
		else{
			Alert.show("Error Loading Particle Effect. File may be corrupted", "ERROR");
			return;
		}
	}
	 */
}

private function onGenerateClass() : void
{
	addChild(classText);
	classText.classText.text = desc.generateClass();
	/* 
	var file:File = new File();
	file.browseForSave("Export .as Class");
	file.addEventListener(Event.SELECT, onSaveData);
	
	function onSaveData() : void {
		var pattern:RegExp = /\.as/;
		if(!pattern.test(file.url)) file.url += ".as";
		
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.WRITE);
		stream.writeUTFBytes(desc.generateClass());
		stream.close();
	}
	 */
}