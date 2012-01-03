/**
 * Basic AssetManager usage.
 */
package 
{
	import com.deadreckoned.assetmanager.AssetManager;
	import com.deadreckoned.assetmanager.events.AssetEvent;
	import flash.display.Sprite;
	
	public class Basic extends Sprite
	{
		private var _assetManager:AssetManager;
		
		public function Basic():void
		{
			// Turn verbose mode on/off
			//AssetManager.verbose = false;
			
			// Setup asset manager
			_assetManager = AssetManager.getInstance();
			_assetManager.addEventListener(AssetEvent.QUEUE_START, onQueueStart, false, 0, true);
			_assetManager.addEventListener(AssetEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			
			// Add assets to load
			_assetManager.add("assets/image1.jpg");
			_assetManager.add("assets/subfolder/image2.png");
			_assetManager.add("assets/sound.mp3");
			_assetManager.add("assets/thisassetwillfailtoload.fail");
			_assetManager.add("assets/swffile.swf");
			_assetManager.add("assets/xmldoc.xml");
		}
		
		/**
		 * Executed when the asset queue begins loading.
		 * @param	e	The AssetEvent object
		 */
		private function onQueueStart(e:AssetEvent):void
		{
			trace("--------------------------");
			trace("Master asset queue started");
			trace("--------------------------");
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
			
			// Test loaded assets
			trace("assets/image1.jpg:", _assetManager.get("assets/image1.jpg").asset);
			trace("assets/subfolder/image2.png:", _assetManager.get("assets/subfolder/image2.png").asset);
			trace("assets/sound.mp3:", _assetManager.get("assets/sound.mp3").asset);
			trace("assets/swffile.swf:", _assetManager.get("assets/swffile.swf").asset);
			trace("assets/xmldoc.xml:", _assetManager.get("assets/xmldoc.xml").asset);
		}
	}
}