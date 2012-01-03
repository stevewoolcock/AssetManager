/**
 * com.deadreckoned.assetmanager.IFormatHandler
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
	 * The IFormatHandler interface must be implemented by all registered file formats for the AssetManager. All format handlers should
	 * also either extends <code>flash.events.EventDispatcher</code> or implement the <code>flash.events.IEventDispatcher</code> interface.
	 */
	public interface IFormatHandler
	{
		/**
		 * A clean up routine that disposes all external references to prepare the class for garbage collection.
		 */
		function dispose():void;
		
		/**
		 * An Array of extensions the IFormatHandler supports.
		 */
		function get extensions():Array;
		
		/**
		 * Retrieves the contents of the loaded asset.
		 * @return	The contents of the loaded asset
		 */
		function getContent():*;
		
		/**
		 * The id of the IFormatHandler.
		 */
		function get id():String;
		
		/**
		 * Begins loading a asset from a specific URL.
		 * @param	uri		The URL of the asset to load
		 * @param	context	An optional load context object
		 */
		function load(uri:String, context:* = null):void;
		
		/**
		 * Pauses the loading of the asset.
		 */
		function pauseLoad():void;
	}
}