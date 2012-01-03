/**
 * com.deadreckoned.assetmanager.VariablesHandler
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
	import flash.net.URLVariables;
	
	/**
	 * The VariablesHandler handles the loading of variables in name/value pair format. It extends the GenericHandler class and loads
	 * files in text format, assuming them to be of name/value pair format (ie. <code>name1=value1&amp;name2=value2</code>) The data loaded
	 * by VariablesHandler is returned as a <code>URLVariables</code>.
	 */
	public class VariablesHandler extends GenericHandler
	{
		private var _data:URLVariables;
		
		/**
		 * Creates a new instance of the VariablesHandler class.
		 */
		public function VariablesHandler():void
		{
			//
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
			if (_data == null) _data = new URLVariables(String(_loader.data));
			return _data;
		}
	}
}