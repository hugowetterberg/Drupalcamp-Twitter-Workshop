package se.goodold.drupal
{
	import flash.events.Event;
	
	public class RestEvent extends Event {
		public static const GOT_REQUEST_TOKEN:String = "got request token";
		public static const GOT_ACCESS_TOKEN:String = "got access token";
		
		public function RestEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
	    {
	    	super(type, bubbles, cancelable);
	    }
	}
}