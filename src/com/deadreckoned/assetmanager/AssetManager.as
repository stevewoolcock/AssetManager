/**
 * com.deadreckoned.assetmanager.AssetManager
 * 
 * Copyright (c) 2013 Stephen Woolcock
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author Stephen Woolcock
 * @version 1.0.0
 * @link blog.deadreckoned.com
*/

package com.deadreckoned.assetmanager
{
	import com.deadreckoned.assetmanager.formats.*;
	import com.deadreckoned.assetmanager.formats.IFormatHandler;
	import flash.utils.Dictionary;
	
	
	/**
	 * [Singleton] The AssetManager class is a Singleton object that handles bulk loading of assets. The singleton AssetManager instance inherits from AssetQueue.
	 */
	public final class AssetManager extends AssetQueue
	{
		static private const GLOBAL_ID:String = "$_global";
		
		static private var _instance:AssetManager;
		
		/**
		 * @private
		 */
		static internal var _formats:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */
		static internal var _formatExtensions:Dictionary = new Dictionary();
		
		/**
		 * Determines if a verbose description of AssetQueue operations are displayed in the output window.
		 */
		static public var verbose:Boolean = true;
		
		/**
		 * The binary asset type id.
		 */
		static public const TYPE_BINARY:String = "bin";
		
		/**
		 * The image asset type id.
		 */
		static public const TYPE_IMAGE:String = "img";
		
		/**
		 * The sound asset type id.
		 */
		static public const TYPE_SOUND:String = "snd";
		
		/**
		 * The SWF asset type id.
		 */
		static public const TYPE_SWF:String = "swf";
		
		/**
		 * The text asset type id.
		 */
		static public const TYPE_TEXT:String = "txt";
		
		/**
		 * The XML asset type id.
		 */
		static public const TYPE_XML:String = "xml";
		
		// Static constructor
		{
			// Default supported file types
			registerFormat(BinaryHandler);
			registerFormat(GenericHandler,		[ "txt" ]);
			registerFormat(ImageHandler);
			registerFormat(SoundHandler);
			registerFormat(SWFHandler);
			registerFormat(XMLHandler);
		}
		
		/**
		 * [Singleton] AssetManager is a Singleton and cannot be directly instantiated. Use <code>AssetManager.getInstance()</code> to retrieve the singleton instance of the AssetManager class.
		 */
		public function AssetManager(enforcer:AssetManagerSingletonEnforcer):void
		{
			super("$global");
			
			if (enforcer == null)
				throw new Error("AssetManager is a Singleton and cannot be directly instantiated. Use AssetManager.getInstance().");
		}
		
		
		// STATIC PUBLIC FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * Retrieves a singleton instance of AssetManager class.
		 * @return	The singleton instance of the AssetManager class
		 */
		static public function getInstance():AssetManager
		{
			return _instance || (_instance = new AssetManager(new AssetManagerSingletonEnforcer()));
		}
		
		/**
		 * Registers a new file format handler.
		 * @param	handler		The handler Class of the format
		 * @param	extensions	[Optional] An Array of file extensions that should be handled by this format handler
		 * @param	id			[Optional] The id to associate the handler with
		 */
		static public function registerFormat(HandlerClass:Class, extensions:Array = null, id:String = null):void
		{
			var instance:IFormatHandler = new HandlerClass();
			
			// If values aren't supplied, use the defaults from the handler
			id = id ? id : instance.id;
			extensions = extensions ? extensions : instance.extensions;
			
			_formats[id] = HandlerClass;
			
			if (extensions != null)
			{
				for (var i:int = 0, len:int = extensions.length; i < len; i++)
				{
					_formatExtensions[extensions[i]] = id;
				}
			}
			
			instance.dispose();
		}
		
		/**
		 * Prints the list of registered file formats to the output window.
		 */
		static public function listRegisteredFormats():void
		{
			var output:String = "AssetManager registered file formats: ";
			for (var i:String in _formats)
			{
				output += "\r	" + i + " (handler: " + _formats[i] + ")";
			}
			trace(output);
		}
		
		
		// PUBLIC FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * Creates a new AssetQueue, with the same settings as the global queue.
		 * @param	id	An option id for the queue
		 * @return	The new AssetQueue, with the same settings as the global queue
		 */
		public function createQueue(id:String = null):AssetQueue
		{
			var queue:AssetQueue = new AssetQueue(id);
			queue.path = this.path;
			queue.queryString = this.queryString;
			queue.urlFunction = this.urlFunction;
			queue.loadSequentially = this.loadSequentially;
			return queue;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			return "(AssetManager assetsTotal=" + assetsTotal + ", assetsLoading=" + assetsLoading + ", assetsLoaded=" + assetsLoaded + ")";
		}
		
		
		// PRIVATE FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * @private
		 */
		internal function addAsset(asset:Asset):void
		{
			_assetsById[asset.id] = asset;
			if (_loaded.indexOf(asset) == -1)
				_loaded.push(asset);
		}
		
		/**
		 * @private
		 */
		internal function removeAsset(asset:Asset):void
		{
			if (_assetsById[asset.id] === asset)
			{
				_loaded.splice(_loaded.indexOf(asset), 1);
				_assetsById[asset.id] = null;
				delete _assetsById[asset.id];
			}
		}
	}
}

/**
 *An internal class used to enforce the AssetManager class as a Singleton.
 */
class AssetManagerSingletonEnforcer { }