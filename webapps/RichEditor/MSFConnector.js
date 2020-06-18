define('DS/RichEditor/MSFConnector', 
		['DS/PlatformAPI/PlatformAPI', 'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'], 
function(PlatformAPI, i3DXCompassPlatformServices) {
	//var myTop;
	//var msfLocalCacheCollection = {};
	var MSFObject = {
		myTop : undefined,
		//msfLocalCacheCollection : {},
		isConnectedWithMSF : function() {
			if(true /*emxUIConstants.USEMSF == "true" */) {
				this.getTop();
				if(this.myTop.window.MSFSocket != null && this.myTop.window.MSFSocket.readyState == 1)
					return true;
			}				
			return false;
		},
		
		onConnectWithMSF : function(msfClientId, curUserId, serverUrl, curTenant, passportURL, proxyTicketURL, myAppsURL, dashboardURL) {		
			if(window.widget) {
				curUserId = PlatformAPI.getUser().login;
				proxyTicketURL = dashboardURL + '/api/passport/ticket?url=V6';
				myAppsURL = dashboardURL + '/resources/AppsMngt/';
			}
			if(( true /*emxUIConstants.USEMSF == "true" */) && (!this.isConnectedWithMSF())) {
				if(!sessionStorage.MSFUrl) {
					var that = this;
					i3DXCompassPlatformServices.getServiceUrl({
						serviceName: '3DPassport',
						platformId : curTenant, 
						onComplete: function(data) { 
							passportURL = UWA.is(data, 'string') ? data : data[0].url;

							if(passportURL && passportURL!="") {
								if(passportURL.slice(-1) == '/') {
									passportURL = passportURL.slice(0, -1);
								}
								require(['DS/i3DXCompass/Data'], function(CompassData){
									CompassData.initialize( {
										userId:curUserId,
										passportUrl:passportURL,
										proxyTicketUrl:proxyTicketURL+ (window.widget ? "&t=" : "?t="),
										myAppsBaseUrl:myAppsURL
									});
									CompassData.getCasTgc({ 
										onComplete: function (tgc) { 
											if(tgc)
												that.connectWithMSF('{"ClientId": "' 
													+ msfClientId 
													+ '", "UserName": "' 
													+ curUserId 
													+ '", "ServerUrl": "' 
													+ serverUrl 
													+ '", "TenantId": "' 
													+ curTenant 
													+ '", "CASTGC": "CASTGC=' 
													+ tgc 
													+ '"}');
											else
												that.connectWithMSF('{"ClientId": "' 
													+ msfClientId 
													+ '", "UserName": "' 
													+ curUserId 
													+ '", "ServerUrl": "' 
													+ serverUrl 
													+ '", "TenantId": "' 
													+ curTenant 
													+ '"}');
										}
									});
								});
							}
							else {
								that.connectWithMSF('{"ClientId": "' 
									+ msfClientId 
									+ '", "UserName": "' 
									+ curUserId 
									+ '", "ServerUrl": "' 
									+ serverUrl 
									+ '", "TenantId": "' 
									+ curTenant 
									+ '"}');
							}
						}
					});
					
				}
				else {
					this.connectWithMSF();
				}
			}
		},
		
		generateNewGuid : function() {
			var d = new Date();
			var uniqueId = Math.random() + 
				"." + 
				d.getFullYear() + 
				"." + 
				d.getMonth() + 
				"." + 
				d.getDate() + 
				"." + 
				d.getHours() + 
				"." + 
				d.getSeconds() + 
				"." + 
				d.getMilliseconds();
			return uniqueId;
		},
		
		connectWithMSF : function(msfConnectionValues) {
			this.getTop();
			if(msfConnectionValues) {
				var msfConnectionValuesString = decodeURIComponent(msfConnectionValues);
				msfConnectionValues = JSON.parse(msfConnectionValues);
				sessionStorage.MSFUrl = "wss://msf.3ds.com:2012/MSFServiceSocket?MSFClientInfo=" + msfConnectionValuesString;
				sessionStorage.ClientId = msfConnectionValues.ClientId;
			}
			this.initSocket();
		},
		
		getTop : function() {	
			this.myTop = window;
		},
		
		initSocket : function() {
			var object = this;
			window.MSFSocket = new WebSocket(sessionStorage.MSFUrl);
			window.MSFSocket.onerror = function (error) {
			};
			//when the connection is established, this method is called
			window.MSFSocket.onopen = function () {
			};
			window.MSFSocket.onmessage = function (evt) {
				var responseData = JSON.parse(evt.data);
				object.getMSFResponse(responseData);
			};
			// when the connection is closed, this method is called
			window.MSFSocket.onclose = function () {
				object.getTop();
				if(event.code != 1006 && event.code != 1000) {
					window.MSFSocket = new WebSocket(sessionStorage.MSFUrl);
				}
				//else
				//	object.updateMSFConnectionStatus(false);
			}
		},
		
		getMSFResponse : function(msfRequestResponse) {
		}
	}
	return MSFObject;
}
);
