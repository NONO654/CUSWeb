//For the connection to TRC server we must call several APIs
//We can find the instructions in 'Quality WS API v15.1 Lifecycle Overiew'

define('DS/SemanticAssistant/Model', [
		'DS/TraceableRequirementsUtils/jQuery',
		'UWA/Class',
		'i18n!DS/SemanticAssistant/assets/nls/saNLS',
		'DS/TraceableRequirementsUtils/Services/RequirementWebServices',
		//'text!DS/SemanticAssistant/assets/FakeResponseQualityCheck.xml', // COMMENT THIS OUT!!!
		'DS/TraceableRequirementsUtils/Utils',
		'text!DS/SemanticAssistant/assets/params.json'
		],
  function(jQuery,
		   Class,
		   saNLS,
		   RequirementWebServices,
		  // FakeResponseQualityCheck, // for development
		   REQUtils,
		   SAParams
		   ){
	
	var that = null;
	
	SAParams = JSON.parse(SAParams);
	
	var SemanticModel = Class.extend({
		
		engine: null,
		
		sessionId: '',
		
		successfulConnection: false,
		
		webServiceUrl: '',
		
		user: null,
		
		failedConnections: 0,
		
		companyName: '',
		
		companyId: '',
		
		init: function(semanticWidget, user) {
			this.engine = semanticWidget;
			// only temporary line, get URL from parameterization
			//this.webServiceUrl = 'https://authoring.reusecompany.com:9095/v18.1/trcapi.asmx/';
			this.user = user;
			that = this;
		},
			
		t: {
	    	blockInternalCode: 1,
	        blockName: 'Test blockName',
	        absoluteNumber: 'Test absolute number',
	        header: 'Header',
	        description: 'Test description',
	        url: 'Test url',
	        authorName: 'Test author name',
	        userName: 'test username',
	        lastModificationUser: 'Test last modification user',
	        level: 0,
	        code: 'Test code',
	        versionCount: 1,
	        numOleObjects: 1,
	        moduleVolatilityCount: 1,
	        authorEmailAddress: 'Test author email address',
	        attrs: null,
	        blockId: ''
	    },
	   	
	    //call() the trc's APIs
		call: function(method, params, successCallbackFunction, failureCallbackFunction) 
		{	
			
			jQuery.ajax({
				type: 'POST',
				url: that.webServiceUrl + method,
				async: true,
				dataType: 'xml',
				cache: false, 
				success: function(xml){ 
					successCallbackFunction(xml);												
				},	
				data: params,						
								
				error: function(msg){ 
					failureCallbackFunction(msg);
				}					
			});
		},
		getWebServiceURL: function(callback) {
			/// returns the trc web server URL that was entered in the Platform Management tab by the administrator
			
			if (this.engine.isOpen)  {
				this.engine.showLoadingState('url');
			}
			
			RequirementWebServices.getTRMExpressionValue({
				expression: 'TRM_TRC_URL',
				securityContext: REQUtils.getSecurityContext(),
				method:'GET',
				onComplete: function(response) {
					var url = jQuery.parseJSON(response).results.value;
					if (UWA.is(url)) {
						var webServiceUrl = url.trim();
						if (webServiceUrl.slice(-1) !== '/') {
							webServiceUrl = webServiceUrl + '/';
						}
						that.webServiceUrl = webServiceUrl;
						callback();
					} else {
						console.error('SA: Web service URL not valid');
						that.engine.showError(saNLS.get('SA_title_URLNotValid'), saNLS.get('SA_info_URLNotValid'));
					}
				},
				onFailure: function(response) {
					console.error('SA: Web service URL not found.');
					that.engine.showError(saNLS.get('SA_title_loadingURLFailed'), saNLS.get('SA_info_loadingURLFailed'));
				},
				onTimeout: function(response) {
					console.error('SA: Timeout on GET web service URL');
					that.engine.showError(saNLS.get('SA_title_loadingURLFailed'), saNLS.get('SA_info_loadingURLFailed'));
				},
				onCancel: function(response) {
					console.error('SA: GET web service URL was canceled');
					that.engine.showError(saNLS.get('SA_title_loadingURLFailed'), saNLS.get('SA_info_loadingURLFailed'));
				}
			});
				
		},
		connect: function(user) {
			//var that = this;
			
			if (this.sessionId === '' || this.successfulConnection === false){
				RequirementWebServices.getTRCSessionInfo({
					onComplete: function(response) {
						var results = jQuery.parseJSON(response).results;
						var sid = results.TRCSessionId;
						that.companyName = results.companyName
						that.companyId = results.companyId
						if (sid) {
							that.sessionId = sid;
							
							that.successfulConnection = true;

							var callbackFct = function(){
								var par = {
									sessionId : that.sessionId, 
									rms : SAParams.rms,
									rmsLogin : SAParams.rmsLogin,
									databaseServer : SAParams.databaseServer,
									dataBaseName : SAParams.dataBaseName,
									projectLocation : '/' + that.user,
									projectName : that.engine.globals.reqSpec,
									projectCode : that.engine.globals.reqSpec
								};
								
									
								console.log('SA: Connection already existing');
								that.call('InitProject', par, that.callbacks.onInitProjectSuccess, that.callbacks.onConnectFailed);
							};
							
							that.getWebServiceURL(callbackFct);
						} else {
							console.log('existing TRC session not found.');
							var callbackFct = function(){
								if (that.engine.isOpen)  {
									that.engine.showLoadingState('connection');
								}
								var data = {
										user: user !== undefined ? user : that.user,
										UserName: user !== undefined ? user : that.user,
										UserCode: user !== undefined ? user : that.user,
										CompanyName: that.companyName,
										CompanyCode: that.companyId
								}
								that.call('Connect', data, that.callbacks.onConnectSuccess, that.callbacks.onConnectFailed);
							};
							
							that.getWebServiceURL(callbackFct);
						}
					},
					onFailure: function(response) {
						console.error('SA: failed to get TRC session info.');
						that.engine.showError("failed to get TRC session info.", "failed to get TRC session info.");
					},
					onTimeout: function(response) {
						console.error('SA: Timeout on getting TRC session info');
						that.engine.showError("Timeout on getting TRC session info.", "Timeout on getting TRC session info.");
					},
					onCancel: function(response) {
						console.error('SA: GET TRC session info was canceled');
						that.engine.showError("GET TRC session info was canceled.", "GET TRC session info was canceled.");
					}
				});
				
				
			} else {
						
					var par = {
						sessionId : this.sessionId, 
						rms : SAParams.rms,
						rmsLogin : SAParams.rmsLogin,
						databaseServer : SAParams.databaseServer,
						dataBaseName : SAParams.dataBaseName,
						projectLocation : '/' + this.user,
						projectName : this.engine.globals.reqSpec,
						projectCode : this.engine.globals.reqSpec
					};
					
						
					that.call('InitProject', par, that.callbacks.onInitProjectSuccess, that.callbacks.onConnectFailed);
				
					console.log('SA: Connection already existing');
				
			}   
		},
		
		disconnect: function(sessionId) {
			if (sessionId !== undefined) {
				var data = {
						sessionId: sessionId
				};
				this.call('Disconnect', data, this.callbacks.onDisconnectSuccess, this.callbacks.onConnectFailed);
			}
		},
		
		callbacks: {
			
	       	onConnectSuccess: function(response)
	       	{
	       		
	       		that.sessionId = jQuery(response).find('SessionId').first().text();
	       		console.log('SA: SESSION ID = ' + that.sessionId);
	       		
	   			(function(){
						
					var par = {
						sessionId : that.sessionId, 
						rms : SAParams.rms,
						rmsLogin : SAParams.rmsLogin,
						databaseServer : SAParams.databaseServer,
						dataBaseName : SAParams.dataBaseName,
						projectLocation : '/' + that.user,
						projectName : that.engine.globals.reqSpec,
						projectCode : that.engine.globals.reqSpec
					};
					if(jQuery(response).find('Success').first().text() === 'true'){
						
						console.log('Connection succesfully established.');
						that.successfulConnection = true;
						
						RequirementWebServices.setTRCSessionId({
							json: {sessionId: that.sessionId},
							onComplete: function(response) {
								var results = jQuery.parseJSON(response).results;
								/*var par = {
									sessionId : that.sessionId, 
									rms : 0,
									rmsLogin : that.user,
									databaseServer : 'localhost',
									dataBaseName : 'name',
									projectLocation : '/' + that.user,
									projectName : that.engine.globals.reqSpec,
									projectCode : that.engine.globals.reqSpec
								};*/
																
								that.call('InitProject', par, that.callbacks.onInitProjectSuccess, that.callbacks.onConnectFailed);
								
							},
							onFailure: function(response) {
								console.error('SA: failed to get TRC session info.');
								that.engine.showError("failed to get TRC session info.", "failed to get TRC session info.");
							},
							onTimeout: function(response) {
								console.error('SA: Timeout on getting TRC session info');
								that.engine.showError("Timeout on getting TRC session info.", "Timeout on getting TRC session info.");
							},
							onCancel: function(response) {
								console.error('SA: GET TRC session info was canceled');
								that.engine.showError("GET TRC session info was canceled.", "GET TRC session info was canceled.");
							}
						});
						
						
					}else{
						//widget.setValue('engine_active', 'false');
						//alert(jQuery(response).find('ErrorMessage').first().text());
						console.error('SemanticAssistant: No connection to web service could be established.');
						that.engine.showError(saNLS.get('SA_title_connectionFailed'), saNLS.get('SA_info_connectionFailed'));
						that.successfulConnection = false;
						//that.engine.onConnectionFailed(jQuery(response).find('ErrorMessage').first().text());
						//that.call('InitProject_EndPoint', par, that.callbacks.onInitProjectSuccess, that.callbacks.onFailure);	
					}   
				})();
	       		
			},
			
			onDisconnectSuccess: function(response) {
				console.log('SA: Session disconnected.');
			},
			
			onFailure: function(response) {
				console.error(jQuery(response).find('ErrorMessage').first().text());
			},
			
			onConnectFailed: function(msg) {
				
				var msg = UWA.is(msg) ? that.engine.onConnectionFailed(msg) : that.engine.onConnectionFailed();
				console.log(msg);
				//widget.setValue('engine_active', 'false');		
				
			},
			
			onInitProjectSuccess: function(response) {
				
				var par = {
							sessionId : that.sessionId, 
							blockCode : '000000x2',
							blockName : that.engine.globals.reqSpec,
							blockLocation : '',
							blockDescription : '',
							blockUrl : '',
						}
				console.log('onInitProjectSuccess called');
				that.call('InitBlock', par, that.callbacks.onInitBlockSuccess, that.callbacks.onConnectFailed);
			},
			onInitBlockSuccess: function(response)
			{
				var t = that.t;
				
				var par = {
							sessionId : that.sessionId, 
							absoluteNumber : 1,
							header : '',
							description : '',
							url : '',
							authorName : that.user,
							userName : that.user,
							lastModificationUser : '',
							level : 0,
							code : '',
							versionCount : 1,
							numOleObjects : 1,
							moduleVolatilityCount : 1,
							authorEmailAddress : '',
							attrs : null
				}
				
				console.log('onInitBlockSuccess called');
				that.call('InitRequirement', par, that.callbacks.onInitRequiremetSuccess, that.callbacks.onConnectFailed);
			},
			onInitRequiremetSuccess: function(response)
			{
				var par = {sessionId : that.sessionId};
				console.log('onInitRequirementSuccess called');
				that.call('HasBlockMetrics', par, that.callbacks.onCheckBlockMetricsSuccess, that.callbacks.onConnectFailed);
			},
			onCheckBlockMetricsSuccess: function(response)
			{
				var result = jQuery(response).find('Result').text();
				var par = {sessionId : that.sessionId};
				
				if(result == 'true'){
					console.log('onCheckBlockMetricsSuccess called with result true');
					that.callbacks.onInitSuccess();
					//api.call('GetPatternGroups', par, api.callbacks.onInitSuccess);
				}else{
					console.log('onCheckBlockMetricsSuccess called with result false');
					that.call('GetMetricsTemplateBlock', par, that.callbacks.onBlockIdSuccess, that.callbacks.onConnectFailed);
				}
			},
			onBlockIdSuccess: function(response)
			{	
				var metricSetId = parseInt(jQuery(response).find('metricTemplateCode').text());
				var baseLineName = jQuery(response).find('metricTemplateName').text();
				
				var par = {
						sessionId : that.sessionId,
						metricsSetId : metricSetId,
						baseLineName: baseLineName
				};
				
				console.log('onBlockIdSuccess called');
				that.call('SetMetricsTemplateBlock', par, that.callbacks.onSetMDefaultMetricsSuccess, that.callbacks.onConnectFailed);
			},
			onSetMDefaultMetricsSuccess: function(response)
			{
				var par = {sessionId : that.sessionId};
				console.log('onSetMDefaultMetricsSuccess called');
				that.callbacks.onInitSuccess();
				//api.call('GetPatternGroups_Endpoint', par, api.callbacks.onInitSuccess);
				
			},
			onInitSuccess: function(response) //return {array}
			{
				var result = null;
				
					// Section concerning pattern groups, not targeted for 19x -> keep for later developments
//		       		(function(){
//		       			
//						result = {
//							AuthoringPatternGroup : new Array()
//						};
//						
//						//Retrieve all the pattern group
//						
//						jQuery(response).find('AuthoringPatternGroup').each(function(){
//							result.AuthoringPatternGroup.push({
//								name : jQuery(this).find('Name').first().text(),
//								code : jQuery(this).find('Code').first().text(),
//								numberPattern : jQuery(this).find('NumberOfSelectablePatterns').first().text()	
//							});
//						});
//						
//					})();
//		       		
//					var select = document.getElementById('patternGroup');
//					
//					//Display all the pattern group on dropdown list 
//					jQuery(result.AuthoringPatternGroup).each(function(index, item){
//						var option = document.createElement('option');
//						option.value = item.name;
//						option.innerHTML = item.name + '(' + item.numberPattern +')';
//						select.appendChild(option);
//					});
//					
//					
//					// "GetPatternsByPatternGroup_Endpoint": to retrieve the pattern of the pattern group selected 
//					jQuery('#patternGroup').change(function(){
//						jQuery( "#patternGroup option:selected" ).each(function(index, item) {
//							if(item.index > 0 && item.index <= result.AuthoringPatternGroup.length){
//								var par = {
//										sessionId : api.sessionId,
//										code : (result.AuthoringPatternGroup)[item.index-1].code
//									};
//									if((result.AuthoringPatternGroup)[item.index-1].numberPattern !== "0"){
//										api.call('GetPatternsByPatternGroup_Endpoint', par, api.callbacks.onGetPatternsByPatternGroupSuccess);
//									}else{
//										jQuery('#pattern')
//											.find('option')
//											.remove()
//											.end()
//											.append('<option value="none">Select a Pattern</option>')
//											.val('none')
//										;
//									}
//							}else{
//								jQuery('#pattern')
//								.find('option')
//								.remove()
//								.end()
//								.append('<option value="none">Select a Pattern</option>')
//								.val('none')
//							;
//							}
//							
//						});
//						
//					});
				console.log('onInitSuccess called');
				
				// call quality check if panel open
				
				that.engine.process();
				
				return result;
			},
//			onGetPatternsByPatternGroupSuccess: function(response){ //return {array}
//				var select = document.getElementById('pattern');
//				jQuery('#pattern')
//					.find('option')
//					.remove()
//					.end()
//					.append('<option value="none">Select a Pattern</option>')
//					.val('none')
//				;
//				(function(){
//					result = {AuthoringPattern: new Array()};
//					jQuery(response).find('AuthoringPattern').each(function(index){
//						if(index !== 0){
//							result.AuthoringPattern.push({
//							name: jQuery(that).find('Name').first().text()
//						});	
//						}
//						
//					});
//				})();
//				jQuery(result.AuthoringPattern).each(function(index, item){
//					var option = document.createElement('option');
//					option.value = item.name;
//					option.innerHTML = item.name ;
//					select.appendChild(option);
//				});
//				return result;
//				
//			},
			calculateQuality: function(current_text){

				var t = that.t;
				var par = {
						sessionId : that.sessionId,
						//headerText : t.header,
						headerText : '',
						descriptionText : current_text											
				};
				
				// For development if server down:
				//that.successfulConnection = true;
			
				if(par.sessionId !== '' && that.successfulConnection === true){
					// dev option if server down
					//that.callbacks.onAuthorTextSuccess(jQuery.parseXML(FakeResponseQualityCheck));
					// real call
					that.call('CalculateQuality', par, that.callbacks.onAuthorTextSuccess, that.callbacks.onConnectFailed);	
				}else{
					// no valid session id -> trigger connection again
					console.log('SA: No valid session ID or successful connection!');
					
					if(that.failedConnections < 10) {
						that.failedConnections++;
						//that.connect(that.user);
					}
				}

			},
			onDisconnectSuccess: function(response)
			{
			    that.sessionId = '';								
			},
			onAuthorTextSuccess: function(response) //return {"string", array}
			{
				var result = {
				            GlobalQualityId: jQuery(response).find('GlobalQualityId').first().text(), 
				            FeaturesByMetric: []	
				};
				
				if (jQuery(response).find('Success').first().text() === 'true') {
					
				    // Pack xml response document into results array		
			        jQuery(response).find('AuthoringMetric').each(function() {
			            result.FeaturesByMetric.push({
			                Quality: jQuery(this).find('Quality').first().text(),
			                QualityLevel: jQuery(this).find('QualityLevel').first().text(),
			                MetricId: jQuery(this).find('MetricPerTypeId').first().text(),
			                MetricName: jQuery(this).find('MetricName').first().text(),
			                AbsoluteValue: jQuery(this).find('AbsoluteValue').first().text(),
			                MetricRtf: jQuery(this).find('MetricRtf').first().text(),
			                Summary: jQuery(this).find('Summary').first().text(),
			                Description: jQuery(this).find('Description').first().text(),
			                UseMetric: jQuery(this).find('UseMetric').first().text(),
			                AffectsOverallQuality: jQuery(this).find('AffectsOverallQuality').first().text(),
			                Weight: jQuery(this).find('Weight').first().text(),
			                FeaturesAsString: jQuery(this).find('FeaturesAsString').first().text()
			            });
			        });
				    
				    // set global quality to be displayed in SemanticAssistant and display results in table
			        that.engine.globals.trcClass = result.GlobalQualityId;					
					that.engine.fillMetricsOnError(result.FeaturesByMetric);
					
				} else {
					// set quality to 0, show error
					that.engine.globals.trcClass = result.GlobalQualityId;
					that.engine.showError(saNLS.get('SA_title_unexpectedResponse'), saNLS.get('SA_info_unexpectedResponse'));
				}
			}
		}
	   	
	});
	
		return SemanticModel;
});
