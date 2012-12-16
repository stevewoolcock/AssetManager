/**
 * com.deadreckoned.assetmanager.formats.GZipHandler
 *
 * Copyright (c) 2012 Stephen Woolcock
 * 23/11/2012 21:09
 *
 * @author Stephen Woolcock
 */

package com.deadreckoned.assetmanager.formats
{
	import com.deadreckoned.assetmanager.AssetManager;
	import com.probertson.utils.GZIPBytesEncoder;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class GZipHandler extends EventDispatcher implements IFormatHandler
	{
		static private var _gzip:GZIPBytesEncoder = new GZIPBytesEncoder();
		
		static public const TYPE:String = "gz";
		
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
			var handlerClass:Class = AssetManager.getFormatHandler(ext);
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