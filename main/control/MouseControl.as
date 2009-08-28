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