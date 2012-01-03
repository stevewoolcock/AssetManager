/**
 * com.deadreckoned.assetmanager.IQueueable
 *
 * Copyright (c) 2012 Stephen Woolcock
 *
 * @author Stephen Woolcock
 */

package com.deadreckoned.assetmanager
{
	
	internal interface IQueueable
	{
		/**
		 * The priority of the object.
		 */
		function get priority():int;
		
		/**
		 * The id of the object.
		 */
		function get id():String;
	}
}