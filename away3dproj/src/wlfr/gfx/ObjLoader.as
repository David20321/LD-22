package wlfr.gfx 
{
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class ObjLoader 
	{
		private var loader:URLLoader;
		
		public function ObjLoader(path:String) 
		{
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onObjLoaded);
			loader.load(new URLRequest(path));
		}

		private function onObjLoaded(evt:Event):void 
		{
			//meshData = evt.target.data;
			trace(evt.target.data);
			loader.removeEventListener(Event.COMPLETE, onObjLoaded);
			loader = null;
		}	
	}
}