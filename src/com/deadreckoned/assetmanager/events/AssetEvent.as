/**
 * com.deadreckoned.assetmanager.events.AssetEvent
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
	
	/**
	 * AssetEvent instances are dispatched by AssetManager instances, and relate to the state of the AssetManager or one if its files.
	 */
	public class AssetEvent extends Event
	{
		/**
		 * The AssetEvent.ASSET_COMPLETE constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetComplete</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has completed loading the file.</td></tr>
		 * <tr><td>fileId</td><td>The id of the file that has completed loading.</td></tr>
		 * <tr><td>data</td><td>Any custom data that was specified when the file was added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetComplete
		 */
		static public const ASSET_COMPLETE:String = "AssetComplete";
		
		/**
		 * The AssetEvent.ASSET_START constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetStart</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has completed loading the file.</td></tr>
		 * <tr><td>fileId</td><td>The id of the file that has completed loading.</td></tr>
		 * <tr><td>data</td><td>Any custom data that was specified when the file was added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetStart
		 */
		static public const ASSET_START:String = "AssetStart";
		
		/**
		 * The AssetEvent.ASSET_FAIL constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetFail</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has completed loading the file.</td></tr>
		 * <tr><td>fileId</td><td>The id of the file that has completed loading.</td></tr>
		 * <tr><td>data</td><td>Any custom data that was specified when the file was added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetFail
		 */
		static public const ASSET_FAIL:String = "AssetFail";
		
		/**
		 * The AssetEvent.LIST_COMPLETE constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetListComplete</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has completed loading the XML file list.</td></tr>
		 * <tr><td>data</td><td>The XML file list containing the file definitions that will be added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetListComplete
		 */
		static public const LIST_COMPLETE:String = "AssetListComplete";
		
		/**
		 * The AssetEvent.LIST_ADDED constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetListAdded</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has added the XML file list to the queue.</td></tr>
		 * <tr><td>data</td><td>The XML file list containing the file definitions that were added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetListAdded
		 */
		static public const LIST_ADDED:String = "AssetListAdded";
		
		/**
		 * The AssetEvent.QUEUE_COMPLETE constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetQueueComplete</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has completed loading its queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetQueueComplete
		 */
		static public const QUEUE_COMPLETE:String = "AssetQueueComplete";
		
		/**
		 * The AssetEvent.QUEUE_START constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetQueueStart</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has completed loading its queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetQueueStart
		 */
		static public const QUEUE_START:String = "AssetQueueStart";
		
		/**
		 * The AssetEvent.QUEUE_STOP constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>AssetQueueStop</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the AssetEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The AssetManager instance that has completed loading its queue.</td></tr>
		 * </table>
		 *
		 * @eventType AssetQueueStop
		 */
		static public const QUEUE_STOP:String = "AssetQueueStop";
		
		private var _asset:Asset;
		private var _data:Object;
		
		/**
		 * The asset the event relates to.
		 */
		public function get asset ():Asset { return _asset; }
		
		/**
		 * An object passed to the event via the dispatching object. This is usually custom data that was specified for the file the event relates to.
		 */
		public function get data ():Object { return _data; }
		
		/**
		 * Creates a new instance of the AssetEvent class
		 * @param	type		The type of event to create
		 * @param	bubbles		Specifies if bubbling is enabled for this event
		 * @param	cancelable	Specifies if this event can be canceled
		 */
		public function AssetEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, asset:Asset = null, data:Object = null):void
		{
			super(type, bubbles, cancelable);
			_asset = asset;
			_data = data;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new AssetEvent(type, bubbles, cancelable, _asset, _data);
		}
	}
}