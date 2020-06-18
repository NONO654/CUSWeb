define(/*'webapps/SMAAnalyticsWidget/smaAdviseWidgetLaunchHelper'*/
		'simulationcentral/smaAdviseWidgetLaunchHelper', [
          'UWA/Core',
          'UWA/Utils',
		  'UWA/Class/Promise',
		  'DS/WAFData/WAFData',
		  'DS/PlatformAPI/PlatformAPI',
		  'DS/UIKIT/Modal'], 
function(UWA, UWAUtils, Promise, WAF, PlatformAPI, Modal){
	'use strict';
	
	/*
	 * In order to test the new code changes in this file, please update the copy of this 
	 * file in SMAAnalyticsComponents.tst module*/
	
	var  AdviseWidgetLaunchHelper = {
		
		// Properties
		_origin: '',
		_model: null, //redundant
		_deferred: null,
		_enoviaurl: '',
		_document: null,
		caseID: '',
		widgetID: '',
		currentUser: '',
		widgetViewType: '',
		secCtx: '',
		userStation: '',
		translator : null,
		JOB_CANCELLED : false,
		_isEssentialsOn: false,
		
		
		adviseLaunchInfo: {
			eedID: '',
			proxyServer: null,
			noServant: false,
			token : null,
			userStation: '',
			stationDisplayName: '',
			stationList: [],
			_appLandingPage: '../common/emxNavigator.jsp?appName=SIMREII_AP&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral',
			cosMetaData: {}
		},
		
		
		setTranslator : function(nlsTranslator){
			this.translator = nlsTranslator;
		},
		setOrigin: function(value){
			this._origin = value;
		},
		setCaseId: function(id){
			this.caseID = id;
			this.adviseLaunchInfo.caseID = this.caseID;
		},
		// Widget ID stored in RA Side for future use
		setWidgetId: function(id){
			this.widgetID = id;
			this.adviseLaunchInfo.widgetID = this.widgetID;
		},
		// Widget view type - indicates if the
		// the view is in 'Windowed' or 'Maximized' mode
		// Useful for resize events
		setWidgetViewType: function(type){
			this.widgetViewType = type;
			this.adviseLaunchInfo.widgetViewType = this.widgetViewType;
		},		
		// This contains the mcs URl that was received 
		// from the Widget Launch View. This is the 3DSpace 
		// url returned by i3dxCompass services.
		// if that was empty, then window url is used, and
		// its split at the string 'webapps'
		setEnoviaUrl: function(url){
			this._enoviaurl = url;
		},
		setCurrentUser: function(user){
			this.currentUser = user;
			this.adviseLaunchInfo.currentUser = this.currentUser;
		},
		setSecurityContext: function(secCtx){
			this.secCtx = secCtx;
			this.adviseLaunchInfo.secCtx = this.secCtx;
		},
		setDeferred: function(deferred){
			this._deferred = deferred;
		},
		setActiveDocument: function(activeDocument) {
			this._document = activeDocument;
		},
		setToken: function(token){
			this.adviseLaunchInfo.token = token;
		},
		setUserStation: function(userStation){
			this.userStation = userStation;
			this.adviseLaunchInfo.userStation = userStation;
		},
		setEssentialsModeFlag: function(isOn){
			this._isEssentialsOn = isOn || false;
		},
		
		
		xmlConverter: function(xmlString){
			var xmlDoc = null;
			try {
				if (window.DOMParser){
					var parser=new DOMParser();
					xmlDoc=parser.parseFromString(xmlString,"text/xml");
				}
				else{ // Internet Explorer
					xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
					xmlDoc.async=false;
					xmlDoc.loadXML(xmlString); 
				}
			} catch(e){
				console.error('Error converting string to XML');
			}
			return xmlDoc;
		},
		emxUICoreTrim: function(str){
			if(!str || typeof str != 'string')
				return null;
			return str.replace(/^[\s]+/,'').replace(/[\s]+$/,'').replace(/[\s]{2,}/,' ');
		},
		htmlUnescape: function(value) {
			return String(value).replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
		},
		setStationNameToSplash: function(){
			var that = this;
			if(typeof that.adviseLaunchInfo.localStationName !== 'undefined' &&
					that.adviseLaunchInfo.localStationName !== null &&
					that.adviseLaunchInfo.localStationName.length > 0){
				return that.adviseLaunchInfo.localStationName;
			}
			return null;
		},
		showLoadingMessage: function(messageText, stationName) {
			this.removeLoadingMessage();
			
			var msg = messageText;
			if(typeof stationName !== 'undefined' && stationName !== null 
				&& stationName.length > 0){
				msg += '<br>Station: ' + stationName;
			}
			$simjq(".sim-ui-splash-progressmessage").html(msg);
		},
		removeLoadingMessage: function () {
			$simjq(".sim-ui-blocking-background").remove();
			$simjq(".sim-ui-blocking-message").remove();
		},

		//========================================================================
		/**
		 * Unable to launch a case from a shared session.  This is usually due to
		 * missing variables in the query string of the url
		 */
		//========================================================================
		tryAgainMessage : function(backupTarget){
			var that = this;
			this.createModalAlert({
				'message': that.translator.translate('PLEASE_OPEN_AGAIN'),
				'backupTarget' : backupTarget
			});
		},
		
		//========================================================================
		/**
		 * Unable to connect to EED. This might be due to the untrusted SSL
		 * certificate. Opens a new popup window with the EED ping url and 
		 * keeps polling for 2 mins. If the user accepts the certificate, the
		 * xecution continues. Else return to case details
		 */
		//========================================================================
		handleEEDCommFailure : function(eedURL, successCallBack){
			var that = this,
				translator = that.translator,
				message = translator.translate('LAUNCH_EED_COMM_FAILURE') + '<br/>',
				acceptCert = false;
			if (eedURL.indexOf('https') === 0){
				message += translator.translate('LAUNCH_EED_ACCEPT_CERT') + '<br/>' +
							translator.translate('LAUNCH_OR') + ' ' +  translator.translate('LAUNCH_CANCEL');
				acceptCert = true;
			} else{
				message += translator.translate('LAUNCH_CANCEL');
			}
			that.createModalAlert({
				'message': message,
				'ok': function(){
					// open a new window to accept the SSL cert
					var eedPingWnd = that.openPopUp( eedURL+'/Ping', 500, 500);
					$simjq
					.when(
						that.urlCheckAlive({
		                        'url': eedURL+'/Ping',
								'timeout': 60000,
		                        'crossDomain': true
		                    })
					)
					.then(
						function(alive){
							try {
								if(typeof eedPingWnd !== 'undefined' &&
									eedPingWnd !== null)
									eedPingWnd.close();
							} catch(ex){}	
							successCallBack();
						},
						function(){
							try {
								if(typeof eedPingWnd !== 'undefined' &&
									eedPingWnd !== null)
									eedPingWnd.close();
							} catch(ex){}
							that.createModalAlert({
								'message': translator.translate('LAUNCH_EED_COMM_FAILURE') + '<br/>' 
											+ translator.translate('LAUNCH_EED_COMM_FAILURE'),
								'close': function(){
									that._deferred.reject();
									that.closeRAFrame();
								}
							});
						}
					);
				},
				'close': function(){
					that._deferred.reject();
		            that.closeRAFrame();
				}
			});
		},
		//****************************************************************
		/**
		 * Creates a modal overlay to display errors and messages. 
		 * Takes an object with the following parameters as input
		 * {
		 * 	title : '',
		 * 	message : '',
		 *  ok : function(){},
		 *  close : function(){},
		 * }
		 * 
		 */
		//****************************************************************
		createModalAlert: function(options){
			var footer = '',
				closable = true,
				title = options['title'] || '',
				message = options['message'] || '',
				okLabel = options['oklabel'] || 'Ok',
				cancelLabel = options['closelabel'] || 'Close',
				that = this;
			if (title.length == 0)
				title = 'Results Analytics';
			
			if (typeof options['ok'] === 'function'){
				footer +=  '<button type="button" class="btn btn-primary" id="ra-mok">' + okLabel + '</button>';
				closable = false;
			}
			
			if (typeof options['close'] === 'function'){
				footer +=  '<button type="button" class="btn btn-default" id="ra-mcancel">' + cancelLabel + '</button>';
				closable = false;
			}
			
			var injectTarget = document.querySelector('.moduleWrapper') || options['backupTarget'];
			
			var raModal = new Modal({
					'closable': closable,
					'header': '<h4>' + title + '</h4>',
					'body': '<p>' + message + '</p>',
					'footer': footer
					}
				).inject(injectTarget);
			
			raModal.getContent().getElements('.btn').forEach(function (element) {
			    element.addEvent('click', function () {
					document.querySelector('.sim-ui-advise-splash-background').classList.remove('no-splash-bgrd');
					document.querySelector('.sim-ui-advise-splash').classList.remove('no-splash');
			    	raModal.hide();
			    	if (element.id === 'ra-mok'){
			    		options['ok'].call(that);
			    	}
			    	if (element.id === 'ra-mcancel'){
						options['close'].call(that);
			    	}
			    });
			});
			document.querySelector('.sim-ui-advise-splash-background').classList.add('no-splash-bgrd');
			document.querySelector('.sim-ui-advise-splash').classList.add('no-splash');
			raModal.show();
			
		},
		
		//****************************************************************
		/**
		 * Cancel Job - Kills the EED job and sends the user back to 
		 * widget landing page
		 */
		//****************************************************************
		cancelJob: function(error){
			
			var that = this,
				jobId = that.adviseLaunchInfo.jobID || '';
			
			if (that.JOB_CANCELLED)
				return;
			
			if (! error)
				error = '';
			
			that.resetRunningServant();
			that.showLoadingMessage(that.translator.translate('LAUNCH_STOPPING'),
			        that.setStationNameToSplash());
			
        	if (jobId.length > 0){
        		
        		var url = that.adviseLaunchInfo.eedURL + "/execution/"
        					+ that.adviseLaunchInfo.jobID + "/cancel",
        			payload = {
        				allowCrossOriginRequest: true,
						method : 'PUT',
						headers : { 'Content-Type' : 'text/plain; charset=utf-8',
									'EEDTicket' : that.adviseLaunchInfo.eedTicket,
									'Credentials' : ''
								},
						onComplete : function(data){
							console.log("Successfully terminated the job.");
							if (error.length > 0){
								that.createModalAlert({
									'message' : error,
									'ok' : function(){ that.closeRAFrame(); }
								});
							} else {
								that.closeRAFrame();
							}
						},
						onFailure : function(errorThrown){
							errorThrown = errorThrown || '';
							that.createModalAlert({
								'message' : that.translator.translate('LAUNCH_CANCEL_JOB_ERROR') + errorThrown,
								'ok' : function(){ that.closeRAFrame(); }
							});
						}
        			};
        		
        		UWA.Data.request(url, payload);
        		
        	} else {
        		that.closeRAFrame();
        	}
		},
		
		pingPrivateStation: function (port) {
			
			return new Promise(function(resolve, reject){
				var xhr = new XMLHttpRequest(),
					launcherURL = ["https://dslauncher.3ds.com:","/SMAExeStation-REST/station/info"],
					url = launcherURL[0]+port+launcherURL[1];

				xhr.open('GET', url);
				xhr.responseType = 'document';
				xhr.onload = function(){
					if (xhr.readyState==4 && xhr.status == 200){
						console.log("Success at port "+port+ ": data = "+this.response);
			            resolve(this.response);
					} else{
		    			console.log("Failed to locate a private station at port "+port);
		    			reject();
		    		}
		    	};
				xhr.send();
			});
		},
		
		//========================================================================
		/**
		 * isLocalStation
		 * Send in the ip of a station to determine if that station is a local
		 * station. A direct '===' doesnt suffice because, the
		 * '/admin/station/query' service returns ipV4 and ipV6 ids in ',' 
		 * separated list.
		 * Returns a boolean
		 */
		//========================================================================
		isLocalStation: function(stationIp, adviseLaunchInfo){
			try {
				var ipArr = stationIp.split(',');
				
				if (ipArr.indexOf(adviseLaunchInfo.localIP) > -1)
					return true;
				else
					return false;
				
			} catch(ex){
				return false;
			}
		},

		//****************************************************************
		/**
		 * RA Widget Launch Sequence - Start 
		 */
		//****************************************************************
		
		initiateRAWidgetLaunch: function() {
			var that = this;
			that.getLaunchInfo();
		},
		
		getLaunchInfo: function(dontContinue) {
			var that = this;

			var url = that._enoviaurl +'/resources/slmservices/advise/getAnalyticsLaunchInfo?caseID=' + that.caseID;
			url += '&mcsURI=' + encodeURIComponent(that._enoviaurl);
			
			if (typeof dontContinue === 'undefined' || dontContinue === null ||
					dontContinue === 0 || dontContinue.length === 0 || dontContinue === 'false'){
				dontContinue = false;
			} else {
				dontContinue = true;
			}

			var payload = {
					type: 'json',
					cache: false,
					allowCrossOriginRequest: true,
					onComplete: function(data){
						
						that.adviseLaunchInfo.eedURL = data.eedURL;
						that.adviseLaunchInfo.ticketURL = data.ticketURL;
						that.adviseLaunchInfo.eedTicket = data.eedTicket;
						that.adviseLaunchInfo.token = that.adviseLaunchInfo.token || data.eedTicket;
						that.adviseLaunchInfo.encodedJobXML = data.encodedJobXML;
						that.adviseLaunchInfo.localIP = data.localIP;
						that.adviseLaunchInfo.runInfo = data.runInfo;
						that.adviseLaunchInfo.proxyServer = data.proxyServer;
						that.adviseLaunchInfo.currentUser = data.currentUser;

						that.adviseLaunchInfo.mcsUrl = data.mcsURL;
						
						/**
						 * This block checks to see if the mcs url
						 * that we get back from launch info is correct
						 */
						var hostUrlObj = that.getURLObject(document.URL),
							encodedJobXML = that.adviseLaunchInfo.encodedJobXML;
						
						if (typeof encodedJobXML !== 'undefined' &&
								encodedJobXML !== null &&
								encodedJobXML.length > 0){
									
							var jobXML = that.htmlUnescape(encodedJobXML),
								mcsUri = (jobXML.split('<AppUrl>')[1])
											.split('</AppUrl>')[0];
							
							// This code does not handle multiple platform ID.
							if(document.URL.indexOf('https') === 0 &&
									mcsUri.indexOf('https') < 0){
								var baseUri = '';
								if (widget){
									baseUri = widget.getUrl() || '';
									if (baseUri.indexOf('/webapps') > -1) {
										baseUri = baseUri.substring(0, baseUri.indexOf('/webapps'));
									}
								} else if (PlatformAPI){
									var PLATFORM_KEY_MYAPPS_URL = 'app.urls.myapps';
									baseUri = PlatformAPI.getApplicationConfiguration(PLATFORM_KEY_MYAPPS_URL);
								}
								if (baseUri.length > 0){
									that.adviseLaunchInfo.encodedJobXML = encodedJobXML.replace(mcsUri, baseUri);
									that.adviseLaunchInfo.mcsUrl = baseUri;
									that._enoviaurl = baseUri;
									
									var ticketURLObj = that.getURLObject(that.adviseLaunchInfo.ticketURL),
										baseURLObj = that.getURLObject(baseUri);
									that.adviseLaunchInfo.ticketURL = baseURLObj['protocol'] + '//' + baseURLObj['hostname']
																		+ (baseURLObj['port'].length > 0 ? '/' + baseURLObj['port'] : '')
																		+ ticketURLObj['pathname'] + ticketURLObj['search'];
								}
							}
						}
					
						if (! dontContinue){
							if(typeof localStorage.getItem('noServant') !== 'undefined' &&
									localStorage.getItem('noServant') !== null){
								that.adviseLaunchInfo.noServant = true;
								that.startApp();
								return;
							}
							that.getCOSVersion();
						}
						
					},
					onFailure: function() {
						console.error('Retrieving launch info failure');
						that._deferred.reject();
						that.cancelJob();
					}
				},
				request = UWA.Data.request(url, payload);
			return request;
		},
		
		getCOSVersion: function(){
			var that = this,
				url = that.adviseLaunchInfo['eedURL'] + '/admin',
				payload = {
					type: 'json',
					allowCrossOriginRequest: true,
					onComplete: function(response){
						
						try {
							
							that.adviseLaunchInfo['cosMetaData']['major'] = parseFloat(response.SystemInfo['@major']);
							that.adviseLaunchInfo['cosMetaData']['minor'] = parseFloat(response.SystemInfo['@minor']);
							that.adviseLaunchInfo['cosMetaData']['fixPack'] = parseFloat(response.SystemInfo['@fix']);
							
							that.getCOSConfigurations();
							
						} catch(ex){
							console.error('Failure retrieving COS configurations');
							that._deferred.reject();
							that.cancelJob();
						}
					},
					onFailure: function(err){
						console.error('Failure retrieving COS configurations');
						that._deferred.reject();
						that.cancelJob();
					}
				};
			return UWA.Data.request(url, payload);
		},
		
		getCOSConfigurations: function(){
			var that = this,
				url = that._enoviaurl + '/resources/eepservices/cos/configurations',
				payload = {
					type : 'json',
					allowCrossOriginRequest: true,
					onComplete: function(data){
						var responseList = data.COSConfiguration || data.configurations;
						try {
			        		for (var i in responseList){
			        			var cosConfig = responseList[i];
			        			if (cosConfig['isDefault']){
				        			that.adviseLaunchInfo['eedID'] = cosConfig['id'];
						        	that.adviseLaunchInfo['eedURL'] = cosConfig['fullCosUrl'];
						        	that.adviseLaunchInfo['proxyServer'] = cosConfig['proxyServerUrl'];
						        	break;
			        			}
			        		}
						} catch(ex){ }
						that.getEEDPublicKey();
					},
					onFailure: function(error){
						console.error('Failure retrieving COS configurations');
						that._deferred.reject();
						that.cancelJob();
					}
				},
				request = UWA.Data.request(url, payload);
			return request;
		},
		
		getEEDPublicKey: function() {
			var that = this;
			
			that.showLoadingMessage(that.translator.translate('LAUNCH_GET_PUBKEY'));
			
			var url = that.adviseLaunchInfo.eedURL + '/execution/pubkey',
				payload = {
					type: 'json',
					allowCrossOriginRequest: true,
					headers: { 'EEDTicket': that.adviseLaunchInfo.eedTicket,
								'Credentials': '' },
					onComplete: function(data){
						try{
							that.adviseLaunchInfo.eedPublicKey = data ? encodeURIComponent(data.KeyRep.$) : '';
						} catch(ex){
							that.showLoadingMessage(that.translator.translate('LAUNCH_PUBKEY_ERROR'));
							that._deferred.reject();
							that.cancelJob();
						}
						
						that.getEncryptedCredentials();
					},
					onFailure: function() {
						that.showLoadingMessage(that.translator.translate('LAUNCH_PUBKEY_ERROR'));
						//that._deferred.reject();
						//that.cancelJob();
						// handle EED failure
						that.handleEEDCommFailure(
							that.adviseLaunchInfo.eedURL,
							that.getEEDPublicKey.bind(that));
					}
					},
				request = UWA.Data.request(url, payload);
			return request;
		},
		
		getEncryptedCredentials : function(_this) {
			var that = this;
			
			that.showLoadingMessage(that.translator.translate('LAUNCH_GET_CREDENTIALS'));
			
			var url = that._enoviaurl + '/resources/slmservices/advise/getEncryptedCredentials?pubkey=' + that.adviseLaunchInfo.eedPublicKey,
				payload = { 
					type: 'text',
					allowCrossOriginRequest: true,
					headers: { 'Accept' : 'text/plain; charset=utf-8', 'Content-Type': 'text/plain; charset=utf-8'},
					timeout: 1000000000,
					onComplete: function(data){
						var cred = that.emxUICoreTrim(data||'') || '';
						if(cred.length>10) {
							
							that.adviseLaunchInfo.resourceCredentials = cred;
							that.checkPrivateStationAndLaunch(_this);
							
							/*if (typeof that.adviseLaunchInfo.userStation !== 'undefined' &&
									that.adviseLaunchInfo.userStation !== null &&
									that.adviseLaunchInfo.userStation.length > 0 &&
									that.adviseLaunchInfo.userStation !== '{localhost}'){
								that.checkLocalStationAndLaunch(_this);
							} else {
								that.checkPrivateStationAndLaunch(_this);	
							}*/
							
						} else {
							
							that.getEncryptedCredentialsViaPassport(_this);
							
						}
					},
					onFailure: function() {
						console.error('Failure retrieving encrypted credentials without passport');
						that.getEncryptedCredentialsViaPassport(_this);
					}
				},
				request = UWA.Data.request(url, payload);
			return request;
		},
		
		getEncryptedCredentialsViaPassport : function(_this) {

			var that = this;
			var ctr = 0, MAX_CTR = 120; // 60 seconds

			that.showLoadingMessage(that.translator.translate('LAUNCH_GET_CREDENTIALS'));
			
			try{
				localStorage.removeItem("ra_resource_cred");
				parent.postMessage('command:'+
						'/resources/slmservices/advise/getEncryptedCredentials?pubkey=' + 
						that.adviseLaunchInfo.eedPublicKey, this._origin);	
			}catch(ex){
				console.error('Failure requesting encrypted credentials from widget');
				that._deferred.reject();
			}	

			var credTimer = window.setInterval(function(){
				ctr++;
				if(ctr>MAX_CTR){
					console.error("timeout getting resource credentials");
					that._deferred.reject();
					that.showLoadingMessage(that.translator.translate("RES_CRED_TIMEOUT") + ".");
					that.cancelJob();
				}
				var data = localStorage.getItem("ra_resource_cred");
				var cred = that.emxUICoreTrim(data||'') || '';
				if(cred.length>10) {
					that.adviseLaunchInfo.resourceCredentials = that.emxUICoreTrim(data);
					localStorage.removeItem("ra_resource_cred");
					
					that.checkPrivateStationAndLaunch(_this);
					
					/*if (typeof that.adviseLaunchInfo.userStation !== 'undefined' &&
							that.adviseLaunchInfo.userStation !== null &&
							that.adviseLaunchInfo.userStation !== '{localhost}'){
						that.checkLocalStationAndLaunch(_this);
					} else {
						that.checkPrivateStationAndLaunch(_this);	
					}*/
					
				} else if(cred === 'error') {
					
					console.error('Failure retrieving encrypted credentials from widget');
					that._deferred.reject();
				}
			}, 500);
		},
		
		checkPrivateStationAndLaunch : function(_this){
			
			var that = this,
				secStationEligible = false;
			
			try {
				
				if ((that.adviseLaunchInfo['cosMetaData']['major'] > 6) ||
					(that.adviseLaunchInfo['cosMetaData']['major'] === 6 && (that.adviseLaunchInfo['cosMetaData']['minor'] > 418)) ||
					(that.adviseLaunchInfo['cosMetaData']['major'] === 6 && (that.adviseLaunchInfo['cosMetaData']['minor'] === 418) &&
							that.adviseLaunchInfo['cosMetaData']['fixPack'] >= 3))
					secStationEligible = true;
				
			} catch(ex){
				secStationEligible = false;
			}
			
			if (! secStationEligible){
				that.checkLocalStationAndLaunch(_this);
				return;
			}
				
			that.showLoadingMessage(that.translator.translate('LAUNCH_CHECK_PRIVATE_STATION'));
			
			var ports = [35125,45341,55447],
		        successPort = -1,
		        data = null,
		        tooLate = false,
		        promises = [];
			
			ports.forEach(function(port, index, array){
				
				promises.push(
					that.pingPrivateStation(port).then(
						function(data){
							
							var stationData = data.getElementsByTagName('StationData');
				            if(stationData) {
				                stationData = stationData[0];
								
								var stationMCS = that.getURLObject(stationData.getAttribute('spaceurl')),
									myMCS = that.getURLObject(that.adviseLaunchInfo.mcsUrl);
				            	
								if (stationMCS.hostname === myMCS.hostname && 
									stationMCS.port === myMCS.port && 
									stationMCS.pathname.replace(/\//g, '') === myMCS.pathname.replace(/\//g, '')){
				            	var stationCOS = stationData.getAttribute('cosid'),
				            		stationUser = stationData.getAttribute('user');
				            	//Check COS Server & User
				            	if (stationCOS === that.adviseLaunchInfo['eedID'] &&
				            			stationUser === that.adviseLaunchInfo['currentUser']){
					            	var stationIP = stationData.getAttribute('ip'),
					            		stationName = stationData.getAttribute('name');
				                
					            // Used to set the station name to the balloon 
				                // inside RA
				                that.adviseLaunchInfo.stationDisplayName = stationName || '';
				                
				                that.adviseLaunchInfo.runInfo = "<RunInfo logLevel=\"Debug\" submissionHost=\""+stationName+"\"></RunInfo>";
				                that.adviseLaunchInfo.stationName = stationName;
				                that.adviseLaunchInfo.proxyServer = "https://dslauncher.3ds.com:"+port+"/SMAExeStation-REST/servant";
				                that.adviseLaunchInfo.secureStation = true;
				                that.adviseLaunchInfo.stationAccess = "https://dslauncher.3ds.com:"+port+"/SMAExeStation-REST/station";
								successPort = port;
				                
				                // Skip the local station etc and go directly to launch?
				                if(!tooLate) {
				                    tooLate = true;
				                    that.makeRunAdviseJob(that.adviseLaunchInfo);
										}				            		
					                }				            		
				                }
				            }	
						},
						function(err){
							console.warn(err);
						}
					)
				);
			});

			var continueExecution = function(){
				tooLate = true;
				
				if(that.adviseLaunchInfo.userStation !== '{localhost}'){
					that.checkLocalStationAndLaunch(_this);
				} else {
					// If the user specifically set affinity to {localhost}, dont submit that job
		    		// to a regular station. Security reasons!!
					that.showLoadingMessage(that.translator.translate('LAUNCH_FAIL_NO_LOCHOST'));
					that._deferred.reject();
					that.cancelJob(that.translator.translate('LAUNCH_FAIL_NO_LOCHOST'));
				}
			};
			
			Promise
				.all(promises)
				.then(function(){
					console.log("All pings to secure private stations are complete.");
		            console.log("Success port: "+successPort);
		            console.log("data: "+ data);
		            if(successPort<0 && !tooLate) continueExecution();
				});
			
			// If secure private station takes too long, then continue
		    window.setTimeout(function(){
		        if(!tooLate) continueExecution();
		    }, 5000);
				
		},

		getActiveStationsList: function(){
			
			var that = this;
			return new Promise(function(resolve, reject){
				var url = that.adviseLaunchInfo.eedURL + '/admin/station/query',
				payload = {
					allowCrossOriginRequest: true,
					headers: { 'Accept': 'application/json' },
					data: {
						'ActiveOnly': true,
						'AllowedUser': that.adviseLaunchInfo.currentUser
						},
						onComplete: resolve,
						onFailure: reject
				};
				UWA.Data.request(url, payload);
			});
		},

		checkLocalStationAndLaunch : function(_this){
			
			var that = this;
			
			that.showLoadingMessage(that.translator.translate('LAUNCH_CHECK_LOCAL_SERVANT'));
			
			var affinitySetByUser = (that.adviseLaunchInfo.userStation.length > 0) ? true : false;
			
			that.getActiveStationsList().then(
			
				function(data){
					
					if(typeof data === 'string'){
						data = JSON.parse(data);
					}
					
					if(data && data.StationList){
						var stationList = data.StationList.Station;
						
						if(! Array.isArray(stationList)){
							stationList = [stationList];
						}
						
						that.adviseLaunchInfo.stationList = stationList;
						for(var i=0;i<stationList.length;i++){
							var stationInfo = stationList[i];
							
							if(stationInfo && stationInfo['@name'] && stationInfo['@name'].length > 0 && stationInfo.GeneralInfo 
									&& stationInfo.GeneralInfo['@hostIP'] && stationInfo.GeneralInfo['@hostIP'].length > 3) {
								
								var stationName = stationInfo['@name'];
								var stationIP = stationInfo.GeneralInfo['@hostIP'].trim();
								
								if(affinitySetByUser){
									if(stationName === that.adviseLaunchInfo.userStation){
										that.adviseLaunchInfo.stationName = stationName;
										that.adviseLaunchInfo.stationIP = stationIP;
		                                that.adviseLaunchInfo.stationDisplayName = stationName || '';
										break;
									}
								} else {
									if (that.isLocalStation(stationIP, that.adviseLaunchInfo)) {
										that.adviseLaunchInfo.localStationName = stationName;
										that.adviseLaunchInfo.stationName = stationName;
										that.adviseLaunchInfo.stationIP = stationIP;
		                                that.adviseLaunchInfo.stationDisplayName = stationName;
										break;
									}
								}
							}
						}
					}
					
					that.makeRunAdviseJob();
				},
				function(err){
					var msg = that.translator.translate('LAUNCH_NO_STATIONS') + '<br/>' +
	                    that.translator.translate('LAUNCH_CHECK_ALLOWED_USER') + '<br/>' +
	                    that.translator.translate('LAUNCH_OR') + ' ' +
	                    that.translator.translate('LAUNCH_START_STATION');
					
					that._deferred.reject();
					that.cancelJob(msg);
				}
			);
		},
		
		
		makeRunAdviseJob: function(){
			
			var that = this,
				resourceCredentials = that.adviseLaunchInfo.resourceCredentials,
		        eedURL = that.adviseLaunchInfo.eedURL,
		        eedTicket = that.adviseLaunchInfo.eedTicket,
		        encodedJobXML = that.htmlUnescape(that.adviseLaunchInfo.encodedJobXML),
		        runInfo = that.adviseLaunchInfo.runInfo,
		        affinity = null;
			
			if(typeof that.adviseLaunchInfo.stationName !== 'undefined' && that.adviseLaunchInfo.stationName !== null
					&& that.adviseLaunchInfo.stationName !== ''){
				affinity = that.adviseLaunchInfo.stationName;
			} else if (typeof that.adviseLaunchInfo.localStationName !== 'undefined' && that.adviseLaunchInfo.localStationName !== null
					&& that.adviseLaunchInfo.localStationName !== ''){
				affinity = that.adviseLaunchInfo.localStationName;
			}
			
			// Private Secure station takes precedence
		    if(that.adviseLaunchInfo.secureStation) {
		        affinity = "{localhost}";
		        
		        var appDataXML = UWAUtils.loadXml(encodedJobXML);
		        var lHostNode = appDataXML.getElementsByTagName('Application')[0].appendChild(
		        		appDataXML.createElement('HasLocalHost'));
		        lHostNode.appendChild(appDataXML.createTextNode('true'));
		        encodedJobXML = UWAUtils.xmlToString(appDataXML);
		    }
		    
		    that.showLoadingMessage(that.translator.translate('LAUNCH_START_SERVANT'),
		            that.setStationNameToSplash(that.adviseLaunchInfo));
		    
		    var proxyServerURL = that.adviseLaunchInfo.proxyServer;
		    if(typeof proxyServerURL === 'undefined' || proxyServerURL === null){
		        proxyServerURL = '';
		    }
		    if(proxyServerURL.indexOf('http') !== 0){
		        proxyServerURL = '';
		    }
		    
		    var modelxml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
			                + "<fiper_Model version=\"6.216.0\" majorFormat=\"1\" timestamp=\"6/5/14\" rootComponentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
			                + "<Properties modelId=\"6a53ba4c-811e-11e2-ae82-e9ce6b18c519\" modelName=\"AdviseServant\" modelVersion=\"6.216.0\" />"
			                + "<Component id=\"812da46e-811e-11e2-ae82-e9ce6b18c519\" name=\"AdviseServant\" type=\"com.dassault_systemes.smacomponent.adviseservant\">";
		    
		    // client
		    modelxml += "<Variable type=\"com.engineous.datatype.String\" id=\"bb27e8af-811e-11e2-ae82-e9ce6b18c519\" name=\"host\" role=\"Parameter\" structure=\"Scalar\" mode=\"Input\" dispName=\"host\" saveToDB=\"true\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
                    	+ "<Value><![CDATA["+window.location.protocol+'//'+window.location.hostname + (window.location.port ? ':' + window.location.port: '') + "]]></Value>"
                    	+ "</Variable>";
		    
		    // csrf
	        modelxml += "<Variable type=\"com.engineous.datatype.String\" id=\"bc27e8af-811e-11e2-ae82-e9ce6b18c519\" name=\"token\" role=\"Parameter\" structure=\"Scalar\" mode=\"Input\" dispName=\"token\" saveToDB=\"true\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
	                    + "<Value><![CDATA["+that.adviseLaunchInfo.token+"]]></Value>"
	                    + "</Variable>";
	        
	        // if a local station was found or if user chose a station, assign affinity to the AdviseServant component
	        if(affinity){
	            modelxml = modelxml
	                    + "<Variable id=\"812da46e-811e-11e2-ae82-e9ce6b18c519:affinities\" name=\"affinities\" role=\"Property\" structure=\"Aggregate\" mode=\"Local\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">" 
	                    + "<Variable type=\"com.engineous.datatype.String\" typeWrittenVersion=\"2.0.0\" id=\"812da46e-811e-11e2-ae82-e9ce6b18c519:Host\" name=\"Host\" role=\"Property\" structure=\"Scalar\" mode=\"Local\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519:affinities\">"
	                    + "<Value>"+affinity+"</Value>"
	                    + "</Variable>"
	                    + "</Variable>";
	        }
	        
	        /**
	         * This variable sets tells the servant if the data should be 
	         * saved and read in Essentials format.
	         */
        	modelxml += "<Variable type=\"com.engineous.datatype.Bool\" id=\"be27e8af-811e-11e2-ae82-e9ce6b18c519\" name=\"_ESSENTIALS_MODE_ON_\" role=\"Parameter\" structure=\"Scalar\" mode=\"Input\" dispName=\"_ESSENTIALS_MODE_ON_\" saveToDB=\"true\" parentId=\"812da46e-811e-11e2-ae82-e9ce6b18c519\">"
    			+ "<Value>"+ that._isEssentialsOn +"</Value>"
    			+ "</Variable>";
	        
	        modelxml = modelxml 
            			+ "</Component>"
            			+ "<Component id=\"6a5a22ed-811e-11e2-ae82-e9ce6b18c519\" name=\"Task1\" type=\"com.dassault_systemes.sma.adapter.Task\">" + "</Component>" + "</fiper_Model>";
	        
	        var eedRunUrl = that.adviseLaunchInfo.eedURL + '/execution/run';
	        
			var payload = { 
					allowCrossOriginRequest: true,
					method : 'POST',
					headers : { 'Content-Type' : 'text/plain; charset=utf-8',
								'EEDTicket' : that.adviseLaunchInfo.eedTicket,
								'Credentials' : '',
								'RunInfo' : that.htmlUnescape(that.adviseLaunchInfo.runInfo),
								'ApplicationData' : encodedJobXML,
								'ResourceCredentials' : that.adviseLaunchInfo.resourceCredentials
							},
					data : modelxml,
					onComplete : function(data){
						
						console.log('Retrieving job ID successful');
						
						var jobIdTxt = jQuery(data).find("JobID").text().trim();
						that.adviseLaunchInfo.jobID = jobIdTxt;
						
						if(that.adviseLaunchInfo.secureStation) {
							
							that.showLoadingMessage(that.translator.translate('LAUNCH_NOTIFY_SEC_STATION'));
							
							var xhr = new XMLHttpRequest(),
								url = that.adviseLaunchInfo.stationAccess+"/claim?jobids="+jobIdTxt;

							xhr.open('GET', url);
							xhr.onload = function(){
								if (xhr.readyState==4 && xhr.status == 200){
										that.waitForServantStartup(that.adviseLaunchInfo);
								} else{
									// The claim call to secure station failed. Stop exec.
									console.error('Localhost execution - claim failed.');
									that.showLoadingMessage(that.translator.translate('LAUNCH_SERVANT_EXEC_ERROR'), that.setStationNameToSplash());
									that._deferred.reject();
									that.cancelJob();
								}
							};
							xhr.send();
							
						} else {
							
							that.waitForServantStartup(that.adviseLaunchInfo);
							
						}
						
					},
					onFailure : function(data){
						that.showLoadingMessage(that.translator.translate('LAUNCH_SERVANT_EXEC_ERROR'), that.setStationNameToSplash());
						that._deferred.reject();
						that.cancelJob();
					}
			};
			
			var request = UWA.Data.request(eedRunUrl, payload);

			return request;
		},
		
		waitForServantStartup: function() {
			var that = this;
			var waitLoop = setInterval(function() {
				that.monitorBulletinBoard(waitLoop);
			}, 2000);
		},
		
		monitorBulletinBoard: function(waitLoop) {
			var that = this;
			
			var url = that._enoviaurl + '/resources/slmservices/advise/getAnalyticsLaunchInfo?caseID=' + that.caseID +
						'&mcsURI=' + encodeURIComponent(that._enoviaurl),
				payload = {
						type: 'json',
						method: 'GET',
						cache: false,
						allowCrossOriginRequest: true,
						onComplete: function(data){
							that.adviseLaunchInfo.eedTicket = data.eedTicket;
							that.tryToLauchAdviseClient(waitLoop);
						},
						onFailure: function() {
							that.tryToLauchAdviseClient(waitLoop);
						}
					},
				request = UWA.Data.request(url, payload);
			
			return request;
		},
		
		//========================================================================
		/**
		 * monitorForError
		 * Checks for any error or status messages from the servant.
		 * if the msg is a status, its displayed on the splash screen
		 */
		//========================================================================
		monitorForError: function(url){
			
			var that = this,
				payload = {
					type: 'xml',
					allowCrossOriginRequest: true,
					data: { 'Topic' : 'ResultsServantError',
							'TimeStamp' : 0 },
					method: 'GET',
					headers: { 'EEDTicket' : that.adviseLaunchInfo.eedTicket,
								'Credentials' : '' },
					onComplete: function(returndata) {
						var errorThrown = returndata.getElementsByTagName('Message');
						if(errorThrown.length > 0){
							
							// check if this is a error message
			                // or if its a status message
			                var msg = errorThrown[errorThrown.length - 1].textContent;
			                
			                try {
			                	var msgObj = JSON.parse(msg);
			                    if (typeof msgObj.operation !== 'undefined' && 
			                           msgObj.operation !== null){
			                    	
			                    	switch(msgObj.operation){
			                    		case 'PLMBATCH':
			                    			that.showLoadingMessage(that.translator.translate('LAUNCH_PLMBATCH_EXEC') +
		                                                     msgObj.current + '/' + msgObj.max,
		                                                     that.setStationNameToSplash(adviseLaunchInfo));
			                    			break;
			                    		default:
			                    			that.cancelJob(msg);
			                    	}
			                    	
			                    } else {
			                    	that.cancelJob(msg);
			                    }
			                } catch(ex){
			                	that.cancelJob(msg);
			                }
						}/*  else {
							that.cancelJob();
						} */
					},
					onFailure: function(error){
						that.cancelJob(error);
					}
				};
			
			UWA.Data.request(url, payload);
		},
		
		
		//========================================================================
		/**
		 * Retrieve the servant url from the Advise Message. 
		 */
		//========================================================================
		deriveServantURL: function(adviseMessage){
			var that = this;
			
			if (typeof adviseMessage === 'undefined' ||
		            adviseMessage === null ||
		            adviseMessage.length === 0){
		        
		        that.showLoadingMessage(that.translator.translate('LAUNCH_BAD_SERVANT_URL'));
		        that.cancelJob(that.translator.translate('LAUNCH_NO_SERVANT_URL'));
		        return;
		    } else {
		        if (adviseMessage.substr(adviseMessage.length - 1) !== '/')
		            adviseMessage += '/';
		    }
			
			// BB message is a servant url
		    if ((adviseMessage.indexOf('http:') === 0) || (adviseMessage.indexOf('https:') === 0)){
		        
		        that.adviseLaunchInfo['servantURL'] = adviseMessage;
		        return;
		    }
		    
		 // BB message isnt a url
		    if (adviseMessage.indexOf('http:') !== 0){
		    	
		    	// Check for existence or proxy
		        if (typeof that.adviseLaunchInfo.proxyServer !== 'undefined'&&
		            that.adviseLaunchInfo.proxyServer !== null){
		        	
		        	// Valid proxy url 
		            if (that.adviseLaunchInfo.proxyServer.indexOf('http') === 0){
		                
		            	if (that.adviseLaunchInfo.proxyServer.slice(-1) !== '/')
		            		that.adviseLaunchInfo.proxyServer += '/';
		                that.adviseLaunchInfo['servantURL'] = that.adviseLaunchInfo['proxyServer'] +
		                                                    adviseMessage;
		            }
		        	return;
		        }
		        else {
		        	// No proxy and BB msg isnt a url - failure
		            that.showLoadingMessage(that.translator.translate('LAUNCH_BAD_SERVANT_URL'));
		            that.cancelJob(that.translator.translate('LAUNCH_BAD_SERVANT_URL') + ' = ' + adviseMessage + '".' );
		            return;
		        }
		    }
		},
		
		
		
		launchCount: 0, // checking every 2 sec so,
		launchLimit: 60, // 60 => 2 minutes
		// message topic that we expect from the EED bulletin board
		messageTopic: 'ResultsServantDowloadingFile', // next will be "ResultsServantURL"
		jobRunning: false,
		
		tryToLauchAdviseClient: function(timer) {
			var that = this;
			
			var jobIdTxt = that.adviseLaunchInfo.jobID,
				eedURL = that.adviseLaunchInfo.eedURL,
				eedTicket = that.adviseLaunchInfo.eedTicket;
			
			that.launchCount++;
			
			if (that.launchCount > that.launchLimit) {
				// sd4 - IR-297707-3DEXPERIENCER2015x - adding a confirmation message 
				// to wait longer in order to allow downloading a large file
				if(confirm(that.translator.translate("SRVNT_START_DELAYED"))) {
					launchCount = 0;
					launchLimit = 150; // 5 minutes
					return;
				}
				clearInterval(timer);
				 
				that.showLoadingMessage(that.translator.translate('LAUNCH_SERVANT_TIMEOUT')+'!', that.setStationNameToSplash());
				that.cancelJob(that.translator.translate('LAUNCH_SERVANT_TIMEOUT'));
				
				return;
			}
			
			var eedURLMonitor = that.adviseLaunchInfo.eedURL + "/job/" + that.adviseLaunchInfo.jobID + "/monitor";
			
			that.monitorForError(eedURLMonitor);
			
			var payload = {
					type: 'xml',
					allowCrossOriginRequest: true,
					data: {
						'Topic' : that.messageTopic,
						'TimeStamp' : 0
						},
					headers: {
							'EEDTicket' : that.adviseLaunchInfo.eedTicket,
							'Credentials' : ''
							},
					onComplete: function(returndata) {
						
						var adviseMessage = $simjq(returndata).find("Message").text();
						if (adviseMessage.length > 4) {
							
							// First message topic that we expect - before downloading the data
			                // file on the servant (done by component BEFORE launching advise servant
							if (that.messageTopic == "ResultsServantDowloadingFile") {
								
								that.showLoadingMessage(that.translator.translate(adviseMessage) + '...',
										that.setStationNameToSplash());
								
								// next message topic that we expect - URL for advise - posted
								// after
								// Advise servant is fully functional
								that.messageTopic = "ResultsServantURL";
								
								// reset the timout to 30 mins - in case of downloading a very
								// large file
								// over a slow network 
								that.launchCount = 0;
								that.launchLimit = 900;
								that.jobRunning = true;
							} else {
								
								clearInterval(timer);
								
								// Retrieve the servant url(s)
				                that.deriveServantURL(adviseMessage);
				                
				                //if ((that.adviseLaunchInfo['stationDisplayName']).length === 0){
								var sName = that.adviseLaunchInfo['stationDisplayName'];
								if (typeof sName === 'undefined' || sName === null || sName.length === 0){
				                	
				                	// The display name would be empty only if
				                	// affinity is not set and the station is not
				                	// a secure station.
				                	var servantIP = '';
				                	if (adviseMessage.indexOf('http') === 0){
				                		// Unproxified url
				                		var parser = document.createElement('a');
				                        parser.href = adviseMessage;
				                        servantIP = parser.hostname;
				                	} else {
				                		// Proxy exists, and the message format is
				                		// 192.178.106.25/8090/Advise
				                		servantIP = adviseMessage.split('/')[0];
				                	}
				                	if (servantIP.length > 0){
				                		for(var i=0; i<that.adviseLaunchInfo.stationList.length; i++) {
				                    		var stationInfo = that.adviseLaunchInfo.stationList[i];
				                    		if (servantIP ===
				                    			stationInfo.GeneralInfo['@hostIP'].trim()){
				                    			that.adviseLaunchInfo.stationIP = servantIP;
				                    			that.adviseLaunchInfo.stationName = stationInfo['@name'];
				                    			that.adviseLaunchInfo.stationDisplayName = stationInfo['@name'] || '';
				                    		}
				                    	}
				                		
				                		if(that.adviseLaunchInfo.stationDisplayName.length === 0){
				                			that.adviseLaunchInfo.stationDisplayName = window.location.host;
				                		}
				                	}
				                }
								
								var startWaitTimer = setInterval(function() {
									clearInterval(startWaitTimer);
									that.removeLoadingMessage();
									//that.adviseLaunchInfo.servantURL = adviseMessage + '/';
									that.startApp();
								}, 2000);	
							}
							
						} else {
							
							var messageElem = $simjq(returndata).find("MonitoringMessages");
							var status = messageElem.attr("status");
							
							if (status == "Running" && !that.jobRunning) {
								// reset the wait timer for the Executor to post the message
								that.showLoadingMessage(that.translator.translate('LAUNCH_WAIT_FOR_SERVANT'),
										that.setStationNameToSplash());
								
								that.launchCount = 0;
								that.jobRunning = true;
							} else if (status == "Done") {
								clearInterval(timer);
								
								if (! that.JOB_CANCELLED){
									var errorThrown = that.translator.translate('LAUNCH_SERVANT_ERROR');
									that.showLoadingMessage(errorThrown, that.setStationNameToSplash());
									that.cancelJob(errorThrown);	
								}
							}
						}
					},
					onFailure: function(data) {
						console.error(data.message);
						that.showLoadingMessage(that.translator.translate('LAUNCH_SERVANT_STATUS_ERROR'),
								that.setStationNameToSplash());
						that.cancelJob(that.translator.translate('LAUNCH_SERVANT_STATUS_ERROR') + data.message);
					}
				};
			
			var request = UWA.Data.request(eedURLMonitor, payload);
			
			return request;
		},
		
		startApp: function() {
			
			var that = this;
			
			try{
				parent.postMessage('RA_LAUNCH_COMPLETE', this._origin);
			}
			catch(e){ }

			//This posts a message to the parent frame
			//which would trigger facet name change
			that.adviseLaunchInfo.changeFacetName = function(pageName){
				that.changeFacetName.call(that, pageName);
			};
			
			that.adviseLaunchInfo.closeRAFrameInWidget = function(){
				that.closeRAFrame.call(that);
			};
			that.adviseLaunchInfo.postServantToWidget = function(details){
				that.postServantToWidget.call(that, details);
			};
			that.adviseLaunchInfo.closeRAServantFrom3DD = function(caseId){
				that.closeRAServantFrom3DD.call(that, caseId);
			};
			
			//This step is mandatory because smaResultsAnalyticsLaunched.html 
			//expects the AdviseLaunchInfo obj to be bound to the parent window.
			window.adviseLaunchInfo = that.adviseLaunchInfo;
			
			$simjq.when(that.checkServantURLValidity(adviseLaunchInfo))
		        .then(function(token){
		        	
		        	if(! that.adviseLaunchInfo.noServant){
						if(that.adviseLaunchInfo.joiningSession){
							that.showLoadingMessage(that.translator.translate('Joining session')+'...', that.setStationNameToSplash());
						}
						else{
							that.showLoadingMessage(that.translator.translate('LAUNCH_READING_DATA'),
									that.setStationNameToSplash());
						}
					}
					else{
						that.showLoadingMessage(that.translator.translate('Loading RA Lite') + '...');
					}
		        	
		        	$simjq('#widgetframe').attr('src', "../webapps/SMAAnalyticsUI/smaResultsAnalyticsLaunched.html").load(function(){
						var widgetWindow = window.frames['widgetframe'];
						if(!widgetWindow.setServantFromParent) {
							widgetWindow = widgetWindow.contentWindow; // needed for FF
						}
						if(widgetWindow.setServantFromParent) {
							$simjq('.embeddedWidget').show();
							if(! that.adviseLaunchInfo.noServant){
								widgetWindow.setServantFromParent(that.adviseLaunchInfo);
							}
							
						} else {
							that.showLoadingMessage(that.translator.translate("LAUNCH_PAGE_LOAD_ERROR"));
							that.cancelJob(that.translator.translate("LAUNCH_PAGE_LOAD_ERROR"));
						}
					});
		        });
		},
		
		//========================================================================
		/**
		 * Checks if the servant can be pinged. In case of ping failure checks
		 * for ssl certificate and mixed content issues.
		 * Also works for multiple servant urls, when in multiple NIC scenarios.
		 */
		//========================================================================
		checkServantURLValidity: function(adviseLaunchInfo){
			
			var that = this,
				servantUrl = that.adviseLaunchInfo['servantURL'],
		        mcsUrl = that.adviseLaunchInfo['mcsUrl'],
		        proxyUrl = that.adviseLaunchInfo['proxyServer'],
		        caseID = that.adviseLaunchInfo['caseID'],
		        probableMixedContent = false,
		        browsr = {},
		        servantDeferred =  $simjq.Deferred();
			
			if (! that.isValidURL(servantUrl)){      
		        that.showLoadingMessage(that.translator.translate('LAUNCH_BAD_SERVANT_URL'));
		        that.cancelJob(that.translator.translate('LAUNCH_BAD_SERVANT_URL'));
		        return; 
			}
			
			// Check if there is a possibility of mixed content
		    probableMixedContent = that.isMixedContent(servantUrl);
		    
			// Check the browser being used.
		    // We might need to handle mixed content
		    // based on the browser being used
		    if(probableMixedContent){
		        browsr = that.whichBrowser();
		    } else {
		        browsr = {
		                'name' : '',
		                'version' : '' 
		            };
		    }
		    
		    switch (browsr.name.toLowerCase()){
		    case 'chrome':
		    	
		    	// Chrome doesnt provide errors when mixed content
		        // is encountered. So run a timer and on timeout
		        // call the failure handler.
		    	that.pingServant(servantUrl, adviseLaunchInfo)
		    	.then(
		    		function(data){
		    			window.clearTimeout(chrTOut);
		                servantDeferred.resolve(data);
		    		},
		    		function(){
		                window.clearTimeout(chrTOut);
		                servantDeferred.reject(false);
		            }
		    	);
		    	
		    	var chrTOut = window.setTimeout(function(){
		            console.warn('Chrome ignored the ping request probably due to mixed content');
		            console.warn('Calling ping failure handler');
		            
		            that.handleServantPingFailure(servantUrl, adviseLaunchInfo);
		        }, 7000);
		    	
		    	break;
		    	
		    default:
		    	
		    	that.pingServant(servantUrl, adviseLaunchInfo)
		    	.then(
	    			function(data){
	                    servantDeferred.resolve(data);
	                },
	                function(){
	                    servantDeferred.reject(false);
	                }
		    	);
		    	
		    	break;
		    }
		    return servantDeferred.promise();
		},
		
		
		//========================================================================
		/**
		 * Pings the servant and returns a promise
		 * Failure doesnt resolve the promise. It kicks the user back to the
		 * launch.
		 */
		//========================================================================
		pingServant: function(servantUrl, adviseLaunchInfo){
			
			var pingDeferred = $simjq.Deferred(),
				that = this;
			
			$simjq.ajax({
				url: servantUrl + 'ping',
		        crossDomain: true,
		        type: 'GET',
		        data: {
	                'caseID': adviseLaunchInfo.caseID,
	                '_t': Date.now()
	            },
	            beforeSend : function(request) {
	    			request.setRequestHeader("ra-from-user", adviseLaunchInfo.currentUser);
	    			request.setRequestHeader("X-CSRFToken", adviseLaunchInfo.token);
	    		}
			})
			.done(function(data){
				pingDeferred.resolve(data);
			})
			.fail(function(error){
				that.handleServantPingFailure(servantUrl, adviseLaunchInfo);
				pingDeferred.reject();
			});
			
			return pingDeferred.promise();
		},
		
		//========================================================================
		/**
		 * Check if we have a https servant or a servant behind a proxy whose
		 * SSL certificate isn't verified
		 */
		//========================================================================
		handleServantPingFailure: function(servantUrl, adviseLaunchInfo){
			
			var failureHandlerDeferred = $simjq.Deferred(),
				that = this;
		    
		    if(servantUrl.indexOf('https:') === 0){
		        
		        that.handleHTTPSServant(servantUrl + 'ping', adviseLaunchInfo,
		            function(response){
		                failureHandlerDeferred.resolve(true);
		                return;
		            }
		        );
		    }
		    
		    if (that.isMixedContent(servantUrl)){
		        
		        that.handleMixedContentServant(servantUrl,
		                adviseLaunchInfo['caseID'], adviseLaunchInfo);
		        
		        failureHandlerDeferred.reject();
		    }
		    return failureHandlerDeferred.promise();
		},
		
		
		//========================================================================
		/**
		 * Handles scenarios were the RA servant is in HTTPS mode and the 
		 * certificate of the servant is not recognised by the browser.
		 * Can be used in cases of
		 * 1. Servant behind a https proxy, whose SSL certificate isn't verified
		 * 2. HTTPS SERVANT
		 */
		//========================================================================
		handleHTTPSServant: function(servantURL, adviseLaunchInfo, successCallBack){
			
			var acceptCert = false,
				that = this,
				message = that.translator.translate('LAUNCH_UNREACHABLE_SERVANT') + '<br/>' 
					+ that.translator.translate('LAUNCH_SERVANT_URL') +  adviseLaunchInfo.servantURL + '<br/>';
			
			if (servantURL.indexOf('https') === 0){
		        message += that.translator.translate('LAUNCH_SERVANT_ACCEPT_CERT') + '<br/>' +
		        		that.translator.translate('LAUNCH_OR') + ' ' + 
		        		that.translator.translate('LAUNCH_CANCEL');
		        acceptCert = true;
		    } else{
		        message += that.translator.translate('LAUNCH_CANCEL');
		    }

			that.createModalAlert({
				'message': message,
				'ok': function(){
					
					// open a new window to accept the SSL cert
		            var servantPingWnd = that.openPopUp( servantURL, 500, 500);
		            
		            $simjq
		                .when(
		                    that.urlCheckAlive({
		                        'url': servantURL, // the url is the complete ping url
		                        'crossDomain': true,
								'timeout': 12000,
		                        'data': {
		                                    'caseID': adviseLaunchInfo.caseID,
		                                    '_t': Date.now()
		                                }
		                    })
		                )
		                .then(
	                		function(token){
	                            if(typeof servantPingWnd !== 'undefined' &&
	                                    servantPingWnd !== null)
	                                servantPingWnd.close();
	                                
	                                successCallBack(token);
	                        },
	                        function(){
	                            if(typeof servantPingWnd !== 'undefined' &&
	                                    servantPingWnd !== null)
	                                servantPingWnd.postMessage('close', that._origin);
	                            
	                            that.cancelJob(that.translator.translate('LAUNCH_UNREACHABLE_SERVANT'));
	                        }
		                );
					
					
				},
				'close': that.cancelJob
			});
			
		},
		
		//===============================================================
		/**
		 * Warn the user for mixed content.
		 */
		//===============================================================
		mcCheckDone : false,
		handleMixedContentServant : function(url, caseId, adviseLaunchInfo){
			
			var that = this;
			
			if (that.mcCheckDone) return;
			
			var message = that.translator.translate('LAUNCH_UNREACHABLE_SERVANT') + '<br/>'
							+ that.translator.translate('LAUNCH_SERVANT_URL') + url + '<br/>'
		                    + that.translator.translate('LAUNCH_UNBLOCK_MC') + '<br/>' 
		                    + that.translator.translate('LAUNCH_OR') + ' ' 
		                    + that.translator.translate('LAUNCH_CANCEL');
			
			if(typeof caseId !== 'undefined' && caseId !== null && caseId.length > 0){
		        localStorage['smaAnalytics_MC_Interruption'] = caseId;
		        localStorage['smaAnalyticsCase' + caseId] = 
		                            JSON.stringify({
		                                'lastUpdateTime' : Date.now(),
		                                'servantURL' : url,
		                                'stationName' : that.adviseLaunchInfo.stationName,
		                                'stationIP' : that.adviseLaunchInfo.stationIP });
		    }
			that.mcCheckDone = true;
			
			that.createModalAlert({
				'message': message,
				'close': function(){
					localStorage.removeItem('smaAnalytics_MC_Interruption');
		            that.cancelJob();
				}
			});
		},

		//****************************************************************
		/**
		 * RA Widget Launch Sequence - End 
		 */
		//****************************************************************
		
		//===============================================================
		/**
		 * Code to position a popup window in the center of the
		 * screen. This code also accounts for dual screens.
		 */
		//===============================================================
		centerPopupWnd: function(w, h){
			var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left,
				dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top,
				width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? 
						document.documentElement.clientWidth : screen.width,
				height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ?
						document.documentElement.clientHeight : screen.height,
				left = ((width / 2) - (w / 2)) + dualScreenLeft,
				top = ((height / 2) - (h / 2)) + dualScreenTop;
			return { 'top': top, 'left': left };
		},
		//===============================================================
		/**
		 * Open a popup window and position it to the center of the
		 * screen. Requires a url, width and height for the window
		 */
		//===============================================================
		openPopUp: function (url, w, h){
			var that = this,
				posn = that.centerPopupWnd(w, h),
				wNd = window,
		        options = 'WIDTH=' + w +
		                    ',HEIGHT=' + h + 
		                    ',top=' + posn.top +
		                    ',left=' + posn.left +
		                    ',scrollbars=yes' +
		                    ',menubar=no' +
		                    ',resizable=yes' +
		                    ',directories=no',
		        popUp = wNd.open(url, '', options);
		    
		    if(typeof popUp === 'undefined' ||
		        popUp === null){
		        alert(that.translator.translate('LAUNCH_DISABLE_POPUP_BLOCKER'));
		    }
		    if(popUp){
		        popUp.onload = function(){
		            if(! popUp.innerHeight > 0){
		                // Popup blocked
		                alert(that.translator.translate('LAUNCH_DISABLE_POPUP_BLOCKER'));
		            }
		        }
		    }
			var eventMethod = popUp.addEventListener ? "addEventListener" : "attachEvent",
				eventer = popUp[eventMethod],
				messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
			eventer(messageEvent, function(){
						window.close();
					}, false);	
		    return popUp;
		},
		
		//===============================================================
		/**
		 * Checks if the url is reachable, repeats itself for 2 mins.
		 * Returns a promise 
		 */
		//===============================================================
		urlCheckAlive: function(data){
		    
		    var url = data['url'],
		        params = data['params'],
		        timeOut = data['timeout'] || null,
		        caseId = data['caseid'],
		        rType = data['type'] || 'GET',
		        crossDomain = data['crossDomain'] || null;
		    
		    var checkDeferred = $simjq.Deferred(),
		        start = new Date().getTime(),
		        urlAlive = false;
		    
		    (function pollUrl(){
		        
		        console.log('Polling ' + url);
		        
		        var payload = {
		            type: rType,
		            url: url,
		            data: params
		        };
		        if(timeOut)
		            payload['timeout'] = timeOut;
		        if(crossDomain)
		            payload['crossDomain'] = crossDomain;
		        $simjq.ajax(payload).done(
		            function(response){
		                console.log('Ping to ' + url + ' was successful');
		                urlAlive = true;
		                checkDeferred.resolve(response);
		                return;
		            }
		        ).fail(
		            function(err){
		                
		                console.log('Poll failed');

		                if(new Date().getTime() - start > timeOut){
		                    console.log('Unable to reach ' + url);
		                    urlAlive = false;
		                    checkDeferred.reject(urlAlive);
		                    return;
		                } else {
		                    setTimeout(pollUrl, 1000);
		                }
		            }
		        );  
		    }()); 
		    
		    return checkDeferred.promise();
		},
		
		
		launchRALite: function(){
			this.adviseLaunchInfo.noServant = true;
			this.startApp();
		},
		changeFacetName: function(pageName) {
			try{
				parent.postMessage('RA_PAGE_CHANGE:' + pageName, this._origin);
			}catch(ex){
				console.error('Error posting RA Page name to widget');
			}
		},
		closeRAFrame: function() {
			try{
				parent.postMessage('CANCEL-WIDGET-LAUNCH', this._origin);	
			}catch(ex){
				console.error('Error posting RA Cancel message to widget');
			}
		},
		postServantToWidget: function(details) {
			try{
				var servantMsg = 'TOKEN:' + (this.adviseLaunchInfo.token || 'notoken') + '__;;__';
				servantMsg += 'SERVANT:' + this.adviseLaunchInfo.servantURL;
				parent.postMessage(servantMsg, this._origin);
			}catch(ex){
				console.error('Error posting servant details to widget')
			}
		},
		closeRAServantFrom3DD: function(caseId){
			if(caseId === ''){
				return;
			}
			try {
			// this is as same as the getrunningservant method
				var previousSessionString = localStorage['smaAnalyticsCase' + caseId],
					that = this,
					servantURL = '';
				
				if (previousSessionString && previousSessionString.length > 5) {
					var previousSession = JSON.parse(previousSessionString),
						prevTime = previousSession.lastUpdateTime;
					servantURL = previousSession.servantURL;
				} else {
					servantURL = that.adviseLaunchInfo.servantURL;
				}
				
				var url = servantURL + 'ping',
					payload = {
						// the cors option avoids adding the
						// X-Requested-With and X-Requested-Method
						// headers to the Data request. 
						// The servant doesnt allow both of these.
						// So all COS/Servant requests using UWA.Data.Request
						// must have this option
						cors: 'cors',
						allowCrossOriginRequest: true,
						data: {
							'caseID' : caseId,
							'_t': Date.now()
						},
						headers: {
							'ra-from-user': that.adviseLaunchInfo.currentUser,
							'X-CSRFToken': that.adviseLaunchInfo.token
						},
						onComplete: function(response) {
							var stopUrl = servantURL + 'stop',
								stopPayload = {
									method: 'POST',
									cors: 'cors',
									allowCrossOriginRequest: true,
									data: { 't': Date.now() },
									headers: {
										'ra-from-user': that.adviseLaunchInfo.currentUser,
										'X-CSRFToken': that.adviseLaunchInfo.token
									},
									onComplete: function(){
										localStorage.removeItem('smaAnalyticsCase' + caseId);
										parent.postMessage('RA_SERVANT_CLOSE_COMPLETE', that._origin);
									},
									onFailure: function() {
										parent.postMessage('RA_SERVANT_CLOSE_COMPLETE', that._origin);
									}
								},
								stopReq = UWA.Ajax.request(stopUrl, stopPayload);
						},
						onFailure: function() {
							console.error('Error closing RA Servant from 3D Dashboard');
							parent.postMessage('RA_SERVANT_CLOSE_COMPLETE', that._origin);
						}
					},
					request = UWA.Ajax.request(url, payload);
			}
			catch(ex){
				console.error('Fatal error closing the RA servant from 3D Dashboard');
				console.info(ex);
				parent.postMessage('RA_SERVANT_CLOSE_COMPLETE', that._origin);
			}
		},
		alertMessage: function(messageText, func, delay) {
			$simjq('.sim-ui-advise-alert-message-text').text(messageText);
			if (messageText.length < 25) {
				$simjq('.sim-ui-advise-alert-message-text').css('line-height', '4rem');
			} else if (messageText.length < 50) {
				$simjq('.sim-ui-advise-alert-message-text').css('line-height', '2rem');
			} else if (messageText.length < 75) {
				$simjq('.sim-ui-advise-alert-message-text').css('line-height', '1.33rem');
			} else {
				$simjq('.sim-ui-advise-alert-message-text').css('line-height', '1.0rem');
			}
			$simjq('.sim-ui-advise-alert-message').css('opacity', 1.0).show();
			if (!delay) {
				delay = 5000;
			}
			$simjq('.sim-ui-advise-alert-message').animate({ opacity : 0.0 }, delay, function() {
				$simjq('.sim-ui-advise-alert-message').hide();
				if (func) {
					func();
				}
			});
		},
		
		//=================================================================================
		/**
		 * Function to detect the browser name and version
		 */
		//=================================================================================
		whichBrowser: function(){
		    var ua=navigator.userAgent,
		        tem,
		        M=ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
		    
		    if(/trident/i.test(M[1])){
		        tem=/\brv[ :]+(\d+)/g.exec(ua) || [];
		        return {
		            name:'IE',
		            version:(tem[1]||'')
		        };
		    }
		    
		    if(M[1]==='Chrome'){
		        tem=ua.match(/\bOPR\/(\d+)/);
		        if(tem!=null){
		            return {
		                name:'Opera',
		                version:tem[1]
		            };
		        }
		    }
		    
		    M=M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
		    
		    if((tem=ua.match(/version\/(\d+)/i))!=null) {
		        M.splice(1,1,tem[1]);
		    }
		    
		    return {
		      name: M[0],
		      version: M[1]
		    };
		},
		
		//===============================================================
		/**
		 * Checks if the url is valid
		 */
		//===============================================================
		isValidURL: function(url){
		    
		    if(typeof url === 'undefined' ||
		            url === null)
		        return false;
		    
		    if(url.indexOf('http:') !== 0 &&
		        url.indexOf('https:') !== 0)
		        return false;
		    
		    return true;
		},
		
		//=================================================================================
		/**
		 * Returns a url object that can be used to extract the host, domain, protocol.
		 * Since IE doesnt support the URL object, uses a href element instead.
		 */
		//=================================================================================
		getURLObject: function(url){
		    try {
		        return new URL(url);
		    }
		    catch(ex){
		        var urlElem = document.createElement('a');
		        urlElem.href = url;
		        return urlElem;
		    }
		},
		
		//===============================================================
		/**
		 * If the host is https and url is http then check for mixed 
		 * content can be prompted
		 */
		//===============================================================
		isMixedContent: function(url){
		    if(typeof url === 'undefined' ||
		            url === null)
		        return false;
		    
			var that = this;
		    var urlObj = that.getURLObject(url); 
		    if (urlObj['protocol'] === 'http:' &&
		            window.location.protocol === 'https:')
		        return true;
		    
		    return false;
		},
		
		openRAinNewWindow : function(_this) {
			var that = this;
			
			that.showLoadingMessage(that.translator.translate("OPEN_NEW_WINDOW"));
			var url = that._enoviaurl +'/common/emxNavigator.jsp?contentPage=';
			url = url + encodeURIComponent('../simulationcentral/smaRunAdviseJob.jsp?objectId='+that.caseID);
			window.open(url);
			that._deferred.reject();
		},
		
		resetRunningServant: function() {
			var that = this;
			delete localStorage['smaAnalyticsCase' + that.caseID];
		},
		
		
		getLaunchInfoForRunningServant: function(){
			var that = this,
				url = that._enoviaurl +'/resources/slmservices/advise/getAnalyticsLaunchInfo?caseID=' + that.caseID,
				dfd = $simjq.Deferred();
			
			url += '&mcsURI=' + encodeURIComponent(that._enoviaurl);
			
			var payload = {
					type: 'json',
					cache: false,
					allowCrossOriginRequest: true,
					onComplete: function(data){
						
						that.adviseLaunchInfo.eedURL = data.eedURL;
						that.adviseLaunchInfo.ticketURL = data.ticketURL;
						that.adviseLaunchInfo.eedTicket = data.eedTicket;
						that.adviseLaunchInfo.token = that.adviseLaunchInfo.token || data.eedTicket;
						//that.adviseLaunchInfo.encodedJobXML = data.encodedJobXML;
						that.adviseLaunchInfo.localIP = data.localIP;
						//that.adviseLaunchInfo.runInfo = data.runInfo;
						that.adviseLaunchInfo.proxyServer = data.proxyServer;
						that.adviseLaunchInfo.currentUser = data.currentUser;

						that.adviseLaunchInfo.mcsUrl = data.mcsURL;

						var hostUrlObj = that.getURLObject(document.URL),
							encodedJobXML = that.adviseLaunchInfo.encodedJobXML;
						
						if (typeof encodedJobXML !== 'undefined' &&
								encodedJobXML !== null &&
								encodedJobXML.length > 0){
									
							var jobXML = that.htmlUnescape(encodedJobXML),
								mcsUri = (jobXML.split('<AppUrl>')[1])
											.split('</AppUrl>')[0];

							if(document.URL.indexOf('https') === 0 &&
									mcsUri.indexOf('https') < 0){
								var baseUri = '';
								if (widget){
									baseUri = widget.getUrl() || '';
									if (baseUri.indexOf('/webapps') > -1) {
										baseUri = baseUri.substring(0, baseUri.indexOf('/webapps'));
									}
								} else if (PlatformAPI){
									var PLATFORM_KEY_MYAPPS_URL = 'app.urls.myapps';
									baseUri = PlatformAPI.getApplicationConfiguration(PLATFORM_KEY_MYAPPS_URL);
								}
								if (baseUri.length > 0){
									that.adviseLaunchInfo.encodedJobXML = encodedJobXML.replace(mcsUri, baseUri);
									that.adviseLaunchInfo.mcsUrl = baseUri;
									that._enoviaurl = baseUri;
									
									var ticketURLObj = that.getURLObject(that.adviseLaunchInfo.ticketURL),
										baseURLObj = that.getURLObject(baseUri);
									that.adviseLaunchInfo.ticketURL = baseURLObj['protocol'] + '//' + baseURLObj['hostname']
																		+ (baseURLObj['port'].length > 0 ? '/' + baseURLObj['port'] : '')
																		+ ticketURLObj['pathname'] + ticketURLObj['search'];
								}
							}
						}
						
						dfd.resolve();
					
						
					},
					onFailure: function() {
						console.error('Retrieving launch info failure');
						that.cancelJob();
						dfd.reject();
					}
				};
				
			UWA.Data.request(url, payload);
			
			return dfd.promise();
		},
		
		getRunningServant: function() {
			var that = this,
				dfd = $simjq.Deferred(),
				clearStg = function() {
				that.adviseLaunchInfo.servantURL = '';
					that.resetRunningServant();
					dfd.resolve(null);
				};
			
			if (typeof (Storage) !== 'undefined') {
				
				var currTime = Date.now();
				var previousSessionString = localStorage['smaAnalyticsCase' + that.caseID];
				
				if (previousSessionString && previousSessionString.length > 5) {
					
					var previousSession = JSON.parse(previousSessionString),
						prevTime = previousSession.lastUpdateTime,
						servantURL = previousSession.servantURL;
					
					that.adviseLaunchInfo.servantURL = servantURL;
					
					$simjq.when(that.getLaunchInfoForRunningServant())
						.then( function(){
							
							$simjq.when(that.checkServantURLValidity(that.adviseLaunchInfo))
							.then(
								function(response){
									
									that.createModalAlert(
											{
												'title' : that.translator.translate('LAUNCH_RA_HEADER_EXS_SERVANT'),
												'message': that.translator.translate('EXSTNG_SRVNT')+ '\n' + that.translator.translate('USE_EXSTNG_SRVNT'),
												'closelabel': 'cancel',
												'ok': function(){
													dfd.resolve({ 
														'servantURL' : servantURL, 
														'stationName' : previousSession.stationName, 
														'stationIP' : previousSession.stationIP,
														'token': response
														});
												},
												'close': function(){
													var stopUrl = servantURL + 'stop',
														stopPayload = {
															method: 'POST',
															cors: 'cors',
															allowCrossOriginRequest: true,
															data: { 't': Date.now() },
															headers: {
																'ra-from-user': that.adviseLaunchInfo.currentUser,
																'X-CSRFToken': that.adviseLaunchInfo.token
															},
															onComplete: function(){
																clearStg();
															},
															onFailure: function() {
																clearStg();
															}
														},
														stopReq = UWA.Ajax.request(stopUrl, stopPayload);
												}
											}
										);
									} /*,
								function(){
									clearStg();
								}*/
							);
							
						},
						function(){
							clearStg();
						}
					);
					
							

					
				} else {
					clearStg();
				}
			} else {
				dfd.resolve(null);
			}
			return dfd;
		},
		
		launchWithExistingServant: function(){
			
			var that = this,
				dfd = Promise.deferred();
		
			that.showLoadingMessage(that.translator.translate('Checking for existing servant')+'...');
			
			try {
				
				$simjq.when(that.getRunningServant())
				.then(
					function(data){
						
						var runningServant = data;
						
						if (runningServant !== null) {
							
							that.adviseLaunchInfo.servantURL = runningServant.servantURL;
							that.adviseLaunchInfo.stationName = runningServant.stationName;
							that.adviseLaunchInfo.stationIP = runningServant.stationIP;
							that.adviseLaunchInfo.token = runningServant.token ;
							that.adviseLaunchInfo.stationDisplayName = runningServant.stationName || '';
							dfd.resolve();
							
						} else {
							dfd.reject();
						}
						
					});
				
			} catch(ex){
				
				dfd.reject();
			}
			
			return dfd.promise;
		},
		
		isAllowedUser: function(stationInfo){
			var that = this;
			
			if(typeof that.adviseLaunchInfo.currentUser === 'undefined' ||
					that.adviseLaunchInfo.currentUser === null){
				return false;
			}
			var users = stationInfo.GeneralInfo['@allowedUsers'] || '';
			if(users.length === 0){
				return true;
			}
			var userList = users.split(',');
			for(var i=0; i<userList.length; i++){
				if(userList[i] === that.adviseLaunchInfo.currentUser){
					return true;
				}
			}
			return false;
		},		

		refreshJobLog: function(jobIdTxt, timer){
			var that = this,
				url = that.adviseLaunchInfo.eedURL + '/job/' + jobIdTxt + '/monitor',
				payload = {
					method : 'GET',
					headers : { 'EEDTicket' : that.adviseLaunchInfo.eedTicket,
								'Credentials' : ''
							},
					data : { 'Topic' : "ResultsServantURL",
							 'TimeStamp' : 0 },
					onComplete : function(data){
						console.log(returndata);
						$simjq(".sim-ui-advise-job-log").text($simjq(data).text());
					},
					onFailure : function(error) {
						var text = $simjq(".sim-ui-advise-job-log").text();
						text = text + "\n\r" + error;
						$simjq(".sim-ui-advise-job-log").text(text);
					}
			};
		},
		
		
		//************************************************************
		/**
		 * Multi Session Launch Code - Start
		 */
		//************************************************************
		joinAdviseSession : function(jobID){
			/*
			 * Code to launch RA client when there is an existing servant
			 * Uses jobID to get the existing servant URL
			 * TODO: merge these with the launch functions used for regular launch
			 */
			
			this.adviseLaunchInfo.isJoiningSession = true;
			this.adviseLaunchInfo.jobID = jobID;
			
			var that = this;
			
			var getLaunchInfo = function() {
				var that = this;
				var deferredObj = $simjq.Deferred();
				var enoviaURLObject = that.getURLObject(that._enoviaurl);
				var urlPrefix = 
					enoviaURLObject['protocol'] + '//' + enoviaURLObject['hostname']
				+ (enoviaURLObject['port'].length > 0 ? ':' + enoviaURLObject['port'] : '');
				
				var envPathName = enoviaURLObject['pathname'];
				envPathName = (envPathName.charAt(0) == "/") ? envPathName : "/" + envPathName;
				
                var enoviaEnv = 
                    (envPathName.length > 0 ? envPathName.split('/')[1] : '');
				var url = urlPrefix +'/'+enoviaEnv+ '/resources/slmservices/advise/getAnalyticsLaunchInfo?caseID=' + that.caseID,
				payload = {
						type: 'json',
						allowCrossOriginRequest: true,
						onComplete: function(data){
							
							if(data.hasLicense && data.hasLicense === 'true'){
								that.adviseLaunchInfo.eedURL = data.eedURL;
								that.adviseLaunchInfo.ticketURL = data.ticketURL;
								that.adviseLaunchInfo.eedTicket = data.eedTicket;
								that.adviseLaunchInfo.encodedJobXML = data.encodedJobXML;
								that.adviseLaunchInfo.localIP = data.localIP;
								that.adviseLaunchInfo.runInfo = data.runInfo;
								that.adviseLaunchInfo.proxyServer = data.proxyServer;
							}
							else{
								alert('No license available to launch Results Analytics.');
								window.location.href = that.adviseLaunchInfo._appLandingPage;
							}
							
							deferredObj.resolve()
						},
						onFailure: function() {
							console.error('Retrieving launch info failure');
							that._deferred.reject();
						}
					},
					request = UWA.Data.request(url, payload);
				return deferredObj;
			};
			
			
			var getEEDPublicKey = function(callback) {
				var that = this;
				var deferredObj = $simjq.Deferred();
				that.showLoadingMessage(that.translator.translate("Getting public key") + "...");
				var url = that.adviseLaunchInfo.eedURL + '/execution/pubkey',
					payload = {
						type: 'json',
						allowCrossOriginRequest: true,
						headers: { 'EEDTicket': that.adviseLaunchInfo.eedTicket,
									'Credentials': '' },
						onComplete: function(data){
							that.adviseLaunchInfo.eedPublicKey = data ? encodeURIComponent(data.KeyRep.$) : '';
							
							// Retrieving EED public key complete
							deferredObj.resolve();
						},
						onFailure: function() {
							console.error('Failure retrieving eed public key');
							that._deferred.reject();
							
							//Launch Lite
						//	that.launchRALite();
						}
						},
					request = UWA.Data.request(url, payload);
				return deferredObj;
			};
			
			
			var getEncryptedCredentials = function(_this) {
				var that = this;
				var deferredObj = $simjq.Deferred();
				that.showLoadingMessage(that.translator.translate("Getting credentials") + "...");
				var url = that._enoviaurl + '/resources/slmservices/advise/getEncryptedCredentials?pubkey=' 
					+ that.adviseLaunchInfo.eedPublicKey,
					payload = { 
						type: 'text',
						//proxy: 'passport',
						allowCrossOriginRequest: true,
						headers: { 'Accept' : 'text/plain; charset=utf-8', 'Content-Type': 'text/plain; charset=utf-8'},
						timeout: 1000000000,
						onComplete: function(data){
							that.adviseLaunchInfo.resourceCredentials = that.emxUICoreTrim(data);
							
							//Retrieving encrypted credentials complete
							deferredObj.resolve();
						},
						onFailure: function() {
							console.error('Failure retrieving encrypted credentials');
							that._deferred.reject();
						}
						},
					request = UWA.Data.request(url, payload);
				return deferredObj;
			};
			
			var tryToLaunchAdviseClient = function(timer) {
				
				var deferredObj = $simjq.Deferred();
				var that = this;
				
				
				var jobIdTxt = that.adviseLaunchInfo.jobID,
					eedURL = that.adviseLaunchInfo.eedURL,
					eedTicket = that.adviseLaunchInfo.eedTicket;
				
				that.launchCount++;
				if (that.launchCount > that.launchLimit) {
					clearInterval(timer);
					
					//FIXME: fix splash message 
					that.showLoadingMessage(that.translator.translate("Servant launch timed out") + "!");
					
					//FIXME: alertMessage function
					
					if (that.alertMessage) {
						that.alertMessage(that.translator.translate("Servant launch timed out") + "!", function() {
						//	that.cancelJob(that.adviseLaunchInfo);
						});
					} else {
						alert(that.translator.translate("Servant launch timed out") + "!");
						//that.cancelJob(that.adviseLaunchInfo);
					}
					return;
				}
				
				var eedURLMonitor = that.adviseLaunchInfo.eedURL + "/job/" + that.adviseLaunchInfo.jobID + "/monitor",
					payload = {
						//method: 'GET',
						type: 'xml',
						allowCrossOriginRequest: true,
						data: { 'Topic' : "ResultsServantURL",
								'TimeStamp' : 0 },
						headers: { /*'Content-Type' : 'application/xml',*/
									'EEDTicket' : that.adviseLaunchInfo.eedTicket,
									'Credentials' : ''
								},
						onComplete: function(returndata) {
							console.log(returndata);
							var adviseMessage = $simjq(returndata).find("Message").text();
							if (adviseMessage.length > 4) {

								clearInterval(timer);
								
								//FIXME: Reverese proxy code goes here.
								//Refer smaAdviseLaunchHelper.js
								if (typeof that.adviseLaunchInfo.proxyServer !== 'undefined' && that.adviseLaunchInfo.proxyServer.length !== 0){
									/**
									 * A reverse proxy server exists.
									 * The servant url returned from the bulletin
									 * board may be of the format
									 * <servanthost>/<servantportmap>/Advise
									 * Check if the message has the actual url or a proxified url
									 * Actual url may be returned if no exposed station name and/or
									 * exposed station ports ar configured in the station properties.
									 * If a proxified url, append the proxy server details. Else let
									 * it run as such.
									 */
									if ((adviseMessage.indexOf('http:') < 0) && (adviseMessage.indexOf('https:') < 0)){
										adviseMessage = that.adviseLaunchInfo.proxyServer + adviseMessage;
									}
								}
								
								// extract servant IP from the URL
								var parser = document.createElement('a');
								parser.href = adviseMessage;
								var servantIP = parser.hostname;
								that.adviseLaunchInfo.stationIP = servantIP;
								that.adviseLaunchInfo.stationName = servantIP;
								that.adviseLaunchInfo.stationList = that.adviseLaunchInfo.stationList || [];
								
								for(var i=0; i<that.adviseLaunchInfo.stationList.length; i++) {
									var stationInfo = that.adviseLaunchInfo.stationList[i];
									if(stationInfo && stationInfo['@name'] && stationInfo['@name'].length > 0 
											&& stationInfo.GeneralInfo 
											&& stationInfo.GeneralInfo['@hostIP'] 
											&& stationInfo.GeneralInfo['@hostIP'].length > 3) {
										var stationName = stationInfo['@name'];
										var stationIP = stationInfo.GeneralInfo['@hostIP'].trim();
										if(stationIP === servantIP) {
											that.adviseLaunchInfo.stationName = stationName;
										}
									}
								}
								
								var startWaitTimer = setInterval(function() {
									clearInterval(startWaitTimer);
									that.removeLoadingMessage();
									that.adviseLaunchInfo.servantURL = adviseMessage + '/';
									deferredObj.resolve()
								}, 2000);	
								
							} else {
								
								var messageElem = $simjq(returndata).find("MonitoringMessages");
								var status = messageElem.attr("status");
								if (status == "Running" && !that.jobRunning) {
									// reset the wait timer for the Executor to post the message
									//FIXME: loading splash
									that.showLoadingMessage(that.translator.translate("Waiting for servant to start") + "...");
									
									that.launchCount = 0;
									that.jobRunning = true;
								} else if (status == "Done") {
									clearInterval(timer);
								//	var errorThrown = "Servant encountered an error.";
								//	that.showLoadingMessage(errorThrown);
									alert(that.translator.translate("INACTIVE_SESSION") + ".");
									window.location.href = that.adviseLaunchInfo._appLandingPage;
									//FIXME: 
									//history.go(-1);
									if (that.alertMessage) {
										//FIXME: alertmessage function
										that.alertMessage(errorThrown, function() {
											//FIXME: How to handle cancel job?
											//history.go(-1);
										});
									} else {
										alert(errorThrown);
										//FIXME: How to handle cancel job?
										//history.go(-1);
									}

								}
								
								
							}
							
						},
						onFailure: function(data) {
							//that.showLoadingMessage("Error: " + data.message);
							console.error(data.message);
							if (that.alertMessage) {
								that.alertMessage(errorThrown, function() {
								});
							} else {
								alert(errorThrown);
							}
						}
					};
				
				var request = UWA.Data.request(eedURLMonitor, payload);
				
				return deferredObj;
			};
			
			var xhr = new XMLHttpRequest();
			xhr.open('GET', '../resources/slmservices/advise/currentUser');
			xhr.send();
			xhr.onload = function(){
				var response = JSON.parse(this.response);
				var currentUser = {};
				currentUser.userID = response.id;
				var domp = new DOMParser();
				var xml = domp.parseFromString(response.xml, 
						'application/xml')
				currentUser.userName = xml.getElementsByTagName("Person")[0].getAttribute("fullname");
				
				that.adviseLaunchInfo.collaborationUser = currentUser;
				
				getLaunchInfo.call(that).done(function(){
					getEEDPublicKey.call(that).done(function(){
						getEncryptedCredentials.call(that).done(function(){
							tryToLaunchAdviseClient.call(that).done(function(){
								$simjq.ajax({
									url: that.adviseLaunchInfo.servantURL+'executeCommand',
									data: {
										'commandGroup': 'collaboration',
										'commandName': 'handshake',
										'userInfo': JSON.stringify(that.adviseLaunchInfo.collaborationUser)
									},
									crossdomain: true,
								}).done(function(data){
									that.adviseLaunchInfo._appLandingPage = '../'+that.adviseLaunchInfo._appLandingPage;
									that.adviseLaunchInfo.userList = JSON.parse(data);
									that.startApp.call(that);
								}).fail(function(data){
									alert(data.responseText);
								});
							});
						});
					});
				});
			};	
		},
		
		//************************************************************
		/**
		 * Multi Session Launch Code - End
		 */
		//************************************************************
		
	};
	
	return AdviseWidgetLaunchHelper;
});

