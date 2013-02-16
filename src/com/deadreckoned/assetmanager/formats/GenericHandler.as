/**
 * com.deadreckoned.assetmanager.GenericHandler
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

package com.deadreckoned.assetmanager.formats
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * The GenericHandler class handles the loading of generic files using a URLLoader. GenericHandler can be used for loading
	 * text-based formats, such a Text or XML files, or can be extended to expand on the features of URLLoader.
	 */
	public class GenericHandler extends EventDispatcher implements IFormatHandler
	{
		protected var _loaded:Boolean;
		protected var _loader:URLLoader;
		
		/**
		 * @inheritDoc
		 */
		public function get id ():String { return null; }
		
		/**
		 * @inheritDoc
		 */
		public function get extensions():Array { return null; }
		
		/**
		 * Indicates if the file has been loaded.
		 */
		public function get loaded():Boolean { return _loaded; }
		
		/**
		 * Creates a new instance of the GenericHandler class.
		 */
		public function GenericHandler():void
		{
			_loader = new URLLoader();
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
			return _loader.data;
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
			_loaded = false;
			_loader.load(new URLRequest(uri));
		}
		
		/**
		 * @inheritDoc
		 */
		public function loadBytes(bytes:ByteArray, context:* = null):void
		{
			_loaded = true;
			_loader.data = bytes;
			dispatchEvent(new Event(Event.COMPLETE));
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