/**
 * com.deadreckoned.assetmanager.SWFHandler
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
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	/**
	 * The SWFHandler handles the loading of Flash SWF files. The data loaded by SWFHandler is returned as a <code>DisplayObject</code>.
	 */
	public class SWFHandler extends EventDispatcher implements IFormatHandler
	{
		private var _loaded:Boolean;
		protected var _loader:Loader;
		
		/**
		 * @inheritDoc
		 */
		public function get id():String { return "swf"; }
		
		/**
		 * @inheritDoc
		 */
		public function get extensions():Array { return [ "swf" ]; }
		
		/**
		 * Indicates if the file has been loaded.
		 */
		public function get loaded():Boolean { return _loaded; }
		
		/**
		 * Creates a new instance of the SWFHandler class.
		 */
		public function SWFHandler():void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError, false, 0, true);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			
			try { _loader.close(); } catch (e:Error) { }
			try { _loader.unloadAndStop(true); } catch (e:Error) { }
			
			_loader = null;
			_loaded = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getContent():*
		{
			if (!_loaded) return null;
			return _loader.content;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getRawContent():*
		{
			if (!_loaded) return null;
			return _loader.content;
		}
		
		/**
		 * @inheritDoc
		 */
		public function load(uri:String, context:* = null):void
		{
			_loaded = false;
			_loader.load(new URLRequest(uri), context as LoaderContext);
		}
		
		/**
		 * @inheritDoc
		 */
		public function loadBytes(bytes:ByteArray, context:* = null):void
		{
			_loaded = false;
			_loader.loadBytes(bytes, context as LoaderContext);
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