//Source: http://blog.another-d-mention.ro/programming/how-to-identify-at-runtime-if-swf-is-in-debug-or-release-mode-build/
package org.adm.runtime
{
	import flash.system.Capabilities;
 
	public class ModeCheck
	{
		/**
		 * Returns true if the user is running the app on a Debug Flash Player.
		 * Uses the Capabilities class
		 **/
		public static function isDebugPlayer() : Boolean
		{
			return Capabilities.isDebugger;
		}
 
		/**
		 * Returns true if the swf is built in debug mode
		 **/
		public static function isDebugBuild() : Boolean
		{
			var st:String = new Error().getStackTrace();
			return (st && st.search(/:[0-9]+]$/m) > -1);
		}
 
		/**
		 * Returns true if the swf is built in release mode
		 **/
		public static function isReleaseBuild() : Boolean
		{
			return !isDebugBuild();
		}
	}
}