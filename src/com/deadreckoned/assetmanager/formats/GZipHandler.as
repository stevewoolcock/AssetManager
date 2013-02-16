/**
 * com.deadreckoned.assetmanager.formats.GZipHandler
 * 
 * Copyright (c) 2013 Stephen Woolcock
 * 
 * GZipHandler utilises and required Paul Robertson's Actionscript GZIP encoding library.
 * The latest version can be downloaded here:
 *    http://probertson.com/projects/gzipencoder/
 * Download the SWC and add it to your project
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

package com.deadreckoned.assetmanager.formats
{
	import com.probertson.utils.GZIPBytesEncoder;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class GZipHandler extends EventDispatcher implements IFormatHandler
	{
		static private var _gzip:GZIPBytesEncoder = new GZIPBytesEncoder();
		static private var _handlerClassByExtension:Dictionary = new Dictionary(true);
		
		static public const TYPE:String = "gz";
		
		/**
		 * Determines wether or not the '.gz' extension is automatically appended to a URI when loading an asset, if required.
		 */
		static public var autoAppendGZExtension:Boolean = true;
		
		private var _context:*;
		private var _loaded:Boolean;
		private var _data:*;
		private var _uri:String;
		protected var _loader:URLLoader;
		
		/**
		 * @inheritDoc
		 */
		public function get id ():String { return "gz"; }
		
		/**
		 * @inheritDoc
		 */
		public function get extensions():Array { return [ "gz" ]; }
		
		/**
		 * Indicates if the file has been loaded.
		 */
		public function get loaded():Boolean { return _loaded; }
		
		/**
		 * Creates a new instance of the GZipHandler class.
		 * GZipHandler utilises and required Paul Robertson's Actionscript GZIP encoding library.
		 * The latest version can be downloaded here:
		 *    http://probertson.com/projects/gzipencoder/
		 * Download the SWC and add it to your project
		 */
		public function GZipHandler():void
		{
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			_loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError, false, 0, true);
		}
		
		/**
		 * Adds a decompression handler type.
		 * @param	handlerClass	The handler class
		 * @param	extension		The extension to use the handler on
		 */
		static public function addHandler(handlerClass:Class, extension:String):void
		{
			_handlerClassByExtension[extension] = handlerClass;
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			try { _loader.close(); } catch (e:Error) { }
			_loader = null;
			_loaded = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getContent():*
		{
			if (!_loaded) return null;
			return _data;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getRawContent():*
		{
			if (!_loaded) return null;
			return _loader.data;
		}
		
		/**
		 * @inheritDoc
		 */
		public function load(uri:String, context:* = null):void
		{
			try { _loader.close(); } catch (e:Error) { }
			
			_uri = uri;
			_context = context;
			_loaded = false;
			
			// Add Gzip extension if required
			if (autoAppendGZExtension)
			{
				if (uri.indexOf(".gz") == -1)
					uri += ".gz";
			}
			
			_loader.load(new URLRequest(uri));
		}
		
		/**
		 * @inheritDoc
		 */
		public function loadBytes(bytes:ByteArray, context:* = null):void
		{
			_loader.data = bytes;
			onLoadComplete(null);
		}
		
		/**
		 * @inheritDoc
		 */
		public function pauseLoad():void
		{
			try { _loader.close(); } catch (e:Error) { }
		}
		
		
		// EVENT HANDLERS
		// ------------------------------------------------------------------------------------------
		/**
		 * Executed when the file has completed loading.
		 * @param	e	The Event object
		 */
		private function onLoadComplete(e:Event):void
		{
			_loaded = true;
			
			// Decompress data
			var unzipped:ByteArray = _gzip.uncompressToByteArray(_loader.data);
			
			// Attempt to determine the file type from the extension
			var uri:String = _uri.replace("." + extensions[0], "");		// Remove gz extension
			var ext:String = uri.substring(uri.lastIndexOf(".") + 1);	// Extract extension
			
			// Get handler for extension
			var handlerClass:Class = _handlerClassByExtension[ext];
			if (handlerClass == null)
				throw new ArgumentError("No format handler with the type '" + ext + "' has been registered. Use AssetManager.registerFormat() to register new or custom formats.");
				
			var handler:IFormatHandler = new handlerClass();
			handler.loadBytes(unzipped, _context);
			_data = handler.getContent();
			
			if (hasEventListener(e.type))
				dispatchEvent(e.clone());
		}
		
		/**
		 * Executed when the file could not be loaded.
		 * @param	e	The IOErrorEvent object
		 */
		private function onLoadIOError(e:IOErrorEvent):void
		{
			if (hasEventListener(e.type))
				dispatchEvent(e.clone());
		}
		
		/**
		 * Executed when the file's load progress changes.
		 * @param	e	The ProgressEvent object
		 */
		private function onLoadProgress(e:ProgressEvent):void
		{
			if (hasEventListener(e.type))
				dispatchEvent(e.clone());
		}
	}
}