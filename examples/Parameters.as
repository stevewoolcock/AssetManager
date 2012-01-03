/**
 * AssetManager usage, using custom parameters for loading individual assets.
 */
package 
{
	import com.deadreckoned.assetmanager.AssetManager;
	import com.deadreckoned.assetmanager.events.AssetEvent;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	public class Parameters extends Sprite
	{
		private var _assetManager:AssetManager;
		
		public function Parameters():void
		{
			// Setup asset manager
			_assetManager = AssetManager.getInstance();
			_assetManager.addEventListener(AssetEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			
			// Set the default path for all assets. Root-relative URLs (/) or URLs beginning
			// with protocols (http://, c:/, etc) will not use the default path.
			_assetManager.path = "assets/";
			
			
			// Load image1.jpg as a binary file, rather than BitmapData
			_assetManager.add("image1.jpg", { type: AssetManager.TYPE_BINARY } );
			
			
			// Load swffile.swf, with a high priority. This will force the file to be loaded first, before all other assets in the queue.
			// The default priority is 0, and priorities can be a positive or negative integer (just like events)
			_assetManager.add("swffile.swf", { priority: 5 } );
			
			
			// Load subfolder/image2.png with an onComplete callback
			_assetManager.add("subfolder/image2.png", { onComplete: function():void
			{
				trace("	subfolder/image2.png complete");
			} });
			
			
			// Load sound.mp3 with an onStart callback, with arguments
			_assetManager.add("sound.mp3", { onStartParams: [ "foobar", int.MAX_VALUE ], onStart: function(param1:String, param2:int):void
			{
				trace("> sound.mp3 started, arguments=" + arguments);
			} });
			
			
			// Load a non-existing asset with an onError callback
			_assetManager.add("thisassetwillfailtoload.fail", { onError: function():void
			{
				trace("	thisassetwillfailtoload.fail failed to load");
			} } );
			
			
			// Load xmldoc.xml, but use a custom id for access
			_assetManager.add("xmldoc.xml", { id: "myXMLDoc" } );
			
			
			// Overwrite subfolder/image2.png. This will cause the initial addition of subfolder/image2.png to be disposed, so the 
			_assetManager.add("binarytest.js", { onStart: function():void { trace("This callback will not be executed"); } } );
			_assetManager.add("binarytest.js", { overwrite: true } );
		}
		
		/**
		 * Executed when all assets in the queue have completed loading.
		 * @param	e	The AssetEvent object
		 */
		private function onQueueComplete(e:AssetEvent):void
		{
			trace("---------------------------");
			trace("Master asset queue complete");
			trace("---------------------------");
			
			trace("image1.jpg:", getQualifiedClassName(_assetManager.get("image1.jpg").asset));
			trace("subfolder/image2.png:", _assetManager.get("subfolder/image2.png").asset);
			trace("sound.mp3:", _assetManager.get("sound.mp3").asset);
			trace("swffile.swf:", _assetManager.get("swffile.swf").asset);
			trace("myXMLDoc:", _assetManager.get("myXMLDoc").asset);
			trace("binarytest.js:", getQualifiedClassName(_assetManager.get("binarytest.js").asset));
		}
	}
}