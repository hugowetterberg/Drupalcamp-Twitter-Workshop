package se.goodold.drupal {
	import com.adobe.serialization.json.JSONEncoder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import org.iotashan.oauth.*;
	
	public class Rest extends EventDispatcher {
		private var server:String;
		private var consumer:OAuthConsumer;
		private var requestToken:OAuthToken;
		private var token:OAuthToken;
		private var sign:OAuthSignatureMethod_HMAC_SHA1;
		
		public function Rest(server:String, consumer:OAuthConsumer, token:OAuthToken=null) {
			this.server = server;
			this.consumer = consumer;
			this.token = token;
			this.sign = new OAuthSignatureMethod_HMAC_SHA1();
		}
		
		public function hasRequestToken():Boolean {
			return this.requestToken != null;
		}
		
		public function getRequestToken():void {
			var request:OAuthRequest = new OAuthRequest('GET', this.server + 'oauth/request_token', {}, this.consumer);
			var req:URLRequest = new URLRequest(request.buildRequest(this.sign));
			this.getToken(req, this.gotRequestToken);
		}
		
		private function getToken(request:URLRequest, callback:Function):void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, callback);
			loader.load(request);
		}
		
		private function gotRequestToken(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if (loader.data) {
				var v:URLVariables = new URLVariables(loader.data);
				this.requestToken = new OAuthToken(v.oauth_token, v.oauth_token_secret);
				var request:OAuthRequest = new OAuthRequest('GET', this.server + 'oauth/authorize', {}, this.consumer, this.requestToken);
				navigateToURL(new URLRequest(request.buildRequest()));
				this.dispatchEvent(new RestEvent(RestEvent.GOT_REQUEST_TOKEN));
			}
		}
		
		public function getAccessToken():void {
			var request:OAuthRequest = new OAuthRequest('GET', this.server + 'oauth/access_token', {}, this.consumer, this.requestToken);
			var req:URLRequest = new URLRequest(request.buildRequest(this.sign));
			this.getToken(req, this.gotAccessToken);
		}
		
		private function gotAccessToken(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if (loader.data) {
				var v:URLVariables = new URLVariables(loader.data);
				this.token = new OAuthToken(v.oauth_token, v.oauth_token_secret);
				this.dispatchEvent(new RestEvent(RestEvent.GOT_ACCESS_TOKEN));
			}
		}
		
		public function getRequest(callback:Function, path:String, params:Object=null):void {
			var request:OAuthRequest = new OAuthRequest('GET', server + path + '.json', params, this.consumer, this.token);
			var reqUrl:String = request.buildRequest(this.sign);
			var req:URLRequest = new URLRequest(reqUrl);
			req.method = URLRequestMethod.GET;
			this.loadRequest(req, callback);
		}
		
		public function postRequest(callback:Function, path:String, data:*=null, params:Object=null):void {
			var serialized:String = '';
			if (data) {
				var enc:JSONEncoder = new JSONEncoder(data);
				serialized = enc.getString();
			}
			
			var request:OAuthRequest = new OAuthRequest('POST', server + path + '.json', params, this.consumer, this.token);
			var reqUrl:String = request.buildRequest(this.sign);
			var req:URLRequest = new URLRequest(reqUrl);
			req.method = URLRequestMethod.POST;
			req.data = serialized;
			req.requestHeaders.push(new URLRequestHeader('Content-type', 'application/json'));
			this.loadRequest(req, callback);
		}
		
		private function loadRequest(request:URLRequest, callback:Function):void {
			var handler:JsonHandler = new JsonHandler(callback);
			var loader:URLLoader = new URLLoader();
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace(event.toString());
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void {
				trace(event.status);
			});
			loader.addEventListener(Event.COMPLETE, handler.finished);
			loader.load(request);
		}
	}
}