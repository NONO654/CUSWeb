define('DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
    ['UWA/Core',
     'DS/WebappsUtils/WebappsUtils',
     'DS/UIKIT/SuperModal',
     'DS/Logger/Logger',
     'module',
	 'DS/Windows/ImmersiveFrame',
     'DS/Windows/Dialog',
     'DS/Controls/Button',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'],
    /*
     * utility methods used in station admin
     */
    function (UWA,  WebappsUtils,  SuperModal,  Logger,  module,  WUXImmersiveFrame,  WUXDialog,  WUXButton,  COSInfo,  NLS) {
         'use strict';
        var ServiceUtils = {};
        // Logger for this module
        var _logger = Logger.getLogger(module);
 		var superModal = new SuperModal({ renderTo: COSInfo.getContainer() });
 		var dialogFrame = null;
 		var contentDialog = null;
 		// map that contains form field name and station property to which it corresponds
 		// station property string should be kept in sync with the list in Station Manager
 		// values are set in helper function - setpropFieldsMap
 		var propFieldsMap = null;

        ServiceUtils = {
        		// method that shows the widget as a transient widget
        		// pass in the widget application id, the title, the options for the widget
        		showTransientWidget : function  (appId,  title,  data) {
        	        require(['DS/TransientWidget/TransientWidget'],  function (Transient) {
        	            Transient.showWidget(appId,  title,  data);
        	        });
        	    },

            	// helper function to tweak node name based on if station or station in a group
        		fixNodeName : function  ( name) {
        			var splitName = name.split('@@');
        			var nodeName = splitName[0];
        			// if we have a second item in the array we are dealing with station/group on a server
        			// second item is server name
        			if (splitName.length > 2){
        				nodeName = nodeName + '@@' + splitName[2];
        			}
        			else if (splitName.length > 1){
        				nodeName = nodeName + '@@' + splitName[1];
        			}
        			return nodeName;
        		},


        	// helper function to clean up server name if in the form of station/group@@server
    		fixServer : function ( server) {
    			var splitServer = server.split('@@');
    			var serverName = splitServer[0];
    			// if we have a second item in the array we are dealing with station/group on a server
    			// second item is server name
    			if (splitServer.length > 1){
    				serverName = splitServer[1];
    			}
    			return serverName;
    		},
    		// find a node in the tree given a name
    		findNode : function (nodeID) {
    			var myNode = null;
    			// check if nodeId is for a server or a station/group
    			var splitNode = nodeID.split('@@');
    			var nodename = splitNode[0];
    			var serverName = '';
    			// if we have a second item in the array we are dealing with group on a server
    			// second item is server name
    			if (splitNode.length > 1){
    				serverName = splitNode[1];
    			}
    			// if we have a third item in the array we are dealing with a station in a group on a server
    			// the server will be the third item in the array
    			if (splitNode.length > 2){
    				serverName = splitNode[2];
    			}

    			// iterate over the tree nodes
    			// station and group nodes in the tree have @@serverName to make the id unique
    			var treeView = COSInfo.getBones().getViewAt(0);
    			if (treeView) {
    				// iterate over all the children
    				treeView.treeModel.getAllDescendants().forEach(function (model) {
    					// if the name matches and we do not have a server in the nodeId and the model
    					// found match for server node
    					if (model.options.label === nodename && serverName === '' &&
    							(model.options.serverName === undefined || model.options.serverName.length === 0))
    					{
    						myNode =  model;
    					}
    					// else if the name and servers match found match for station/group nodeId
    					else if (model.options.label === nodename && serverName !== '' &&
    							serverName === model.options.serverName) {
    						myNode =  model;
    					}
    				});
    			}
    			return myNode;
    		},

    		// Utility function that refreshes the multi-select row so the
    		// check-box and check-mark are restored.  Needed since updating the row
    		// with a changed status or group value causes the check-box and check-mark to go away

    		// if the commented code is uncommented then the selection will be removed and
    		// the multi-select count and drop-down will be cleared
    		fixSelection : function() {
    			var view = COSInfo.getBones().getViewAt(1);
    			if ( view) {
    				/*
    				view.unSelectAll();
    				if (view.multiselHeaderView) {
    					view.multiselHeaderView.resetMultisel();
    					view.multiselHeaderView.selectedModels = [];
    				}
    				*/
    				if (view.contentsViews && view.contentsViews.table &&
    						view.contentsViews.table.nestedView) {
    					/*
    					var selectedItems = view.contentsViews.table.nestedView.getSelection();
    					while (selectedItems.length > 0) {
    						view.contentsViews.table.nestedView.removeSelection(selectedItems[0]);
    						selectedItems = view.contentsViews.table.nestedView.getSelection();
    					}
    					*/
    					view.contentsViews.table.nestedView.refreshUI();
    				}
    			}

    		},

    		// find a model in the collection of the given view
    		findModel : function (viewIdx,  modelID) {
    			var view = COSInfo.getBones().getViewAt(viewIdx);

    			// safety check
    			if (view) {
	    			for (var i = 0 ; i < view.collection._models.length; i++) {
	    				var model = view.collection._models[i];
	    				if (model.get('id')=== modelID) {
	    					return model;
	    				}
	    			}
    			}
    			return null;
    		},

    		// remove the corresponding model in the tree given the model id
    		removeTreeModel : function (modelID) {
    			var treeView = COSInfo.getBones().getViewAt(0);
    			if (treeView) {
    				var treeModel = this.findModel(0,  modelID);
    				if (treeModel && treeView.collection) {
    					treeView.collection.remove(treeModel);
    				}
    			}
    		},

    		//set the status badge on a node
    		setBadgesOnNode : function(name,  status) {
    			var node = ServiceUtils.findNode(ServiceUtils.fixNodeName(name));
    			if (node) {
    				var badge = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/colorSwatchRed.png');
    				if (status === 'RUNNING' || status === 'Running') {
    					badge = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/colorSwatchBrightGreen.png');
    				}
    				else if (status === 'PAUSED' || status === 'Paused' || status === 'Suspended') {
    					badge = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/colorSwatchYellow.png');
    				}
    				else if (status === 'Shutdown' || status === 'SHUTDOWN') {
    					badge = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/colorSwatchLightBlue.png');
    				}
    				node.setBadges({topRight:badge});
    			}
    		},

    		// find the node for the given name and set a default badge on the node
    		setDefaultBadgeOnNode : function(name) {
    			var node = ServiceUtils.findNode(name);
    			if (node) {
    				var badge = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/default.png');
    				node.setBadges({bottomLeft:badge});
    			}
    		},

    		// clear the default badge for a node
    		clearDefaultBadgeOnNode : function(name) {
    			var node = ServiceUtils.findNode(name);
    			if (node) {
    				node.setBadges({bottomLeft:''});
    			}
    		},

    		// logs an error message to the console using the logger
    		// if alert is set also displays an alert
    		displayError : function (message,  showAlert) {
    			if (showAlert) {
    				superModal.alert(message,  function () {
    					_logger.error(message);
    				});
    			}
    			else {
    				_logger.error(message);
    			}

    		},

    		// logs an info message using the logger
    		displayInfo : function (message,  showAlert) {
    			if (showAlert) {
    				superModal.alert(message,  function () {
    					_logger.info(message);
    				});
    			}
    			else {
    				_logger.info(message);
    			}
    		},


    		// logs a debug  message using the logger
    		displayDebug : function (message) {
    			_logger.debug(message);
    		},

    		// check if station name is already in use on the server
    		checkForDuplicates : function (nameToCheck,  serverName)
    		{
      	   		var view = COSInfo.getBones().getViewAt(1);
      	   		var haveDuplicate = false;

      	   		// if the view model id contains @@ then we have the station list for a group
      	   		if (view.model.id.contains('@@')) {
      	   			// since we have the group station list we had to expand the tree to get to the group
      	   			// get the view from the tree and adjust the name to add the server when checking id
      	   			view = COSInfo.getBones().getViewAt(0);
      	   			nameToCheck += '@@' + this.fixServer(serverName);
      	   		}
    	   		if (view && view.collection) {
    		   		for (var i = 0 ; i < view.collection._models.length; i++) {
    		   			var model = view.collection._models[i];
    		   			if (model.id === nameToCheck) {
    		   				haveDuplicate = true;
    		   			}
	        		}
    	   		}
    	   		return haveDuplicate;
    		},

    		// utility method to make sure station JSON object is valid
    		// checks to make sure name is not already in use
    		// checks that if station is in a group the group exists

    		// if the server is for a group make sure the drm mode is not for a group
    		// since we do not support groups within groups,  make sure if drm mode is
    		// for a station the group name is the same as the server group.
    		validateStation : function (station,  server) {

    			// cannot import station or group that already exists
      	   		var haveDuplicate = this.checkForDuplicates(station['@name'],  server) ;
		   		if (haveDuplicate ) {
		   			var msg2 = station['@name'] + UWA.i18n( NLS.dupImportErr);
		   			var err2 ={message:msg2};
		   			throw (err2);
		   		}

		   		// if groupName is set make sure it already exists
		   		var groupname = station['@group'];
		   		if (groupname) {
		   			var haveGroup = this.checkForDuplicates(groupname, server);
		   			if (!haveGroup){
			   			var msg3 = groupname + UWA.i18n( NLS.importErrNoGroup) + station['@name'] ;
			   			var err3 ={message:msg3};
			   			throw (err3);
		   			}
		   		}
		   		var goodDRMs = ['fiper', 'fiperGrp', 'LsfGrp'];
		   		var drmMode = station.GeneralInfo['@drmMode'];
		   		if (goodDRMs.indexOf(drmMode) < 0) {
		   			var msg4 = station['@name'] + UWA.i18n( NLS.importErrBadMode) ;
		   			var err4 ={message:msg4};
		   			throw (err4);
		   		}

		   		// check that simshared is defined in the import json for the station
		   		// it can only be set to $SHARED_DRIVE or an absolute path
		   		if (station.SharedFSList === undefined || station.SharedFSList.SharedFS === undefined) {
		   			var msg5 = station['@name'] + UWA.i18n( NLS.importErrBadSharedFS) ;
		   			var err5 ={message:msg5};
		   			throw (err5);
		   		}
		   		else {
		   			var haveSimShared = false;
		   			if (station.SharedFSList.SharedFS.length){
        				station.SharedFSList.SharedFS.forEach(function (item) {
        					if (item['@Name'] === 'simshared') {
        						haveSimShared = true;
        						if (item['@Path'].startsWith('$')) {
        							if (item['@Path']!== '$SHARED_DRIVE') {
        								haveSimShared = false;
        							}
        						}
        					}
                    	});
		   			}
		   			else {
		   				if (station.SharedFSList.SharedFS['@Name'] === 'simshared'){
    						haveSimShared = true;
    						if (station.SharedFSList.SharedFS['@Path'].startsWith('$')) {
    							if (station.SharedFSList.SharedFS['@Path']!== '$SHARED_DRIVE') {
    								haveSimShared = false;
    							}
    						}
		   				}
		   			}
		   			if (!haveSimShared) {
			   			var msg6 = station['@name'] + UWA.i18n( NLS.importErrBadSharedFS) ;
			   			var err6 ={message:msg6};
			   			throw (err6);
		   			}
		   		}


    			var splitServer = server.split('@@');
    			// check if we are importing into a group and if so
    			// do addtional validation
    			if (splitServer.length > 1) {
        			var serverGroupName = splitServer[0];

        			// cannot import a group into another group
        			if (drmMode.endsWith('Grp')) {
    		   			var msg7 = station['@name'] + UWA.i18n( NLS.importErrGroupInGroup) +  groupname;
    		   			var err7 ={message:msg7};
    		   			throw (err7);

        			}

        			// cannot import a station with a group defined into another group
        			if (groupname &&  serverGroupName !== groupname) {
    		   			var msg8 = station['@name'] + UWA.i18n( NLS.importErrStationInWrongGroup) +
    		   						groupname + ' and ' + serverGroupName;
		   				var err8 ={message:msg8};
		   				throw (err8);
        			}

        			// make sure groupName is set to the server group
        			station['@group'] = serverGroupName;
    			}

    		},

    		// helper function to the value of a property from a model given the station property key
    		getPropertyValueFromModel : function (model, key) {
    	    	var retVal = '';
    	    	if (model) {
	    	        if ( model.get('PropertyList') && model.get('PropertyList').Property){
	    	        	retVal = model.get('PropertyList').Property.get(key);
	    	        }
    	    	}
    	    	return retVal;
    		},
    		
    		// helper function to set the property map with properties now being exposed in UI
    		setpropFieldsMap : function () {
    			if (propFieldsMap === null) {
        	 		propFieldsMap = new Map();
        	 		propFieldsMap.set('numBackups',  'fiper.logging.numBackups');
        	 		propFieldsMap.set('maxSize',  'fiper.logging.maxSizeKB');
        	 		propFieldsMap.set('fastFlowResults',  'fiper.station.fastflowSendResultsInterval');
        	 		propFieldsMap.set('mpiPath',  'fiper.station.mpirunPath');
        	 		propFieldsMap.set('largeFileDir',  'fiper.station.sim.largeFileWorkingDir');
        	 		propFieldsMap.set('portRange',  'fiper.station.sim.portrange');
        	 		propFieldsMap.set('computeServices',  'fiper.station.sim.computeservices');
        	 		propFieldsMap.set('clientServices',  'fiper.station.sim.clientservices');
        	 		propFieldsMap.set('resultsServices',  'fiper.station.sim.resultsservices');
        	 		propFieldsMap.set('exposedIPAddr',  'fiper.station.sim.exposedipaddress');
        	 		propFieldsMap.set('parameterMatch',  'fiper.station.advise.variant.parametermatch');
        	 		propFieldsMap.set('exposedName',  'fiper.station.exposedname');
        	 		propFieldsMap.set('exposedPorts',  'fiper.station.exposedports');
        	 		propFieldsMap.set('stageFileScript',  'fiper.station.sim.stageFileScript');
        	 		propFieldsMap.set('subStarttime',  'fiper.station.substation.starttime');
        	 		propFieldsMap.set('subLaunchtimeout',  'fiper.substation.launchtimeout');
        	 		propFieldsMap.set('subKeepalive',  'fiper.substation.keepalive.interval.ms');
        	 		propFieldsMap.set('fcsEnginedir',  'fiper.station.fcs.enginedir');
        	 		propFieldsMap.set('fcsServerStagingdir',  'fiper.station.fcs.serverstagingdir');
        	 		propFieldsMap.set('cacheplmfiles',  'fiper.station.cacheplmfiles');
        	 		propFieldsMap.set('predefinedonly',  'fiper.station.oscommand.predefinedonly');
        	 		propFieldsMap.set('certificate',  'fiper.station.certificate');
        	 		propFieldsMap.set('certificateKey',  'fiper.station.certificate.key');
        	 		propFieldsMap.set('certificateCert',  'fiper.station.certificate.cert');
        	 		propFieldsMap.set('skiplock',  'fiper.system.templib.skiplock');
        	 		propFieldsMap.set('saveLogOnError',  'fiper.station.saveLogOnError');
        	 		propFieldsMap.set('jobLogRepository',  'smaexe.cos.station.ftp.joblog.repository');
        	 		propFieldsMap.set('leaseinterval',  'fiper.station.leaseinterval');
        	 		propFieldsMap.set('maxquiescetime',  'fiper.station.maxquiescetime');
        	 		propFieldsMap.set('shareableLicPath',  'fiper.station.defaultshareablelicconfig.file');
        	 		propFieldsMap.set('shareableLicRetryNum',  'fiper.station.defaultshareablelicconfig.retry');
        	 		propFieldsMap.set('shareableLicRetryInterval',  'fiper.station.defaultshareablelicconfig.retryinterval');
    			}
    		},
    		
    		// helper function to check if the station property form name is being handled by the admin UI
    		// checks if it is in the map of properties handled by the UI
    		hasFieldProp : function (key) {
    			this.setpropFieldsMap();
    			return propFieldsMap.has(key);
    		},

    		// helper function to check if the station property  is being handled by the admin UI
    		// checks if it is in the map of properties handled by the UI
    		hasFieldPropValue : function (val) {
    			var retVal = false;
    			this.setpropFieldsMap();
    			propFieldsMap.forEach(function (value) {
					if (value === val){
						retVal =  true;
					}
				});
    			return retVal;
    		},

    		// helper function to get the station property  value from the model
    		getFieldProp : function (key, model) {
    			var retVal = '';
    			this.setpropFieldsMap();
    			if (propFieldsMap.has(key)) {
    				retVal = this.getPropertyValueFromModel(model,  propFieldsMap.get(key));
    			}
    			return retVal;
    		},

    		// helper function to set a station property  value in the map
    		setPropertyMap : function (item) {
        		var propMap = new Map();
        		if (item.PropertyList && item.PropertyList.Property ) {
                	if (item.PropertyList.Property.length){
                		item.PropertyList.Property.forEach(function (prop) {
                			propMap.set(prop['@name'], prop['@value']);
					   });
                	}
                	else {
                		if (item.PropertyList.Property['@name']) {
                			propMap.set(item.PropertyList.Property['@name'], item.PropertyList.Property['@value']);
                		}
                	}
                	item.PropertyList.Property= propMap;
        		}

    		},

    		// get property list xml string for a station from a model
    		// model can either be a collection model or a json object
    		// if it is a collection model then the get method is defined
    		// otherwise it is a station JSON object and the data needs to be
    		// accessed accordingly
    		getPropertyXml : function (model) {
    			var _PROPERTYXML = '';

    			if (model) {

	    			// if get method defined then collection model and can 'get' the model attributes
	    			if ( model.get) {
		    			if ( model.get('PropertyList')&& model.get('PropertyList').Property){
		    				_PROPERTYXML = '<PropertyList>';
		    				// if length is defined then have an array of properties
		    				// need to iterate over the list
		    				model.get('PropertyList').Property.forEach(function (value,  key) {
		    						_PROPERTYXML = _PROPERTYXML + '<Property name = \'' + key +
		    						'\' value=\'' + value +'\' />';
		    					});
		    				// else have a single property
		    				_PROPERTYXML = _PROPERTYXML + '</PropertyList>';
		    			}
	    			}
	    			// else have station JSON and access using []
	    			else {
		    			if ( model.PropertyList && model.PropertyList.Property && model.PropertyList.Property.length){
		    				_PROPERTYXML = '<PropertyList>';
		    				// need to iterate over the map
		    				model.PropertyList.Property.forEach(function (value,  key) {
		    					_PROPERTYXML = _PROPERTYXML + '<Property name = \'' + key +
		    					'\' value=\'' + value +'\' />';
		    				});
		    				_PROPERTYXML = _PROPERTYXML + '</PropertyList>';
		    			}

	    			}
    			}
    			return _PROPERTYXML;
    		},
    		// get application list xml string for a station from a model
    		// model can either be a collection model or a json object
    		// if it is a collection model then the get method is defined
    		// otherwise it is a station JSON object and the data needs to be
    		// accessed accordingly
    		getAppListXml : function (model) {
    			var _APPLXML = '';
    			if ( model.get) {
	    			if ( model.get('ApplicationList')){
	    				if (model.get('ApplicationList').Application.length){
	    					model.get('ApplicationList').Application.forEach(function (appl) {
	    						_APPLXML = _APPLXML+'<Application Name=\''+appl['@Name'] + '\' Version=\''+
	  	                	  	appl['@Version'] +'\' ExecPath=\'' + appl['@ExecPath']  +
			              		'\' />';
	    					});
	    				}
	    				else {
	    					if (model.get('ApplicationList').Application['@Name']) {
	    						var appl2 = model.get('ApplicationList').Application;
	    						_APPLXML = _APPLXML + '<Application Name = \'' + appl2['@Name'] + '\' Version=\''+
	  	                	  	appl2['@Version'] +'\' ExecPath=\'' + appl2['@ExecPath']  +
			              		'\' />';
	    					}
	    				}
	    				_APPLXML = '<ApplicationList>' + _APPLXML + '</ApplicationList>';
	    			}
    			}
    			else {
	    			if ( model.ApplicationList){
	    				if (model.ApplicationList.Application.length){
	    					model.ApplicationList.Application.forEach(function (appl) {
	    						_APPLXML = _APPLXML+'<Application Name=\''+appl['@Name'] + '\' Version=\''+
	  	                	  	appl['@Version'] +'\' ExecPath=\'' + appl['@ExecPath'] +
			              		'\' />';
	    					});
	    				}
	    				else {
	    					if (model.ApplicationList.Application['@Name']) {
	    						var appl3 = model.ApplicationList.Application;
	    						_APPLXML = _APPLXML + '<Application Name = \'' + appl3['@Name'] + '\' Version=\''+
	  	                	  	appl3['@Version'] +'\' ExecPath=\'' + appl3['@ExecPath'] +
			              		'\' />';
	    					}
	    				}
	    				_APPLXML = '<ApplicationList>' + _APPLXML + '</ApplicationList>';
	    			}

    			}
    			return _APPLXML;
    		},
    		// get shared drive list xml string for a station from a model
    		// model can either be a collection model or a json object
    		// if it is a collection model then the get method is defined
    		// otherwise it is a station JSON object and the data needs to be
    		// accessed accordingly
    		getDriveListXml : function (model) {
    			var _DRIVEXML = '';
    			if ( model.get) {
	    			if ( model.get('SharedFSList')){
	    				if (model.get('SharedFSList').SharedFS.length){
	    					model.get('SharedFSList').SharedFS.forEach(function (drive) {
	    						var desc = drive['@description']?drive['@description']:'';
	    						_DRIVEXML = _DRIVEXML+'<SharedFS Name=\''+drive['@Name'] +
	  	                	  	'\' Path=\'' + drive['@Path'] + '\' description=\'' + desc +'\' />';
	    					});
	    				}
	    				else {
	    					if (model.get('SharedFSList').SharedFS['@Name']) {
	    						var drive2 = model.get('SharedFSList').SharedFS;
	    						var desc2 = drive2['@description']?drive2['@description']:'';
	    						_DRIVEXML = _DRIVEXML + '<SharedFS Name = \'' + drive2['@Name'] +
	  	                	  	'\' Path=\'' + drive2['@Path'] + '\' description=\'' + desc2 +'\' />';
	    					}
	    				}
	    				_DRIVEXML = '<SharedFSList>' + _DRIVEXML + '</SharedFSList>';
	    			}
    			}
    			else {
	    			if ( model.SharedFSList){
	    				if (model.SharedFSList.SharedFS.length){
	    					model.SharedFSList.SharedFS.forEach(function (drive) {
	    						var desc = drive['@description']?drive['@description']:'';
	    						_DRIVEXML = _DRIVEXML+'<SharedFS Name=\''+drive['@Name'] +
	  	                	  	'\' Path=\'' + drive['@Path'] + '\' description=\'' +desc +'\' />';
	    					});
	    				}
	    				else {
	    					if (model.SharedFSList.SharedFS['@Name']) {
	    						var drive4 = model.SharedFSList.SharedFS;
	    						var desc4 = drive4['@description']?drive4['@description']:'';
	    						_DRIVEXML = _DRIVEXML + '<SharedFS Name = \'' + drive4['@Name'] +
	  	                	  	'\' Path=\'' + drive4['@Path'] + '\' description=\'' + desc4+'\' />';
	    					}
	    				}
	    				_DRIVEXML = '<SharedFSList>' + _DRIVEXML + '</SharedFSList>';
	    			}

    			}
    			return _DRIVEXML;
    		},

    		fixGroup : function (grp, newGroup, action) {
    			var grpVal= grp;
    			if (newGroup && newGroup.length > 0) {
    				grpVal = newGroup;
    			}
    			if ('remove' === action) {
    				grpVal =  '';
    			}

    			return grpVal;
    		},

    		// helper function to get the application and sharedFS xml
    		getExtraXml : function (extraXml, action, model) {
    			var extraVal = extraXml;
    			if ('import'===action) {
    				extraXml=ServiceUtils.getAppListXml(model) + ServiceUtils.getDriveListXml(model);
    			}
    			return extraVal;
    		},

    		// helper function to eliminate use of Conditional (ternary) operator to reduce complexity
    		getValFromModel : function (value) {
    			var retVal = '';
    			if (value && value !== 'empty') {
    				retVal = value;
    			}
    			return retVal;
    		},
    		// get station xml string from a model
    		// model can either be a collection model or a json object
    		// if it is a collection model then the get method is defined
    		// otherwise it is a station JSON object and the data needs to be
    		// accessed accordingly
    		// allow for additional application or drive xml to be passed in
    		// pass in group name if changing group
    		// if doing import get extra xml from JSON object passed in
    		getStationXml : function (model,  extraXml, newGroup, action) {
    			// place holder variables for the update xml
    			var _NAME = '';
    			var _DESCRIPTION = '';
    			var _GROUP = '';
    			var _WORKDIR = '';
    			var _STAGEDIR = '';
    			var _TEMPDIR = '';
    			var _ALLOWED_USERS = '';
    			var _AFFIN = '';
    			var _CONCUR = '';
    			var _LOGLEVEL = '';
    			var _RUNAS = '';
    			var _OS = '';
    			var _OSNAME = '';
    			var _OSVERSION = '';
    			var _OSARCH = '';
    			var _DOMAIN = '';
    			var _DRM='';

    			// if get defined have collection model and use get to access model atteributes
    			if (model.get) {
	    			_NAME = model.get('@name');
	    			_LOGLEVEL = model.get('GeneralInfo')['@logLevel'];
	    			_RUNAS = model.get('GeneralInfo')['@disableRunAs'];
	    			_OS = model.get('GeneralInfo')['@os'];
	    			_DRM = model.get('GeneralInfo')['@drmMode'];
	    			_DESCRIPTION= ServiceUtils.getValFromModel(model.get('@description'));
	    			_GROUP= ServiceUtils.getValFromModel(model.get('@group'));
	    			_WORKDIR= ServiceUtils.getValFromModel(model.get('GeneralInfo')['@workDir']);
	    			_STAGEDIR= ServiceUtils.getValFromModel(model.get('GeneralInfo')['@stageDir']);
	    			_TEMPDIR= ServiceUtils.getValFromModel(model.get('GeneralInfo')['@tempDir']);
	    			_ALLOWED_USERS= ServiceUtils.getValFromModel(model.get('GeneralInfo')['@allowedUsers']);
	    			_AFFIN= ServiceUtils.getValFromModel(model.get('GeneralInfo')['@othersAffinity']);
	    			_CONCUR = ServiceUtils.getValFromModel(model.get('GeneralInfo')['@concurrency']);
	    			_OSNAME= ServiceUtils.getValFromModel(model.get('GeneralInfo')['@osName']);
	    			_OSVERSION= ServiceUtils.getValFromModel(model.get('GeneralInfo')['@osVersion']);
	    			_OSARCH = ServiceUtils.getValFromModel(model.get('GeneralInfo')['@osArch']);
	    			_DOMAIN = ServiceUtils.getValFromModel(model.get('GeneralInfo')['@domain']);
    			}
    			// else have station object use [] to access object properties
    			else {
	    			_NAME = model['@name'];
	    			_LOGLEVEL = model.GeneralInfo['@logLevel'];
	    			_RUNAS = model.GeneralInfo['@disableRunAs'];
	    			_OS = model.GeneralInfo['@os'];
	    			_DRM = model.GeneralInfo['@drmMode'];
	    			_DESCRIPTION = ServiceUtils.getValFromModel(model['@description']);
	    			_GROUP =  ServiceUtils.getValFromModel(model['@group']);
	    			_WORKDIR = ServiceUtils.getValFromModel(model.GeneralInfo['@workDir']);
	    			_STAGEDIR = ServiceUtils.getValFromModel(model.GeneralInfo['@stageDir']);
	    			_TEMPDIR = ServiceUtils.getValFromModel(model.GeneralInfo['@tempDir']);
	    			_ALLOWED_USERS = ServiceUtils.getValFromModel(model.GeneralInfo['@allowedUsers']);
	    			_AFFIN = ServiceUtils.getValFromModel(model.GeneralInfo['@othersAffinity']);
	    			_CONCUR = ServiceUtils.getValFromModel(model.GeneralInfo['@concurrency']);
	    			_OSNAME = ServiceUtils.getValFromModel(model.GeneralInfo['@osName']);
	    			_OSVERSION = ServiceUtils.getValFromModel(model.GeneralInfo['@osVersion']);
	    			_OSARCH = ServiceUtils.getValFromModel(model.GeneralInfo['@osArch']);
	    			_DOMAIN = ServiceUtils.getValFromModel(model.GeneralInfo['@domain']);
    			}

    			_GROUP = ServiceUtils.fixGroup(_GROUP, newGroup, action);
    			// if importing get  extra xml from the station application list & shared drive list
    			extraXml=ServiceUtils.getExtraXml(extraXml, action, model);
    			var StationXml =
    				'<Station name=\'' + _NAME + '\' description=\'' + _DESCRIPTION + '\' group=\'' + _GROUP + '\'>' +
    				'<GeneralInfo logLevel=\'' +_LOGLEVEL + '\' disableRunAs=\''+  _RUNAS + '\' tempDir=\''+ _TEMPDIR +
    				'\' allowedUsers=\'' +_ALLOWED_USERS + '\' othersAffinity=\'' + _AFFIN +
    				'\' stageDir=\'' + _STAGEDIR + '\' workDir=\'' + _WORKDIR +
    				'\' domain=\'' + _DOMAIN + '\' concurrency=\'' + _CONCUR + '\'  os =\'' + _OS +
    				'\' drmMode =\'' +_DRM +
    				'\' osName =\'' +_OSNAME +
    				'\' osVersion =\'' +_OSVERSION +
    				'\' osArch =\'' +_OSARCH +
    				'\'/>' + ServiceUtils.getPropertyXml(model) + extraXml +
    				'</Station>';
    			return StationXml;
    		},

    		// method to update model attributes from a group model
    		updateModelAttributesFromGroup: function (modelAttr, grp) {
    			if (grp) {
    				modelAttr.GeneralInfo['@allowedUsers'] = grp._attributes.GeneralInfo['@allowedUsers'];
    				modelAttr.allowedUsers = grp._attributes.GeneralInfo['@allowedUsers'];
    				modelAttr.GeneralInfo['@workDir'] =grp._attributes.GeneralInfo['@workDir'];
    				modelAttr.GeneralInfo['@tempDir'] = grp._attributes.GeneralInfo['@tempDir'];
    				modelAttr.GeneralInfo['@stageDir'] =grp._attributes.GeneralInfo['@stageDir'];
    				modelAttr.GeneralInfo['@othersAffinity'] =grp._attributes.GeneralInfo['@othersAffinity'];
    				modelAttr.GeneralInfo['@concurrency'] = grp._attributes.GeneralInfo['@concurrency'];
    				modelAttr.GeneralInfo['@logLevel'] =  grp._attributes.GeneralInfo['@logLevel'];
    				modelAttr.GeneralInfo['@disableRunAs'] =grp._attributes.GeneralInfo['@disableRunAs'];
    				modelAttr.GeneralInfo['@domain'] =grp._attributes.GeneralInfo['@domain'];
    				modelAttr.PropertyList = grp._attributes.PropertyList;
    			}
    		},

    		// download method which may be used to download station JSON object
    		// so it can be imported.
    		download :    function (stationData) {
    		    var doc = document,
    	         	a = doc.createElement('a'),
    	         	mimeType =  'text/plain',
    	         	fileNmae =  'stationDownload.json';

    		    //build download link:
    		    a.href = 'data:' + mimeType + 'charset=utf-8, ' + stationData;

    		    // test for IE
    			if (window.navigator.msSaveBlob !== undefined) {
    	   			var file = new Blob([stationData],  { type: 'text/plain;charset=utf-8' });
    				return window.navigator.msSaveBlob(file, fileNmae );
    			}

    			//Firefox or Chrome logic
    			a.setAttribute('download',  fileNmae);
    			a.innerHTML = 'downloading...';
    			doc.body.appendChild(a);
    			setTimeout(function() {
    				var ev = doc.createEvent('MouseEvents');
    				ev.initMouseEvent('click',  true,  false,  window,
    						0,  0,  0,  0,  0,  false,  false,  false,  false,  0,  null);
    				a.dispatchEvent(ev);
    				doc.body.removeChild(a);
    			},  60);
    			return true;

    		},

    	    /*
    	     * Open the process in transient PS Widget
    	     * Takes the id of a simulation to be opened
    	     * Opens in the default collab space which may only show the item readonly
    	     * may need to investigate collab space preference?
    	     */
    	    openProcessInPS : function (procID) {
    	        var processData,  psWidgetOptions;
    	        processData = {
    	            objectId : procID,
    	            id : procID,
    	            objectType : 'Simulation'
    	        };

    	        //setting the widget options
    	        psWidgetOptions = {
    	            procID: procID,
    	            mode: 'viewondrop',
    	            processData: processData
    	        };
    	        ServiceUtils.showTransientWidget('SIMDISB_AP',  'Performance Study',  psWidgetOptions);

    	    },

    	    // display a WUX dialog having an OK and Close button with the given content
            showDialogPanel: function (title,  content) {
                if (dialogFrame) {
                	dialogFrame.destroy();
                	dialogFrame = null;
                }

                dialogFrame = new WUXImmersiveFrame();
                dialogFrame.inject(COSInfo.getContainer());
                contentDialog = new WUXDialog({
                    title: title,
                    content: content,
                    closeButtonFlag: false,
                    immersiveFrame: dialogFrame,
                    buttons: {
                        Ok: new WUXButton({
                            onClick: function () {
                                if (UWA.typeOf(content.ok) === 'function') {
                                    content.ok();
                                }
                            }
                        }),
                        Close: new WUXButton({
                            onClick: function () {

                                if (UWA.typeOf(content.close) === 'function') {
                                    content.close();
                                }
                            }
                        })
                    }
                });

                contentDialog.bringToFront();

                content.addEvent('onClose',  function () {
                    content.destroy();
                    content = null;
                    contentDialog.close();
                    dialogFrame.destroy();
                });

            },


            // use a JSON file reader to read the content of the given file
            readFile: function (file,  onStart,  onProgress,  onComplete,  onError) {

                var reader = new FileReader();

                reader.onerror = function (evt) {
                    switch (evt.target.error.code) {
                        case evt.target.error.NOT_FOUND_ERR:
                            onError('File Not Found!');
                            break;
                        case evt.target.error.NOT_READABLE_ERR:
                            onError('File is not readable');
                            break;
                        case evt.target.error.ABORT_ERR:
                            break;
                        default:
                            onError('An error occurred reading this file.');
                    }
                };

                reader.onprogress = function (evt) {
                    if (evt.lengthComputable) {
                        var percentLoaded = Math.round((evt.loaded / evt.total) * 100);
                        if (percentLoaded < 100) {
                            onProgress(percentLoaded);
                        }
                    }
                    else {
                        onProgress(100);
                    }

                };

                reader.onloadstart = onStart;

                reader.onload = function () {
                    onComplete(reader.result);
                    reader = null;
                };

                reader.readAsText(file);

                return {

                    cancel: function () {
                        reader.abort();
                        reader = null;
                    }
                };
            }
        };

        return ServiceUtils;
});
