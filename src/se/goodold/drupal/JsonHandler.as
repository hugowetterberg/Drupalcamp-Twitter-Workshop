package se.goodold.drupal {
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	public class JsonHandler {
		private var callback:Function;
		
		public function JsonHandler(callback:Function) {
			this.callback = callback;
		}

		public function finished(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if (loader.data) {
				var decoder:JSONDecoder = new JSONDecoder(loader.data);
				var value:Object = decoder.getValue();
				callback(value);
			}
		}
	}
}