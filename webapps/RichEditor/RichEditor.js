/* global jQuery */
/* global widget */
//TODO: fix x3dPlatformId pref name
define('DS/RichEditor/RichEditor', [
        'UWA/Core',
        'UWA/Controls/Abstract',
        'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
        'DS/WAFData/WAFData',
        'DS/RichEditor/MSFConnector',
        'i18n!DS/RichEditor/assets/nls/RichEditor.json'
    ],
    function(UWA,
        Abstract,
        i3DXCompassPlatformServices,
        WAFData,
        MSFObject,
        RichEditorNLS) {

        'use strict';
        
        if(localStorage['debug.AMD']) {
        	console.info("AMD: RichEditor/RichEditor.js dependency loaded.");
        }
        var languages = ['de', 'es', 'fr', 'it', 'ja', 'zh'];
        var userLang = window.navigator.languages || window.navigator.language.split(','); 
        userLang = userLang[0].substring(0, 2);
        if(languages.indexOf(userLang) < 0) {
        	userLang = ''
        }
        
		var baseURL; 
		if(window.widget){
			widget.addEvent('onLoad', function(){
				var platformId = widget.getValue("req_tenant"); //x3dPlatformId
	    		i3DXCompassPlatformServices.getServiceUrl({
	    			serviceName: '3DSpace',
		    		platformId : platformId ? platformId.value : undefined, 
	        		onComplete: function(data) { //this call is async!!
	        			baseURL = UWA.is(data, 'string') ? data : data[0].url;
	        			getPreferredEditor(false, function(pref){
	        				if(pref == "Word" && !isMobile()){
	                			var dashboardURL = window.location.protocol+"//"+ window.location.host+"/" + window.location.pathname.split( '/' )[1];
	                			MSFObject.onConnectWithMSF(MSFObject.generateNewGuid(), "", baseURL, platformId ? platformId.value : undefined, '', '', '', dashboardURL);
	        				}
	        			});
	        			if(preferredEditor == "Word" && !isMobile()){ //pref already cached
	            			var dashboardURL = window.location.protocol+"//"+ window.location.host+"/" + window.location.pathname.split( '/' )[1];
	            			MSFObject.onConnectWithMSF(MSFObject.generateNewGuid(), "", baseURL, platformId ? platformId.value : undefined, '', '', '', dashboardURL);
	    				}
	        		}
	        	});
			});
		}
		else{
			baseURL = window.location.protocol+"//"+ window.location.host+"/" + window.location.pathname.split( '/' )[1];
			getPreferredEditor(false);
		}
		
		//IR-479552: launch raw link to new tab
		var linkSelector = ".richTextContainer a";
		if(window.widget) {
			linkSelector = ".rich-object-content a";
		}
		if(window.jQuery) {
			jQuery(function(){
				jQuery(document).on("click", linkSelector, function(e){ 
					if( this.href && !this.href.toLowerCase().startsWith("javascript:") && this.innerText && !this.target) {
						var parts1 = this.innerText.split( '/' );
						var parts2 = this.href.split( '/' );
						
						if(parts1.length >= 3 && parts2.length >= 3 && parts1[0].toLowerCase() == parts2[0].toLowerCase() && parts1[2].toLowerCase() == parts2[2].toLowerCase()) {
							window.open(this.href);
							return false;
						}
					}
				});
			});
		}

		var webSocketURL = "wss://msf.3ds.com:2014/WordAction"; 
		var hiddenFrame = 'listHidden';
		//jQuery

        function getSecurityContext() {
    		
    		var value = widget.getValue('trm_security_ctx');
    		
    		if(!UWA.is(value) || value === "") {
    			// maybe pad_security_ctx ?
    			value = widget.getValue('pad_security_ctx');
    			
    			if(value === "") {
    				return undefined;
    			}
    			
    		}
    		
    		if(UWA.is(value,"string") && value.indexOf('ctx::') === -1) {
    			
    			value = 'ctx::' + value;
    		}
    		
    		return value;

    	}

        function appendSecurityContext(url) {
        	var context = getSecurityContext();
        	if(url.indexOf('?') >= 0) {
        		url += "&SecurityContext=" + context;
        	}
        	else{
        		url += "?SecurityContext=" + context;
        	}
        	return url;
        }
		function restService(method, url, type, successHandler, errorHandler, data, sync){
			url = baseURL + url;
			if(window.widget) {
				url = appendSecurityContext(url);
			}
			
			WAFData.authenticatedRequest(url, {
				method: method,
				headers: {
						'Accept': 'application/'  + type,
						'Content-Type': 'application/json'
				},
				data: data,
				cache: false,
				onComplete: successHandler,
				onFailure: errorHandler,
				responseType: 'text',
				async:!sync
			});
		}

		var wordLaunchAttempted = false;
		var wordLaunchAttempting = false;
		var webSocketAttempts = 0;
		var webSocketConnected = false;
		var WordSocket = null;
		var preferredEditor = null;
		var csrfToken = null;
		
		function initSocket(objectId, closeWordWindowHandler, isNew, ooxml, type){
				if (++webSocketAttempts > 7) { 
					console.log("user may have cancelled word launching dialog");
					WordSocket = null;
					webSocketAttempts = 0;
					wordLaunchAttempted = false;
					wordLaunchAttempting = false;
					return;
				}
				WordSocket = new WebSocket(webSocketURL);
				WordSocket.onerror = function (error) {
					if(webSocketConnected) { //Word closed by end user
						return;
					}
					//console.log("error: " + error);
					WordSocket = null;
					if(!wordLaunchAttempted){
						wordLaunchAttempted = true;
						wordLaunchAttempting = true;
						//what if user cancels this dialog??
						var wordLauncherURL = 'ms-word:ofe|u|' + baseURL + '/webapps/RichEditor/assets/__WordLauncher__' + userLang + '.docx';
						if(window.widget){
							jQuery('<iframe width="0%" height="0%" name="hiddenFrame"></iframe>').appendTo(document.body);
							hiddenFrame = "hiddenFrame";
						}
						window.open(wordLauncherURL, hiddenFrame);
					}
					setTimeout(function(){
						initSocket(objectId, closeWordWindowHandler, isNew, ooxml, type);
					}, 5); //100
				};
				WordSocket.onmessage = function (evt) {
					var data = JSON.parse(evt.data);
					//console.log("message received: ");
					//console.log(data.ooxml);
					//console.log("text received: ");
					//console.log(data.text);
					if(data.action == "modify"){
						var thisObjectId = data.objectId? data.objectId : "";
						if(!window.widget && window.turnOnProgress) {
							turnOnProgress();
						} 
						if(window.emxEditableTable) {
							getTopWindow().jQuery("div#layerOverlay").css('display', 'block');
							getTopWindow().jQuery("div#layerOverlay").css('top',0);
						}
						restService("POST", 
							"/resources/richeditor/res/htmlpreview", 
							"json", 
							function( html ) {
								html = UWA.is(html, 'string') ? JSON.parse(html) : html;
								if(!window.widget && window.turnOffProgress) {
									turnOffProgress();
								}
								if(window.emxEditableTable) {
									getTopWindow().jQuery("div.content-mask").css('display', 'none');
								}
								//console.log("html:");
								//console.log(html.html);
								closeWordWindowHandler(thisObjectId, data.ooxml, html.html);
							}, 
							function(message) {
								//session timeout?
								console.log(message);
							},
							evt.data
						);
					}
					else if(data.action == "error"){
						alert(data.message);
					}
				};

				// when the connection is established, this method is called
				WordSocket.onopen = function () {
					wordLaunchAttempting = false;
					webSocketConnected = true;
					//console.log("socket opened");
					openWord(objectId, isNew, ooxml, type);
			   };

				// when the connection is closed, this method is called
				WordSocket.onclose = function () {
					WordSocket = null;
					webSocketAttempts = 0;
					webSocketConnected = false;
					if(!wordLaunchAttempting) {
						wordLaunchAttempted = false;
					}
					//console.log("socket closed");
				}
		}
		function openWord(objectId, isNew, ooxml, type) {
			if(isNew || ooxml){
				var data = {};
				data.action = "open";
				data.cookie = document.cookie;
				data.objectId = objectId;
				data.isNew = isNew;
				data.ooxml = ooxml;
				data.type = type;
				WordSocket.send(JSON.stringify(data));
			}
			else{
				restService("GET", "/resources/richeditor/res/DownloadContent/" + objectId, "json", function( data ) {
					data = UWA.is(data, 'string') ? JSON.parse(data) : data;
					csrfToken = data.csrf;
					delete data.csrf; //otherwise breaks C# code
					if(!data.cookie) {
						data.cookie = document.cookie;
					}
					data.objectId = objectId;
					data.action = "open";
					if(!data.URL) {
						data.URL = baseURL + "/resources/richeditor/res/DownloadAttribute/" + objectId;
					}
					WordSocket.send(JSON.stringify(data));
				}, function(message) {
					//session timeout?
					console.log(message);
				});
				
			}
		}
		
		function openObjectContentDataInWord (objectId, closeWordWindowHandler, isNew, ooxml, type){
			
			if(typeof arguments[0] == "object"){
				var params = arguments[0];
				objectId = params.uid;
				closeWordWindowHandler = params.onClose;
				isNew = params.isNew;
				ooxml = params.ooxml;
				type = params.type;
			}
				if(WordSocket != null /* && status is open */) {
					openWord(objectId, isNew, ooxml, type);
				}
				else{
					initSocket(objectId, closeWordWindowHandler, isNew, ooxml, type);
				}
		}
		
		function getPreferredEditor(sync, callBack) {
			if(preferredEditor == null){
				preferredEditor = sessionStorage.getItem("PLCPreferredRichEditor");
				if(preferredEditor == null) {
					restService("GET", "/resources/richeditor/res/preferredEditor/", "json", function( data ) {
						data = UWA.is(data, 'string') ? JSON.parse(data) : data;
						preferredEditor = data.result;
						sessionStorage.setItem("PLCPreferredRichEditor", preferredEditor);
						if(callBack){
							callBack(preferredEditor);
						}
					}, function(message) {
						//session timeout?
						console.log(message);
					},
					null,
					sync);
				}
			}
			
			return preferredEditor;
		}
		
		function getPreferredEditorSync() {
			try{
				return getPreferredEditor(true); //fail in Firefox if it's sync call.
			}catch(e){ }
			return "HTML";
		}
		
		function isMobile() {
			return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
		}
		var RichEditor = Abstract.extend({
			openObjectContentDataInWord : openObjectContentDataInWord,
			
			openRichTextInWord: openObjectContentDataInWord,
			
			getPreferredEditor : getPreferredEditorSync,
			
			saveRichText : function(id, ooxml){
				if(typeof arguments[0] == "object"){
					var params = arguments[0];
					id = params.objectId;
					ooxml = params.ooxml;
				}
				var data = {};
				data.id = id;
				data.ooxml = ooxml;
				if(csrfToken) {
					data.csrf = csrfToken;
				}
				restService("POST", "/resources/richeditor/res/saveRichText", "json", function( result ) {
					//notify result
				}, function(message) {
					//session timeout?
					console.log(message);
				},
					JSON.stringify(data)
				);
				
				this.cleanup(id);
			},
			cleanup : function (objectId) {
				var data = {};
				data.action = "cleanup";
				data.objectId = objectId;
				WordSocket.send(JSON.stringify(data));
			},
			nls : RichEditorNLS,
			isMobile : isMobile,
			
			RICH_TEXT_STREAM_CONST : {
				READ_ONLY : 1,
				READY_FOR_EDITING : 2,
				HTML_EDITABLE : 4,
				RCO_CONVERSION_NEEDED : 8
			}
		});

        return RichEditor;

    });

if(localStorage['debug.AMD']) {
	console.info("AMD: RichEditor/RichEditor.js finish.");
}
