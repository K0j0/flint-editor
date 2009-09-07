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

package main.control
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import main.events.EditorEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.flintparticles.common.actions.Action;
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.counters.Counter;
	import org.flintparticles.common.counters.Pulse;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.initializers.AlphaInit;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.Initializer;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.initializers.ScaleImageInit;
	import org.flintparticles.common.initializers.SharedImages;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.initializers.RotateVelocity;
	import org.flintparticles.twoD.initializers.Rotation;
	import org.flintparticles.twoD.renderers.BitmapRenderer;
	import org.flintparticles.twoD.renderers.PixelRenderer;
	import org.flintparticles.twoD.zones.DiscSectorZone;
	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.lib.reflect.Constructor;
		
	public class FXManager extends EventDispatcher
	{	
		private static var instance:FXManager;
		private var desc:FXDescriptor;
		private var editor:FlintEditor;
		private var index:int = 0;	//	emitter index
		private var currentEmitter:Emitter2D;
		private var currentEmitters:Array = [];
		private var currentEmitterNames:ArrayCollection = new ArrayCollection([]);
		private var pixelEmitterNames:ArrayCollection = new ArrayCollection([]);
		private var bitmapEmitterNames:ArrayCollection = new ArrayCollection([]);
		private var pixelEmitters:Array = [];
		private var bitmapEmitters:Array = [];
		private var bitmapActionsGroup:Array = [];
		private var pixelActionsGroup:Array = [];
		private var currentActions:ArrayCollection;
		private var pixelFilters:ArrayCollection = new ArrayCollection([]);
		private var bitmapFilters:ArrayCollection = new ArrayCollection([]);
		private var currentFilters:ArrayCollection = new ArrayCollection([]);
		private var bitmapInitializersGroup:Array = [];
		private var pixelInitializersGroup:Array = [];
		private var currentInitializers:Array = [];
		private var currentBitmaps:Array = [];
		private var bitmapsGroup:Array = [currentBitmaps];
		private var currentBitmapNames:ArrayCollection = new ArrayCollection([]);
		private var bitmapNamesGroup:Array = [currentBitmapNames];
		private var renderer:BitmapRenderer;
		private var rendererBlendMode:String = "normal";
		private var rectangle:Rectangle;
		private var center:Point;
		
		public function FXManager(privateClass:PrivateClass, target:IEventDispatcher=null)
		{
			super(target);	
		}
		
		public static function getInstance() : FXManager
		{
			if(!instance)
			{
				instance = new FXManager(new PrivateClass());
			}
			return instance;
		}
		 
		 
		 public function setRendererBlendMode(value:String) : void
		 {
		 	rendererBlendMode = value;
		 	desc.rendererBlendMode = rendererBlendMode;
		 }
		 
		public function getEmitter() : Emitter2D
		{
			return currentEmitter;
		}
		
		public function getEmitterNames() : ArrayCollection
		{
			return currentEmitterNames;
		}
		
		public function getRenderer() : BitmapRenderer
		{ 
			return renderer;
		}
		
		public function getInitializers() : Array
		{
			return currentInitializers;
		}
		
		public function getBitmapNames() : ArrayCollection
		{
			return currentBitmapNames;
		}
		
		public function getAllBitmapNames() : Array
		{
			return bitmapNamesGroup;
		}
		
		public function getAllBitmaps() : Array
		{
			return bitmapsGroup;
		}
		
		public function getBitmaps() : Array
		{
			return currentBitmaps;
		}
		
		public function getActions() : ArrayCollection
		{
			return currentActions;
		}
		
		public function getFilters() : ArrayCollection
		{
			return currentFilters;
		}
		
		public function getCounterInfo() : Array
		{
			var counter:XML = desc.effect.emitter[index].counter.*[0];
			var params:Array = [counter.name().toString()];
			for each(var node:XML in counter.children()){
				params.push(Number(node.toString()))
			}			
			return params;
		}
		
		public function initialize(editor:FlintEditor, desc:FXDescriptor) : void
		//	creates default particle effects
		{
			this.editor = editor;
			this.desc = desc;
			rectangle = new Rectangle(0, 0,editor.canvas.width, editor.canvas.height)
			renderer = new PixelRenderer(rectangle);			
			center = new Point(rectangle.width/2, rectangle.height/2);
			
			currentEmitters = bitmapEmitters;
			desc.setEffect("bitmap");
			addEmitter();
			currentEmitters = pixelEmitters;
			desc.setEffect("pixel");
			addEmitter();
			setEffect("pixel");
		}
		
		public function setEffect(value:String, restart:Boolean = true) : void
		{
			clearEffect()
			renderer = null;
			if(value == "pixel"){
				currentEmitters = pixelEmitters;
				currentEmitterNames = pixelEmitterNames;
				currentFilters = pixelFilters;
				renderer = new PixelRenderer(rectangle);
			}
			else if(value == "bitmap"){
				currentEmitters = bitmapEmitters;
				currentEmitterNames = bitmapEmitterNames;
				currentFilters = bitmapFilters;
				renderer = new BitmapRenderer(rectangle);
			}
			renderer.blendMode = rendererBlendMode;
			desc.setEffect(value);
			if(restart){ 
				selectEmitter(0);
				restartEffect();
			}
			else{	//	restart is false when adding SharedImages
				selectEmitter(desc.emitterIndex);
			}
			var e:EditorEvent = new EditorEvent(EditorEvent.RENDERER_SWITCH);
			e.text1 = value;
			dispatchEvent(e);
		}
		
		public function refresh() : void
		{
			clearEffect();
			restartEffect();
		}
		
		public function clearEffect() : void
		{
			for each(var e:Emitter2D in currentEmitters){
				for each(var f:BitmapFilter in currentFilters){
					renderer.removeFilter(f);
				}
				e.stop();
				e.killAllParticles();
				renderer.removeEmitter(e);
			}
		}
		
		public function restartEffect() : void
		{
			for each(var e:Emitter2D in currentEmitters){
				e.start();
				renderer.addEmitter(e);
				for each(var f:BitmapFilter in currentFilters){
					renderer.addFilter(f);
				}
			}
		}
		
		public function pause() : void
		{
			for each(var e:Emitter2D in currentEmitters){
				if(e.running) e.pause();
				else e.resume();
			}
		}
		
		public function addEmitter() : void
		{
			var emitter:Emitter2D = new Emitter2D();
			currentEmitters.push(emitter);
			desc.addEmitter();
			
			var actions:ArrayCollection = new ArrayCollection([]);
			var initializers:Array = [];
			
			if(currentEmitters == pixelEmitters){
				pixelEmitterNames.addItem("emitter");
				emitter.counter = new Steady(2000);
				desc.setProperty("counter", ["Steady", 2000]);
				
				var move:Move = new Move();
				emitter.addAction(move);
				actions.addItem(move);
				desc.setProperty("actions", ["Move"]);
				var age:Age = new Age();
				emitter.addAction(age);
				actions.addItem(age);
				desc.setProperty("actions", ["Age"]);
				
				var alphaInit:AlphaInit = new AlphaInit(1, 1);
				emitter.addInitializer(alphaInit);
				desc.addInitializer(["AlphaInit", 1, 1]);
				initializers["AlphaInit"] = alphaInit;
				var colorInit:ColorInit = new ColorInit(0xff0000ff, 0xffffffff); 
				emitter.addInitializer(colorInit);
				initializers["ColorInit"] = colorInit;
				desc.addInitializer(["ColorInit", 0xff0000ff, 0xffffffff]);
				var lifeTime:Lifetime = new Lifetime(1,2);
				emitter.addInitializer(lifeTime);
				initializers["Lifetime"] = lifeTime;
				desc.addInitializer(["Lifetime", 1, 2]);
				var position:Position = new Position(new DiscSectorZone(center, 200, 0, 360, 0));
				emitter.addInitializer(position);
				initializers["Position"] = position;
				desc.addInitializer(["Position", "DiscSectorZone", "Point", editor.canvas.width/2, editor.canvas.height/2, 200, 0, 360, 0]);
				
				pixelActionsGroup.push(actions);
				pixelInitializersGroup.push(initializers);
			}
			else if(currentEmitters == bitmapEmitters){
				bitmapEmitterNames.addItem("emitter");
				emitter.counter = new Pulse(1, 30);
				desc.setProperty("counter",["Pulse", 1, 30]);
				
				currentActions = bitmapActionsGroup[0];
				move = new Move();
				emitter.addAction(move);
				actions.addItem(move);
				desc.setProperty("actions", ["Move"]);
				age = new Age();
				emitter.addAction(age);
				actions.addItem(age);
				desc.setProperty("actions", ["Age"]);
				
				alphaInit = new AlphaInit(1, 1);
				emitter.addInitializer(alphaInit);
				initializers["AlphaInit"] = alphaInit;
				desc.addInitializer(["AlphaInit", 1, 1]);
				colorInit = new ColorInit(0xffff0000, 0xffffffff);
				emitter.addInitializer(colorInit);
				initializers["ColorInit"] = colorInit;
				desc.addInitializer(["ColorInit", 0xffff0000, 0xffffffff]);
				lifeTime = new Lifetime(.5,1);
				emitter.addInitializer(lifeTime);
				initializers["Lifetime"] = lifeTime;
				desc.addInitializer(["Lifetime", .5, 1]);
				position = new Position(new DiscSectorZone(center,100, 0, 360, 0));
				emitter.addInitializer(position);
				initializers["Position"] = position;
				desc.addInitializer(["Position", "DiscSectorZone", "Point", editor.canvas.width/2, editor.canvas.height/2, 100, 0, 360, 0]);
				var rotation:Rotation = new Rotation(0, 0);
				emitter.addInitializer(rotation);
				initializers["Rotation"] = rotation;
				desc.addInitializer(["Rotation", 0, 0]);
				var rotateVelocity:RotateVelocity = new RotateVelocity(0, 0);
				emitter.addInitializer(rotateVelocity);
				initializers["RotateVelocity"] = rotateVelocity;
				desc.addInitializer(["RotateVelocity", 0, 0]);
				var scaleImageInit:ScaleImageInit = new ScaleImageInit(1, 1);
				emitter.addInitializer(scaleImageInit);
				initializers["ScaleImageInit"] = scaleImageInit;
				desc.addInitializer(["ScaleImageInit", 1, 1]);
				
				bitmapActionsGroup.push(actions);
				bitmapInitializersGroup.push(initializers);

				if(currentBitmaps.length > 0){
					var images:Array = [];
					var imageNames:ArrayCollection = new ArrayCollection(currentBitmapNames.toArray());
					for each(var b:Bitmap in currentBitmaps){
						var bmp:Bitmap = new Bitmap(b.bitmapData.clone());
						images.push(bmp);
					}
					bitmapsGroup.push(images);
					bitmapNamesGroup.push(imageNames);
					var sharedImages:SharedImages = new SharedImages(images);
					initializers["SharedImages"] = sharedImages;
					emitter.addInitializer(sharedImages);
				}
			}
			selectEmitter(currentEmitters.length - 1);
		}
		
		public function removeEmitter(index:int) : void
		{
			clearEffect();
			currentEmitters.splice(index, 1);
			currentEmitterNames.removeItemAt(index);
			if(currentEmitters == pixelEmitters){
				pixelActionsGroup.splice(index, 1);
				pixelInitializersGroup.splice(index, 1);
			}
			else if(currentEmitters == bitmapEmitters){
				bitmapActionsGroup.splice(index, 1);
				bitmapInitializersGroup.splice(index, 1);
				bitmapsGroup.splice(index, 1);
				bitmapNamesGroup.splice(index, 1);
			}
			
			if(index == currentEmitters.length) index--;
			selectEmitter(index);
			restartEffect();
		}
		
		public function changeEmitterNames(name:String, index:int) : void
		{
			desc.nameEmitter(name, index);
			currentEmitterNames.addItemAt(name, index);
			currentEmitterNames.removeItemAt(++index);
		}
		
		public function selectEmitter(index:int) : void
		{
			currentEmitter = currentEmitters[index];
			desc.emitterIndex = index;
			if(currentEmitters == pixelEmitters){
				currentInitializers = pixelInitializersGroup[index];
				currentActions = pixelActionsGroup[index];				
			}
			else if(currentEmitters == bitmapEmitters){
				currentInitializers = bitmapInitializersGroup[index];
				currentActions = bitmapActionsGroup[index];
				currentBitmaps = bitmapsGroup[index];
				currentBitmapNames = bitmapNamesGroup[index];
			}			
			dispatchEvent(new EditorEvent(EditorEvent.UPDATE_REFERENCES));
		}
		
		public function setCounter(c:Counter, params:Array) : void
		{
			clearEffect();
			currentEmitter.counter = c;
			desc.setProperty("counter", params);
			restartEffect();
		}
		
		public function addImage(bmp:Bitmap) : void
		{
			setEffect("bitmap", false);
			currentBitmaps.push(bmp);
			var sharedImages:SharedImages =  currentInitializers["SharedImages"];
			if(sharedImages) currentEmitter.removeInitializer(sharedImages)
			sharedImages = new SharedImages(currentBitmaps);
			currentInitializers["SharedImages"] = sharedImages;
			currentEmitter.addInitializer(sharedImages);
			desc.addImage(bmp, "bitmap");
			setEffect("bitmap");
		}
		
		public function removeImage(index:int) : void
		{
			clearEffect();
			currentBitmaps.splice(index, 1);
			var sharedImages:SharedImages =  currentInitializers["SharedImages"];
			if(sharedImages) currentEmitter.removeInitializer(sharedImages)
			sharedImages = new SharedImages(currentBitmaps);
			currentInitializers["SharedImages"] = sharedImages;
			currentEmitter.addInitializer(sharedImages);
			desc.removeImage(index);
			setEffect("bitmap");		
		}
		
		public function changeImageName(name:String, index:int) : void
		{
			currentBitmapNames.addItemAt(name, index);
			desc.editImageProperties(index, "name", name);
			currentBitmapNames.removeItemAt(++index);
		}
		
		public function changeImageBlendMode(index:int, blendMode:String) : void
		{
			currentBitmaps[index].blendMode = blendMode;
			desc.editImageProperties(index, "blendMode", blendMode);
		}
		
		public function generateImages(bytes:ByteArray) : void
		{
			var bitmaps:Array = [];
			var bitmapNamesGroup:Array = [];
			var effect:XML = desc.effect;
			var outer:int = effect.child("emitter").length();
			for(var j:int = 0; j < outer; j++){
				var inner:int = effect.child("emitter")[j].initializers.SharedImages.children().length();
				var imageArray:Array = [];
				var bitmapNames:ArrayCollection = new ArrayCollection([]);
				var images:XMLList = effect.child("emitter")[j].initializers.SharedImages.children();
				for(var i:int = 0; i < inner; i++){
					var image:XML = images[i];
					var len:int = int(image.@length);
					var width:int = int(image.@width);
					var height:int = int(image.@height);
					var name:String = image.@name;
					bitmapNames.addItem(name);
					var imgBytes:ByteArray = new ByteArray();
					bytes.readBytes(imgBytes, 0, len);
					imgBytes.uncompress(CompressionAlgorithm.DEFLATE);
					var rect:Rectangle = new Rectangle(0, 0, width, height);
					var bData:BitmapData = new BitmapData(width, height);
					bData.setPixels(rect, imgBytes);
					var bmp:Bitmap = new Bitmap(bData);
					bmp.blendMode = image.@blendMode;
					imageArray.push(bmp);
				}
				bitmaps.push(imageArray);
				bitmapNamesGroup.push(bitmapNames);
				var emitter:Emitter2D = bitmapEmitters[j];
				var sharedImages:SharedImages = new SharedImages(imageArray);
				emitter.addInitializer(sharedImages);
			}
			currentBitmaps = imageArray;
			bitmapsGroup = bitmaps;
			this.bitmapNamesGroup = bitmapNamesGroup;
			currentBitmapNames = bitmapNames;
			setEffect("bitmap");
		}
		
		public function generateEffect(type:String) : void
		{
			var effect:XML = desc.effect;
			var eLen:int = effect.emitter.length();
			var emitters:Array = [];
			var emitterNames:Array = [];
			var currentActionsGroup:Array;
			var currentInitializersGroup:Array;
			var newFilters:ArrayCollection;
			if(type == "pixel"){
				pixelEmitters = emitters;
				pixelEmitterNames.source = emitterNames;
				currentActionsGroup = pixelActionsGroup = [];
				currentInitializersGroup = pixelInitializersGroup = [];
				pixelFilters = newFilters = new ArrayCollection([]);
			}
			else if(type == "bitmap"){ 
				bitmapEmitters = emitters;
				bitmapEmitterNames.source = emitterNames;
				currentActionsGroup = bitmapActionsGroup = [];
				currentInitializersGroup = bitmapInitializersGroup = [];
				bitmapFilters = newFilters = new ArrayCollection([]);
			}
			
			for(var j:int = 0; j < eLen; j++){
				var emitter:Emitter = new Emitter2D();
				//	set emitter name
				var name:String = effect.emitter[j].@name;
				emitterNames.push(name);
				
				//	set counter
				var counter:XML = effect.emitter[j].counter[0].*[0];
				name = counter.name();
				var ci:ClassInfo = ClassInfo.forName("org.flintparticles.common.counters." + name);
				var params:Array = [];
				for each(var param:XML in counter.children()){
					var num:int = int(param.toString());
					params.push(num);
				}
				var con:Constructor = ci.getConstructor();
				var c:Counter = con.newInstance(params);
				emitter.counter = c;
				
				//	get actions
				var actions:XMLList = effect.emitter[j].actions;
				var currentActions:ArrayCollection = new ArrayCollection([]);
				for each(var node:XML in actions[0].children()){
					name = node.name();
					try{
						ci = ClassInfo.forName("org.flintparticles.common.actions." + name);
					} catch(e:ReferenceError) {
						ci = ClassInfo.forName("org.flintparticles.twoD.actions." + name);
					}
					params = [];
					for each(param in node.children()){
						num = int(param.toString());
						params.push(num);
					}  
					con = ci.getConstructor(); 
					var a:Action = con.newInstance(params);
					emitter.addAction(a);
					currentActions.addItem(a);
				}
				currentActionsGroup.push(currentActions);
				
				//	get initializers
				var initializers:XMLList = effect.emitter[j].initializers;
				var currentInitializers:Array = [];
				for each(node in initializers[0].children()){
					if(node.name() == "SharedImages") continue;
					var initializer:Initializer = func(node);
					emitter.addInitializer(initializer);
					currentInitializers[node.name()] = initializer;
				}
				currentInitializersGroup.push(currentInitializers);
				emitters.push(emitter);
			}
			
			//	get filters
				var filters:XMLList = effect.filters;
				for each(node in filters[0].children()){
					name = node.name();
					try{
						ci = ClassInfo.forName("flash.filters." + name);
					} catch(e:ReferenceError) {}
					params = [];
					for each(param in node.children()){
						num = int(param.toString());
						params.push(num);
					}  
					con = ci.getConstructor(); 
					var f:BitmapFilter = con.newInstance(params);
					newFilters.addItem(f);
				}
			
			function func(node:XML) : * {
				var name:String = node.name();
				if(name == "param"){
					var num:Number = Number(node.toString());
					return num;
				}
				if(/zone/i.test(name)) ci = ClassInfo.forName("org.flintparticles.twoD.zones." + name);
				else if(/point/i.test(name)) var ci:ClassInfo = ClassInfo.forName("flash.geom.Point");
				else{
					try{
						ci = ClassInfo.forName("org.flintparticles.common.initializers." + name);
					} catch(e:ReferenceError) {
						ci = ClassInfo.forName("org.flintparticles.twoD.initializers." + name);
					}
				}
				var params:Array = [];
				for each(var param:XML in node.children()){
					params.push(func(param));
				}
				var con:Constructor = ci.getConstructor();
				return con.newInstance(params);
			}
			rendererBlendMode = effect.blendMode.toString();
			if(type == "pixel") setEffect(type);
			else if(type == "bitmap") setEffect(type, false);
		}
		
		public function addInitializer(i:Initializer, params:Array) : void
		{
			currentEmitter.addInitializer(i);
			var name:String = params[0];
			currentInitializers[name] = i;
			desc.addInitializer(params);
		}
		
		public function removeInitializer(name:String) : void
		{
			var initializer:Initializer = currentInitializers[name];
			currentInitializers[name] = null;
			currentEmitter.removeInitializer(initializer);
			desc.removeInitializer(name);
		}
		
		public function updateInitializer(name:String, params:Array) : void
		{
			desc.removeInitializer(name);
			desc.addInitializer(params);
		}
		
		public function addAction(a:Action, params:Array) : void
		{
			currentEmitter.addAction(a);
			currentActions.addItem(a);
			desc.setProperty("actions", params);
		}
		
		public function removeAction(index:int) : void
		{
			var action:Action = currentActions.removeItemAt(index) as Action;
			currentEmitter.removeAction(action);
			desc.removeAction(index);
		}
		
		public function addFilter(f:BitmapFilter, params:Array) : void
		{
			currentFilters.addItem(f);
			desc.addFilter(params);
			renderer.addFilter(f, false);
		}
		
		public function removeFilter(index:int) : void
		{
			desc.removeFilter(index);
			renderer.removeFilter(currentFilters[index]);
			currentFilters.source.splice(index, 1);
		}
	}
}

class PrivateClass
{
	public function PrivateClass() {}
}