/**
 * Usage example showing nested queues.
 */
package 
{
	import com.deadreckoned.assetmanager.AssetManager;
	import com.deadreckoned.assetmanager.AssetQueue;
	import com.deadreckoned.assetmanager.events.AssetEvent;
	import flash.display.Sprite;
	
	public class NestedQueues extends Sprite
	{
		private var _assetManager:AssetManager;
		
		public function NestedQueues():void
		{
			_assetManager = AssetManager.getInstance();
			_assetManager.addEventListener(AssetEvent.QUEUE_START, onQueueStarted, false, 0, true);
			_assetManager.addEventListener(AssetEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			
			// Add a regular asset
			_assetManager.add("assets/image1.jpg");
			
			// Create a secondary queue and add assets
			var secondaryQueue:AssetQueue = AssetManager.getInstance().createQueue("secondary");
			secondaryQueue.addEventListener(AssetEvent.QUEUE_START, onQueueStarted, false, 0, true);
			secondaryQueue.addEventListener(AssetEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			secondaryQueue.add("assets/subfolder/image2.png");
			secondaryQueue.add("assets/swffile.swf");
			secondaryQueue.add("assets/sound.mp3");
			
			// Add secondary queue to master queue
			_assetManager.add(secondaryQueue);
			
			// Add some more assets to the master queue
			_assetManager.add("assets/binarytest.js");
			_assetManager.add("assets/xmldoc.xml");
			
			// Prioritize the secondary queue
			//_assetManager.prioritize(secondaryQueue);
		}
		
		private function onQueueStarted(e:AssetEvent):void
		{
			trace("Queue started:", e.target);
		}
		
		private function onQueueComplete(e:AssetEvent):void
		{
			trace("Queue complete:", e.target);
			
			if (e.target == _assetManager)
			{
				// Access assets loaded by the secondary queue via AssetManager
				trace("assets/swffile.swf:", _assetManager.get("assets/swffile.swf"));
			}
		}
	}
}