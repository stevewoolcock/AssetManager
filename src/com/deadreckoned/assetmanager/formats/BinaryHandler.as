/**
 * com.deadreckoned.assetmanager.BinaryHandler
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
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * The BinaryHandler class handles the loading of binary files. It extends the GenericHandler class and loads files in binary
	 * format. The data loaded by BinaryHandler is returned as a <code>ByteArray</code>.
	 */
	public class BinaryHandler extends GenericHandler
	{
		private var _data:ByteArray;
		
		/**
		 * @inheritDoc
		 */
		public override function get id():String { return "bin"; }
		
		/**
		 * Creates a new instance of the BinaryHandler class.
		 */
		public function BinaryHandler():void
		{
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function dispose():void
		{
			_data = null;
			super.dispose();
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getContent():*
		{
			if (!loaded) return null;
			if (_data == null) _data = ByteArray(_loader.data);
			return _data;
		}
	}
}