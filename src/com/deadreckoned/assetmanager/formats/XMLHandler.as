/**
 * com.deadreckoned.assetmanager.XMLHandler
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
	
	/**
	 * The XMLHandler handles the loading of XML files. It extends the GenericHandler class. The data loaded by XMLHandler is
	 * returned as an <code>XML</code> object.
	 */
	public class XMLHandler extends GenericHandler
	{
		private var _data:XML;
		
		/**
		 * @inheritDoc
		 */
		public override function get id():String { return "xml"; }
		
		/**
		 * @inheritDoc
		 */
		public override function get extensions():Array { return [ "xml", "htm", "html" ]; }
		
		/**
		 * Creates a new instance of the XMLHandler class
		 */
		public function XMLHandler ()
		{
			super();
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
			if (_data == null) _data = new XML(_loader.data);
			return _data;
		}
	}
}