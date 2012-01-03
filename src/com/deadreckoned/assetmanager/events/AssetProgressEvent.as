/**
 * com.deadreckoned.assetmanager.events.AssetProgressEvent
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

package com.deadreckoned.assetmanager.events
{
	import com.deadreckoned.assetmanager.Asset;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	/**
	 * AssetProgressEvent instances are dispatched by AssetManager instances, and relate to the load progress state of files
	 * being loaded by a AssetManager instance.
	 */
	public class AssetProgressEvent extends ProgressEvent
	{
		/**
		 * The AssetProgressEvent.PROGRESS constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetComplete</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>bytesLoaded</td><td>The number of items or bytes loaded at the time the listener processes the event.</td></tr>
		 * <tr><td>bytesTotal</td><td>The total number of items or bytes that ultimately will be loaded if the loading process succeeds.</td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The object reporting progress.</td></tr>
		 * <tr><td>fileId</td><td>The id of the file that the event relates to.</td></tr>
		 * </table>
		 *
		 * @eventType AssetProgress
		 */
		static public const PROGRESS:String = "AssetProgress";
		
		private var _asset:Asset;
		
		/**
		 * The asset the event relates to.
		 */
		public function get asset():Asset { return _asset; }
		
		/**
		 * Creates a new instance of the AssetProgressEvent class
		 * @param	type		The type of event to create
		 * @param	bubbles		Specifies if bubbling is enabled for this event
		 * @param	cancelable	Specifies if this event can be canceled
		 */
		public function AssetProgressEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, bytesLoaded:uint = 0, bytesTotal:uint = 0, asset:Asset = null):void
		{
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
			_asset = asset;
		}
	}
}