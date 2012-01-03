/**
 * Loading assets from an XML formatted list.
 */
package 
{
	import com.deadreckoned.assetmanager.AssetManager;
	import com.deadreckoned.assetmanager.events.AssetEvent;
	import flash.display.Sprite;
	
	public class AssetLists extends Sprite
	{
		private var _assetManager:AssetManager;
		
		public function AssetLists():void
		{
			// Setup asset manager
			_assetManager = AssetManager.getInstance();
			_assetManager.addEventListener(AssetEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			
			// Set the default path for all assets. Root-relative URLs (/) or URLs beginning
			// with protocols (http://, c:/, etc) will not use the default path.
			_assetManager.path = "assets/";
			
			// Load assets from an asset list XML
			_assetManager.loadFromXML("asset-list.xml");
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
			
			trace("image1.jpg:", _assetManager.get("image1.jpg").asset);
			trace("subfolder/image2.png:", _assetManager.get("subfolder/image2.png").asset);
			trace("sound.mp3:", _assetManager.get("sound.mp3").asset);
			trace("swffile.swf:", _assetManager.get("swffile.swf").asset);
			trace("xmldoc.xml:", _assetManager.get("xmldoc.xml").asset);
		}
	}
}