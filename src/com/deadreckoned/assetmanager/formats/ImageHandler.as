/**
 * com.deadreckoned.assetmanager.ImageHandler
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
 * @version 1.0
 * @link blog.deadreckoned.com
*/

package com.deadreckoned.assetmanager.formats
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * The ImageHandler class handles the loading of image files. It supports the loading and retrieving of images in JPEG, PNG or GIF formats.
	 * The data loaded by ImageHandler is returned as a <code>BitmapData</code>.
	 */
	public class ImageHandler extends SWFHandler
	{
		private var _bitmapData:BitmapData;
		
		/**
		 * @inheritDoc
		 */
		public override function get id():String { return "img"; }
		
		/**
		 * @inheritDoc
		 */
		public override function get extensions():Array { return [ "jpg", "jpe", "jpeg", "gif", "png" ]; }
		
		/**
		 * Creates a new instance of the ImageHandler class
		 */
		public function ImageHandler():void
		{
			//
		}
		
		/**
		 * @inheritDoc
		 */
		public override function dispose():void
		{
			super.dispose();
			if (_bitmapData != null)
			{
				_bitmapData.dispose();
				_bitmapData = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getContent():*
		{
			if (!loaded) return null;
			if (_bitmapData == null) _bitmapData = Bitmap(_loader.content).bitmapData;
			return _bitmapData;
		}
	}
}