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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import main.events.EditorEvent;
	
	import mx.containers.Canvas;

	public class MouseControl extends EventDispatcher
	{
		private static var instance:MouseControl;
		private var _canvas:Canvas;
		private var objs:Array = [];
		private var props:Array = [];
		
		public function MouseControl(privateClass:PrivateClass, target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function set canvas(value:Canvas) : void
		{
			_canvas = value;
		}
		
		public static function getInstance() : MouseControl
		{
			if(!instance)
			{
				instance = new MouseControl(new PrivateClass());
			}
			return instance;
		}
		
		public function setObjectAndProperties(objs:Array, props:Array) : void
		{
			this.objs = objs;
			this.props = props;
			
			_canvas.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_canvas.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_canvas.addEventListener(MouseEvent.CLICK, onClick);			
		}
		
		private function onMouseMove(e:MouseEvent) : void
		{
			objs[0][props[0]] = e.localX;
			objs[1][props[1]] = e.localY;
		}
		
		private function onMouseOut(e:MouseEvent) : void
		{
			_canvas.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_canvas.removeEventListener(MouseEvent.CLICK, onClick);
			_canvas.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			dispatchEvent(new EditorEvent(EditorEvent.MOUSE_DONE));
		}
		
		private function onClick(e:MouseEvent) : void
		{
			_canvas.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_canvas.removeEventListener(MouseEvent.CLICK, onClick);
			_canvas.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			dispatchEvent(new EditorEvent(EditorEvent.MOUSE_DONE));
		}
	}
}

class PrivateClass
{
	public function PrivateClass() {}
}