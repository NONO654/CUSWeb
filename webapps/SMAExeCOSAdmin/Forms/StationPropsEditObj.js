define('DS/SMAExeCOSAdmin/Forms/StationPropsEditObj',
    ['DS/WebappsUtils/WebappsUtils',
     'UWA/Core',
     'UWA/Class/Model',
	 'DS/UIKIT/Form',
     'DS/UIKIT/Modal',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
     'DS/SMAExeCOSAdmin/Forms/COSFormUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
     'DS/SMAExeCOSAdmin/Views/ServerForm',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],
    /*
     * function to create modal edit dialog for station properties and methods to
     * control filling in the dialogs data and displaying the dialog.
     * When the dialog is submitted get the data and create JSON object representing the station data.
     */
    function (WebappsUtils,   UWA,   Model,     UIForm,   UIModal,   WSUtils,  FormUtils,  COSInfo,  COSUtils,   ServerForm,   NLS) {
         'use strict';
         var modal = {};
         var serverToUse = '';
         var inEdit = false;
         var myModel = {};
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
         var _DRM = '';
         var _OS = '';
         var _OSNAME = '';
         var _OSVERSION = '';
         var _OSARCH = '';
         var _DOMAIN = '';
         var _PROPS = '';
         var _NUMBAK = '';
         var _MAXSIZE = '';
         var _FASTFLOWRES = '';
         var _MPIPATH = '';
         var _LARGEFILE = '';
         var _PORTRANGE = '';
         var _CLIENTSERVICES = '';
         var _COMPUTESERVICES = '';
         var _PARAMMATCH = '';
         var _EXPOSEDNAME = '';
         var _EXPOSEDPORTS = '';
         var _EXPOSEDIPADDR = '';
         var _RESULTSERVICES = '';
         var _STAGEFILE = '';
         var _SUBSTARTTIME = '';
         var _SUBLAUNCH = '';
         var _SUBKEEP = '';
         var _FCSENGINEDIR = '';
         var _FCSSTAGEDIR = '';
         var _CACHEPLM = '';
         var _PREDEFINED = '';
         var _CERTIFICATE = '';
         var _CERTIFICATEKEY = '';
         var _CERTIFICATECERT = '';
         var _LEASEINTERVAL = '';
         var _SKIPLOCK = '';
         var _SAVELOG = '';
         var _MAXQUIESCE = '';
         var _JOBLOGREPOS = '';
         var _SHAREABLELICPATH = '';
         var _SHAREABLERETRYNUM = '';
         var _SHAREABLERETRYINTERVAL = '';
         var PropertyList = {};
         var oldRunAs = '';
         var runAsChanged = false;


 		 // get the data from the model passed in ad update the form's fields
         var StationPropsEditObj = {
        		 
         		isNameValid : function (name) {
            		var badChar=['!','@','#','$','%','^','&','*','(',')','~','/','\\','[',']',',',':',';','\'','"','<','>','{','}','?','=','|','+','`'];
        			var ok = true;
        			badChar.forEach(function(ch){
        				if (name.contains(ch)) {
        					ok = false;
        				}
        			});
        			return ok;
        		},
        		 // utility method to check if any problems when restarting station
        		 okFunc : function (data) {
                	 var message = data.split('problem');
                	 // if stations could not be restarted...display error
                	 if (message.length > 1) {
                		 COSUtils.displayError(data, true);
                	 }
                 },
                 // function to update model attributes from modified form data if src is null
                 // or from a group model if station is changing groups
                 // model can be form's model that was modified
                 // or station model if group model is modified and station
                 // is part of group
        		 updateModelAttributes : function (modelAttr,  src) {
                	 if (src) {
                		 COSUtils.updateModelAttributesFromGroup(modelAttr,  src);
                	 }
                	 else {
        	        	 modelAttr.GeneralInfo['@allowedUsers'] = _ALLOWED_USERS;
        	        	 modelAttr.GeneralInfo['@workDir'] =_WORKDIR;
        	        	 modelAttr.GeneralInfo['@tempDir'] = _TEMPDIR;
        	        	 modelAttr.GeneralInfo['@stageDir'] = _STAGEDIR;
        	        	 modelAttr.GeneralInfo['@othersAffinity'] =_AFFIN;
        	        	 modelAttr.GeneralInfo['@concurrency'] = _CONCUR;
        	        	 modelAttr.GeneralInfo['@logLevel'] =  _LOGLEVEL;
        	        	 modelAttr.GeneralInfo['@disableRunAs'] = _RUNAS;
        	        	 modelAttr.GeneralInfo['@domain'] = _DOMAIN;
        	        	 modelAttr.PropertyList = PropertyList;
                	 }
                 },

         		// helper function to eliminate use of Conditional (ternary) operator to reduce complexity
                 getValueFromModel : function (model,  attr,  needGenInfo) {
                	 var value = '';
                	 if (needGenInfo) {
                		 value = model._attributes.GeneralInfo[attr] ;
                	 }
                	 else {
                		 value = model._attributes[attr] ;
                	 }
                	 if (value === undefined || value === 'undefined') {
                		 value = '';
                	 }
                	 return value;
                 },

                 // utility method to set or remove a property in the property map based on the value being set
                 setProperty : function (Property,  value,  key){
                	 if (value) {
                		 Property.set(key,  value);
                	 }
                	 else if (Property.has(key)) {
                		 Property.delete(key);
                	 }
                 },

          		// helper function to either get the values from the model or the form values entered in the dialog
                 getPropValues : function (form,  formVal) {
                	 _NAME = form.model? form.model._attributes['@name']:formVal.stationName;
                 	 _NAME = _NAME.trim();
                	 PropertyList = form.model?  form.model._attributes.PropertyList : {};
                	 if (form.model) {
        	             _DESCRIPTION = StationPropsEditObj.getValueFromModel(form.model,  '@description',  false);
        	             _GROUP = StationPropsEditObj.getValueFromModel(form.model,  '@group',  false);
        	             _WORKDIR = StationPropsEditObj.getValueFromModel(form.model,  '@workDir',  true);
        	             _STAGEDIR = StationPropsEditObj.getValueFromModel(form.model,  '@stageDir',  true);
        	             _TEMPDIR = StationPropsEditObj.getValueFromModel(form.model,  '@tempDir',  true);
        	             _ALLOWED_USERS = StationPropsEditObj.getValueFromModel(form.model,  '@allowedUsers',  true);
        	             _AFFIN = StationPropsEditObj.getValueFromModel(form.model,  '@othersAffinity',  true);
        	             _CONCUR = StationPropsEditObj.getValueFromModel(form.model,  '@concurrency',  true);
        	             _RUNAS = StationPropsEditObj.getValueFromModel(form.model,  '@disableRunAs',  true);
        	             _OS = StationPropsEditObj.getValueFromModel(form.model,  '@os',  true);
        	             _OSNAME = StationPropsEditObj.getValueFromModel(form.model,  '@osName',  true);
        	             _OSVERSION = StationPropsEditObj.getValueFromModel(form.model,  '@osVersion',  true);
        	             _OSARCH = StationPropsEditObj.getValueFromModel(form.model,  '@osArch',  true);
        	             _DOMAIN = StationPropsEditObj.getValueFromModel(form.model,  '@domain',  true);
        	             _DRM = StationPropsEditObj.getValueFromModel(form.model,  '@drmMode',  true);

                	 }
                	 else {
                         _DESCRIPTION = formVal.description;
                         _GROUP = formVal.group?formVal.group:'' ;
                         _WORKDIR = formVal.workDir;
                         _STAGEDIR = formVal.stageDir;
                         _TEMPDIR = formVal.tempDir;
                         _ALLOWED_USERS = formVal.allowedUsers;
                         _AFFIN = formVal.othersAffinity;
                         _CONCUR = formVal.concurrency;
                         _LOGLEVEL = formVal.logLevel;
                         _RUNAS = formVal.disableRunAs;
                         _OS = formVal.os;
                         _OSNAME = formVal.osName;
                         _OSVERSION = formVal.osVersion;
                         _OSARCH = formVal.osArch;
                         _DOMAIN = formVal.domain;
                         _DRM = formVal.drmMode?  formVal.drmMode:'fiper';
                	 }
                 },

           		 // helper functions to get the values from the various property tabs
                 getValuesFromLoggingTab : function (form,  formVal,  Property) {
                 	 if (form.cn.contains('logging')) {
                         _LOGLEVEL = formVal.logLevel;
                         _NUMBAK = formVal.numBackups?formVal.numBackups:'';
                         _MAXSIZE = formVal.maxSize?formVal.maxSize:'';
                         _SAVELOG = formVal.saveLogOnError?formVal.saveLogOnError:'';
                         // set the properties in the property map from the fields in the dialog
                         StationPropsEditObj.setProperty(Property,  _NUMBAK,  'fiper.logging.numBackups');
                         StationPropsEditObj.setProperty(Property,  _MAXSIZE,  'fiper.logging.maxSizeKB') ;
                         StationPropsEditObj.setProperty(Property,  _SAVELOG,  'fiper.station.saveLogOnError') ;
                	 }
                 	 return '';
                 },
                 getValuesFromGeneralTab : function (form,  formVal) {
                 	 if (form.cn.contains('general')) {
                         _WORKDIR = formVal.workDir;
                         _TEMPDIR = formVal.tempDir;
                         _ALLOWED_USERS = formVal.allowedUsers;
                         _AFFIN = formVal.othersAffinity;
                         _CONCUR = formVal.concurrency;
                	 }
                 	 return '';
                 },
                 getValuesFromRoTab : function (form,  formVal) {
                 	 if ( form.cn.contains('-ro-')) {
                         _DESCRIPTION = formVal.description;
                         _GROUP = formVal.group?formVal.group:'' ;
                         _OS = formVal.os;
                         _OSNAME = formVal.osName;
                         _OSVERSION = formVal.osVersion;
                         _OSARCH = formVal.osArch;
                         _DRM = formVal.drmMode?  formVal.drmMode:'fiper';
                	 }
                 	 return '';
                 },
                 getValuesFromAdvancedTab : function (form,  formVal,  Property) {
                	 var advancedErrMsg = '';
                 	 if (form.cn.contains('advanced')) {
                         _STAGEDIR = formVal.stageDir?formVal.stageDir:'';
                         _RUNAS = formVal.disableRunAs;
                         _DOMAIN = formVal.domain;
                         _PROPS = formVal.moreProps;
                         _FASTFLOWRES = formVal.fastFlowResults?formVal.fastFlowResults:'';
                         _SUBSTARTTIME = formVal.subStarttime?formVal.subStarttime:'';
                         _SUBLAUNCH = formVal.subLaunchtimeout?formVal.subLaunchtimeout:'';
                         _SUBKEEP = formVal.subKeepalive?formVal.subKeepalive:'';
                         _FCSENGINEDIR = formVal.fcsEnginedir?formVal.fcsEnginedir:'';
                         _FCSSTAGEDIR = formVal.fcsServerStagingdir?formVal.fcsServerStagingdir:'';
                         _CACHEPLM = formVal.cacheplmfiles?formVal.cacheplmfiles:'';
                         _PREDEFINED = formVal.predefinedonly?formVal.predefinedonly:'';
                         _CERTIFICATE = formVal.certificate?formVal.certificate:'';
                         _CERTIFICATEKEY = formVal.certificateKey?formVal.certificateKey:'';
                         _CERTIFICATECERT = formVal.certificateCert?formVal.certificateCert:'';
                         _LEASEINTERVAL = formVal.leaseinterval?formVal.leaseinterval:'';
                         _SKIPLOCK = formVal.skiplock?formVal.skiplock:'';
                         _MAXQUIESCE = formVal.maxquiescetime?formVal.maxquiescetime:'';
                         _JOBLOGREPOS = formVal.jobLogRepository?formVal.jobLogRepository:'';
                         _SHAREABLELICPATH = formVal.shareableLicPath?formVal.shareableLicPath:'';
                         _SHAREABLERETRYNUM = formVal.shareableLicRetryNum?formVal.shareableLicRetryNum:'';
                         _SHAREABLERETRYINTERVAL = formVal.shareableLicRetryInterval?formVal.shareableLicRetryInterval:'';
                         
                         if (isNaN(_SHAREABLERETRYNUM)) {
                        	 advancedErrMsg = NLS.get('retryNumErr');
                         }
                         else if (isNaN(_SHAREABLERETRYINTERVAL)) {
                        	 advancedErrMsg = NLS.get('retryIntervalErr');
                         }
                         else if (_SHAREABLERETRYNUM < 0) {
                        	 advancedErrMsg = NLS.get('retryNumErr');                        	 
                         }
                         else if (_SHAREABLERETRYINTERVAL < 0) {
                        	 advancedErrMsg = NLS.get('retryIntervalErr');
                         }
                         if (advancedErrMsg.length == 0){
	                         if (form.model) {
	                        	 //check to see if run-as changed
	                        	 oldRunAs = StationPropsEditObj.getValueFromModel(form.model,  '@disableRunAs',  true);
	                        	 if (oldRunAs !==_RUNAS) {
	                        		 runAsChanged = true;
	                        	 }
	                         }
	
	                         if (_PROPS  && _PROPS.length > 1) {
	                           	var propArray = _PROPS.split('\n');
	                            	propArray.forEach(function (prp) {
	                           		if (prp ){
	                           			var propData = prp.split('=');
	                           			if (propData && propData.length && propData.length ===2) {
	                           				Property.set(propData[0],  propData[1]);
	                           			}
	                           		}
	                           	});
	                         }
	                         else {
	                         	Property.forEach(function (value,  key) {
	                        		if (!(COSUtils.hasFieldPropValue(key))) {
	                           		 	Property.delete(key);
	                        		}
	                        	});
	                         }
	
	                         // set the properties in the property map from the fields in the dialog
	                         StationPropsEditObj.setProperty(Property,  _FASTFLOWRES,  'fiper.station.fastflowSendResultsInterval');
	                         StationPropsEditObj.setProperty(Property,  _SUBSTARTTIME,  'fiper.station.substation.starttime');
	                         StationPropsEditObj.setProperty(Property,  _SUBLAUNCH,  'fiper.substation.launchtimeout');
	                         StationPropsEditObj.setProperty(Property,  _SUBKEEP,  'fiper.substation.keepalive.interval.ms');
	                         StationPropsEditObj.setProperty(Property,  _FCSENGINEDIR,  'fiper.station.fcs.enginedir');
	                         StationPropsEditObj.setProperty(Property,  _FCSSTAGEDIR,  'fiper.station.fcs.serverstagingdir');
	                         StationPropsEditObj.setProperty(Property,  _CACHEPLM,  'fiper.station.cacheplmfiles');
	                         StationPropsEditObj.setProperty(Property,  _PREDEFINED,  'fiper.station.oscommand.predefinedonly');
	                         StationPropsEditObj.setProperty(Property,  _CERTIFICATE,  'fiper.station.certificate');
	                         StationPropsEditObj.setProperty(Property,  _CERTIFICATEKEY,  'fiper.station.certificate.key');
	                         StationPropsEditObj.setProperty(Property,  _CERTIFICATECERT,  'fiper.station.certificate.cert');
	                         StationPropsEditObj.setProperty(Property,  _LEASEINTERVAL,  'fiper.station.leaseinterval');
	                         StationPropsEditObj.setProperty(Property,  _SKIPLOCK,  'fiper.system.templib.skiplock');
	                         StationPropsEditObj.setProperty(Property,  _MAXQUIESCE,  'fiper.station.maxquiescetime');
	                         StationPropsEditObj.setProperty(Property,  _JOBLOGREPOS,  'smaexe.cos.station.ftp.joblog.repository');
	                         StationPropsEditObj.setProperty(Property,  _SHAREABLELICPATH,  'fiper.station.defaultshareablelicconfig.file');
	                         StationPropsEditObj.setProperty(Property,  _SHAREABLERETRYNUM,  'fiper.station.defaultshareablelicconfig.retry');
	                         StationPropsEditObj.setProperty(Property,  _SHAREABLERETRYINTERVAL,  'fiper.station.defaultshareablelicconfig.retryinterval');
	                	 }
                 	 }
                 	 return advancedErrMsg;
                 },
                 getValuesFromComputeTab : function (form,  formVal,  Property) {
                 	 if (form.cn.contains('compute')) {
                 		 _MPIPATH = formVal.mpiPath?formVal.mpiPath:'';
                 		 _LARGEFILE = formVal.largeFileDir?formVal.largeFileDir:'';
                 		 _PORTRANGE = formVal.portRange?formVal.portRange:'';
                 		 _CLIENTSERVICES = formVal.clientservices?formVal.clientservices:'';
                 		 _COMPUTESERVICES = formVal.computeServices?formVal.computeServices:'';
                 		 _STAGEFILE = formVal.stageFileScript?formVal.stageFileScript:'';
                         // set the properties in the property map from the fields in the dialog
                         StationPropsEditObj.setProperty(Property,  _MPIPATH,  'fiper.station.mpirunPath');
                         StationPropsEditObj.setProperty(Property,  _LARGEFILE,  'fiper.station.sim.largeFileWorkingDir');
                         StationPropsEditObj.setProperty(Property,  _PORTRANGE,  'fiper.station.sim.portrange');
                         StationPropsEditObj.setProperty(Property,  _CLIENTSERVICES,  'fiper.station.sim.clientservices');
                         StationPropsEditObj.setProperty(Property,  _COMPUTESERVICES,  'fiper.station.sim.computeservices');
                         StationPropsEditObj.setProperty(Property,  _STAGEFILE,  'fiper.station.sim.stageFileScript');
                 	 }
                 	 return '';
                 },
                 getValuesFromResultsTab : function (form,  formVal,  Property) {
                 	 if ( form.cn.contains('results')) {
                         _PARAMMATCH = formVal.parameterMatch?formVal.parameterMatch:'';
                         _EXPOSEDNAME = formVal.exposedName?formVal.exposedName:'';
                         _EXPOSEDIPADDR = formVal.exposedIPAddr?formVal.exposedIPAddr:'';
                         _EXPOSEDPORTS = formVal.exposedPorts?formVal.exposedPorts:'';
                         _RESULTSERVICES = formVal.resultsServices?formVal.resultsServices:'';
                         // set the properties in the property map from the fields in the dialog
                         StationPropsEditObj.setProperty(Property,  _PARAMMATCH,  'fiper.station.advise.variant.parametermatch');
                         StationPropsEditObj.setProperty(Property,  _EXPOSEDNAME,  'fiper.station.exposedname');
                         StationPropsEditObj.setProperty(Property,  _EXPOSEDPORTS,  'fiper.station.exposedports');
                         StationPropsEditObj.setProperty(Property,  _EXPOSEDIPADDR,  'fiper.station.sim.exposedipaddress');
                         StationPropsEditObj.setProperty(Property,  _RESULTSERVICES,  'fiper.station.sim.resultsservices');
                 	 }
                 	 return '';
                 },
                 getValuesFromTab : function (form,  formVal,  Property) {
                	 var errorMessage = '';
                	 if (form.model) {
                		 errorMessage = StationPropsEditObj.getValuesFromLoggingTab(form,  formVal,  Property);
                		 if (errorMessage.length == 0) {
                			 errorMessage = StationPropsEditObj.getValuesFromGeneralTab(form,  formVal);
                		 }
                		 if (errorMessage.length == 0) {
                			 errorMessage = StationPropsEditObj.getValuesFromRoTab(form,  formVal);
                		 }
                		 if (errorMessage.length == 0) {
                			 errorMessage = StationPropsEditObj.getValuesFromAdvancedTab(form,  formVal,  Property);
                		 }
                		 if (errorMessage.length == 0) {
                			 errorMessage = StationPropsEditObj.getValuesFromComputeTab(form,  formVal,  Property);
                		 }
                		 if (errorMessage.length == 0) {
                			 errorMessage = StationPropsEditObj.getValuesFromResultsTab(form,  formVal,  Property);
                		 }
                	 }
                	 return errorMessage;
                 },
                 // function that gets the form data and constructs the JSON object representing a station
                 updateStation : function (form,  serverName,  url) {

                	 // get the form data
                	 var formVal = form.getValues();
                	 var _DRIVEXML = '';
                	 StationPropsEditObj.getPropValues(form,  formVal);

                  	  var Property = new Map();
                  	  if (PropertyList ) {
                  		  if (PropertyList.Property) {
                  			  Property = PropertyList.Property;
                  		  }
                  		  else {
                  			PropertyList.Property = Property;
                  		  }
                  	  }
                  	  else if (form.model){
                  		  form.model.set('PropertyList',  {Property:new Map()});
                  		  PropertyList = form.model.get('PropertyList');
                  		  Property = PropertyList.Property;
                  	  }

                  	  // check for duplicates when creating stations or groups
                  	  if (!inEdit) {
              	   		var haveDuplicate = COSUtils.checkForDuplicates(_NAME,  serverName) ;
        		   		if (haveDuplicate ) {
        		   			COSUtils.displayError(NLS.get('dupCreateErr'),  true);
        	    	   		return;
        		   		}
        		   		
        		   		// check for invalid characters in station name
        		   		var nameOK = StationPropsEditObj.isNameValid(_NAME);
        		   		if (!nameOK) {
        		   			COSUtils.displayError(_NAME + NLS.get('machineInvalid'),  true);
        	    	   		return;        		   			
        		   		}

        		   		// if we are creating a station or a group
        		   		// define simshared to be $SHARED_DRIVE,   the default for physics app
        		   		_DRIVEXML = _DRIVEXML + '<SharedFSList>';
        		   		_DRIVEXML = _DRIVEXML +'<SharedFS Name=\'simshared\' Path=\'$SHARED_DRIVE\'/>';
        		   		_DRIVEXML = _DRIVEXML + '</SharedFSList>';

                  	  }
                  	var errMsg = StationPropsEditObj.getValuesFromTab(form,  formVal,  Property);
                  	if (errMsg.length > 0){
    		   			COSUtils.displayError(errMsg,  true);
                  	}
                  	else {
	                     var _PROPERTYXML =  COSUtils.getPropertyXml(form.model);
	
	                     if (_DESCRIPTION.length > 250){
	                     	 _DESCRIPTION = _DESCRIPTION.substr(0,240);
	        		   			COSUtils.displayInfo(_NAME + NLS.get('descriptionTooLong'),  true);
	                      }
	
	                     
	                     var StationXml = '<?xml version=\'1.0\' encoding=\'utf-8\'?>' +
	                	 	'<StationList>' +
	                	 		'<Station name=\'' + _NAME + '\' description=\'' + encodeURIComponent(_DESCRIPTION) + '\' group=\'' + _GROUP + '\'>' +
	                	 			'<GeneralInfo logLevel=\'' +_LOGLEVEL + '\' disableRunAs=\''+  _RUNAS + '\' tempDir=\''+ _TEMPDIR +
	                	 				  '\' allowedUsers=\'' +_ALLOWED_USERS + '\' othersAffinity=\'' + _AFFIN +
	                	 				  '\' stageDir=\'' + _STAGEDIR + '\' workDir=\'' + _WORKDIR +
	                	 				  '\' domain=\'' + _DOMAIN + '\' concurrency=\'' + _CONCUR + '\'  os =\'' + _OS +
	                	 				  '\' drmMode =\'' +_DRM +
	                	 				  '\' osName =\'' +_OSNAME +
	                	 				  '\' osVersion =\'' +_OSVERSION +
	                	 				  '\' osArch =\'' +_OSARCH +
	                	 				  '\'/>'
	                	 			+ _PROPERTYXML + _DRIVEXML +
	                	 		'</Station>' +
	                	 	'</StationList>';
	
	
	                	 WSUtils.updateStation(url,   serverName,   StationXml,
	                         function(){
	                		    var groupChanged = false;
	                             // get the original station info and update with the form data
	                          	if (myModel){
	                          		var Station1 = myModel._attributes;
	                          		StationPropsEditObj.updateModelAttributes(Station1,  null);
	                          		Station1['@description'] =  _DESCRIPTION;
	
	                          		// if we are modifying a station and the group changed set the flag
	                          		// we need to reset the station model from the new group
	                          		if (Station1['@group'] !== _GROUP && !_DRM.endsWith('Grp')) {
	                          			groupChanged = true;
	                          		}
	                          		Station1['@group'] =  _GROUP;
	                          		// since not using model.set to make changes need to notify change occured
	                          		myModel.dispatchEvent('onChange');
	                          		
	                          		// if run-as changed need to restart the station
	                          		if (runAsChanged && !(_DRM.endsWith('Grp'))) {
	                          			var stationList = myModel.get('name');
	                          			StationPropsEditObj.restartStations(myModel,stationList,false) ;
	                          		}
	                          	}
	
	                          	// if creating new station collapse tree so can be rebuilt correctly
	        		        	if (!inEdit) {
	        		        		var node = COSUtils.findNode(serverToUse);
	        		        		if (node) {
	        		        			node.collapseAll();
	        		        		}
	        		        		COSInfo.getBones().slideBack();
	        			   			COSUtils.displayInfo(_NAME + NLS.get('stationCreated'),  true);
	
	        		        	}
	        		        	// else if edit and modfying a group need to make same modifications
	        		        	// for station in that group
	        		        	else if (_DRM.endsWith('Grp')) {
	     		        		    var statList = '';
	     		        		    var first = true;
	        		        	    for (var idx = 0 ; idx < myModel.collection._models.length; idx++) {
	        		        			var mod1 = myModel.collection._models[idx];
	        		        			if (myModel._attributes.name === mod1.get('@group')) {
	        		        				StationPropsEditObj.updateModelAttributes(mod1._attributes,  null);
	        		         	 			// since changing station in group need to notify change occurred
	        		         	 			mod1.dispatchEvent('onChange');
	        		         	 			// get the station names in the list for restart
	        		         	 			if (first) {
	        		         	 				statList = statList + 'stationName=' + mod1.get('name');
	        		         	 				first =false;
	        		         	 			}
	        		         	 			else {
	        		         	 				statList = statList + '&stationName=' + mod1.get('name');
	        		         	 			}
	        		        			}
	        		        		}
	
	        		        	    // if run-as changed need to restart the stations in the group
	        		        	    if (runAsChanged) {
	                          			StationPropsEditObj.restartStations(myModel,statList,true) ;
	                          		}
	        		        	}
	        		        	// if we changed the group for a station
	        		        	// need to re-parent station node in the tree
	        		        	// also if changing to a different group
	        		        	// need to update the station with the properties from the group
	        		        	else if (groupChanged) {
	        		        		var myNode = COSUtils.findNode(myModel.id);
	        		        		var parNode = myNode.getParent();
	
	        		        		// assume the new parent is the server (removed station from a group)
	        		        		var newPar = COSUtils.findNode(serverToUse);
	        		        		// if changing to a new group
	        		        		if (_GROUP.length > 0) {
	        		        			var groupId = _GROUP+'@@'+serverToUse;
	
	        		        			// get node of the new group in the tree so station can be re-parented
	        		        			newPar = COSUtils.findNode(groupId);
	        		        			// find the new group's  model so station properties can be updated from group model
	        			        		for (var idx2 = 0 ; idx2 < myModel.collection._models.length; idx2++) {
	        			        			var mod2 = myModel.collection._models[idx2];
	        			        			if (mod2.id === groupId) {
	        			                  		var Station = myModel._attributes;
	        			                  		StationPropsEditObj.updateModelAttributes(Station,  mod2);
	        			         	 			// since changing station in group need to notify change occurred
	        			                  		myModel.dispatchEvent('onChange');
	        			        			}
	        			        		}
	        		        		}
	        		        		// re-parent the station
	        		        		parNode.removeChild(myNode);
	        		        		newPar.addChild(myNode);
	        		        	}
	                	 });
	                 	modal.hide();
                  	}
                 },
                 
                 // method to restart the stations if run-as changed
                 restartStations : function(model,stationName,forGroup) {
                	 var url = model.get('fullCosUrl');
                	 var server = model.get('serverName');
                	 var functionToCall = WSUtils.startStation;
                	 if (forGroup) {
                		 functionToCall = WSUtils.startStations;
                	 }
            		 functionToCall(
            				 url,
            				 server,
            				 stationName, StationPropsEditObj.okFunc);
                	 
                 },

         		updateFields : function (model,  editMode,  serverName,  url,  forGroup) {
                    // define the form fields
        			var v=COSInfo.getBones();
        			var cn = '';
        			var func = null;

        			if (v) {
        				v=COSInfo.getBones().getViewAt(1);
        				cn = v.container.className;
        			}

        			// check container classname to get the appropriate property tab fields
        			if (cn.contains('general')) {
        				func=FormUtils.getStationGeneralFields;
        			}
        			else if (cn.contains('logging')) {
        				func=FormUtils.getStationLoggingFields;
        			}
        			else if (cn.contains('advanced')) {
        				func=FormUtils.getStationAdvancedFields;
        			}
        			else if (cn.contains('compute')) {
        				func=FormUtils.getStationComputeFields;
        			}
        			else if (cn.contains('results')) {
        				func=FormUtils.getStationResultsFields;
        			}
        			else if (cn.contains('-ro-')) {
        				func=FormUtils.getStationROFields;
        			}
        			else if (!editMode){
        				func = FormUtils.getStationFields;
        			}
        			if (func) {
        				if (editMode){
	        				var formOptions = {
	        						className : 'vertical',
	        						fields: func(model,  editMode,  serverName,  false,  forGroup),
	        						buttons: [{
	        							type: 'submit',
	        							value: NLS.get('submit')
	        						}],
	        						events: {
	        							onSubmit:  function () {
	        								var splitServer = serverName.split('@@');
	        								if (splitServer.length >1) {
	        									serverName = splitServer[1];
	        								}
	        								serverToUse = serverName;
	        								inEdit = editMode;
	        								myModel = model;
	        								StationPropsEditObj.updateStation(this,  serverName,  url);
	        							},
	        							onInvalid: function () {
	        								COSUtils.displayError(NLS.get('dlgErr'),  true);
	        							}
	        						}
	        				};

	        				var theForm = new ServerForm(UWA.extend({
	        					model : model
	        				},   formOptions));
	        				theForm.model = model;
	        				theForm.cn = cn;
	        				return theForm;
        				}
        				else {
	        				var myForm = new UIForm({
	        					className: 'vertical',
	        					fields: func(model,  editMode,  serverName,  false,  forGroup),
	        					buttons: [{
	        						type: 'submit',
	        						value: NLS.get('submit')
	        					}],
	        					events: {
	        						onSubmit:  function () {
	        							var splitServer = serverName.split('@@');
	        							if (splitServer.length >1) {
	        								serverName = splitServer[1];
	        							}
	        							serverToUse = serverName;
	        							inEdit = editMode;
	        							myModel = model;
	        							StationPropsEditObj.updateStation(this,  serverName,  url);
	        						},
	        						onInvalid: function () {
	        							COSUtils.displayError(NLS.get('dlgErr'),  true);
	        						}
	        					}
	        				});
	        				myForm.model = model;
	        				return myForm;
        				}
        			}
        			return null;

        		},
        		// function to create the modal dialog from the form and show it
        		showDialog : function (theForm,  forGroup) {
        			var headerStr = NLS.get('createStation');
        			if (forGroup) {
        				headerStr = NLS.get('createGroup');
        			}
        			if (theForm.model){
        				headerStr = NLS.get('editStation');
            			// check container classname to get the appropriate header for the tab being editted
        				if (theForm.cn.contains('general')) {
            				headerStr = NLS.get('editStationGeneral');
        				}
        				if (theForm.cn.contains('logging')) {
            				headerStr = NLS.get('editStationLogging');
        				}
        				if (theForm.cn.contains('advanced')) {
            				headerStr = NLS.get('editStationAdvanced');
        				}
        				if (theForm.cn.contains('compute')) {
            				headerStr = NLS.get('editStationCompute');
        				}
        				if (theForm.cn.contains('results')) {
            				headerStr = NLS.get('editStationResults');
        				}
        			}
                    modal = new UIModal({
                        closable : true,
                        header : headerStr,
                        body: theForm
                    });

                    modal.inject(COSInfo.getContainer());
                    modal.show();

        		}
        };
        return StationPropsEditObj;
});
