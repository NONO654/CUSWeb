
var SnN = {
			FROM_SNN : false,
			FRAME_TO_BE_REFRESHED : null,
			is3DSearchActive : false,
			selected_Objects_search : function _selected_Objects_search (url, parameters){
				var that = this;
				that.is3DSearchActive=false;
				if(!getTopWindow().getWindowOpener()){
			   that.FROM_SNN = true;
				}else{
					that.POPUP_SNN = true;

				}
			   
			   var submitForm = document.createElement('form');
			   submitForm.method = "POST";
				var urlParams = new Query(url);
				var submitURL = "";
				var parentOID = "";
				var relId = "";
				var rowId = "";
				var hasTableRowId = false;
				var isRDF=false;
				var serviceURL = "../resources/bps/PhyIdToObjId/phyIds";
				urlParams.items.forEach(function(urlParamItems){
					var input1   = document.createElement('input');
					input1.type  = "hidden";
					input1.name  = urlParamItems.name;
					input1.value = urlParamItems.value;
					if(urlParamItems.name === "submitURL"){
						if(urlParamItems.value.contains("?")){
							var submitURLParams = new Query(urlParamItems.value);
							submitURLParams.items.forEach(function(submitURLParamItems){
								var submitURLInput   = document.createElement('input');
								submitURLInput.type  = "hidden";
								submitURLInput.name  = submitURLParamItems.name;
								submitURLInput.value = submitURLParamItems.value;
								submitForm.appendChild(submitURLInput);
							});
						}
						submitURL = urlParamItems.value;
					}
					if(urlParamItems.name == "rdfQuery"){
						isRDF = true;
						serviceURL = "../resources/bps/uuids";
					}
					if(urlParamItems.name === "objectId" && parentOID === ""){
						parentOID = urlParamItems.value;
					}
					if(urlParamItems.name !== "emxTableRowId"){
						submitForm.appendChild(input1);
					}else{
						var ids = urlParamItems.value.split("|");
						parentOID = ids[1];
						hasTableRowId=true;
					}
				});
				if(hasTableRowId){
					for(var i=0; i<submitForm.length; i++){
						if(submitForm[i].name === "objectId"){
							submitForm[i].value=parentOID;
						}
					}
				}
				var phyIds = new Array();
				parameters.forEach(function(selectedObject){
					phyIds.push(selectedObject.id);
				});	
					jQuery.ajax({
						   url: serviceURL,
						   dataType: 'json',
						   async:false,
						   contentType:'application/json; charset=utf-8',
						   data:JSON.stringify({phyIds : phyIds}),
						   method:'POST',
						   success: function (data){
								data.ObjIds.forEach(function(selectedObjId){
									var selectedObjectDetails = relId + "|" + selectedObjId + "|" + parentOID + "|" + rowId;
					var input2 = document.createElement('input');
					input2.type = "hidden";
					input2.name = "emxTableRowId";
					input2.value = selectedObjectDetails;
					submitForm.appendChild(input2);
				});
				if(that.FROM_SNN){
				submitForm.target = "hiddenFrame";
								}
								else{
					jQuery("<iframe name='submitFrame' id='submitFrame'></iframe>").appendTo(document.body);
					submitForm.target = "submitFrame";
				}
				submitForm.action=submitURL;
				addSecureToken(submitForm);
				document.body.appendChild(submitForm);
				submitForm.submit();
				removeSecureToken(submitForm);
		}
				     });
		},
		selected_global_action : function (url, parameters){
			var sHelpMarker;
			var helpSuiteDir;
			var langStr;
			var langOnlineStr;
			var suiteKey;
			var suiteDirParam;
			var urlParams = new Query(url);
			urlParams.items.forEach(function(urlParamItems){
				if(urlParamItems.name.toUpperCase() === "HELPMARKER"){
					sHelpMarker = urlParamItems.value;
				}
				if(urlParamItems.name.toUpperCase() === "SUITEKEY"){
					suiteKey = urlParamItems.value;
				}
				if(urlParamItems.name.toUpperCase() === "SUITEDIR"){
					suiteDirParam = urlParamItems.value;
				}
			});
			if(sHelpMarker == null || sHelpMarker.length == 0){
				sHelpMarker = "emxhelpfullsearch";
			}
			var suiteDir = "";
			if ((suiteKey != null) && (suiteKey.trim().length > 0))
			{
				
				jQuery.ajax({
					   url: '../resources/bps/SuiteInfo/suiteDir',
					   dataType: 'json',
					   async:false,
					   contentType:'application/json; charset=utf-8',
					   data:JSON.stringify({suiteKey : suiteKey}),
					   method:'POST',
					   success: function (data){
						   suiteDir = data.suiteDir;
					   }
				});
			}
			if (suiteDir == null || "" == suiteDir)
			{
			    suiteDir = suiteDirParam;
			}
			helpSuiteDir = suiteDir;
			if (helpSuiteDir == null || "" == helpSuiteDir)
			{
			    helpSuiteDir = "common";
			}
			openHelp(sHelpMarker,helpSuiteDir,emxUIConstants.STR_HELP_LANGUAGE,emxUIConstants.STR_HELP_ONLINE_LANGUAGE,'',suiteKey);
		},
		loadSnN : function _loadSnN(refinementToSnN, url){
			var searchcom_socket;
			var socket_id = UWA.Utils.getUUID();
			var that = this;
			that.is3DSearchActive=true;
				if (!UWA.is(searchcom_socket)) {
					require(['DS/SNInfraUX/SearchCom'], function(SearchCom) {
						searchcom_socket = SearchCom.createSocket({
							socket_id: socket_id
						});
			var refinementToSnNJSON = JSON.parse(refinementToSnN);
						refinementToSnNJSON.app_socket_id = socket_id;
						refinementToSnNJSON.widget_id = socket_id;
						refinementToSnNJSON.global_actions = [{"id":"incontextHelp","title":emxUIConstants.SEARCH_HELP,"icon":"fonticon fonticon-help","overflow":false}];
						if (UWA.is(searchcom_socket)) {
							searchcom_socket.dispatchEvent('RegisterContext', refinementToSnNJSON);
							searchcom_socket.addListener('Selected_Objects_search', that.selected_Objects_search.bind(that, url));
							searchcom_socket.addListener('Selected_global_action', that.selected_global_action.bind(that, url));
		        // Dispatch the in context search event
							searchcom_socket.dispatchEvent('InContextSearch', refinementToSnNJSON);

			if((getTopWindow().location.href.indexOf("targetLocation=popup")!= -1) && refinementToSnNJSON.title){
							getTopWindow().document.title = refinementToSnNJSON.title + emxUIConstants.SEARCH_WINDOW_TITLE_SEPERATOR + emxUIConstants.SEARCH_TITLE ;
							}
		    } else {
		        throw new Error('Socket not initialized');
		    }
					});
					
					
		            
		        }
			}
};
