/**
 * com.deadreckoned.assetmanager.AssetQueue
 * 
 * Copyright (c) 2012 Stephen Woolcock
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
	import com.deadreckoned.assetmanager.events.AssetEvent;
	import com.deadreckoned.assetmanager.formats.*;
	import com.deadreckoned.assetmanager.formats.IFormatHandler;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * Dispatched when an asset has completed loading
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.ASSET_COMPLETE
	 */
	[Event(name = "AssetComplete", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when an asset has started loading
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.ASSET_START
	 */
	[Event(name = "AssetStart", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when an asset has failed to load
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.ASSET_FAIL
	 */
	[Event(name = "AssetFail", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when an XML asset list has completed loading, but before the assets have been added to the queue (when using loadFromXML())
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.LIST_COMPLETE
	 */
	[Event(name = "AssetListComplete", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when assets from an XML asset list have been added to the queue
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.LIST_ADDED
	 */
	[Event(name = "AssetListAdded", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when all assets in the queue have completed loading
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.QUEUE_COMPLETE
	 */
	[Event(name = "AssetQueueComplete", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when all assets in the queue begins loading
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.QUEUE_START
	 */
	[Event(name = "AssetQueueStart", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when the queue has stopped loading via a call to pause()
	 * @eventType com.deadreckoned.assetmanager.events.AssetEvent.QUEUE_STOP
	 */
	[Event(name = "AssetQueueStop", type = "com.deadreckoned.assetmanager.events.AssetEvent")]
	
	/**
	 * Dispatched when a the load progress of an asset changes
	 * @eventType com.deadreckoned.assetmanager.events.AssetProgressEvent.PROGRESS
	 */
	[Event(name = "AssetProgress", type = "com.deadreckoned.assetmanager.events.AssetProgressEvent")]
	
	/**
	 * The AssetQueue handles the loading and storage of individual Asset objects.
	 */
	public class AssetQueue extends EventDispatcher implements IQueueable
	{
		private var _path:String = "";
		private var _id:String;
		private var _loaded:Vector.<Asset>;
		private var _loading:Boolean;
		private var _loadingId:String;
		private var _loadingXML:Boolean;
		private var _loadSequentially:Boolean = true;
		private var _queue:Vector.<IQueueable>;
		
		/**
		 * @private
		 */
		protected var _assetsById:Dictionary;
		
		/**
		 * @private
		 */
		internal var _priority:int;
		
		/**
		 * A query string to append to the URLs of assets when loading.
		 * For example, set <code>queryString</code> to <code>noCache=Math.random()</code> to force all assets in the queue to have avoid the cache.
		 */
		public var queryString:String;
		
		/**
		 * The id of the file currently loading. If <code>loadSequentially</code> is false, this value will be <code>null</code>.
		 */
		public function get currentLoadingId():String { return _loadSequentially ? _loadingId : null; }
		
		/**
		 * The base path to load assets from. For example, if <code>path</code> was set to "myApp/data/", all assets added to the
		 * queue (and XML file lists loaded using <code>loadFromXML()</code>) would have "myApp/data/" prepended to their URLs, making
		 * the final URL "myApp/data/myXMLAsset.xml". This is not applied for URIs with root access (URIs beginning with '/'), or for URIs containing
		 * a protocol or drive access token (for example, http://, c:/, etc).
		 */
		public function get path():String { return _path; }
		public function set path(value:String):void
		{
			_path = value;
			
			// If a forward slash is not supplied, add one
			if (_path != null && _path.substr(_path.length - 1) != "/") _path += "/";
		}
		
		/**
		 * The id of the AssetQueue instance.
		 */
		public function get id():String { return _id; }
		
		/**
		 * The total number of assets in the AssetQueue. This is the sum of both <code>assetsLoading</code> and <code>assetsLoaded</code>.
		 */
		public function get assetsTotal():uint { return assetsLoading + _loaded.length; }
		
		/**
		 * The number of assets that have completed loading, or have been added using <code>addAsset</code>.
		 */
		public function get assetsLoaded():uint { return _loaded.length; }
		
		/**
		 * The number of assets still to be loaded, not including unloaded assets in child queues.
		 */
		public function get assetsLoading():uint
		{
			var c:int = 0;
			for each (var a:IQueueable in _queue)
			{
				if (!(a is AssetQueue)) c++;
			}
			return c;
		}
		
		/**
		 * The number of assets still to be loaded, including the number of unloaded assets in child queues.
		 */
		public function get assetsLoadingTotal():uint
		{
			var c:int = 0;
			for each (var a:IQueueable in _queue)
			{
				var assetQueue:AssetQueue = a as AssetQueue
				if (assetQueue != null) c += assetQueue.assetsLoadingTotal;
				else c++;
			}
			return c;
		}
		
		/**
		 * Determines if the AssetQueue instance is currently set to load assets in the queue. This value will be set to <code>true</code> when
		 * <code>load()</code> or <code>loadFromXML()</code> methods are called, and set to false when <code>pause()</code> is called.
		 */
		public function get loading():Boolean { return _loading; }
		
		/**
		 * Determines if assets within the queue are loaded sequentially (one after the other) or all at once (using the browser's on queue, if running inside a browser).
		 * This value is <code>true</code> by default.
		 */
		public function get loadSequentially():Boolean { return _loadSequentially; }
		public function set loadSequentially(value:Boolean):void
		{
			_loadSequentially = value;
			
			for each (var object:IQueueable in _queue)
			{
				!_loadSequentially ? loadObject(object) : pauseObject(object);
			}
			if (_loadSequentially) load();
		}
		
		/**
		 * The priority of the AssetQueue when nested as a child queue within the AssetManager, or another AssetQueue. This value can be set when adding this AssetQueue to another,
		 * using the <code>add()</code> method, or by using the <code>prioritize()</code> method.
		 */
		public function get priority():int { return _priority; }
		
		/**
		 * Creates a new AssetQueue instance.
		 * @param	id	An optional id for the queue
		 */
		public function AssetQueue(id:String = null):void
		{
			_id = id;
			_queue = new Vector.<IQueueable>();
			_loaded = new Vector.<Asset>();
			_assetsById = new Dictionary(true);
		}
		
		
		// PUBLIC METHODS
		// ------------------------------------------------------------------------------------------
		/**
		 * Adds an asset to the queue. A valid asset can be a URL, which will be loaded, an AssetQueue to add as a child queue, or any other valid ActionScript object.
		 * The second argument can be an object containing information about the file. If adding an ActionScript object, the <code>args</code> parameter can be a single string, which will be used
		 * as the unique identifier for the asset. When an asset is added to ANY queue, it is also added to the AssetManager default queue, so it can be accessed from anywhere within
		 * your application, so beware of duplicate ids.
		 * <p>If an asset has already been loaded, unless the <code>overwrite</code> property is supplied, the asset will not be loaded. However, asset and queue related events will still execute
		 * as expected.</p>
		 * <p>AssetQueue objects, when added to another AssetQueue, are added as child queues. When they are reached in the queue while loading, they will begin loading their assets.
		 * When a child AssetQueue has completed loading, it is removed from the parent queue, and the parent queue will continue loading any remaining child assets. With this system, it makes it
		 * easy to prioritize and manage your individual AssetQueue instances.</p>
		 * 
		 * @param	obj		Either a URL to load an asset from, an AssetQueue object to add as a child queue or any other valid ActionScript object you want to store in the queue.
		 * @param	args	Arguments to supply when loading and storing the asset. See method description for a full list of supported arguments.
		 * <p>The available properties for the <code>args</code> object when loading an asset from a URL are:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
		 * <tr><td>id</td><td>String</td><td>A unique identifier for the asset. If this value is <code>null</code>, the value of the <code>uri</code> parameter is used as the identifier.</td></tr>
		 * <tr><td>type</td><td>String</td><td>Determines the type of the asset. If no type is supplied, AssetQueue will try to derive the type from the file extension of the URI. If no type can be discerned, the binary type is used.</td></tr>
		 * <tr><td>priority</td><td>int</td><td><code>0</code>. The priority of the asset. Higher prorities will be added to the front of the queue.</td></tr>
		 * <tr><td>context</td><td>LoaderContext or SoundLoaderContext</td><td>A context object to use when loading the file (LoaderContext or SoundLoaderContext, if loading a Sound).</td></tr>
		 * <tr><td>data</td><td>Object</td><td>Any custom data you want to store along with the file. This can be any valid ActionScript object.</td></tr>
		 * <tr><td>ovewrite</td><td>Boolean</td><td><code>false</code>. Determines if this asset should overwrite another asset with the same id.</td></tr>
		 * <tr><td>onStart</td><td>Function</td><td>A callback to execute when the asset begins loading.</td></tr>
		 * <tr><td>onStartParams</td><td>Array</td><td>An array of parameters to send to the onStart callback.</td></tr>
		 * <tr><td>onComplete</td><td>Function</td><td>A callback to execute when the asset has completed loading.</td></tr>
		 * <tr><td>onCompleteParams</td><td>Array</td><td>An array of parameters to send to the onComplete callback.</td></tr>
		 * <tr><td>onProgress</td><td>Function</td><td>A callback to execute when the asset's load progress changes.</td></tr>
		 * <tr><td>onProgressParams</td><td>Array</td><td>An array of parameters to send to the onProgress callback.</td></tr>
		 * <tr><td>onError</td><td>Function</td><td>A callback to execute when the asset fails to load.</td></tr>
		 * <tr><td>onErrorParams</td><td>Array</td><td>An array of parameters to send to the onError callback.</td></tr>
		 * </table>
		 * 
		 * <p>The available properties for the <code>args</code> object when adding a child AssetQueue are:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
		 * <tr><td>priority</td><td>int</td><td>Applicable only when adding an AssetQueue, sets the priority of the queue.</td></tr>
		 * </table>
		 * 
		 * <p>The available properties for the <code>args</code> object when adding an ActionScript object are:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Type</th><th>Description</th></tr>
		 * <tr><td>id</td><td>String</td><td><b>Required</b>. A unique identifier for the asset.</td></tr>
		 * <tr><td>type</td><td>String</td><td>The type of asset. AssetQueue will try to determine the type of the asset by its ActionScript type, if no type value is supplied. This value should be one of the registered file formats, although it can technically be anything you wish.</td></tr>
		 * <tr><td>data</td><td>Object</td><td>Any custom data you want to store along with the asset. This can be any valid ActionScript object.</td></tr>
		 * </table>
		 * <p><b>Note:</b> When adding an ActionScript object, the <code>args</code> paratmer can simply be the unique identifier, if the other parameters are not required.</p>
		 * 
		 * @return	The new Asset object, or the AssetQueue, that was added to the queue
		 * @throws	ArgumentError No format handler exists for the type supplied.
		 * @throws	ArgumentError Manually added assets must supply an <code>id</code> or <code>uri</code> property.
		 * @example	Load an asset from a URL: <listing version="3.0">AssetManager.getInstance().add("images/myImage.jpg");</listing>
		 * @example	Load an asset from a URL, with callbacks and custom data: <listing version="3.0">AssetManager.getInstance().add("images/myImage.jpg", {
	onComplete: myCompleteHandler,
	onStart: myStartHandler,
	onStartParams: [ "param1", 0.5 ],
	data: { foo: "bar" }
} );</listing>
		 * @example	Add a custom object: <listing version="3.0">AssetManager.getInstance().add( { foo: "bar", number: 100 }, "myCustomAsset");</listing>
		 * @example	Add a child AssetQueue: <listing version="3.0">var childQueue:AssetQueue = new AssetQueue();
childQueue.add("images/myImage.jpg");
AssetManager.getInstance().add(childQueue);</listing>
		 */
		public function add(obj:*, args:Object = null):IQueueable
		{
			var asset:Asset;
			
			args ||= { };
			
			
			// Loading an external asset
			// -----------------------------
			if (obj is String)
			{
				var uri:String = obj as String;
				
				// Default values
				if (args.id == null) args.id = uri;
				if (_assetsById[args.id] != null)
				{
					// An asset with this id already exists
					if (args.overwrite === true)
					{
						// Flagged for overwrite, so dispose of previous asset
						disposeAsset(_assetsById[args.id]);	
					}
					else
					{
						if (AssetManager.verbose)
							trace("AssetManager: Warning: " + uri + " already exists and is not flagged for overwrite.");
						
						// Not flagged for overwrite. If the queue is loading and is currently empty, we should dispatch start and complete events
						if (_loading && _queue.length == 0)
						{
							if (hasEventListener(AssetEvent.QUEUE_START))
								dispatchEvent(new AssetEvent(AssetEvent.QUEUE_START));
								
							if (hasEventListener(AssetEvent.ASSET_START))
								dispatchEvent(new AssetEvent(AssetEvent.ASSET_START));
								
							if (hasEventListener(AssetEvent.ASSET_COMPLETE))
								dispatchEvent(new AssetEvent(AssetEvent.ASSET_COMPLETE));
								
							if (hasEventListener(AssetEvent.QUEUE_COMPLETE))
								dispatchEvent(new AssetEvent(AssetEvent.QUEUE_COMPLETE));
						}
						
						// Return previous asset
						return _assetsById[args.id];
					}
				}
				if (args.type == null)		args.type		= getTypeFromURL(uri);
				if (args.priority == null)	args.priority	= 0;
				
				// Get format handler class
				var handlerClass:Class = AssetManager._formats[args.type];
				if (handlerClass == null) throw new ArgumentError("No format handler with the type '" + args.type + "' has been registered. Use AssetManager.registerFormat() to register new or custom formats.");
				
				asset = new Asset(new handlerClass());
				asset._uri				= uri;
				
				// Apply properties to the asset
				asset._id				= args.id;
				asset._context			= args.context;
				asset._data				= args.data;
				asset._type				= args.type;
				asset._priority			= args.priority;
				
				// Set callbacks
				asset.onStart			= args.onStart;
				asset.onStartParams		= args.onStartParams;
				asset.onProgress		= args.onProgress;
				asset.onProgressParams	= args.onProgressParams;
				asset.onComplete		= args.onComplete;
				asset.onCompleteParams	= args.onCompleteParams;
				asset.onError			= args.onError;
				asset.onErrorParams		= args.onErrorParams;
				
				// Add asset
				_assetsById[asset._id] = asset;
				if (AssetManager.getInstance() != this) AssetManager.getInstance().addAsset(asset);
				addObjectToQueue(asset, args.priority, _loading && _queue.length > 1);
				
				if (_loading)
				{
					// Begin loading the queue
					if (_queue.length == 1)
					{
						if (hasEventListener(AssetEvent.QUEUE_START))
							dispatchEvent(new AssetEvent(AssetEvent.QUEUE_START));
							
						load();
					}
					else if (!_loadSequentially)
					{
						loadObject(asset);
					}
				}
				
				return asset;
				// EXIT
			}
			
			
			// Adding a child queue
			// -----------------------------
			var assetQueue:AssetQueue = obj as AssetQueue;
			if (assetQueue != null)
			{
				// Default priority is NaN, to force the child queue to be added to the end of this queue
				if (!args.hasOwnProperty("priority")) args.priority = NaN;
				
				// Add as a child queue, if it doesn't already exist in this queue
				if (_queue.indexOf(assetQueue) == -1)
				{
					assetQueue.addEventListener(AssetEvent.QUEUE_COMPLETE, onChildQueueComplete, false, 0, true);
					addObjectToQueue(assetQueue, args.priority);
				}
				
				return assetQueue;
				// EXIT
			}
			
			
			// Adding an ActionScript object
			// -----------------------------
			var argsIsId:Boolean = args is String;
			if (!argsIsId && (args.id == null && args.uri == null))
				throw new ArgumentError("Manually added assets must have an 'id' or 'uri' supplied.");
			
			// Create asset container
			asset = new Asset();
			asset._asset = obj;
			
			// Set properties
			asset._id = argsIsId ? String(args) : (args.id || args.uri);
			if (args.hasOwnProperty("data")) asset._data = args.data;
			
			// Set type
			if (args.hasOwnProperty("type"))
			{
				asset._type = args.type;
			}
			else
			{
				// Attempt to detect type
				if (obj is String)			asset._type = AssetManager.TYPE_TEXT;
				else if (obj is XML)		asset._type = AssetManager.TYPE_XML;
				else if (obj is Sound)		asset._type = AssetManager.TYPE_SOUND;
				else if (obj is BitmapData)	asset._type = AssetManager.TYPE_IMAGE;
				else if (obj is ByteArray)	asset._type = AssetManager.TYPE_BINARY;
			}
			
			_loaded.push(asset);
			_assetsById[asset._id] = asset;
			if (AssetManager.getInstance() != this) AssetManager.getInstance().addAsset(asset);
			return asset;
		}
		
		/**
		 * Adds assets to the queue from an XML asset list. Each asset node within the XML document should be formatted as follows:<br/>
		 * 
		 * <p><code>&lt;asset [id="uniqueId"] [type="typeId"] [nocache="1"]&gt;uriToAsset&lt;/asset&gt;</code></p>
		 * <p><b>NOTE:</b> attributes in brackets are optional, see below for full list of supported attributes</p>
		 * 
		 * Once the asset has loaded, you can use <code>get(uriToAsset).data</code> to retrieve the XML node for the asset.
		 * This is useful if you are supplying custom attributes for an asset on an application-specific level.
		 * 
		 * <p>Supported attributes for an asset node are as follows:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Description</th></tr>
		 * <tr><td>id</td><td>A unique identifier for the asset. If this value is <code>null</code>, the value of the <code>uri</code> parameter is used as the identifier.</td></tr>
		 * <tr><td>type</td><td>Determined the type of the asset. If no type is supplied, AssetQueue will try to derive the type from the file extension of the URI. If no type can be discerned, the binary type is used</td></tr>
		 * <tr><td>priority</td><td><code>0</code>. The priority of the asset. Higher prorities will be added to the front of the queue.</td></tr>
		 * <tr><td>context</td><td>Determins the ApplicationDomain to use when loading this asset. Leave this value out to use no LoaderContext.
		 * In the case of sounds, a SoundLoaderContext is always used if the<code>context</code> is supplied, although the value of the attribute does not matter.
		 * 		<p>Valid values are:</p>
		 * 		<p><code>new</code> — A new ApplicationDomain.</p>
		 * 		<p><code>parent</code> — The ApplicationDomain of the SWF loading the asset.</p>
		 * 		<p><code>this</code> — The parent ApplicationDomain of the the SWF loading the asset.</p>
		 * </td></tr>
		 * <tr><td>checkPolicyFile</td><td>Determines the value checkPolicyFile flag on the LoaderContext or SoundLoaderContext used to load the asset. Defaults to false.</td></tr>
		 * <tr><td>bufferTime</td><td><code>1000</code>. For sounds using a context, this is the buffer time setting in milliseconds.</td></tr>
		 * <tr><td>nocache</td><td><code>0</code>. A value of 0 or 1, indicating if a random number should be assigned as part of the query string for the URI when loading, to avoid caching on some servers.</td></tr>
		 * </table>
		 * 
		 * @param	xml	The XML document containing a list of assets to load
		 * @example	Add a list of assets to the AssetQueue, using XML formatting. Here, the first asset is loaded using its URI as the id. The second element specifies
		 * a unique id to use for the asset. The third asset specifies that the image asset should be loaded as binary data, rather than as a BitmapData instance: <listing version="3.0">var assetList:XML = &lt;assets&gt;
	&lt;asset&gt;images/myImage.jpg&lt;/asset&gt;
	&lt;asset id="mySound"&gt;sounds/mySound.mp3&lt;/asset&gt;
	&lt;asset type="bin"&gt;images/myImage.jpg&lt;/asset&gt;
&lt;/assets&gt;;

// Load asset list
AssetManager.getInstance().addFromXML(assetList);
</listing>
		 */
		public function addFromXML(xml:XML):void
		{
			var loading:Boolean = _loading;
			var assetList:XMLList = xml.asset;
			
			// We set loading to false so that the assets added from the list do not begin loading until the LIST_ADDED event has been fired
			_loading = false;
			
			for (var i:int = 0, len:int = assetList.length(); i < len; i++)
			{
				var node:XML = assetList[i];
				var uri:String = node.toString();
				
				// Create parameters
				var args:Object = {};
				args.data 		= node;
				args.priority	= node.hasOwnProperty("@priority")	? int(node.@priority.toString()) : 0;
				args.id			= node.hasOwnProperty("@id")		? node.@id.toString() : null;
				args.type		= node.hasOwnProperty("@type")		? node.@type.toString() : getTypeFromURL(uri);
				
				// Check for LoaderContext settings
				if (node.hasOwnProperty("@context"))
				{
					var checkPolicyFile:Boolean = node.hasOwnProperty("@checkPolicyFile") ? Boolean(int(node.@checkPolicyFile.toString())) : false;
					if (args.type == AssetManager.TYPE_SOUND)
					{
						var bufferTime:int = node.hasOwnProperty("@bufferTime") ? int(node.@bufferTime.toString()) : 1000;
						args.context = new SoundLoaderContext(bufferTime, checkPolicyFile);
					}
					else
					{
						var domain:ApplicationDomain;
						switch (node.@context.toString())
						{
							case "new":
								domain = new ApplicationDomain();
								break;
								
							case "this":
								domain = ApplicationDomain.currentDomain;
								break;
								
							case "parent":
								domain = ApplicationDomain.currentDomain.parentDomain;
								break;
						}
						
						args.context = new LoaderContext(checkPolicyFile, domain);
					}
				}
				
				// Check for cache settings
				if (node.hasOwnProperty("@nocache") && (node.@nocache.toString() == "1" || node.@nocache.toString() == "true"))
					uri += (uri.indexOf("?") > -1 ? "&" :" ?") + "nocache=" + Math.random();
				
				add(uri, args);
			}
			
			if (hasEventListener(AssetEvent.LIST_ADDED))
				dispatchEvent(new AssetEvent(AssetEvent.LIST_ADDED, false, false, null, xml));
			
			if (loading) load();
		}
		
		/**
		 * Loads an asset list from an external location and adds each asset node to the queue. See <code>addFromXML</code> for full documentation on the asset list XML format.
		 * @param	url	The URL to the XML document containing the queue
		 * @see		AssetQueue#addFromXML()
		 */
		public function loadFromXML(url:String):void
		{
			if (_loading) pauseSilently();
			
			_loadingXML = true;
			_loading = true;
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onXMLComplete, false, 0, true);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXMLError, false, 0, true);
			xmlLoader.load(new URLRequest(processURL(url)));
		}
		
		/**
		 * Returns a Boolean value indicating if the asset with the specified id exists within the queue (loaded or unloaded).
		 * @param	id	The id of the asset.
		 * @return	A Boolean value indicating if an asset with the supplied is exists within the queue.
		 */
		public function contains(id:String):Boolean
		{
			return _assetsById[id] != null;
		}
		
		/**
		 * Retrieves an asset from the queue.
		 * @param	id	The id of the asset
		 * @return	The assets with the id supplied
		 */
		public function get(id:String):Asset
		{
			return _assetsById[id] as Asset;
		}
		
		/**
		 * Retrieves a child AssetQueue from the queue. This method will only return child AssetQueue objects which have not completed loading.
		 * @param	id	The id of the AssetQueue
		 * @return	The AssetQueue with the id supplied
		 */
		public function getQueue(id:String):AssetQueue
		{
			for (var i:int = 0, len:int = _queue.length; i < len; i++)
			{
				var assetQueue:AssetQueue = _queue[i] as AssetQueue;
				if (assetQueue != null && assetQueue.id == id)
					return assetQueue;
			}
			return null;
		}
		
		/**
		 * Retrieves the list of all asset ids in the queue (loaded or unloaded).
		 * @return	An Array containing the list of assets ids currently loaded
		 */
		public function getIds():Array
		{
			var output:Array = [];
			var all:Vector.<Asset> = _loaded.concat(_queue);
			for (var i:int = 0, len:int = all.length; i < len; i++)
				output.push(Asset(all[i]).id);
			
			return output;
		}
		
		/**
		 * Retrieves the list of asset ids that have been loaded.
		 * @return	An Array containing the list of assets ids currently loaded
		 */
		public function getLoadedIds():Array
		{
			var output:Array = [];
			for (var i:int = 0, len:int = _loaded.length; i < len; i++)
				output.push(Asset(_loaded[i]).id);
			
			return output;
		}
		
		/**
		 * Retrieves the list of asset ids that are currently in the queue.
		 * @return	An Array containing the list of assets ids currently in the queue
		 */
		public function getUnloadedIds():Array
		{
			var output:Array = [];
			for (var i:int = 0, len:int = _queue.length; i < len; i++)
			{
				output.push(Asset(_queue[i]).id);
			}
			
			return output;
		}
		
		/**
		 * Returns the object at the head of the loading queue (the first asset in the queue). This could be an Asset, or an AssetQueue object.
		 * @return	The object at the head of the queue.
		 */
		public function getHeadObject():IQueueable
		{
			return _queue.length > 0 ? _queue[0] : null;
		}
		
		/**
		 * Returns the object at the tail of the loading queue (the last object in the queue). This could be an Asset, or an AssetQueue object.
		 * @return	The object at the head of the queue.
		 */
		public function getTailObject():IQueueable
		{
			return _queue.length > 0 ? _queue[_queue.length - 1] : null;
		}
		
		/**
		 * Returns a Boolean value indicating if an asset with a specific id has completed loading.
		 * @param	id	The id of the asset to search for.
		 * @return	A Boolean value indicating if the asset with the id supplied has completed loading.
		 */
		public function isLoaded(id:String):Boolean
		{
			var asset:Asset;
			for (var i:int = 0, len:int = _queue.length; i < len; i++)
			{
				asset = _queue[i] as Asset;
				if (asset != null && asset.id == id) return true;
			}
			
			return false;
		}
		
		/**
		 * Begins loading the asset at the head of the queue. This will flag the queue as 'loading', so any assets added AFTER the <code>load()</code> method is called will
		 * begin loading immediately. By default, the AssetManager default queue will call <code>load()</code> automatically, so calling it is not necessary when using the
		 * <code>AssetManager.getInstance()</code> queue.
		 * <p>To begin loading another queue manually, you can call the <code>load()</code> method at any time. If an AssetQueue is added as a child to another AssetQueue, when
		 * the queue is reached during the loading process, <code>load()</code> will automatically be called.</p>
		 * <p>In most general use cases, you should not have to call <code>load()</code>, unless you have called <code>pause()</code> beforehand.</p>
		 */
		public function load():void
		{
			if (_loadingXML) return;
			
			// Dispatch a QUEUE_START event if we're not already loading
			if (!_loading)
			{
				_loading = true;
				if (_queue.length > 0 && hasEventListener(AssetEvent.QUEUE_START))
					dispatchEvent(new AssetEvent(AssetEvent.QUEUE_START));
			}
			
			if (_loadSequentially)
			{
				// Load the asset at the head of the queue
				if (_queue.length > 0) loadObject(_queue[0]);
			}
			else
			{
				// Load all assets
				for each (var asset:Asset in _queue)
				{
					loadObject(asset);
				}
			}
		}
		
		/**
		 * Pauses the loading of assets in the queue. Use <code>load()</code> to resume loading.
		 */
		public function pause():void
		{
			_loading = false;
			pauseSilently(); // Pause all assets in the queue
			
			if (hasEventListener(AssetEvent.QUEUE_STOP))
				dispatchEvent(new AssetEvent(AssetEvent.QUEUE_STOP));
		}
		
		/**
		 * Prioritizes an asset within the queue. If <code>priority</code> is not set, the asset will be moved to the front of the queue, by setting its priority
		 * to priority of the first item in the queue, + 1. If a custom priority is set, the asset is moved to the correct position in the queue.
		 * @param	idOrObject	Either a String, representing the id of the asset to prioritize, or an IQueueable instance (eg. Asset or AssetQueue instance)
		 * @param	priority	The priority to set the asset to. Leave this value as NaN to move the asset to the front of the queue.
		 * @throws	ArgumentError The object supplied must be either a String or IQueueable instance.
		 */
		public function prioritize(idOrObject:*, priority:Number = Number.NaN):void
		{
			var obj:IQueueable;
			if (idOrObject is IQueueable)
			{
				obj = IQueueable(idOrObject);
				if (_queue.indexOf(obj) == -1) return;
			}
			else if (idOrObject is String)
			{
				obj = getObjectInQueue(idOrObject);
			}
			else
			{
				throw new ArgumentError("idOrObject must be either a String or IQueueable instance.");
			}
			
			// If the priority isn't changing, exit here
			if (obj == null || obj.priority == priority) return;
			
			var queueLen:int = _queue.length;
			var highestPriority:int = queueLen > 0 ? _queue[0].priority : 0;
			
			// A NaN value is used to force the object to the front of the queue.
			// The priority becomes the highest + 1
			if (isNaN(priority))
			{
				if (_queue.indexOf(obj) == 0) return;	// Already at the front of the queue, don't change priority, just exit
				priority = highestPriority + 1;
			}
			
			addObjectToQueue(obj, priority);
		}
		
		/**
		 * Releases data from the queue to prepare the contents for garbage collection. If a specific id is supplied, the asset with
		 * the supplied id is disposed of. If no id is supplied, all assets in the queue are purged. The AssetQueue instance
		 * is still useable after this method is called, unlike when calling <code>dispose()</code>.
		 * @param	id	The id of an asset to purge. If no id is supplied, all assets in the queue are purged.
		 */
		public function purge(id:String = null):void
		{
			var asset:Asset;
			
			if (id != null)
			{
				// Purge single asset
				asset = _assetsById[id];
				if (asset != null) disposeAsset(asset);
				return;
			}
			
			pauseSilently();
			
			// Purge all assets
			var allAssets:Vector.<Asset> = _loaded.concat(_queue);
			for (var i:int = 0, len:int = allAssets.length; i < len; i++)
			{
				asset = allAssets[i];
				disposeAsset(asset, false);
			}
			
			_queue.length = 0;
			_loaded.length = 0;
			_assetsById = new Dictionary(true);
		}
		
		/**
		 * Releases all data that has not already been loaded. Assets that have already been loaded will remain stored within the loader.
		 */
		public function purgeUnloaded():void
		{
			for (var i:int = _queue.length - 1; i >= 0; i--)
			{
				removeFromQueue(_queue[i].id);
			}
		}
		
		/**
		 * Removes a child AssetQueue from this AssetQueue.
		 * @param	queue	The AssetQueue to remove
		 * @return	The AssetQueue that was removed
		 */
		public function removeQueue(queue:AssetQueue):AssetQueue
		{
			var index:int = _queue.indexOf(queue);
			if (index > -1) _queue.splice(index, 1);
			return null;
		}
		
		/**
		 * Returns the string representation of the specified object.
		 * @return	A string representation of the object.
		 */
		public override function toString():String
		{
			return "(AssetQueue " + id + ", assetsTotal=" + assetsTotal + ", assetsLoading=" + assetsLoading + ", assetsLoaded=" + assetsLoaded + ")";
		}
		
		
		// PRIVATE FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * Adds an object to the queue at a specific priority
		 * @param	obj	The object to add to the queue
		 */
		private function addObjectToQueue(obj:IQueueable, priority:Number = NaN, loadWhenAdded:Boolean = true):void
		{
			var queueLen:int = _queue.length;
			
			if (queueLen == 0 || isNaN(priority))
			{
				// The queue is empty, or no priority was supplied, so all we have to do is push the object into the queue
				_queue.push(obj);
			}
			else
			{
				// The queue is already populated, so we need to find the position in which to add it
				var highestPriority:int = queueLen > 0 ? _queue[0].priority : 0;
				var lowestPriority:int = queueLen > 0 ? _queue[queueLen - 1].priority : 0;
				var head:IQueueable = _queue[0];
				var currentIndex:int = _queue.indexOf(obj);
				var newIndex:int = 0;
				
				// Force priority to be an integer
				priority = int(priority);
				
				// Set the object's priority proprty value
				if (obj is Asset) Asset(obj)._priority = priority;
				else if (obj is AssetQueue) AssetQueue(obj)._priority = priority;
				
				// Remove the object from the queue, if it exists
				if (currentIndex > -1) _queue.splice(currentIndex, 1);
				
				if (priority > highestPriority)
				{
					// This is the highest priority object, add it to the front
					_queue.unshift(obj);
				}
				else if (priority <= lowestPriority)
				{
					// This is the lowest priority object, add it to the back
					_queue.push(obj);
				}
				else
				{
					// Find the index to add the object at
					var objInQueue:IQueueable = _queue[0];
					while (objInQueue.priority >= priority)
					{
						newIndex++;
						if (newIndex == _queue.length) break; // Reached the end of the queue
						objInQueue = _queue[newIndex];
					}
					
					// Index hasn't changed, exit
					if (newIndex == currentIndex) return;
					
					// Add the object to the queue at the new index
					_queue.splice(newIndex, 0, obj);
				}
			}
			
			// If loading sequentially, and the head object has changed, stop loading all assets, and call
			// load() again to begin loading the new head asset
			if (loadWhenAdded && _loadSequentially && head != _queue[0])
			{
				pauseSilently();
				if (_loading) load();
			}
		}
		
		/**
		 * Completely removes an asset from the AssetManager and prepares it for garbage collection.
		 * @param	asset			The Asset to dispose.
		 * @param	removeFromLists	Determines if the asset is removed from asset lists.
		 */
		private function disposeAsset(asset:Asset, removeFromLists:Boolean = true):void
		{
			if (asset == null) return;
			
			// Remove event listeners
			var loaderAsDispatcher:IEventDispatcher = asset._handler as IEventDispatcher;
			if (loaderAsDispatcher != null)
			{
				loaderAsDispatcher.removeEventListener(Event.COMPLETE, onAssetLoadComplete);
				loaderAsDispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onAssetIOError);
				loaderAsDispatcher.removeEventListener(ProgressEvent.PROGRESS, onAssetProgress);
			}
			
			if (removeFromLists)
			{
				// Remove from assetsById dictionary
				if (AssetManager.getInstance() != this) AssetManager.getInstance().removeAsset(asset);
				_assetsById[asset.id] = null;
				delete _assetsById[asset.id];
				
				// Remove from asset list
				var i:int = _loaded.indexOf(asset);
				if (i > -1) _loaded.splice(i, 1);
				
				// Remove from queue
				i = _queue.indexOf(asset);
				if (i > -1) _queue.splice(i, 1);
			}
			
			asset.dispose();
		}
		
		/**
		 * Retrieves the asset in the queue with the id supplied.
		 * @param	id	The id of the asset
		 * @return	The Asset with the id supplied
		 */
		private function getObjectInQueue(id:String):IQueueable
		{
			var object:IQueueable;
			for (var i:int = 0, len:int = _queue.length; i < len; i ++)
			{
				object = _queue[i];
				if (object.id == id) return object;
			}
			
			return null;
		}
		
		/**
		 * Retrieves the asset in the queue with the handler supplied.
		 * @param	handler	The handler of the asset.
		 * @return	The Asset with the handler supplied.
		 */
		private function getAssetInQueueByHandler(handler:IFormatHandler):Asset
		{
			for each (var obj:IQueueable in _queue)
			{
				var asset:Asset = obj as Asset;
				if (asset != null && asset._handler === handler) return asset;
			}
			
			return null;
		}
		
		/**
		 * Retrieves a format handler for an asset based on the asset's extension in the URL. If no handler could be found
		 * for the asset's extension, the binary handler will be used.
		 * @param	uri	The URL of the asset
		 * @return	The id of the format handler to use for the URL
		 */
		private function getTypeFromURL(url:String):String
		{
			var ext:String = url.substr(url.lastIndexOf(".") + 1);
			var handlerId:String = AssetManager._formatExtensions[ext];
			return handlerId ? handlerId:"bin";
		}
		
		/**
		 * Begins a load operation for an asset.
		 * @param	asset	The Asset to begin loading
		 */
		private function loadObject(obj:IQueueable):void
		{
			var asset:Asset = obj as Asset;
			if (asset != null)
			{
				if (asset._loading) return;
				
				// Add listeners to the loader
				var loaderAsDispatcher:IEventDispatcher = IEventDispatcher(asset._handler);
				loaderAsDispatcher.addEventListener(Event.COMPLETE, onAssetLoadComplete, false, 0, true);
				loaderAsDispatcher.addEventListener(IOErrorEvent.IO_ERROR, onAssetIOError, false, 0, true);
				loaderAsDispatcher.addEventListener(ProgressEvent.PROGRESS, onAssetProgress, false, 0, true);
				
				_loadingId = asset.id;
				asset._bytesLoaded = asset._bytesTotal = 0;
				asset._loading = true;
				
				if (hasEventListener(AssetEvent.ASSET_START))
					dispatchEvent(new AssetEvent(AssetEvent.ASSET_START, false, false, asset));
				
				// Execute callbacks
				if (asset.onStart != null) asset.onStart.apply(null, asset.onStartParams);
				
				// Begin loading the asset
				asset._handler.load(processURL(asset.uri), asset.context);
				return;
			}
			
			var assetQueue:AssetQueue = obj as AssetQueue;
			if (assetQueue != null)
			{
				assetQueue.load();
				return;
			}
		}
		
		/**
		 * Pauses an asset's load operation and removes any event listeners attached.
		 * @param	asset	The Asset to pause
		 */
		private function pauseObject(object:IQueueable):void
		{
			var asset:Asset = object as Asset;
			if (asset != null)
			{
				var loaderAsDispatcher:IEventDispatcher = IEventDispatcher(asset._handler);
				loaderAsDispatcher.removeEventListener(Event.COMPLETE, onAssetLoadComplete);
				loaderAsDispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onAssetIOError);
				loaderAsDispatcher.removeEventListener(ProgressEvent.PROGRESS, onAssetProgress);
				
				_loadingId = null;
				asset._handler.pauseLoad();
				asset._loading = false;
				return;
			}
			
			var queue:AssetQueue = object as AssetQueue;
			if (queue != null)
			{
				queue.pauseSilently();
				return;
			}
		}
		
		/**
		 * Pauses the queue silently, without modifying the <code>loading</code> property.
		 */
		private function pauseSilently():void
		{
			for each (var object:IQueueable in _queue)
			{
				pauseObject(object);
			}
		}
		
		/**
		 * Processes a URL and returns the full URL containing the base path.
		 * @param	uri	The uri to process
		 * @return	A String continaing the fully processed URL
		 */
		private function processURL(uri:String):String
		{
			// Add the query string
			var query:String = "";
			if (queryString)
			{
				if (queryString.substr(0, 1) == "?") query = queryString.substr(1);
				else query = queryString;
				
				query = (uri.indexOf("?") > -1 ? "&":"?") + query;
			}
			
			// Protocol supplied, or accessing the root, so just return the URI with the query
			if (uri.indexOf(":/") > -1 || uri.indexOf(":\\") > -1 || uri.substr(0, 1) == "/")
				return uri + query;
			
			// Get base URL
			var base:String = _path != null ? _path : AssetManager.getInstance().path;
			if (base == null) base = "";
			
			// Return base + URI + query
			return base + uri + query;
		}
		
		/**
		 * Removes an asset from the queue.
		 * @param	id	The id of the asset to remove from the queue
		 */
		private function removeFromQueue(id:String):void
		{
			var asset:IQueueable;
			for (var i:int = 0, len:int = _queue.length; i < len; i++)
			{
				asset = _queue[i];
				if (asset.id == id)
				{
					disposeAsset(asset as Asset);
					break;
				}
			}
			
			if (_loadingId == id) _loadingId = null;
			if (i == 0 && _loading) load();	// If the asset was currently being loaded, begin loading the next item in the queue
		}
		
		
		// EVENT HANDLERS
		// ------------------------------------------------------------------------------------------
		/**
		 * Executed when a child AssetQueue has completed loading all its assets.
		 * @param	e	The AssetEvent object
		 */
		private function onChildQueueComplete(e:AssetEvent):void
		{
			var assetQueue:AssetQueue = e.currentTarget as AssetQueue;
			var index:int = _queue.indexOf(assetQueue);
			
			// Remove child queue
			_queue.splice(index, 1);
			
			// Remove listeners
			assetQueue.removeEventListener(AssetEvent.QUEUE_COMPLETE, onChildQueueComplete);
			
			// If this queue is empty, it's complete, otherwise continue loading the next asset
			if (_queue.length == 0)
			{
				if (hasEventListener(AssetEvent.QUEUE_COMPLETE))
					dispatchEvent(new AssetEvent(AssetEvent.QUEUE_COMPLETE));
			}
			else if (_loading && _loadSequentially)
			{
				loadObject(_queue[0]);
			}
		}
		
		/**
		 * Executed when an asset has completed loading.
		 * @param	e	The Event object
		 */
		private function onAssetLoadComplete(e:Event):void
		{
			// Find the asset that was loaded within the queue
			var asset:Asset, index:int = -1;
			for (var i:int = 0, len:int = _queue.length; i < len; i++)
			{
				var f:Asset = _queue[i] as Asset;
				if (f != null && f._handler == e.target)
				{
					asset = f;
					index = i;
					break;
				}
			}
			
			if (index == -1) return;
			
			_queue.splice(index, 1); // Remove the asset from the queue
			
			// Remove event listeners
			var loaderAsDispatcher:IEventDispatcher = asset._handler as IEventDispatcher;
			if (loaderAsDispatcher != null)
			{
				loaderAsDispatcher.removeEventListener(Event.COMPLETE, onAssetLoadComplete);
				loaderAsDispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onAssetIOError);
				loaderAsDispatcher.removeEventListener(ProgressEvent.PROGRESS, onAssetProgress);
			}
			
			_loaded.push(asset);
			_loadingId = null;
			
			if (AssetManager.verbose)
				trace("AssetManager: Complete: " + asset.uri);
			
			if (hasEventListener(AssetEvent.ASSET_COMPLETE))
				dispatchEvent(new AssetEvent(AssetEvent.ASSET_COMPLETE, false, false, asset));
			
			// Execute callbacks
			if (asset.onComplete != null) asset.onComplete.apply(null, asset.onCompleteParams);
			asset.clean();
			
			// If the queue is empty, it's complete, otherwise continue loading the next asset
			if (_queue.length == 0)
			{
				if (hasEventListener(AssetEvent.QUEUE_COMPLETE))
					dispatchEvent(new AssetEvent(AssetEvent.QUEUE_COMPLETE));
			}
			else if (_loading && _loadSequentially)
			{
				loadObject(_queue[0]);
			}
		}
		
		/**
		 * Executed when an asset could not be loaded.
		 * @param	e	The IOErrorEvent object
		 */
		private function onAssetIOError(e:IOErrorEvent):void
		{
			var asset:Asset = getAssetInQueueByHandler(IFormatHandler(e.target));
			var wasLoading:Boolean = _loading;
			
			if (AssetManager.verbose)
				trace("AssetManager: Error: Asset '" + asset.id + "' could not be found: " + asset.uri);
			
			// Store the asset data
			var onError:Function = asset.onError, onErrorParams:Array = asset.onErrorParams;
			var assetId:String = asset.id;
			var assetData:* = asset.data;
			
			if (hasEventListener(AssetEvent.ASSET_FAIL))
				dispatchEvent(new AssetEvent(AssetEvent.ASSET_FAIL, false, false, asset));
			
			// Execute callbacks
			if (onError != null) onError.apply(null, onErrorParams);
			
			_loading = false;
			disposeAsset(asset);
			
			// Continue loading the queue
			_loading = wasLoading;
			if (_queue.length == 0)
			{
				if (hasEventListener(AssetEvent.QUEUE_COMPLETE))
					dispatchEvent(new AssetEvent(AssetEvent.QUEUE_COMPLETE));
			}
			else if (_loading && _loadSequentially)
			{
				loadObject(_queue[0]);
			}
		}	
		
		/**
		 * Executed when an asset's load progress changes.
		 * @param	e	The ProgressEvent object
		 */
		private function onAssetProgress(e:ProgressEvent):void
		{
			var asset:Asset = getAssetInQueueByHandler(IFormatHandler(e.target));
			if (asset == null) return;
			
			// Update asset progress
			asset._bytesLoaded = e.bytesLoaded;
			asset._bytesTotal = e.bytesTotal;
			
			// Don't dispatch any events if the total bytes is 0
			if (asset.bytesTotal == 0) return;
			
			if (hasEventListener(AssetProgressEvent.PROGRESS))
				dispatchEvent(new AssetProgressEvent(AssetProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal, asset));
				
			// Execute callbacks
			if (asset.onProgress != null) asset.onProgress.apply(null, asset.onProgressParams);
		}
		
		/**
		 * Executed when an XML cue has completed loading.
		 * @param	e	The Event object
		 */
		private function onXMLComplete(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			_loadingXML = false;
			
			if (hasEventListener(AssetEvent.LIST_COMPLETE))
				dispatchEvent(new AssetEvent(AssetEvent.LIST_COMPLETE, false, false, null, xml));
				
			addFromXML(xml);
			if (_loading) load();
		}
		
		/**
		 * Executed when an XML queue could not be loaded.
		 * @param	e	The IOErrorEvent object
		 */
		private function onXMLError(e:IOErrorEvent):void
		{
			_loadingXML = false;
			
			if (AssetManager.verbose)
				trace("AssetManager: Error: XML queue file could not be found.");
				
			if (hasEventListener(e.type)) dispatchEvent(e.clone());
		}
	}
}