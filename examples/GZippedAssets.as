/**
 * GZip AssetManager usage.
 */
package 
{
	import com.deadreckoned.assetmanager.AssetManager;
	import com.deadreckoned.assetmanager.events.AssetEvent;
	import com.deadreckoned.assetmanager.formats.GZipHandler;
	import com.deadreckoned.assetmanager.formats.XMLHandler;
	import flash.display.Sprite;
	
	public class GZippedAssets extends Sprite
	{
		private var _assetManager:AssetManager;
		
		public function GZippedAssets():void
		{
			// Turn verbose mode on/off
			//AssetManager.verbose = false;
			
			// NOTE: To load and decompress gzip assets, Paul Robertson's Actionscript GZIP encoding library is required,
			// which can be found here: http://probertson.com/projects/gzipencoder/
			// Download the SWC and add it to the project
			
			// Register the GZip handler with the asset manager
			AssetManager.registerFormat(GZipHandler, [ "gz" ], "gz");
			
			// Register the XML handler with the GZip handler
			GZipHandler.addHandler(XMLHandler, "xml");
			
			// Setup asset manager
			_assetManager = AssetManager.getInstance();
			_assetManager.addEventListener(AssetEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			
			// There are two ways to load gzipped assets:
			// The second method is generally more useful, as it can allow you to work with uncompressed files
			// during development, and compressed files in the live environment, while maintining the same URI formats
			_assetManager.add("assets/xmldoc.xml.gz");                            // Load gzip file directly
			_assetManager.add("assets/xmldoc.xml", { type: GZipHandler.TYPE } );  // Specify gzip as the asset type
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
			
			// Test loaded assets are of XML type
			trace("assets/xmldoc.xml.gz:", (_assetManager.get("assets/xmldoc.xml.gz").asset is XML));
			trace(_assetManager.get("assets/xmldoc.xml.gz").asset);
			
			trace("assets/xmldoc.xml:", (_assetManager.get("assets/xmldoc.xml").asset is XML));
			trace(_assetManager.get("assets/xmldoc.xml").asset);
		}
	}
}