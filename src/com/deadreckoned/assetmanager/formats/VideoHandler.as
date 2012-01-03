/**
 * com.deadreckoned.assetmanager.VideoHandler
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

package com.deadreckoned.assetmanager.formats
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	/**
	 * The VideoHandler handles the loading of complete video files, for later playback.
	 */
	public class VideoHandler extends EventDispatcher implements IFormatHandler
	{
		private var _metaData:Object;
		private var _netConn:NetConnection;
		private var _netStream:NetStream;
		private var _loadTimer:Timer;
		
		/**
		 * @inheritDoc
		 */
		public function get id():String { return "vid"; }
		
		/**
		 * @inheritDoc
		 */
		public function get extensions():Array { return [ "flv", "f4v", "mp4" ]; }
		
		/**
		 * Creates a new instance of the VideoHandler class.
		 */
		public function VideoHandler ():void
		{
			_netConn = new NetConnection();
			_netConn.connect(null);
			
			_netStream = new NetStream(_netConn);
			_netStream.client = {
				onMetaData: function (data:Object):void
				{
					_metaData = data;
				}
			};
			
			_netStream.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError, false, 0, true);
			_netStream.pause();
			
			_loadTimer = new Timer(100);
			_loadTimer.addEventListener(TimerEvent.TIMER, onLoadTimerTick, false, 0, true);
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			try { _netStream.close(); } catch (e:Error) { }
			try { _netConn.close(); } catch (e:Error) { }
			
			_netStream.client = {}; // Can't set it to null, apparently...
			_netStream = null;
			_netConn = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getContent():*
		{
			return { netStream: _netStream, metaData: _metaData };
		}
		
		/**
		 * @inheritDoc
		 */
		public function load(uri:String, context:* = null):void
		{
			_netStream.play(uri);
			_netStream.pause();
			_loadTimer.start();
		}
		
		/**
		 * @inheritDoc
		 */
		public function pauseLoad():void
		{
			try { _netStream.close(); } catch (e:Error) { }
			_loadTimer.stop();
		}
		
		
		// EVENT HANDLERS
		// ------------------------------------------------------------------------------------------
		/**
		 * Executed when the load timer ticks.
		 * @param	e	The TimerEvent object.
		 */
		private function onLoadTimerTick(e:TimerEvent):void
		{
			if (hasEventListener(ProgressEvent.PROGRESS))
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _netStream.bytesLoaded, _netStream.bytesTotal));
			
			// Has the stream completed loading?
			if (_netStream.bytesLoaded >= _netStream.bytesTotal)
			{
				_loadTimer.stop();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * Executed when the file could not be loaded.
		 * @param	e	The IOErrorEvent object.
		 */
		private function onLoadIOError(e:IOErrorEvent):void
		{
			if (hasEventListener(e.type))
				dispatchEvent(e.clone());
		}
	}
}