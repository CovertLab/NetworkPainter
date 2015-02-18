package edu.stanford.covertlab.manager 
{
	import br.com.stimuli.string.printf;
	import edu.stanford.covertlab.event.UserManagerEvent;
	import edu.stanford.covertlab.window.LogoffWindow;
	import edu.stanford.covertlab.window.UserAccountWindow
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import org.adm.runtime.ModeCheck;
	import phi.db.Query;
	import phi.interfaces.IDatabase;
	import phi.interfaces.IQuery;
	
	/**
	 * Implements user security and manages user id and profile. Also controls the UserAccountWindow 
	 * which allows a user to edit their profile and the LogoffWindow which allows
	 * a user to logoff properly.
	 *
	 * <p>Security
	 * <ol>
	 * <li>Retrieves user id from PHP session var set on login</li>
	 * <li>Loads user profile from database</li>
	 * <li>(If logoffError was true NetworkManager will recover last autosave)</li>
	 * <li>Sets logoffError to true.</li>
	 * <li>Starts timer which checks for user activity</li>
	 * <li>After period of 1 hr without user activity, automatically logs off user</li>
	 * <li>If a user exists using the LogoffWindow set logoffError to false</li>
	 * </ol>
	 * </p>
	 * 
	 * @see edu.stanford.covertlab.window.UserAccountWindow
	 * @see edu.stanford.covertlab.window.LogoffWindow
	 * @see edu.stanford.covertlab.networkpainter.manager.NetworkManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class UserManager extends EventDispatcher
	{
		private var application:Application;		
		private var db:IDatabase;
		
		private var loginUserQuery:IQuery;
		private var saveUserQuery:IQuery;
		private var logoffUserQuery:IQuery;
		
		[Bindable] public var isGuest:Boolean;
		[Bindable] public var id:uint;
		[Bindable] public var firstname:String;
		[Bindable] public var lastname:String;
		[Bindable] public var email:String;
		[Bindable] public var principalinvestigator:String;
		[Bindable] public var organization:String;
		public var autosaveid:uint;
		public var logofferror:Boolean;
		
		private var timeLastUserActivity:uint = 0;
		private var timeoutTimer:Timer;
		
		private var httpService:HTTPService;
				
		public var logoffWindow:LogoffWindow;
		public var userAccountWindow:UserAccountWindow;
		
		public static const TIMEOUT_TIME:uint = 60 * 60 * 1000;

		public function UserManager(application:Application, db:IDatabase) 
		{
			this.application = application;
			this.db = db;
			
			loginUserQuery = new Query();
			loginUserQuery.connect("conn", db);
			loginUserQuery.addEventListener(Query.QUERY_END, loginUserQueryHandler);
			loginUserQuery.addEventListener(Query.QUERY_ERROR, queryErrorHandler);
			
			saveUserQuery = new Query();
			saveUserQuery.connect("conn", db);
			saveUserQuery.addEventListener(Query.QUERY_END, saveUserQueryHandler);
			saveUserQuery.addEventListener(Query.QUERY_ERROR, queryErrorHandler);
			
			logoffUserQuery = new Query();
			logoffUserQuery.connect("conn", db);
			logoffUserQuery.addEventListener(Query.QUERY_END, logoffUserQueryHandler);
			logoffUserQuery.addEventListener(Query.QUERY_ERROR, queryErrorHandler);
			
			getSessionVars();			
			
			userAccountWindow = new UserAccountWindow(application, this);
			logoffWindow = new LogoffWindow(application, this);
			
			timeoutTimer = new Timer(TIMEOUT_TIME, 0);
			timeoutTimer.addEventListener(TimerEvent.TIMER, checkTimeout);
			timeoutTimer.start();
		}
		
		/********************************************************************
		 * login security
		 * *****************************************************************/
		private function getSessionVars():void
		{	
			httpService = new HTTPService();
			httpService.url = 'services/getVars.php';
			httpService.addEventListener(ResultEvent.RESULT, loginUser);
			httpService.send();
		}
		
		/********************************************************************
		 * login user, get profile from database
		 * *****************************************************************/
		private function loginUser(event:ResultEvent):void {
			if (httpService.lastResult.response.isguest == '1') {
				var oldUserData:Object = {
					isGuest:isGuest,
					id:id, 
					firstname:firstname, 
					lastname:lastname, 
					email:email, 
					principalinvestigator:principalinvestigator, 
					organization:organization,
					autosaveid:autosaveid,
					logofferror:logofferror 
					};
					
				isGuest = true;
				id = 0;
				firstname = 'Guest';
				lastname = '';
				email = '';
				principalinvestigator = '';
				organization = '';
				autosaveid = 0;
				logofferror = false;
				
				var userData:Object = {
					isGuest:isGuest,
					id:id, 
					firstname:firstname, 
					lastname:lastname, 
					email:email, 
					principalinvestigator:principalinvestigator, 
					organization:organization,
					autosaveid:autosaveid,
					logofferror:logofferror };
				
				dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_LOGIN, false, userData, oldUserData));
				dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_UPDATE, false, userData, oldUserData));
				return;
			}
			
			id = parseInt(httpService.lastResult.response.userid);
			if (!isNaN(id)) {
				//ExternalInterface.call('console.log', 'userid', id);
				loginUserQuery.execute('CALL loginuser(' + id + ');');
			} else {
				Alert.show("Invalid Session: Please relogin.", "Redirect Alert", Alert.OK, null, logoffUser);
			}
		}

		private function loginUserQueryHandler(event:Event):void {
			//ExternalInterface.call('console.log', loginUserQuery, loginUserQuery.getRecords());
			var userData:Object = loginUserQuery.getRecords().getItemAt(0);
			var oldUserData:Object = { 
				isGuest:isGuest, 
				id:id, 
				firstname:firstname, 
				lastname:lastname, 
				email:email, 
				principalinvestigator:principalinvestigator, 
				organization:organization, 
				autosaveid:autosaveid, 
				logofferror:logofferror 
				};

			isGuest = false;
			firstname = userData.firstname;
			lastname = userData.lastname;
			email = userData.email;
			principalinvestigator = userData.principalinvestigator;
			organization = userData.organization;
			autosaveid = userData.autosaveid;
			logofferror = userData.logofferror;
			
			dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_LOGIN, false, userData, oldUserData));
			dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_UPDATE, false, userData, oldUserData));
		}

		/********************************************************************
		 * save user profile to database
		 * *****************************************************************/
		public function saveUser():void {
			saveUserQuery.execute(printf("CALL saveUser(%d,'%s','%s','%s','%s')",
				id, firstname.replace(/'/g, "\'"), 
				lastname.replace(/'/g, "\'"), 
				principalinvestigator.replace(/'/g, "\'"), 
				organization.replace(/'/g, "\'")));
		}
		
		private function saveUserQueryHandler(event:Event):void {
			var userData:Object = saveUserQuery.getRecords().getItemAt(0);
			var oldUserData:Object = {
				isGuest:isGuest, 
				id:id, 
				firstname:firstname, 
				lastname:lastname, 
				email:email, 
				principalinvestigator:principalinvestigator,
				organization:organization, 
				autosaveid:autosaveid,
				logofferror:logofferror 
				};

			isGuest = false;
			id = userData.id;
			firstname = userData.firstname;
			lastname = userData.lastname;
			email = userData.email;
			principalinvestigator = userData.principalinvestigator;
			organization = userData.organization;
			autosaveid = userData.autosaveid;
			logofferror = userData.logofferror;
			
			dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_SAVE, false, userData, oldUserData));
			
			userAccountWindow.close();
		}
	
		/********************************************************************
		 * time since last user activity
		 * *****************************************************************/
		public function setLastUserActivity(event:Event=null):void {
			timeLastUserActivity = getTimer();
		}
		
		public function get timedOut():Boolean {
			return (getTimer() - timeLastUserActivity > TIMEOUT_TIME);
		}
		
		public function set timedOut(value:Boolean):void { }	
		
		private function checkTimeout(event:TimerEvent):void {
			if (timedOut) {
				endSession();
				Alert.show('Session timed out. Please relogin.', 'Redirect Alert', Alert.OK, null, logoffUser);
			}else{
				dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_CHECK_TIMEOUT, timedOut));
			}
		}
		
		/********************************************************************
		 * logoff
		 * *****************************************************************/	 
		public function logoffUser(event:Event, logoffError:Boolean = true):void {
			if (isGuest){
				endSession();
				ExternalInterface.call('eval', 'loggingOff=true;');
				navigateToURL(new URLRequest('login.php?cmd=logoff'), '_self');
				dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_LOGOFF, true));
				return;
			}
			
			logoffUserQuery.execute('CALL logoffuser(' + id + ',' + logoffError + ');');
		}
		
		private function logoffUserQueryHandler(event:Event):void {
			endSession();
			ExternalInterface.call('eval', 'loggingOff=true;');
			navigateToURL(new URLRequest('login.php?cmd=logoff'), '_self');
			dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_LOGOFF, true));
		}
			
		private function endSession():void{
			httpService.url = 'services/endSession.php';
			httpService.removeEventListener(ResultEvent.RESULT, loginUser);
			httpService.send();
			dispatchEvent(new UserManagerEvent(UserManagerEvent.USER_ENDSESSION, true));
		}
				
		/********************************************************************
		 * query error handler
		 * *****************************************************************/
		private function queryErrorHandler(event:Event):void {
			if (ModeCheck.isDebugBuild()) {
				trace(event.target.getError());
			}
			Alert.show('Please retry last action.', 'Database Connection Error.');
		}	
	}	
}