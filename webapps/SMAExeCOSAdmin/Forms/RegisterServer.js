define('DS/SMAExeCOSAdmin/Forms/RegisterServer',
    ['DS/WebappsUtils/WebappsUtils',
     'UWA/Core',
     'UWA/Controls/Abstract',
     'UWA/Class/Model',
	 'DS/Controls/ButtonGroup',
	 'DS/Controls/Button',
     'DS/Tree/TreeNodeModel',
	 'DS/UIKIT/Form',
     'DS/UIKIT/Modal',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],
     function (
    	WebappsUtils,   UWA,   Abstract,   Model,    ButtonGroup,   Button,   TreeNodeModel,
    	UIForm,   UIModal,  COSInfo,  COSUtils,  WSUtils,  NLS)
    	{

         'use strict';
     	var modal = {};
     	var newServer = {};
		var editMode = false;


		 // get the data from the model passed in and update the form's fields if there
        var RegisterServer = {
        		// utility method to check validity of a single port number
        		isPortValid : function (port,forPrivate) {
        			// make sure it is a number
        			if (isNaN(port)) {
        				return false;
        			}
	    			//make sure it is an integer
	    		    var remainder = (port % 1);
	    		    if (remainder !== 0) {
	        			return false;
	    		    }
	    		    if (forPrivate ){
		    		    if (port > 65535) {
		    		    	return false;
		    		    }
		    		    if (port <= 1024 ){
		    		    	return false;
		    		    }
	    		    }
	    		    return true;
        		},
        		
        		isMachineValid : function (machine) {
            		var badChar=['!','@','#','$','%','^','&','*','(',')','~','/','\\','[',']',',',':',';','\'','"','<','>','{','}','?','=','|','+','`'];        			
        			var ok = true;
        			badChar.forEach(function(ch){
        				if (machine.contains(ch)) {
        					ok = false;
        				}
        			});
        			return ok;
        		},

        		// utility method to check the validity of the private station ports
        		// splits the comma separated list and check the validity of each port in the list
        		isPrivPortsValid : function (ports) {
        			var portsOK=true;

        			// if ports field is empty then just use default ports
        			var portList = ports.split(',');
        			portList.forEach(function (port) {
        				if (!RegisterServer.isPortValid(port,true)) {
        					portsOK = false;
        				}
        			});
        			return portsOK;
        		},

        		registerTheServer : function () {
                	var _NAME = arguments[0][0].ID.trim();
                	var _EEDURL = '';
                	var _EEDWSURI = 'SMAExeServer-REST';
                	var _PUBKEY = arguments[0][0].publicKey;
                	var _PORT = arguments[0][0].port;
                	var _MACHINE = arguments[0][0].machine	;
                	var _METHOD = 'https';
                	var _PRIVPORTS = arguments[0][0].privatePorts; 
                	var _SERVERPROPID = arguments[0][0].serverPropId
                	
                	if (_SERVERPROPID === undefined || _SERVERPROPID === null) {
                		_SERVERPROPID='';
                	}

                	var _PROXURL = _METHOD+'://' + _MACHINE + ':' + _PORT +'/';
            		var fullUrl = _PROXURL + _EEDWSURI;

            		// check if the COS server port is valid
		      		var portOK = RegisterServer.isPortValid(_PORT,false);
		      		
		      		// if no ports are entered just use the defaults
        			if (_PRIVPORTS === undefined || _PRIVPORTS.length === 0) {
        				_PRIVPORTS = '35125, 45341, 55447';
        			}


		      		//check if the private station ports is valid
		    		var isPrivPortsOK = RegisterServer.isPrivPortsValid(_PRIVPORTS);
		    		var isMachineOK = RegisterServer.isMachineValid(_MACHINE);
		    		var isNameOK = RegisterServer.isMachineValid(_NAME);
		    		var isServerPropOK = RegisterServer.isMachineValid(_SERVERPROPID);

		    		// display error message if cos server machine name invalid
		    		if (!isMachineOK) {
		    			COSUtils.displayError(_MACHINE + NLS.get('machineInvalid'),  true);
		    		}

		    		// display error message if cos server alias name invalid
		    		if (!isNameOK) {
		    			COSUtils.displayError(_NAME + NLS.get('machineInvalid'),  true);
		    		}

		    		// display error message if cos server properties id  invalid
		    		if (!isServerPropOK) {
		    			COSUtils.displayError(_SERVERPROPID + NLS.get('machineInvalid'),  true);
		    		}

		    		// display error message if cos server port invalid
		    		if (!portOK) {
		    			COSUtils.displayError(_PORT + NLS.get('portIsNaN'),  true);
		    		}

		    		// display error message if the private station ports are not valid
		    		if (!isPrivPortsOK) {
		    			COSUtils.displayError(NLS.get('privPortsIsNaN'),  true);
		    		}

		    		// check if server is already registered and try to register again
		    		var node = COSUtils.findNode(_NAME);
            		var treeView = COSInfo.getBones().getViewAt(0);
            		var isGlobal = _NAME === treeView.collection._models[0].id;
            		if (!editMode && node) {
            			COSUtils.displayError(NLS.get('registerDupErr'),  true);
            		}
            		// else either editing server or registering new server
            		// if editing get old data
            		else if (isPrivPortsOK && portOK && isMachineOK && isNameOK && isServerPropOK) {
                    	var oldKey = '';
                    	var oldurl = '';
        				var oldprivports = '';
        				var oldServerPropId = '';
	            		var viewAt1 = COSInfo.getBones().getViewAt(1);
        				if (editMode && viewAt1) {
        					oldprivports = viewAt1.model.get('privatePorts');
        					if (oldprivports === undefined || oldprivports.length === 0) {
        						oldprivports = '35125, 45341, 55447';
        					}
        					oldurl = viewAt1.model.get('fullCosUrl');
        					oldKey = viewAt1.model.get('publicKey');
        					oldServerPropId = viewAt1.model.get('serverPropId');
        				}
        	        	newServer = {
        	        			id:_NAME,
        	        			proxyServerUrl:_PROXURL,
        	        			eedUrl:_EEDURL,
        	        			eedwsUri:_EEDWSURI,
        	        			fullCosUrl:fullUrl,
        	        			idDefault:false,
        	        			privatePorts:oldprivports, // don't set unless set ports works
        	        			eedPublicKey:_PUBKEY,
        	        			serverPropId:_SERVERPROPID
        	        	};

        	        	// if the private ports are ok and have changed
        	        	// call web service to update port configs when we are in edit mode
        	        	// register will not process the private ports
            			if (_PRIVPORTS !== oldprivports && editMode) {
	            				WSUtils.adminSetPortConfig(fullUrl, _NAME, _PRIVPORTS,
		            				function () {
		            					var viewAt1 = COSInfo.getBones().getViewAt(1);
		            					if (editMode && viewAt1) {
		            						viewAt1.model.set('privatePorts',  _PRIVPORTS);
		            					}
		                    			else {
		                    				newServer.privatePorts = _PRIVPORTS;
		                    			}

	            					},
	            					function (jqXHR,  textStatus) {
	            						var errMsg = NLS.get('privatePortsNotChanged');
	            						if (textStatus)  {
	            							errMsg = errMsg + textStatus;
	            						}
	            						else if (jqXHR.indexOf('404') >= 0) {
	            							errMsg = errMsg + ' ' + NLS.get('privatePortsChangeMethodNA');
	            						}
	                        			COSUtils.displayError(errMsg,  true);
	                        			isPrivPortsOK = false;
	            					}
	            				);
            			}

            			// if this is the global server and changing any other properties besides private station ports
            			// this is an error
            			if (isGlobal) {
            				if (fullUrl !== oldurl || _PUBKEY !== oldKey) {
            					COSUtils.displayError(NLS.get('registerEditErr'),  true);
            				}
            				modal.hide();
            			}

            			// if the  data has changed update EEP with configuration
            			else if (fullUrl !== oldurl  || _PUBKEY !== oldKey || _SERVERPROPID !==oldServerPropId){
            				var regXml =  '<?xml version="1.0" encoding="utf-8"?>' +
            				'<COSConfiguration id="' + _NAME +'">' +
            				'<proxyServerUrl>' + _PROXURL +'</proxyServerUrl>' +
            				'<eedwsUri>' + _EEDWSURI + '</eedwsUri>' +
            				'<eedUrl>' + _EEDURL + '</eedUrl>' +
            				'<serverPropId>' + _SERVERPROPID + '</serverPropId>' +
            				' <isDefault>false</isDefault>' +
            				'<fullCosUrl>' + fullUrl + '</fullCosUrl>' +
            				'<eedPublicKey>' + _PUBKEY +'</eedPublicKey>' +
            				'</COSConfiguration>';

            				// do web service to register the server
            				WSUtils.registerServer(regXml,
            						function(){
            					var viewAt1 = COSInfo.getBones().getViewAt(1);
            					if (editMode && viewAt1) {
            						viewAt1.model.set('proxyServerUrl',  newServer.proxyServerUrl, {silent:true});
            						viewAt1.model.set('eedUrl',  newServer.eedUrl, {silent:true});
            						viewAt1.model.set('eedwsUri',  newServer.eedwsUri, {silent:true});
            						viewAt1.model.set('cosUrl',  newServer.fullCosUrl, {silent:true});
            						viewAt1.model.set('eedPublicKey',  newServer.eedPublicKey, {silent:true});
            						viewAt1.model.set('fullCosUrl',  newServer.fullCosUrl);
            						viewAt1.model.set('serverPropId',  newServer.serverPropId);
            						
            						// if the url changed need to modify badges and try to get
            						// drms, server deploy type in case old url was wrong 
            						// and could not be done before
            						if (fullUrl !== oldurl ) {
            							
            							// if showing collection in view1 need to update station list
            							// and url
            							if (viewAt1.collection) {
            								viewAt1.collection.fullCosUrl = newServer.fullCosUrl;
            								viewAt1.collection.fetch();
            							}
	             	            		var treeView1 = COSInfo.getBones().getViewAt(0);
	            	            		if (treeView1) {
	            		    		        treeView1.treeModel.getRoots().forEach(function (root) {
	            								if (root.options.label === _NAME){
	            									root.fullCosUrl = newServer.fullCosUrl;
	            									WSUtils.setServerBadge(root,  newServer.fullCosUrl,  newServer.id,  false);
	                								// make web service call to check if server is on the cloud
	                								// result will be save as attribute on server model						
	                								WSUtils.adminIsOnCloud(viewAt1.model);
	                								// make web service call to get drms for modified server and add it to the server model
	                								WSUtils.getDrmList(viewAt1.model,root);
	                             	            	WSUtils.getServerDeployType(viewAt1.model,root,true);
	            							    }
	            		    		        });
	            	            		}
            						}
            					}
            					else if (!editMode  ){
            						var root = new TreeNodeModel({
            							label: newServer.id,
            							icons: [WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',   'images/server.png')],
            							children: []
            						});
            						root.fullCosUrl = fullUrl;
            						var treeView = COSInfo.getBones().getViewAt(0);
            						if (treeView) {
            							treeView.treeModel.addRoot(root);
            							treeView.collection.add(newServer);
            							WSUtils.setServerBadge(root,  newServer.fullCosUrl,  newServer.id,  true);

            							// safety check to make sure new server was added to collection
            							// it will be the last model in the collection
            							if (treeView.collection && treeView.collection._models) {
            								// make web service call to check if server is on the cloud
            								// result will be save as attribute on server model						
            								WSUtils.adminIsOnCloud(treeView.collection._models[treeView.collection.length-1]);
            								// make web service call to get drms for new server and add it to the server model
            								WSUtils.getDrmList(treeView.collection._models[treeView.collection.length-1],root);
                         	            	WSUtils.getServerDeployType(treeView.collection._models[treeView.collection.length-1],root,false);
            							}
            						}
            					}
            				});
            			}
            			modal.hide();
            		}
                },

       		// function to create the modal dialog from the form and show it
            // add extra server prop field if we are editing the server and it is not
            // the global server the global server does not have a server prop id
            //  since it is set from the properties file
       		showDialogAlias : function (model) {
       			editMode = false;
       			var sName = '';
       			var eedUrl = '';
       			var proxyUrl = '';
       			var pubKey = '';
       			var machine = '';
       			var port = '';
       			var privPorts = '';
       			var serverPropId = '';
       			var headerStr = NLS.get('regServerHeader');
       			var urlFields = [];
       			var onCloud = 'false';
       			var isFirstModel=false;

       			// if we have a model we are editing so get data from model to show in dialog
       			if (model) {
       				editMode = true;
       				sName = model.get('id');
       				
       				eedUrl = model.get('eedUrl');
       				proxyUrl = model.get('proxyServerUrl');
       				pubKey = model.get('eedPublicKey');
       				if (pubKey === undefined || pubKey === 'undefined') {
       					pubKey='';
       				}
       				privPorts = model.get('privatePorts');
       				serverPropId = model.get('serverPropId');
       				headerStr = NLS.get('editServerHeader');
       				if (proxyUrl && proxyUrl.length > 0) {
       					urlFields = proxyUrl.split(':');
       				}
       				else {
       					urlFields = eedUrl.replace('/SMAExeServer-REST', '').split(':');
       				}
   					machine = urlFields[1].replace('//',  '');
   					port  = urlFields[2].replace('/',  '');
   					onCloud = model.get('onCloud');
   					isFirstModel = model.cid === model.collection.first().cid;
       			}
       			var myForm = null;
       			if (model && 'false' === onCloud) {
       				if (isFirstModel) {
           				myForm = new UIForm({
    	       			    className: 'vertical',
    	       			    fields: [
    			       			    // cannot edit the name field must be entered for register
    			       			    // only allow private port to be editable for the first COS server
    			       			    {
    			       			        type: 'text',
    			       			        label: NLS.get('alias'),
    			       	                name : 'ID',
    			       			        required: true,
    			                        disabled : editMode,
    			                        value:sName,
    			                        placeholder: NLS.get('aliasHint')
    			       			    },   {
    			       			        type: 'text',
    			       			        label: NLS.get('machine'),
    			       			        required: true,
    			       	                name : 'machine',
    			                        disabled : isFirstModel,
    			                        value: machine
    			       			    },   {
    			       			        type: 'text',
    			       			        label: NLS.get('port'),
    			       	                name : 'port',
    			       			        required: true,
    			                        disabled : isFirstModel,
    			       	                value: port
    			       			    },   {
    			                        type : 'text',
    			                        name : 'privatePorts',
    			           		        value : privPorts,
    			                        label : NLS.get('privatePorts'),
    			                        placeholder: NLS.get('privatePortsHint')
    			
    			                    },   {
    			       			        type: 'text',
    			       			        label: NLS.get('publicKey'),
    			       	                name : 'publicKey',
    			       	                multiline : true,
    			       	                rows: 5,
    			       	                value : pubKey,
    			                        disabled : isFirstModel,
    			                        className: 'verticalResizeTextArea'
    	       			    }],
    	       			    buttons: [{
    	       			        type: 'submit',
    	       			        value: NLS.get('register')
    	       			    }],
    	       			    events: {
    	       			        onSubmit:  function () {
    	       			        	RegisterServer.registerTheServer(arguments);
    	       			        },
    	       			        onInvalid: function () {
    	       			        	COSUtils.displayError(NLS.get('dlgErr'),  true);
    	       			        }
    	       			    }
    	       			});
       					
       				}
       				else {
	       				myForm = new UIForm({
		       			    className: 'vertical',
		       			    fields: [
				       			    // cannot edit the name field must be entered for register
				       			    // only allow private port to be editable for the first COS server
				       			    {
				       			        type: 'text',
				       			        label: NLS.get('alias'),
				       	                name : 'ID',
				       			        required: true,
				                        disabled : editMode,
				                        value:sName,
				                        placeholder: NLS.get('aliasHint')
				       			    },   {
				       			        type: 'text',
				       			        label: NLS.get('machine'),
				       			        required: true,
				       	                name : 'machine',
				                        disabled : isFirstModel,
				                        value: machine
				       			    },   {
				       			        type: 'text',
				       			        label: NLS.get('port'),
				       	                name : 'port',
				       			        required: true,
				                        disabled : isFirstModel,
				       	                value: port
				       			    },   {
				       			        type: 'text',
				       			        label: NLS.get('serverPropId'),
				       	                name : 'serverPropId',
				       			        required: false,
				                        disabled : isFirstModel,
				       	                value: serverPropId,
				                        placeholder: NLS.get('serverPropIdHint')
				       			    },   {
				                        type : 'text',
				                        name : 'privatePorts',
				           		        value : privPorts,
				                        label : NLS.get('privatePorts'),
				                        placeholder: NLS.get('privatePortsHint')
				
				                    },   {
				       			        type: 'text',
				       			        label: NLS.get('publicKey'),
				       	                name : 'publicKey',
				       	                multiline : true,
				       	                rows: 5,
				       	                value : pubKey,
				                        disabled : isFirstModel,
				                        className: 'verticalResizeTextArea'
		       			    }],
		       			    buttons: [{
		       			        type: 'submit',
		       			        value: NLS.get('register')
		       			    }],
		       			    events: {
		       			        onSubmit:  function () {
		       			        	RegisterServer.registerTheServer(arguments);
		       			        },
		       			        onInvalid: function () {
		       			        	COSUtils.displayError(NLS.get('dlgErr'),  true);
		       			        }
		       			    }
		       			});
       				}
       			}
       			else {
       				myForm = new UIForm({
	       			    className: 'vertical',
	       			    fields: [
			       			    // cannot edit the name field must be entered for register
			       			    {
			       			        type: 'text',
			       			        label: NLS.get('alias'),
			       	                name : 'ID',
			       			        required: true,
			                        disabled : editMode,
			                        value:sName,
			                        placeholder: NLS.get('aliasHint')
			       			    },   {
			       			        type: 'text',
			       			        label: NLS.get('machine'),
			       			        required: true,
			       	                name : 'machine',
			                        value: machine
			       			    },    {
			       			        type: 'text',
			       			        label: NLS.get('port'),
			       	                name : 'port',
			       			        required: true,
			       	                value: port
			       			    },   {
			       			        type: 'text',
			       			        label: NLS.get('serverPropId'),
			       	                name : 'serverPropId',
			       			        required: false,
			                        disabled : isFirstModel,
			       	                value: serverPropId,
			                        placeholder: NLS.get('serverPropIdHint')
			       			    },   {
			       			        type: 'text',
			       			        label: NLS.get('publicKey'),
			       	                name : 'publicKey',
			       	                multiline : true,
			       	                rows: 5,
			       	                value : pubKey,
			                        className: 'verticalResizeTextArea'
	       			    }],
	       			    buttons: [{
	       			        type: 'submit',
	       			        value: NLS.get('register')
	       			    }],
	       			    events: {
	       			        onSubmit:  function () {
	       			        	RegisterServer.registerTheServer(arguments);
	       			        },
	       			        onInvalid: function () {
	       			        	COSUtils.displayError(NLS.get('dlgErr'),  true);
	       			        }
	       			    }
	       			});
       				
       			}




       			modal = new UIModal({
                       closable : true,
                       header : headerStr,
                       body: myForm
                   });

                   modal.inject(COSInfo.getContainer());
                   modal.show();
                   return myForm;
       		},
       		// function to create the modal dialog from the form and show it
       		showDialog : function (model) {
       			editMode = false;
       			var sName = '';
       			var eedUrl = '';
       			var proxyUrl = '';
       			var pubKey = '';
       			var machine = '';
       			var port = '';
       			var privPorts = '';
       			var headerStr = NLS.get('regServerHeader');
       			var urlFields = [];
       			var onCloud = 'false';
       			var isFirstModel=false;

       			// if we have a model we are editing so get data from model to show in dialog
       			if (model) {
       				editMode = true;
       				sName = model.get('id');
       				
       				eedUrl = model.get('eedUrl');
       				proxyUrl = model.get('proxyServerUrl');
       				pubKey = model.get('eedPublicKey');
       				if (pubKey === undefined || pubKey === 'undefined') {
       					pubKey='';
       				}
       				privPorts = model.get('privatePorts');
       				headerStr = NLS.get('editServerHeader');
       				if (proxyUrl && proxyUrl.length > 0) {
       					urlFields = proxyUrl.split(':');
       				}
       				else {
       					urlFields = eedUrl.replace('/SMAExeServer-REST', '').split(':');
       				}
   					machine = urlFields[1].replace('//',  '');
   					port  = urlFields[2].replace('/',  '');
   					onCloud = model.get('onCloud');
   					isFirstModel = model.cid === model.collection.first().cid;
       			}
       			var myForm = null;
       			if (model && 'false' === onCloud) {
       				myForm = new UIForm({
	       			    className: 'vertical',
	       			    fields: [
			       			    // cannot edit the name field must be entered for register
			       			    // only allow private port to be editable for the first COS server
			       			    {
			       			        type: 'text',
			       			        label: NLS.get('name'),
			       	                name : 'ID',
			       			        required: true,
			                        disabled : editMode,
			                        value:sName,
			                        placeholder: 'smaexe.eed.id value...'
			       			    },   {
			       			        type: 'text',
			       			        label: NLS.get('machine'),
			       			        required: true,
			       	                name : 'machine',
			                        disabled : isFirstModel,
			                        value: machine
			       			    },   {
			       			        type: 'text',
			       			        label: NLS.get('port'),
			       	                name : 'port',
			       			        required: true,
			                        disabled : isFirstModel,
			       	                value: port
			       			    },   {
			                        type : 'text',
			                        name : 'privatePorts',
			           		        value : privPorts,
			                        label : NLS.get('privatePorts'),
			                        placeholder: NLS.get('privatePortsHint')
			
			                    },   {
			       			        type: 'text',
			       			        label: NLS.get('publicKey'),
			       	                name : 'publicKey',
			       	                multiline : true,
			       	                rows: 5,
			       	                value : pubKey,
			                        disabled : isFirstModel,
			                        className: 'verticalResizeTextArea'
	       			    }],
	       			    buttons: [{
	       			        type: 'submit',
	       			        value: NLS.get('register')
	       			    }],
	       			    events: {
	       			        onSubmit:  function () {
	       			        	RegisterServer.registerTheServer(arguments);
	       			        },
	       			        onInvalid: function () {
	       			        	COSUtils.displayError(NLS.get('dlgErr'),  true);
	       			        }
	       			    }
	       			});
       			}
       			else {
       				myForm = new UIForm({
	       			    className: 'vertical',
	       			    fields: [
			       			    // cannot edit the name field must be entered for register
			       			    {
			       			        type: 'text',
			       			        label: NLS.get('name'),
			       	                name : 'ID',
			       			        required: true,
			                        disabled : editMode,
			                        value:sName,
			                        placeholder: 'smaexe.eed.id value...'
			       			    },   {
			       			        type: 'text',
			       			        label: NLS.get('machine'),
			       			        required: true,
			       	                name : 'machine',
			                        value: machine
			       			    },    {
			       			        type: 'text',
			       			        label: NLS.get('port'),
			       	                name : 'port',
			       			        required: true,
			       	                value: port
			       			    },   {
			       			        type: 'text',
			       			        label: NLS.get('publicKey'),
			       	                name : 'publicKey',
			       	                multiline : true,
			       	                rows: 5,
			       	                value : pubKey,
			                        className: 'verticalResizeTextArea'
	       			    }],
	       			    buttons: [{
	       			        type: 'submit',
	       			        value: NLS.get('register')
	       			    }],
	       			    events: {
	       			        onSubmit:  function () {
	       			        	RegisterServer.registerTheServer(arguments);
	       			        },
	       			        onInvalid: function () {
	       			        	COSUtils.displayError(NLS.get('dlgErr'),  true);
	       			        }
	       			    }
	       			});
       				
       			}




       			modal = new UIModal({
                       closable : true,
                       header : headerStr,
                       body: myForm
                   });

                   modal.inject(COSInfo.getContainer());
                   modal.show();
                   return myForm;
       		}

       };
       return RegisterServer;
});
