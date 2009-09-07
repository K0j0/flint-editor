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
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import org.spicefactory.lib.reflect.ClassInfo;
	
	public class FXDescriptor
	{
		private var fxManager:FXManager;
		private var pixelEffect:XML = 
									<effect type="pixel">
										<filters />
										<blendMode>normal</blendMode>
									</effect>;
		private var bitmapEffect:XML = 
									<effect type="bitmap">
										<filters />
										<blendMode>normal</blendMode>
									</effect>;
		private var currentEffect:XML;
		private var eIndex:int = 0;	//	emitter index
		
		public function FXDescriptor()
		{
			fxManager = FXManager.getInstance();			
		}
		
		public function get effect() : XML
		{
			return currentEffect;
		}
		
		public function set emitterIndex(value:int) : void
		{
			eIndex = value;
		}
		
		public function get emitterIndex() : int
		{
			return eIndex;
		}
		
		public function set rendererBlendMode(value:String) : void
		{
			currentEffect.blendMode = value;
		}
		
		public function addEmitter() : void
		{
			var emitterNode:XML;
			if(currentEffect.@type == "pixel"){
				emitterNode =
								<emitter name="emitter">
									<counter />
									<initializers />
									<actions />									
								</emitter>;				
			}
			else if(currentEffect.@type == "bitmap"){
				emitterNode =
								<emitter name="emitter">
									<counter />
									<initializers>
										<SharedImages />
									</initializers>
									<actions />									
								</emitter>;
				var emitterCount:int = effect.emitter.length();
				if(emitterCount > 0){
					var sharedImages:XML = currentEffect.emitter[emitterCount-1].initializers.SharedImages[0];
					emitterNode.initializers.SharedImages = sharedImages;
				}		
			}
			
			currentEffect.appendChild(emitterNode);
			eIndex = effect.emitter.length() - 1;
		}
		
		public function removeEmitter(index:int) : void
		{
			delete currentEffect.emitter[index];
		}
		
		public function nameEmitter(name:String, index:int) : void
		{
			currentEffect.emitter[index].@name = name;
		}
		
		public function setEffect(type:String) : void
		{
			if(type == "pixel") currentEffect = pixelEffect;
			else if(type == "bitmap") currentEffect = bitmapEffect;
			eIndex = 0;
		}
		
		public function addInitializer(params:Array) : void
		{
			var name:String = params.shift();
			var property:XML = <{name} />;
			if(/zone/i.test(params[0].toString())){
				var zone:XML = <{params.shift().toString()}/>;
				while(params.length > 0){
					if(/point/i.test(params[0].toString())){
						params.shift();
						var point:XML = <Point>
											<param>{params.shift()}</param>
											<param>{params.shift()}</param>
										</Point>;
						zone.appendChild(point);
					}
					else{
						zone.appendChild(<param>{params.shift()}</param>);
					}
				}
				property.appendChild(zone);
			}
			else{
				for(var j:int = 0; j < params.length; j++){
					property.appendChild(<param>{params[j]}</param>);
				}
			}
			currentEffect.emitter[eIndex].initializers.appendChild(property);
		}
		
		public function removeInitializer(name:String) : void
		{
			delete currentEffect.emitter[eIndex].initializers.child(name)[0];
		}
		
		public function addImage(bitmap:Bitmap, path:String) : void
		{
			var rect:Rectangle = new Rectangle(0, 0, bitmap.width, bitmap.height);
			var imageBytes:ByteArray = bitmap.bitmapData.getPixels(rect);
			imageBytes.compress(CompressionAlgorithm.DEFLATE);
			var image:XML = <image />;
			image.@length = imageBytes.length;
			image.@width = bitmap.width;
			image.@height = bitmap.height;
			image.@blendMode = bitmap.blendMode;
			image.@name = "bitmap";
			image.@path = path;
			currentEffect.emitter[eIndex].initializers.SharedImages.appendChild(image);
			imageBytes = null;
		}
		
		public function removeImage(index:int) : void
		{
			delete currentEffect.emitter[eIndex].initializers.SharedImages.*[index];
		}
		
		public function editImageProperties(index:int, prop:String, val:String) : void
		{
			var image:XML = currentEffect.emitter[eIndex].initializers.SharedImages.*[index];
			if(prop == "name") image.@name = val;
			else if(prop == "blendMode") image.@blendMode = val;
		}
		
		public function setProperty(type:String, params:Array) : void
		//	used to set counters and add actions
		{
			if(type == "counter") delete currentEffect.emitter[eIndex].counter.*[0];
			var name:String = params.shift();
			var property:XML = <{name} />;
			for(var j:int = 0; j < params.length; j++){
				property.appendChild(<param>{params[j]}</param>);
			}
			currentEffect.emitter[eIndex].child(type).appendChild(property);
		}
		
		public function removeAction(index:int) : void
		{
			delete currentEffect.emitter[eIndex].actions.*[index];
		}
		
		public function addFilter(params:Array) : void
		{
			var name:String = params.shift();
			var filter:XML = <{name} />;
			for(var j:int = 0; j < params.length; j++){
				filter.appendChild(<param>{params[j]}</param>);
			}
			currentEffect.filters.appendChild(filter);
		}
		
		public function removeFilter(index:int) : void
		{
			delete currentEffect.filters.*[index];
		}
		
		public function generateBytes() : ByteArray
		{
			var savedEffect:XML = currentEffect.copy();
			var bytes:ByteArray = new ByteArray();
			if(currentEffect == bitmapEffect){
				bytes.writeUTFBytes("b");
				var imgBytes:ByteArray = new ByteArray();
				var bitmaps:Array = fxManager.getAllBitmaps();
				var bitmapNames:Array = fxManager.getAllBitmapNames();
				for(var j:int = 0; j < bitmaps.length; j++){
					emitterIndex = j;
					var currentBitmaps:Array = bitmaps[j];
					for(var i:int = 0; i < currentBitmaps.length; i++){
						var bmp:Bitmap = currentBitmaps[i];
						var rect:Rectangle = new Rectangle(0, 0, bmp.width, bmp.height);
						var currentImgBytes:ByteArray = bmp.bitmapData.getPixels(rect);
						currentImgBytes.compress(CompressionAlgorithm.DEFLATE);
						imgBytes.writeBytes(currentImgBytes);
					}
				}
				bytes.writeInt(savedEffect.toXMLString().length);
				bytes.writeUTFBytes(savedEffect.toXMLString());
				bytes.writeBytes(imgBytes);
			}
			else{
				bytes.writeUTFBytes("p");
				bytes.writeUTFBytes(savedEffect.toXMLString());
			}
			return bytes;
		}
		
		public function effectLoaded(type:String, effect:XML) : void
		{
			if(type == "pixel"){
				pixelEffect = effect;
			}
			else if(type == "bitmap"){
				bitmapEffect = effect;
			}
			setEffect(type);
		}
		
		public function generateClass() : String
		{
			var imports:Array = ["flash.display.Sprite;", "org.flintparticles.twoD.emitters.Emitter2D;"];
			var particleClass:String = "";
			var emittersArray:Array = [];
			
			for each(var emitter:XML in currentEffect.emitter){				
				//	set emitter
				var emitterName:String = emitter.@name;
				var emitterString:String = "var " + emitterName + ":Emitter2D = new Emitter2D();\n";
				emittersArray.push(emitterName);
				particleClass += emitterString;
				
				//	get counter
				var counter:XML = emitter.counter.*[0];
				var name:String = counter.name();
				var counterName:String = emitterName + "_counter";
				imports.push("org.flintparticles.common.counters." + name);
				var counterString:String = "var " + emitterName + "_" + "counter:" + name + " = new " + name + "(";
				var params:String = "";
				var len:int = counter.children().length();
				for(var j:int = 0; j < len; j++){
					params += counter.*[j].toString();
					if(j < len-1) params += ",";
				}
				counterString += params + ");\n";
				particleClass += counterString + emitterName + ".counter = " + counterName +";\n\n";
				
				var ci:ClassInfo;
				//	get actions
				var actions:XML = emitter.actions[0];
				var allActionsString:String = "";
				var actionsArray:Array = [];
				len = actions.children().length();
				for(j = 0; j < len; j++){
					var actionName:String =  emitterName + "_action" + j;
					actionsArray.push(actionName);
					var action:XML = actions.*[j];
					name = action.name();
					try{
						ci = ClassInfo.forName("org.flintparticles.common.actions." + name);
						imports.push("org.flintparticles.common.actions." + name + ";");
					} catch(e:ReferenceError){
						imports.push("org.flintparticles.twoD.actions." + name + ";");
					}
					var actionString:String = "var " + actionName + ":" + name + " = new " + name + "(";
					params = "";
					var paramLen:int = action.children().length();
					for(var i:int = 0; i < paramLen; i++){
						params += action.*[i].toString();
						if(i < paramLen - 1) params += ",";
					}
					actionString += params + ");\n";
					allActionsString += actionString;
				}
				particleClass += allActionsString;
				for each(var s:String in actionsArray){
					particleClass += emitterName + ".addAction(" + s + ");\n";
				}
				particleClass += "\n";
				
				//	get initializers
				var initializers:XML = emitter.initializers[0];
				var allInitializers:String = "";
				var initializersArray:Array = [];
				len = initializers.children().length();
				for(j = 0; j < len; j++){
					var initializer:XML = initializers.*[j];
					name = initializer.name();
					if(name == "SharedImages") continue;
					var initializerName:String = emitterName + "_initializer" + j;
					initializersArray.push(initializerName);
					var initializerString:String = "var " + initializerName + ":" + name + " = ";
					params = "";
					func(initializer);
					initializerString += params + ";\n";
					allInitializers += initializerString;
					
					function func(node:XML) : void {
						name = node.name();
						if(/param/i.test(name)){
							params += node.toString();
						}
						else{
							if(/point/i.test(name)){
								imports.push("flash.geom.Point");
							}
							else if(/zone/i.test(name)){
								imports.push("org.flintparticles.twoD.zones." + name);
							}
							else {
								try{
									ci = ClassInfo.forName("org.flintparticles.common.initializers." + name);
									imports.push("org.flintparticles.common.initializers." + name + ";");
								} catch(e:ReferenceError){
									imports.push("org.flintparticles.twoD.initializers." + name + ";");
								}
							}
							params += "new " + name + "(";
							var len:int = node.children().length();
							for(var k:int = 0; k < len; k++){
								func(node.*[k]);
								if(k < len - 1) params += ",";
							}
							params += ")";
						}
					}
				}
				particleClass += allInitializers;
				for each(s in initializersArray){
					particleClass += emitterName + ".addInitializer(" + s + ");\n";
				}
				//	get images
				if(currentEffect == bitmapEffect){
					imports.push("flash.display.Bitmap;");
					imports.push("org.flintparticles.common.initializers.SharedImages;");
					var sharedImages:XML = emitter.initializers.SharedImages[0];
					var embedString:String = "";
					var sharedImagesParams:String = "";
					len = sharedImages.children().length();
					for(j = 0; j < len; j++){
						var image:XML = sharedImages.*[j];
						embedString += "\n[Embed (source=\"" + image.@path + "\")]\nprivate var imgClass_" + emitterName + "_" + j
						 + ":Class;\nprivate var " + image.@name + "_" + emitterName + "_" + j + ":Bitmap = new imgClass_" + emitterName + "_" + j
						 + "();\n";
						 particleClass += image.@name + "_" + emitterName + "_" + j + ".blendMode = " + "\"" + image.@blendMode + "\";\n";
						 sharedImagesParams += image.@name + "_" + emitterName + "_" + j;
						 if(j < len-1) sharedImagesParams += ",";
					}
					particleClass += emitterName + ".addInitializer(new SharedImages([" + sharedImagesParams + "]));\n";
				}
				particleClass += "\n";
			}
			//	set renderer
			if(currentEffect == pixelEffect){
				var rendererString:String = "var renderer:PixelRenderer = new PixelRenderer(new Rectangle(0, 0, 530, 430));\n";
				imports.push("org.flintparticles.twoD.renderers.PixelRenderer;");
			}
			else if(currentEffect == bitmapEffect){
				rendererString = "var renderer:BitmapRenderer = new BitmapRenderer(new Rectangle(0, 0, 530, 430));\n";
				imports.push("org.flintparticles.twoD.renderers.BitmapRenderer;");
			}
			particleClass += rendererString + "\n";
			imports.push("flash.geom.Rectangle;");
			
			for each(s in emittersArray){
				particleClass += "renderer.addEmitter(" + s + ");\n";
			}
			particleClass += "\n";
			for each(s in emittersArray){
				particleClass += s + ".start();\n";
			}
			particleClass += "\n";
			
			//	get filters
			var filters:XML = currentEffect.filters[0];
			var allFiltersString:String = "";
			var addFilterString:String = "";
			len = filters.children().length();
			for(j = 0; j < len; j++){
				var filter:XML = filters.*[j];
				name = filter.name();
				imports.push("flash.filters." + name);
				var filterString:String = "var filter" + j + ":" + name + " = new " + name + "(";
				params = "";
				paramLen = filter.children().length();
				for(i = 0; i < paramLen; i++){
					params += filter.*[i].toString();
					if(i < paramLen - 1) params += ",";
				}
				filterString += params + ");\n";
				allFiltersString += filterString;
				addFilterString += "renderer.addFilter(filter" + j + ");\n";
			}
			particleClass += allFiltersString + "\n";
			particleClass += addFilterString;
			particleClass += "addChild(renderer);\n";
			
			var importsString:String = "";
			imports.sort(Array.CASEINSENSITIVE);
			len = imports.length;
			for(j = 0; j < len-1; j++){
				if(imports[j] == imports[j+1]){ 
					imports.splice(j,1);
					len--;
				}
			}
			for each(s in imports){
				importsString += "import " + s + "\n";
			}
			particleClass = "package\n{\n" + importsString + "\npublic class ParticleEffect extends Sprite\n{\n" +
					embedString + "\npublic function ParticleEffect() : void\n{\n" + particleClass
					+ "}\n}\n}";
			
			return particleClass;
		}
	}
}