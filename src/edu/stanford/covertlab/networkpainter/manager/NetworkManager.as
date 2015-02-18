package edu.stanford.covertlab.networkpainter.manager 
{
	import br.com.stimuli.string.printf;
	import com.adobe.serialization.json.JSON;
	import edu.stanford.covertlab.diagram.core.Diagram;
	import edu.stanford.covertlab.diagram.core.Membrane;
	import edu.stanford.covertlab.diagram.panel.CompartmentsPanel;
	import edu.stanford.covertlab.networkpainter.event.NetworkManagerEvent;
	import edu.stanford.covertlab.event.UserManagerEvent;
	import edu.stanford.covertlab.manager.UserManager;
	import edu.stanford.covertlab.networkpainter.ExchangeFormat.BioPax;
	import edu.stanford.covertlab.networkpainter.ExchangeFormat.CellML;
	import edu.stanford.covertlab.networkpainter.ExchangeFormat.SBML;
	import edu.stanford.covertlab.networkpainter.window.ImportNetworkWindow;
	import edu.stanford.covertlab.networkpainter.window.ManageNetworksWindow;
	import edu.stanford.covertlab.networkpainter.window.NetworkPropertiesWindow;
	import edu.stanford.covertlab.networkpainter.window.OpenNetworkWindow;
	import edu.stanford.covertlab.networkpainter.window.SaveAsNetworkWindow;	
	import edu.stanford.covertlab.service.NetworkPainter;
	import edu.stanford.covertlab.util.AS2MXML;
	import edu.stanford.covertlab.util.AS2XML;
	import edu.stanford.covertlab.util.HTML;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	import phi.db.Query;
	import phi.interfaces.IDatabase;
	import phi.interfaces.IQuery;
	
	/**
	 * Handles several network operations.
	 * <ul>
	 * <li>create new network</li>
	 * <li>retrieve list of networks a user has permissions on</li>
	 * <li>loading, saving from/to database, to/from diagram</li>
	 * <li>network permissions, network publishing</li>
	 * <li>network locking (prevent multiple users from simultaneously editing a network)</li>
	 * <li>rename, delete network</li>
	 * <li>default network properties
	 *   <ul>
	 *   <li>styles</li>
	 *   <li>compartments</li>
	 *   <li>size</li>
	 *   <li>frame rate, repetitions</li>
	 *   <li>node sep, rank sep</li>
	 *   </ul></li>
	 * <li>auto save</li>
	 * <li>auto recovery on user login if logoffError is true</li>
	 * <li>exporting current network in diagram to several formats
	 *   <ul>
	 *   <li>raster graphics: png, jpeg, gif</li>
	 *   <li>vector graphics: svg, pdf</li>
	 *   <li>exchange formats: BioPax, CellML, SBML</li>
	 *   <li>xml</li>
	 *   </ul></li>
	 * <li>import network from xml</li>
	 * <li>import network from a pathway database (KEGG, Reactome, etc.)</li>
	 * <li>print network</li>
	 * </ul>
	 * 
	 * @see edu.stanford.covertlab.networkpainter.window.OpenNetworkWindow
	 * @see edu.stanford.covertlab.networkpainter.window.SaveAsNetworkWindow
	 * @see edu.stanford.covertlab.networkpainter.window.ManageNetworksWindow
	 * @see edu.stanford.covertlab.networkpainter.window.NetworkPropertiesWindow
	 * @see edu.stanford.covertlab.networkpainter.window.ImportNetworkWindow
	 * @see edu.stanford.covertlab.manager.UserManager
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @author Harendra Guturu, hguturu@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/23/2009
	 */
	public class NetworkManager extends EventDispatcher
	{		
		private var application:Application;
		private var userManager:UserManager;
		private var networkManager:NetworkManager;
		private var diagram:Diagram;		
		private var db:IDatabase;
		private var networkPainter:NetworkPainter;
				
		[Bindable] public var networks:ArrayCollection; // has a permissions field plus those in networks table
		[Bindable] public var networkDetails:Object;
		[Bindable] public var networkPermissions:ArrayCollection;
		
		[Bindable] public var id:uint;
		[Bindable] public var name:String;
		[Bindable] public var description:String;
		[Bindable] public var publicstatus:String;
		[Bindable] public var owner:String;
		[Bindable] public var creation:String;
		[Bindable] public var lastsave:String;
		[Bindable] public var locked:Boolean;
		[Bindable] public var lockuserid:uint;
		[Bindable] public var lockuser:String;
		[Bindable] public var permissions:String;
		
		public var width:uint;
		public var height:uint;
		public var showPores:Boolean;
		public var poreFillColor:uint;
		public var poreStrokeColor:uint;
		public var membraneHeight:Number;
		public var membraneCurvature:Number;
		public var minCompartmentHeight:Number;
		public var ranksep:Number;
		public var nodesep:Number;
		public var animationFrameRate:Number;
		public var loopAnimation:Boolean;
		public var dimAnimation:Boolean;
		public var exportShowBiomoleculeSelectedHandles:Boolean;
		public var exportColorBiomoleculesByValue:Boolean;
		public var exportAnimationFrameRate:Number;
		public var exportLoopAnimation:Boolean;
		public var exportDimAnimation:Boolean;
		
		public var biomoleculestyles:ArrayCollection;
		public var compartments:ArrayCollection;
		public var biomolecules:ArrayCollection;
		public var edges:ArrayCollection;	
		
		public var experimentManager:ExperimentManager;
		
		public var openNetworkWindow:OpenNetworkWindow;
		public var networkPropertiesWindow:NetworkPropertiesWindow;
		public var saveAsNetworkWindow:SaveAsNetworkWindow;
		public var manageNetworksWindow:ManageNetworksWindow;
		public var importNetworkWindow:ImportNetworkWindow;
		
		private var exportFileReference:FileReference;
		private var importFileReference:FileReference;
		
		private var autoSaveTimer:Timer;
		
		public function NetworkManager(application:Application, userManager:UserManager, diagram:Diagram, db:IDatabase) 		
		{ 
			this.application = application;
			this.userManager = userManager;
			this.diagram = diagram;
			this.db = db;
			
			biomoleculestyles = new ArrayCollection();
			compartments = new ArrayCollection();
			biomolecules = new ArrayCollection();
			edges = new ArrayCollection();
			
			userManager.addEventListener(UserManagerEvent.USER_LOGIN, recoverNetwork);
			userManager.addEventListener(UserManagerEvent.USER_CHECK_TIMEOUT, renewLock);
			userManager.addEventListener(UserManagerEvent.USER_ENDSESSION, clearNetworkLock);
			userManager.addEventListener(UserManagerEvent.USER_UPDATE, updateUserName);
							
			openNetworkWindow = new OpenNetworkWindow(application, this);
			networkPropertiesWindow = new NetworkPropertiesWindow(application, this);
			saveAsNetworkWindow = new SaveAsNetworkWindow(application, this);			
			manageNetworksWindow = new ManageNetworksWindow(application, this);
			importNetworkWindow = new ImportNetworkWindow(application, this);
			
			exportFileReference = new FileReference();
			importFileReference = new FileReference();
			importFileReference.addEventListener(Event.SELECT, importFileReferenceSelectHandler);
			importFileReference.addEventListener(Event.COMPLETE, importFileReferenceLoadCompleteHandler);
			
			networkPainter = new NetworkPainter();			
			networkPainter.addEventListener(NetworkPainter.LIST_NETWORKS, listNetworksQueryHandler);
			networkPainter.addEventListener(NetworkPainter.GET_NETWORK_DETAILS, getNetworkDetailsQueryHandler);
			networkPainter.addEventListener(NetworkPainter.GET_NETWORK_PERMISSIONS, getNetworkPermissionsQueryHandler);
			networkPainter.addEventListener(NetworkPainter.SAVE_AS_NETWORK, saveAsNetworkQueryHandler);
			networkPainter.addEventListener(NetworkPainter.UPDATE_NETWORK, updateNetworkDataQueryHandler);
			networkPainter.addEventListener(NetworkPainter.SAVE_NETWORK_PROPERTIES, saveNetworkPropertiesQueryHandler);
			networkPainter.addEventListener(NetworkPainter.LOAD_NETWORK, loadNetworkQueryHandler);
			networkPainter.addEventListener(NetworkPainter.RENEW_NETWORK_LOCK, networkLocksQueryHandler);
			networkPainter.addEventListener(NetworkPainter.CLEAR_NETWORK_LOCK, networkLocksQueryHandler);
			networkPainter.addEventListener(NetworkPainter.DELETE_NETWORK, deleteNetworkQueryHandler);
			networkPainter.addEventListener(NetworkPainter.FAULT, networkPainterErrorHandler);
			
			autoSaveTimer = new Timer(1 * 60 * 1000, 0);
			autoSaveTimer.addEventListener(TimerEvent.TIMER, autoSave);
		}
		
		/********************************************************************
		 * list of available networks
		 * *****************************************************************/
		public function listNetworks():void {
			networkPainter.listNetworks(userManager.id);
		}

		private function listNetworksQueryHandler(event:Event):void {
			networks = networkPainter.networks;
		}
		
		/********************************************************************
		 * get details of a network
		 * *****************************************************************/
		public function getNetworkDetails(networkid:uint):void {
			networkPainter.getNetworkDetails(userManager.id, networkid);
		}

		private function getNetworkDetailsQueryHandler(event:Event):void {
			networkDetails = networkPainter.networkDetails;
			dispatchEvent(new NetworkManagerEvent(NetworkManagerEvent.GET_NETWORK_DETAILS));
		}
		
		/********************************************************************
		 * user permissions on available networks
		 * *****************************************************************/
		public function getNetworkPermissions(id:uint=0):void {
			if (id == 0) networkPermissions = new ArrayCollection();			
			else networkPainter.getNetworkPermissions(id);
		}
		
		private function getNetworkPermissionsQueryHandler(event:Event):void {
			networkPermissions = networkPainter.networkPermissions;
		}

		/********************************************************************
		 * new network
		 * *****************************************************************/
		public function newNetwork(event:Event = null):void {
			if (diagram.historyManager.modified) {
				Alert.show('Network has been modified. Opening a new network will discard all unsaved changes. Are you sure you want to continue?', 'Warning: Network Modified',
					Alert.OK | Alert.CANCEL, null, function(event:CloseEvent):void { if (event.detail == Alert.OK) loadNewNetwork(); } );
			}
			else loadNewNetwork();
		}
		
		private function loadNewNetwork():void {
			clearNetwork();
			loadNetworkDefaults();
			autoSaveTimer.reset();
			autoSaveTimer.start();
			diagram.loadNetwork(this);
			dispatchEvent(new NetworkManagerEvent(NetworkManagerEvent.NETWORK_NEW));
		}
		
		public function clearNetwork():void {
			var now:Date = new Date();	
			
			id = 0;
			name = '';
			description = '';
			publicstatus = 'No';
			owner = userManager.firstname + ' ' + userManager.lastname;
			creation = now.toLocaleDateString() + ' ' + now.toLocaleTimeString();
			lastsave = '';
			locked = false;
			lockuserid = userManager.id;
			lockuser = userManager.firstname + ' ' + userManager.lastname;
			permissions = 'o';
			
			width = 800;
			height = 600;
			showPores = true;
			poreFillColor = 0xFFD700;
			poreStrokeColor = 0xCDAD00;
			membraneHeight = 25.5;
			membraneCurvature = 25;
			minCompartmentHeight = 100;
			ranksep = 18;
			nodesep = 54;
			animationFrameRate = exportAnimationFrameRate = 20;
			loopAnimation = exportLoopAnimation = true;
			dimAnimation = exportDimAnimation = true;
			exportShowBiomoleculeSelectedHandles = false;
			exportColorBiomoleculesByValue = false;
			
			biomoleculestyles=new ArrayCollection();
			compartments=new ArrayCollection();
			biomolecules = new ArrayCollection();
			edges = new ArrayCollection();
		}
		
		//default network: 5 styles, 3 compartments, 0 biomolecules, 0 edges
		private function loadNetworkDefaults():void {			
			biomoleculestyles = new ArrayCollection([
				{name:'Annotation', shape:'Rectangle', color:0x999999, outline:0x000000 },
				{name:'Receptor', shape:'Y-Receptor', color:0xFF3333, outline:0x000000 },					
				{name:'Second_Messenger', shape:'Ellipse', color:0x00FF66, outline:0x000000 },					
				{name:'Stimulus', shape:'Inverted Triangle', color:0xFFFF33, outline:0x000000 },					
				{name:'Transcription_Factor', shape:'Ellipse', color:0x0099FF, outline:0x000000 } ]);
			compartments = new ArrayCollection([
				{name:'Media', color:0xCCCCCC, membranecolor:0xFFCC00, phospholipidbodycolor:0xFFD700, phospholipidoutlinecolor:0xCDAD00, height:183 },					
				{name:'Cytosol', color:0x99CCFF, membranecolor:0xFFCC00, phospholipidbodycolor:0xFFD700, phospholipidoutlinecolor:0xCDAD00, height:183 },					
				{name:'Nucleus', color:0x99CCFF, membranecolor:0xFFCC00, phospholipidbodycolor:0xFFD700, phospholipidoutlinecolor:0xCDAD00, height:183 } ]);								
		}

		/********************************************************************
		 * open network
		 * *****************************************************************/
		public function openNetwork(properties:Object):void {			
			if (diagram.historyManager.modified) {
				Alert.show('Network has been modified. Opening a different network will discard all unsaved changes. Are you sure you want to continue?', 'Warning: Network Modified',
					Alert.OK | Alert.CANCEL, null, function(event:CloseEvent):void { if (event.detail == Alert.OK) loadNetwork(properties); } );
			}else {
				loadNetwork(properties);
			}
		}
			
		private function loadNetwork(properties:Object):void{
			id = properties.id;
			
			//ExternalInterface.call('console.log', properties);
			
			if (properties.locked) {
				Alert.show('Opening read only copy.', 'Warning: Network Locked', Alert.OK|Alert.CANCEL, null,
					function(event:CloseEvent):void {
						if (event.detail == Alert.OK) {
							userManager.setLastUserActivity();
							networkPainter.loadNetwork(userManager.id, id);
						}
					} );
			}else {
				userManager.setLastUserActivity();
				networkPainter.renewNetworkLock(userManager.id, id);
				networkPainter.loadNetwork(userManager.id, id);
			}
		}

		public function loadNetworkQueryHandler(event:Event):void {
			var network:Object = networkPainter.network;
			fromObject(network, true, true, true, false);
			openNetworkWindow.close();
			dispatchEvent(new NetworkManagerEvent(NetworkManagerEvent.NETWORK_LOADED));
		}
		
		/********************************************************************
		 * save network
		 * *****************************************************************/
		public function saveNetwork():void {
			if (userManager.isGuest)
				return;
			
			if (id == 0 || permissions == 'a' || permissions == 'r' || locked) {
				saveAsNetworkWindow.open();
			}else {
				updateNetworkData(id);
				diagram.historyManager.modified = false;
			}
		}

		public function saveAsNetwork(name:String, description:String, publicstatus:String):void {
			if (userManager.isGuest)
				return;
			
			if (id > 0) 
				networkPainter.clearNetworkLock(id);
				
			var now:Date = new Date();
			
			id = 0;
			this.name = name;
			this.description = description;
			this.publicstatus = publicstatus;
			owner = userManager.firstname + ' ' + userManager.lastname;
			creation = now.toLocaleDateString() + ' ' + now.toLocaleTimeString();
			lastsave = now.toLocaleDateString() + ' ' + now.toLocaleTimeString();
			locked = false;
			lockuserid = userManager.id;
			lockuser = userManager.firstname + ' ' + userManager.lastname;
			permissions = 'o';
			
			var network:Object = diagram.generateNetwork();
			
			networkPainter.saveAsNetwork(userManager.id, name, description, publicstatus, 
				network.width, network.height, network.showPores, network.poreFillColor, network.poreStrokeColor,
				network.membraneHeight, network.membraneCurvature, network.minCompartmentHeight, 
				network.ranksep, network.nodesep, 
				network.animationFrameRate, network.loopAnimation, network.dimAnimation,
				network.exportShowBiomoleculeSelectedHandles, network.exportColorBiomoleculesByValue, 
				network.exportAnimationFrameRate, network.exportLoopAnimation, network.exportDimAnimation);
		}


		public function saveAsNetworkQueryHandler(event:Event):void {
			id = networkPainter.newNetworkId;
			updateNetworkData(id);
			diagram.historyManager.modified = false;
		}

		public function updateNetworkData(networkid:uint, autosave:Boolean = false):void {
			if (userManager.isGuest)
				return;
				
			var preview:ByteArray;
			
			userManager.setLastUserActivity();
			
			//if regular saving, capture png preview of network
			if (!autosave)
				preview = diagram.render('png', null);
			
			var network:Object = diagram.generateNetwork();
			network.description = description;
			network.publicstatus = publicstatus;
			
			networkPainter.updateNetwork(networkid, userManager.id, network, preview);
			dispatchEvent(new NetworkManagerEvent(NetworkManagerEvent.NETWORK_SAVED, networkid));
		}
		
		public function updateNetworkDataQueryHandler(event:Event):void { 
			autoSaveTimer.reset();
			autoSaveTimer.start();
		}
		
		
		/********************************************************************
		 * auto save
		 * *****************************************************************/
		private function autoSave(event:TimerEvent):void {
			if (userManager.isGuest)
				return;
				
			updateNetworkData(userManager.autosaveid, true);
		}
		
		private function recoverNetwork(event:UserManagerEvent):void {
			if (!userManager.isGuest && event.userData.logofferror) {
				Alert.show('Loading auto-saved network.', 'Auto-Recovery', Alert.OK | Alert.CANCEL, null,
					function(event:CloseEvent):void {
						if (event.detail == Alert.OK) {
							loadNetwork( { id:userManager.autosaveid, locked:false } );
							diagram.historyManager.modified = true;
							Application.application.parameters['networkid'] = '';
						}else if (Application.application.parameters['networkid'] != '') {				
							loadNetwork( { id:parseInt(Application.application.parameters['networkid']), locked:false } );
						}else{
							loadNewNetwork();
							openNetworkWindow.open();
						}
					});
			}else if (Application.application.parameters['networkid'] != '') {
				loadNetwork( { id:parseInt(Application.application.parameters['networkid']), locked:false } );
			}else{
				loadNewNetwork();
				openNetworkWindow.open();
			}
		}
		
		/********************************************************************
		 * edit network properties
		 * *****************************************************************/		
		//save network properties edited by network manager window
		public function saveNetworkProperties(network:Object, permissions:ArrayCollection):void {
			var sql:String = '';
			var validPermissions:Boolean = false;	

			if (network.permissions == 'o') {
				for (var i:uint = 0; i < permissions.length; i++) {
					if (permissions[i].permissions == 'o') validPermissions = true;
				}
				if (!validPermissions) {
					Alert.show('At least one owner must be defined.', 'Network Permissions Error');
					return;
				}
			}
			
			manageNetworksWindow.editable = false;
			networkPainter.saveNetworkProperties(network.id, network.name, network.description, network.publicstatus, network.permissions, permissions);
		}
		
		private function saveNetworkPropertiesQueryHandler(event:Event):void{
			manageNetworksWindow.errorMsg.text = 'Network properties saved.';
			manageNetworksWindow.editable = true;
		}
		
		
		/********************************************************************
		 * delete network
		 * *****************************************************************/
		public function deleteNetwork(network:Object):void {			
			if (network.permissions != 'o') return;
			
			networks.removeItemAt(networks.getItemIndex(network));
			manageNetworksWindow.editable = false;
			networkPainter.deleteNetwork(network.id);
		}
		
		private function deleteNetworkQueryHandler(event:Event):void {
			manageNetworksWindow.editable = true;
		}
		
		/********************************************************************
		 * network locks
		 * *****************************************************************/
		private function renewLock(event:UserManagerEvent):void {
			if (userManager.isGuest)
				return;
				
			if (id > 0 && !locked)
				networkPainter.renewNetworkLock(userManager.id, id);
		}
		
		private function clearNetworkLock(event:UserManagerEvent):void {
			if (userManager.isGuest)
				return;
				
			networkPainter.clearNetworkLock(id);
		}
		
		private function networkLocksQueryHandler(event:Event):void { }
		

		
		
		/********************************************************************
		 * update user name
		 * *****************************************************************/
		private function updateUserName(event:UserManagerEvent):void {
			if (userManager.isGuest)
				return;
				
			if (permissions == 'o')
				owner.replace(
					event.oldUserData.firstname + ' ' + event.oldUserData.lastname, 
					event.userData.firstname + ' ' + event.userData.lastname);
			if (lockuserid == userManager.id)
				lockuser.replace(
					event.oldUserData.firstname + ' ' + event.oldUserData.lastname,
					event.userData.firstname + ' ' + event.userData.lastname);
		}
		
		/********************************************************************
		 * network analyzer data error handler
		 * *****************************************************************/	
		private function networkPainterErrorHandler(event:FaultEvent):void {
			Alert.show('Please retry last action. ' + event.message.toString(), 'Database Error.');
		}
		
		/********************************************************************
		 * exporting/importing
		 * *****************************************************************/	
		public function exportNetwork(format:String):void {
			var fileData:*;			
			var metaData:Object = generateMetaDataObject();			
			
			var extension:String = format;
			switch(format) {
				case 'gif':
				case 'jpg':
				case 'png':
				case 'svg':
					fileData = diagram.render(format, metaData);
					break;
				case 'pdf':
				case 'ps':
				case 'eps':
					diagram.rasterize(format, metaData);
					return;
				case 'dot':
					fileData = diagram.dotCode(72, metaData);
					break;	
				case 'json':
					fileData = toJSON(metaData);
					break;
				case 'biopax':
					fileData = BioPax.export(diagram.generateNetwork(), metaData);
					extension = 'owl';
					break;
				case 'cellml':
					fileData = CellML.export(diagram.generateNetwork(), metaData);
					break;
				case 'sbml':
					fileData = SBML.export(diagram.generateNetwork(), metaData);
					break;
			}
			
			exportFileReference.save(fileData, metaData.title + '.' + extension);
		}
		
		public function toJSON(metaData:Object):String {
			return JSON.encode(toObject());
		}
		
		public function importNetwork(source:String):void {
			switch(source) {
			case 'json':
				var fileFilter:FileFilter = new FileFilter(Application.application['aboutData'].applicationName + ' networks (*.json)', "*.json");
				importFileReference.browse([fileFilter]);
				break;
			case 'kegg':
			case 'reactome':
				importNetworkWindow.open(source);
				break;
			}
		}
		
		private function importFileReferenceSelectHandler(event:Event):void {			
			importFileReference.load();
		}
			
		private function importFileReferenceLoadCompleteHandler(event:Event):void {		
			var o:Object = JSON.decode(importFileReference.data.readUTFBytes(importFileReference.data.length));			
			fromObject(o, true, false, true, true);
		}
		
		public function toObject():Object {
			/*******************************
			 * Network from diagram
			 ******************************/
			var o:Object = diagram.generateNetwork();
			o.name = name;
			o.description = description;
			
			var network:Object = diagram.generateNetwork();
			
			o.biomoleculestyles = o.biomoleculestyles.toArray();
			o.compartments = o.compartments.toArray();
			o.biomolecules = o.biomolecules.toArray();
			o.edges = o.edges.toArray();
			
			/*******************************
			 * Metadata from network manager
			 ******************************/
			var metaData:Object = generateMetaDataObject();			
			o.author = metaData.author;
			o.creator = metaData.creator;
			o.timestamp = metaData.timestamp;
			
			/*******************************
			 * Axes, experiments from experiment manager
			 ******************************/
			var m:Object = experimentManager.toObject();
			for (var key:String in m)
				o[key] = m[key];
			
			/*******************************
			 * return
			 ******************************/
			return o;
		}
		
		public function fromObject(o:Object, loadProperties:Boolean, loadMetadata:Boolean, loadExperimentMetadata:Boolean, loadExperiments:Boolean):void {
			clearNetwork();
			loadNetworkDefaults();		
			experimentManager.clearExperiments();
			
			name = o.name;
			description = o.description;
			
			if (loadMetadata) {
				id = o.id;
				owner = o.owner;
				creation = o.creation;
				lastsave = o.lastsave;
				publicstatus = o.publicstatus;
				lockuserid = o.lockuserid;
				lockuser = o.lockuser;
				locked = o.locked;
				permissions = o.permissions;
			}
			
			width = o.width;
			height = o.height;
			
			if (loadExperimentMetadata) {
				showPores = o.showPores;
				poreFillColor = o.poreFillColor;
				poreStrokeColor = o.poreStrokeColor;
				
				membraneHeight = o.membraneHeight;
				membraneCurvature = o.membraneCurvature;
				minCompartmentHeight = o.minCompartmentHeight;
				
				ranksep = o.ranksep;
				nodesep = o.nodesep;
				
				animationFrameRate = o.animationFrameRate;
				loopAnimation = o.loopAnimation;
				dimAnimation = o.dimAnimation;
				
				exportShowBiomoleculeSelectedHandles = o.exportShowBiomoleculeSelectedHandles;
				exportColorBiomoleculesByValue = o.exportColorBiomoleculesByValue;
				exportAnimationFrameRate = o.exportAnimationFrameRate;
				exportLoopAnimation = o.exportLoopAnimation;
				exportDimAnimation = o.exportDimAnimation;
			}
			
			biomoleculestyles = (o.biomoleculestyles is ArrayCollection ? o.biomoleculestyles : new ArrayCollection(o.biomoleculestyles));
			compartments = (o.compartments is ArrayCollection ? o.compartments : new ArrayCollection(o.compartments));
			biomolecules = (o.biomolecules is ArrayCollection ? o.biomolecules : new ArrayCollection(o.biomolecules));
			edges = (o.edges is ArrayCollection ? o.edges : new ArrayCollection(o.edges));
					
			autoSaveTimer.reset();
			autoSaveTimer.start();
			
			//load diagram
			diagram.loadNetwork(this);
			
			//load experiments
			if (loadExperiments) {
				experimentManager.fromObject(o);
			}
		}
		
		/********************************************************************
		 * printing
		 * *****************************************************************/
		public function print():void {
			diagram.print();
		}
		
		/********************************************************************
		 * meta data
		 * *****************************************************************/
		private function generateMetaDataObject():Object {
			var now:Date = new Date();
			return {
				creator:application['aboutData'].applicationName, 				
				timestamp:now.toLocaleDateString() + ' ' + now.toLocaleTimeString(),				
				title:(name == '' ? application['aboutData'].applicationName : name), 
				author:owner, 
				subject:description };
		}
	}	
}