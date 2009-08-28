
import flash.events.MouseEvent;

import main.control.CheckBoxGroup;

private var clickFunction:Function;
private var checkBoxGroup:CheckBoxGroup;
public var enableFlag:Boolean = true;

private function init() : void
{
	checkBoxGroup = CheckBoxGroup.getInstance();
	checkBoxGroup.addCheckBox(this);
	
	addEventListener(MouseEvent.CLICK, onClick);
}

public function set daClickFunction(value:Function) : void
{
	clickFunction = value;
}

private function onClick(e:MouseEvent) : void
{
	checkBoxGroup.update(this);	
	clickFunction.call(this);
}

public function clearAll() : void
{
	checkBoxGroup.clearAll();
}