/**
 * com.deadreckoned.assetmanager.Asset
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
	import com.deadreckoned.assetmanager.formats.IFormatHandler;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	
	/**
	 * The Asset class contains data relating to a stored or loaded asset within an AssetQueue.
	 */
	public class Asset implements IQueueable
	{
		/**
		 * @private
		 */
		internal var _asset:*;
		
		/**
		 * @private
		 */
		internal var _bytesLoaded:int;
		
		/**
		 * @private
		 */
		internal var _bytesTotal:int;
		
		/**
		 * @private
		 */
		internal var _context:*;
		
		/**
		 * @private
		 */
		internal var _data:*;
		
		/**
		 * @private
		 */
		internal var _id:String;
		
		/**
		 * @private
		 */
		internal var _loading:Boolean;
		
		/**
		 * @private
		 */
		internal var _priority:int;
		
		/**
		 * @private
		 */
		internal var _type:String;
		
		/**
		 * @private
		 */
		internal var _uri:String;
		
		// Handlers
		/**
		 * @private
		 */
		internal var _handler:IFormatHandler;
		
		/**
		 * @private
		 */
		internal var onComplete:Function;
		
		/**
		 * @private
		 */
		internal var onCompleteParams:Array;
		
		/**
		 * @private
		 */
		internal var onError:Function;
		
		/**
		 * @private
		 */
		internal var onErrorParams:Array;
		
		/**
		 * @private
		 */
		internal var onProgress:Function;
		
		/**
		 * @private
		 */
		internal var onProgressParams:Array;
		
		/**
		 * @private
		 */
		internal var onStart:Function;
		
		/**
		 * @private
		 */
		internal var onStartParams:Array;
		
		/**
		 * The asset data. This is only available after the asset has completed loading. This value will be <code>null</code> if the asset has not completed loading.
		 */
		public function get asset():* { return _asset; }
		
		/**
		 * The raw asset data. This is only available after the asset has completed loading. This value will be <code>null</code> if the asset has not completed loading.
		 */
		public function get rawData():* { return (_handler != null) ? _handler.getRawContent() : null; }
		
		/**
		 * The current number of bytes loaded.
		 */
		public function get bytesLoaded():int { return _bytesLoaded; }
		
		/**
		 * The total size of the asset, in bytes.
		 */
		public function get bytesTotal():int { return _bytesTotal; }
		
		/**
		 * The context to use when loading the asset. The type of context depends on the asset being loaded (LoaderContext or SoundLoaderContext for sound files).
		 */
		public function get context():* { return _context; }
		public function set context(value:*):void
		{
			_context = value;
		}
		
		/**
		 * Custom data associated with the asset.
		 */
		public function get data():* { return _data; }
		public function set data(value:*):void
		{
			data = value;
		}
		
		/**
		 * The id of the asset.
		 */
		public function get id():String { return _id; }
		
		/**
		 * Determines if the asset is currently loading.
		 */
		public function get loading():Boolean { return _loading; }
		
		/**
		 * The type of the asset.
		 */
		public function get type():String { return _type; }
		
		/**
		 * The URI of the asset.
		 */
		public function get uri():String { return _uri; }
		
		/**
		 * The extension of the asset's URI.
		 */
		public function get extension():String { return !_uri ? "" : _uri.substr(_uri.lastIndexOf(".") + 1); }
		
		/**
		 * @inheritDoc
		 */
		public function get priority():int { return _priority; }
		
		/**
		 * Creates a new instance of the Asset class.
		 * @param	handler	The format handler instance to use
		 */
		public function Asset(handler:IFormatHandler = null):void
		{
			_handler = handler;
			
			if (_handler != null)
			{
				var dispatcher:IEventDispatcher = _handler as IEventDispatcher;
				dispatcher.addEventListener(Event.COMPLETE, onLoadCompleted, false, 0, true);
				dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onLoadFailed, false, 0, true);
			}
		}
		
		/**
		 * @private
		 */
		internal function dispose():void
		{
			clean();
			disposeHandler();
			
			_asset = null;
			_context = null;
			_data = null;
			_uri = _id = _type = null;
			_priority = _bytesLoaded = _bytesTotal = 0;
		}
		
		/**
		 * Generates a String representation of the object.
		 * @return	A String representation of the object.
		 */
		public function toString():String
		{
			return "(Asset id=" + id + ", priority=" + _priority + ", type=" + type + ", uri=" + uri + ")";
		}
		
		/**
		 * An internal method for cleaning up the asset's external references once loading has completed.
		 * @private
		 */
		internal function clean():void
		{
			// Remove callbacks
			onComplete = onError = onProgress = onStart = null;
			onCompleteParams = onErrorParams = onProgressParams = onStartParams = null;
		}
		
		/**
		 * Disposes of the asset's handler.
		 */
		private function disposeHandler():void
		{
			if (_handler != null)
			{
				var dispatcher:IEventDispatcher = _handler as IEventDispatcher;
				dispatcher.removeEventListener(Event.COMPLETE, onLoadCompleted);
				dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFailed);
				_handler.dispose();
			}
			
			_handler = null;
		}
		
		/**
		 * Executed when the asset has completed loading.
		 * @param	e	The Event object
		 */
		private function onLoadCompleted(e:Event):void
		{
			_asset = _handler.getContent();
		}
		
		/**
		 * Executed when the asset fails to load.
		 * @param	e	The IOErrorEvent object
		 */
		private function onLoadFailed(e:IOErrorEvent):void
		{
			_asset = null;
		}
	}
}