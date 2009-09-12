private function onClose() : void
{
	if(this.parent.contains(this)) this.parent.removeChild(this);
}