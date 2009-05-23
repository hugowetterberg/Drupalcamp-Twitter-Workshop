package se.goodold.drupal {
	import org.iotashan.oauth.OAuthToken;
	
	public class TokenHandler {
		private var callback;
		
		public function TokenHandler(callback:Function):void{
			this.callback = callback;
		}

		public function finished(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if (loader.data) {
				var v:URLVariables = new URLVariables(loader.data);
				this.callback(new OAuthToken(v.oauth_token, v.oauth_token_secret));
			}
		}
	}
}