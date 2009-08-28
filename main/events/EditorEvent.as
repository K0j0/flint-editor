package main.events
{
	import flash.events.Event;

	public class EditorEvent extends Event
	{
		public static const MOUSE_DONE:String = "mouseDone";
		public static const RENDERER_SWITCH:String = "rendererSwitch";
		public static const UPDATE_REFERENCES:String = "updateReferences";
		
		public function EditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var text1:String;
	}
}