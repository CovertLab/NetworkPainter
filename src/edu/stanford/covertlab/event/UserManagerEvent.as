package edu.stanford.covertlab.event 
{
	import flash.events.Event;
	
	/**
	 * Event class for UserManager. Defines several events.
	 * <ul>
	 * <li>user login: called when user logs in</li>
	 * <li>user logoff: called when user clicks logoff in LogoffWindow</li>
	 * <li>user end session: called when user automatically logged off due to inactivity</li>
	 * <li>user check timeout: called every hour to check if there has been user activity in the past hour.</li>
	 * 	   if there has been activity, nothing happens. if there has been no activity, the user is automatically logged off</li>
	 * <li>user save: called when user edits their profile using the UserAccountWindow and the profile is committed to the database</li>
	 * <li>user update: called when user information in the UserManager is updated either from the database on login or by the user
	 *     using the UserAccountWindow</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.manager.UserManager
	 * @see edu.stanford.covertlab.window.LogoffWindow
	 * @see edu.stanford.covertlab.window.UserAccountWindow
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class UserManagerEvent extends Event
	{
		public var timedOut:Boolean;
		public var userData:Object;
		public var oldUserData:Object;
		
		public function UserManagerEvent(type:String, timedOut:Boolean=false,userData:Object=null,oldUserData:Object=null)
		{
			this.timedOut = timedOut;
			this.userData = userData;
			this.oldUserData = oldUserData;
			super(type);
		}
		
		public static const USER_LOGIN:String = "userLogin";
		public static const USER_LOGOFF:String = "userLogoff";
		public static const USER_ENDSESSION:String = "userEndSession";
		public static const USER_CHECK_TIMEOUT:String = "userCheckTimeout";
		public static const USER_SAVE:String = "userSaves";
		public static const USER_UPDATE:String = "userUpdate";
	}
	
}