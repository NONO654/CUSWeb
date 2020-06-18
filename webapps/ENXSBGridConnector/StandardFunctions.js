define('DS/ENXSBGridConnector/StandardFunctions',
		['UWA/Core',
		 'emxUICore',
		 'emxUIModal',
		 'emxUIConstants',
		 'emxUITableUtil',
		 'DS/WAFData/WAFData',
		 'DS/Windows/ImmersiveFrame',
		 'DS/ENXDataGrid/URLUtils',
		 'DS/ENXDataGrid/ENXSBGridPerformanceLogs',
		 'DS/ENOFrameworkPlugins/jQuery',
		 'DS/Tree/TreeNodeModel',
		 'DS/Utilities/Utils',
		 'DS/etree/syncwidget',
		 'DS/Notifications/NotificationsManagerViewOnScreen',
		 'i18n!DS/ENXDataGrid/assets/nls/message'
		 ],
		function(UWA,
				 emxUICore,
				 emxUIModal,
				 emxUIConstants,
				 emxUITableUtil,
				 WAFData,
				 WUXImmersiveFrame,
				 URLUtils,
				 ENXSBGridPerformanceLogs,
				 jQuery,
				 TreeNodeModel,
				 Utils,
				 graphWidget,
				 NotificationsManagerViewOnScreen,
				 nlsMessageJSON
				 ) {

	"use strict";

	var StandardFunctions = {

		structChangesMap: {
			cut: new Array(),
			copy: new Array(),
			paste: new Array(),
			undo: new Array(), //undo array will have arrays of objects with modified rows details
			latestOperation: 'paste',
			lookupEntries: new Array()
		},

		frameWindowReference: undefined,

		setFrameReference: function(fRef) {
			StandardFunctions.frameWindowReference = fRef;
		},

		getDataGridModel: function() {
			if(typeof StandardFunctions.frameWindowReference != 'undefined' && StandardFunctions.frameWindowReference != null && StandardFunctions.frameWindowReference != '') {
				return StandardFunctions.frameWindowReference.dataGridModel;
			} else {
				return window.dataGridModel;
			}
		},

		openNewWindow: function(args) {
			var modal = args.modal || "false";
			var target  = args.target || "_self";
			var height = args.height || "650";
			var width = args.width || "930";

			if(args.target == "popup") {
				if(modal == "true") {
					showModalDialog(args.href, width, height);
				} else {
					showNonModalDialog(args.href, width, height);
				}
			} else {
				window.open(args.href, target, "width=" + width + ", height=" + height);
			}
		},

		addBasicParamsToURL: function(url) {
			var currentParamsMap = URLUtils.getParametersMap();

			var objectId = currentParamsMap['objectId'];
			if(StandardFunctions.isNotNullAndNotEmpty(objectId)) {
				url += '&objectId=' + objectId;
			}

			var relId = currentParamsMap['relId'];
			if(StandardFunctions.isNotNullAndNotEmpty(relId)) {
				url += '&relId=' + relId;
			}

			var parentOID = currentParamsMap['parentOID'];
			if(StandardFunctions.isNotNullAndNotEmpty(parentOID)) {
				url += '&parentOID=' + parentOID;
			}

			return url;
		},

		executeListHiddenAction: function(args) {
			var objFrame = findFrame(window,'listHidden');
			var URLUtilshref=URLUtils.getQueryString();
			URLUtilshref=URLUtilshref.replace('SuiteDirectory','SuiteDirectoryFromURLUtils');
			URLUtilshref=URLUtilshref.replace('suiteKey','suiteKeyFromURLUtils');
			var customHref = args.href + "&" +URLUtilshref+"&uiType=structureBrowser";
			submitWithCSRF(customHref,objFrame);
			emxUICore.addToPageHistory(args.listHiddenString);
		},

		executeSlideinAction: function(args) {
			var openerFrame = window.name;
			if(args.slideinWidth)
				getTopWindow().showSlideInDialog(args.href, args.isModal, openerFrame,"right",args.slideinWidth);
			getTopWindow().showSlideInDialog(args.href, args.isModal, openerFrame);
		},

		executeSlideinSubmitAction: function(args) {
			var openerFrame = window.name;
			var emxTableRowId = StandardFunctions.getEmxTableRowId(args);
			var customHref = args.href;
			if (args.targetPath) {
				customHref = customHref + "&emxTableRowId=" + encodeURI(args.targetPath);
			}
			if(args.slideinWidth)
				getTopWindow().showSlideInDialog(customHref, args.isModal, openerFrame,"right",args.slideinWidth);
			getTopWindow().showSlideInDialog(customHref, args.isModal, openerFrame);
		},

		executePopupAction: function(args) {
			if(args.href.contains("../../")){
				args.href=args.href.replace("../",'');
			}
			var width = 600, height = 600;
			var href = StandardFunctions.addBasicParamsToURL(args.href);
			var modal = args.isModal;
			if(modal === 'true')
				window.showModalDialog(href, "Modal Dialog", 'dialogWidth=' + width + ',dialogHeight='+ height);
			else
				//window.open(href,"Popup",'width=' + width + ',height='+ height);
				window.showNonModalDialog(href, 'Popup', 'dialogWidth=' + width + ',dialogHeight='+ height);
		},

		createTableRowIdInputs: function(emxTableRowIds, submitForm) {
			for(var idIndex = 0; idIndex < emxTableRowIds.length; idIndex++) {
				var element = document.createElement('input');
				element.setAttribute("type","hidden");
				element.setAttribute("name","emxTableRowId");
				element.setAttribute("value",emxTableRowIds[idIndex]);

				submitForm.appendChild(element);
			}
		},

		getInputValuesFromToolbar: function(href){
			//var toolbarRef = StandardFunctions.getToolbarReference();
			var inputsUrl = href;
			toolbarInputControlsIds.forEach(function(id) {
				var nodeModel = StandardFunctions.getToolbarReference().getNodeModelByID(id);
				var typeRep = dgView.getTypeRepresentationFactory().getRegisteredTypeRepresentation(nodeModel.options.grid.typeRep);
				var possibleValues = JSON.parse(typeRep.dataelements.semantics).possibleValues;
				var actualValue = "";
				/*TODO
				 * This is a work-around to get the actual value. Check with Techno to get the actual value from the node model
				 */
				if(nodeModel.options.grid.data != undefined){
					possibleValues.forEach(function(element) {
	                    if (element.value === nodeModel.options.grid.data) {
	                    	actualValue = element.actualValue;
	                    }
	                  });
				}

				inputsUrl += "&" + id + "=" + actualValue + "";

			});

			return inputsUrl;
		},

		executePopupSubmitAction: function(args) {
			args.href = StandardFunctions.getInputValuesFromToolbar(args.href);
			if(args.href.indexOf('emxFullSearch.jsp') > -1) {
				var modal = args.isModal;
				/*var href = StandardFunctions.addBasicParamsToURL(args.href);
				var submitHref = "../common/emxAEFSubmitPopupAction.jsp?frameName="+window.name+ "&url="+escape(args.href + "&" + URLUtils.getQueryString());*/
				if(modal === 'true') {
					window.showModalDialog(args.href, width, height, "true", "");
				} else {
					window.showNonModalDialog(args.href, 'Popup', 'dialogWidth=' + width + ',dialogHeight='+ height);
				}
			} else {
				var width = 812, height = 500;
				if(args.href.contains("../../")){
					args.href=args.href.replace("../",'');
				}
				args.href += URLUtils.getQueryString();

				var submitForm    = document.createElement('form');
				submitForm.name   = "emxSubmitForm";
				submitForm.id     = "emxSubmitForm";
				submitForm.setAttribute("method", "post");
				submitForm.setAttribute("action", args.href);
				submitForm.setAttribute("target", "Modal Dialog");

				StandardFunctions.createTableRowIdInputs(StandardFunctions.getEmxTableRowId(args), submitForm);

				document.body.appendChild(submitForm);
				window.open("","Modal Dialog",'width=' + width + ',height='+ height);
				submitForm.submit();

	            document.body.removeChild(submitForm);
			}
		},

		getEmxTableRowId: function(args) {
			var nodes;
			if(args instanceof Array){
				nodes = args;
			} else {
				nodes = StandardFunctions._privateGetSelectedNodes();
			}
			var strData="", sLevelIds="",emxTableRowId=[];
			for(var i=0; i<nodes.length;i++){
				var rowData = nodes[i].options.grid;
				var objectId = rowData.id;
				var parentId = StandardFunctions.getParentId(nodes[i]);

				var relId = (rowData.relId!=undefined)? rowData.relId : "";
				var rowId = (rowData.rowId!=undefined)? rowData.rowId : "0,"+nodes[i]._rowID;
				if(nodes.length>0){
					emxTableRowId.push(relId + "|" + objectId + "|" + parentId + "|" + rowId);
				}
				else{

				}
			}
			return emxTableRowId;
		},

		getParentId: function(node){
			var parentId = URLUtils.getParameter("parentOID");
			parentId = (parentId!=undefined && node.options.grid.rowId!=0)? parentId : "";
			if(parentId == ""){
				parentId = (typeof node.getParent().options.grid.id != "undefined") ? node.getParent().options.grid.id : "";
			}
			return parentId;
		},

		executeListHiddenSubmitAction: function(args) {
			args.href = StandardFunctions.getInputValuesFromToolbar(args.href);
			if (!args.href.endsWith("?")) {
				args.href = args.href + "?";
			}
			var URLUtilshref=URLUtils.getQueryString();
			URLUtilshref=URLUtilshref.replace('SuiteDirectory','SuiteDirectoryFromURLUtils');
			URLUtilshref=URLUtilshref.replace('suiteKey','suiteKeyFromURLUtils');
			var customHref = args.href + "&" +URLUtilshref+"&uiType=structureBrowser";
			var submitForm    = document.createElement('form');
			submitForm.name   = "emxSubmitForm";
			submitForm.id     = "emxSubmitForm";
			submitForm.setAttribute("method", "post");
			submitForm.setAttribute("action", customHref);
			submitForm.setAttribute("target", "listHidden");
			if(args.confirmMessage!=null && args.confirmMessage!="undefined" && args.confirmMessage!="null" && args.confirmMessage!=""){
				var bResponse=window.confirm(args.confirmMessage);
				if(!bResponse){
					return;
				}
			}

			StandardFunctions.createTableRowIdInputs(StandardFunctions.getEmxTableRowId(args), submitForm);
			document.body.appendChild(submitForm);

			addSecureToken(submitForm);
		    submitForm.submit();
		    removeSecureToken(submitForm);

			var nodes = StandardFunctions._privateGetNodesBase(true);
		    for(var i=0; i<nodes.length;i++){
		    	nodes[i].updateOptions();
		    }
		},

		executeJSAction: function(args) {
			require(['DS/ENXSBGridConnector/ENXSBGridConnector',], function(ENXSBGridConnector) {
				if(typeof args.href == 'undefined' && typeof args.parameters != 'undefined') {
					args = args.parameters;
				}

				if(args.href.indexOf("javascript:") != -1) {
					var executeMethod = args.href.split("javascript:")[1];

					// find object
					var fn = window[executeMethod];
					// is object a function?
					if (typeof fn === "function") {
						fn(args);
					} else {
						if('()' == executeMethod.substring(executeMethod.length - 2)) {
							executeMethod = executeMethod.substring(0, executeMethod.length - 1) + 'args)';
						}

//						if(executeMethod.indexOf("ENXSBGridConnector") >= 0) {
////							var ENXSBGridConnector = new connector({"callGridService":"false"});
//							var executeFunction = executeMethod.split(".")[1].split("(args)")[0];
//							eval(connector.prototype.executeFunction);
//					    	/*var func = ENXSBGridConnector[executeFunction];
//					    	if(typeof func === 'function') {
//					    		func.call(ENXSBGridConnector);
//					    	}*/
//						} else {
							eval(executeMethod);
//						}
					}
				}
			});
		},

		//function to create the request body for the updateJPO
		saveEdits: function(args) {
			var URLQueryString = URLUtils.getQueryString();
			if(URLQueryString.contains("applyURL")){
				var applyURL=URLUtils.getParameter("applyURL");
				applyURL = decodeURIComponent(applyURL);
				if(applyURL.indexOf('javascript:') != -1){
					applyURL=applyURL+"();";
					try{
						eval(applyURL);
					}catch(err){
						console.log("catch......");
						return;
					}

					return;
				}
			}

			/*var collectionView = args.context;
			var localDataGridModel;
			if (typeof collectionView != 'undefined') {
				localDataGridModel = collectionView.getTreeDocument();
			}*/

			var payLoad = new Object();
			var editedArray = new Array();

			for(var i in editMap) {
				var editedObj = {
					id: i,
					dataelements: editMap[i]
				};
				editedArray.push(editedObj);
	    	}
			StandardFunctions.structChangesMap.cut.forEach(function(cutOnlyNode) {
				var editedCutObj = {
					id: cutOnlyNode.options.grid.id,
					relId: cutOnlyNode.options.grid.relId,
					dataelements: JSON.parse(JSON.stringify(cutOnlyNode.options.grid))
				};
				editedArray.push(editedCutObj);
			});

			if(!StandardFunctions.validInlineRows(StandardFunctions.structChangesMap.paste)) {
				return;
			}

			StandardFunctions.structChangesMap.paste.forEach(function(pastedNode) {
				var editedPasteObj = {
					id: pastedNode.options.grid.id,
					relId: pastedNode.options.grid.relId,
					dataelements: JSON.parse(JSON.stringify(pastedNode.options.grid))
				};
				editedArray.push(editedPasteObj);
			});

			payLoad["data"] = editedArray;
			console.log(payLoad);
			StandardFunctions.saveEditsToDB(payLoad);
	    },

	    saveEditsToDB: function(payLoad, onSuccessFunc, onFailureFunc) {
	    	var url = "../../resources/v1/ui/gridview/rowData?" + URLUtils.getQueryString();

	    	var options = {
				method: 'GET',
				onComplete: function(csrf){
					payLoad["csrf"] = JSON.parse(csrf).csrf;
					var saveEditedObjects = {
				    	method: 'PUT',
				    	data: JSON.stringify(payLoad),
				    	onComplete: function(result) {
				    		if(typeof onSuccessFunc == 'function') {
				    			onSuccessFunc.call();
				    		}

				    		result = JSON.parse(result);
				    		result = result.data;
				    		var actions = result[0].dataelements;

				    		var aMsgType = ((actions.action.toLowerCase() == 'stop') || (actions.action.toLowerCase() == 'error')) ? 'error' : 'success';

// TODO
// ***** Below code is commented as a temporary fix for IR-682407-3DEXPERIENCER2019x. ****
// ***** The save functionality has to be properly handled *****

		    				/*if(result.length == 1 && StandardFunctions.structChangesMap.paste.length > 0) {
		    					aMsgType = 'error';
		    				}*/

				    		var sMessage;
				    		if((typeof actions.message != 'undefined' || actions.message != null) && (typeof actions.action != 'undefined')) {
				    			if(aMsgType == 'error') {
				    				alert(sMessage);
				    			}

				    			if(actions.action != "execScript") {
				    				sMessage = actions.message;
		    					} else {
		    						sMessage = (aMsgType == 'success') ? nlsMessageJSON.success : nlsMessageJSON.error;
		    					}
		    				} else {
		    					sMessage = (aMsgType == 'success') ? nlsMessageJSON.success : nlsMessageJSON.error;
		    				}

		    				console.log("request sent to save"+result);
		    				StandardFunctions.showNotification(sMessage, aMsgType);

		    				if(aMsgType === 'success' && (typeof actions.action != 'undefined')) {
		    					var msg = actions.message;
		    					console.log("message: "+msg);
		    					if(msg && msg != null && msg != "" && actions.action == "execScript") {
		    		                   var jsObject = eval('(' + msg + ')');
		    		                   jsObject.main();

//		    						emxEditableTable.refreshStructureWithOutSort();
		    		            }

		    					//clear the map after the response is returned and save is successful
		    					result.remove(result[0]);
		    					result.forEach(function(rowData) {
		    						var rowObjId = rowData.id;
		    						var rowRelId = rowData.relId;
		    						var rowOldRelId = rowData.dataelements.oldRelId;

		    						var tempNode;
		    						if(StandardFunctions.isNullOrEmpty(rowOldRelId)) {
		    							tempNode = StandardFunctions._privGetNodeById(rowObjId)[0];

		    							if(typeof tempNode == 'undefined') {
		    								tempNode = StandardFunctions._privGetNodeByRowId(rowData.dataelements.rowId)[0];
		    							}
		    						} else {
		    							tempNode = StandardFunctions._privGetNodeById(undefined, rowOldRelId)[0];
		    						}

		    						tempNode.options.grid.id = rowObjId;
		    						tempNode.options.grid.relId = rowRelId;

			    					delete tempNode.options.grid.dgvStructChangesOperation;
			    					delete tempNode.options.grid.dgvStructChangesOldRowId;
			    					delete tempNode.options.grid.dgvStructChangesOldParentId;
			    					/*delete tempNode.options.grid.dgvStructChangesOldParentRowId;*/ //as removing dropJPO code
			    					delete tempNode.options.grid.dgvStructChangesNewParentId;
			    					delete tempNode.options.grid.dgvStructChangesNewParentRowId;
			    					delete tempNode.options.grid.dgvStructChangesRelName;
			    					/*delete tempNode.options.grid.dgvDroppedOnRowRelId; //as removing dropJPO code
			    					delete tempNode.options.grid.dgvDraggedFromWindow;
			    					delete tempNode.options.grid.dgvDroppedOnWindow;
			    					delete tempNode.options.grid.dgvDroppedOnColumnName;*/
		    					});

				    			StandardFunctions.structChangesMap.paste = new Array();
				    			StandardFunctions.structChangesMap.cut = new Array();
				    			StandardFunctions.structChangesMap.undo = new Array();
				    			var localDataGridModel = StandardFunctions.getDataGridModel();
								if(typeof localDataGridModel != 'undefined') {
									localDataGridModel.acceptChanges();
								}
				    			editMap={};
				    		}
				    	},
		    			onFailure: function(error, backendresponse, response_hdrs) {
		    				if(typeof onFailureFunc == 'function') {
		    					onFailureFunc.call();
				    		}

		    				backendresponse = JSON.parse(backendresponse);
		    				var errMsg = backendresponse.internalError;
		    				if(StandardFunctions.isNullOrEmpty(errMsg)) {
		    					errMsg = nlsMessageJSON.error;
		    				}

		    				StandardFunctions.showNotification(errMsg, 'error');
			    		}
			    	};

				   	WAFData.authenticatedRequest(url, saveEditedObjects);
				}
			};
			WAFData.authenticatedRequest("../../resources/v1/application/E6WFoundation/CSRF", options);
	    },

	    resetEdits:function(objParam) {
			var  URLQueryString = URLUtils.getQueryString();
			if(URLQueryString.contains("onReset")){
				var onReset=URLUtils.getParameter("onReset");
				onReset= decodeURIComponent(onReset);
				if(onReset.indexOf('javascript:') != -1){
					onReset=onReset+"();";
					try{

						eval(onReset);
					}catch(err){
						console.log("catch......");
						return;
					}

					return;
				}
			}

            var collectionView = objParam.context;
            if (collectionView) {
                var treeDocument = collectionView.getTreeDocument();
                if (treeDocument) {
                    treeDocument.cancelChanges();
                }
            }

            editMap = {};
            StandardFunctions.structChangesMap.cut = new Array();
            StandardFunctions.structChangesMap.copy = new Array();
            StandardFunctions.structChangesMap.paste = new Array();
			StandardFunctions.structChangesMap.undo = new Array();
	    },

		expandNodes: function(args) {
			if(typeof args.methodArgs != 'undefined') {
				expandLevel = Number(args.methodArgs);
				expandLevel = isNaN(expandLevel) ? 0 : expandLevel;
			} else {
				expandLevel = 0;
			}

			if(gridType == 'SINGLE_ROOT_NODE') {
				location.href = URLUtils.changeParamValue("emxExpandFilter", expandLevel);
			} else if(gridType == 'MULTI_ROOT_NODE') {
				var selectedNodeModelRowIds = StandardFunctions.getAttributesFromSelectedNodes('rowId');
				window.emxEditableTable.expand(selectedNodeModelRowIds, expandLevel);
			}
		},

		launchDataGrid: function(args){
			var width = 600, height = 600;
			var href = location.href.replace("portalMode=true","");
			window.showModalDialog(href,"Modal Dialog",'dialogWidth=' + width + ',dialogHeight='+ height);

		},

		DataGridExport: function(args)	{
			var programHTMLColumns = new Array();
			var columns = dgView.layout.getLeafColumns();
			for (var i = 0; i < columns.length; i++) {
				if(columns[i].exportableFlag==true && columns[i].allowUnsafeHTMLContent) {
					if(columns[i].id=="treeLabel"){
						programHTMLColumns.push(columns[i].Tempid);
					}else{
						programHTMLColumns.push(columns[i].id);
					}

				}
			}

			if (programHTMLColumns.length > 0) {
				// get columns for export from server and let refreshColumnValues do export.
				StandardFunctions.refreshColumnValues(programHTMLColumns, true,true);
			} else {
				StandardFunctions.exportTable();
			}

		},
		exportTable: function() {
			var options= new Object();
			var columnKeys= new Array();
			var columns = dgView.layout.getLeafColumns();
			for (var i = 0; i < columns.length; i++) {

				if(columns[i].exportableFlag==true) {
					columnKeys.push(i);
				}
			}
			options.columnKeys=columnKeys;
			options.addLevelInformation = true;

			var data = dgView.getAsCSV(options);
			var header=jQuery('.wux-windows-window-header.wux-element-contentbox').find('h1').text();
			var csv1=header;
			csv1+="\n";
			csv1+=data;
			if(isIE) {
				var IEwindow = window.open();
				IEwindow.document.write('sep=,\r\n' + csv1);
				IEwindow.document.close();
				IEwindow.document.execCommand('SaveAs', true, header+ ".csv");
				IEwindow.close();
			} else {
				var hiddenElement = document.createElement('a');
				hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI("\uFEFF" + csv1);
				hiddenElement.target = '_blank';
				hiddenElement.download=header+".csv";
				document.body.appendChild(hiddenElement);
				hiddenElement.click();
				document.body.removeChild(hiddenElement);
			}
		},

		executeDefaultAction: function(args, objectId, rowID) {
			var targetPath = encodeURI(args.targetPath);
			var targetLocation = args.targetLocation;
			var strHref = args.href;
			var isModal = args.isModal;
			var width = args.itemWidth || '600';
			var height = args.itemHeight || '600';
			var dump = document.getElementById("dummy");
			if(targetLocation == 'listHidden'){
				var objFrame = this.findFrame(window,targetLocation);
				submitWithCSRF(targetPath,objFrame);
				var customHref = args.customHref;
				emxUICore.addToPageHistory(customHref);
			}

			if(targetLocation == 'content' || targetLocation == 'popup'){
				window.open(targetPath,"Modal Dialog",'width=' + width + ',height='+ height);
			}

			if(targetLocation == 'slidein'){
				targetPath = targetPath.split(",");
				var href = targetPath[0];
				var openerFrame = targetPath[1];
				openerFrame = openerFrame.replace('$OPENERFRAME$', window.name);
				if(targetPath.indexOf("right")!= -1){

					var direction = targetPath[2];
					var slideInWidth = targetPath[3];
					getTopWindow().showSlideInDialog(href,isModal,openerFrame,direction,slideInWidth);
				}else{
					getTopWindow().showSlideInDialog(href,isModal,openerFrame);
				}
			}

			if(targetLocation == ''){
				if(targetPath.indexOf("javascript:") != -1){
					var executeMethod = strHref.split("javascript:")[1];

					// find object
					var fn = window[executeMethod];
					// is object a function?
					if (typeof fn === "function")
						fn();
					else
						eval(executeMethod);
				}
				else{
					window.open(targetPath,"Modal Dialog",'width=' + width + ',height='+ height);
				}

			}
		},

		findFrame: function(objWindow,locationString) {
			switch(locationString) {
            case "_top":
                    return getTopWindow();
            case "_self":
                    return self;
            case "_parent":
                    return parent;
            default:
                 var objFrame = null;
            try{
				for (var i = 0; i < objWindow.frames.length && !objFrame; i++) {
					try {
						if (objWindow.frames[i].name == locationString) {
							objFrame = objWindow.frames[i];
						}
					} catch(ex){
					}
				}
				for (var i=0; i < objWindow.frames.length && !objFrame; i++) {
					objFrame = this.findFrame(objWindow.frames[i], locationString);
				}
			}catch (e){}
                        return objFrame;
			}
		},

		showNotification :function (msg, messageType) {
			NotificationsManagerViewOnScreen.removeLastNotificationDisplayed();
			NotificationsManagerViewOnScreen.slide({right:window.innerWidth/2 - 50});
			NotificationsManagerViewOnScreen.setFadeOutPolicy(1);
			alertMessageNotification.addNotif({ message: msg,level:messageType});

		},

		tableViewHandler: function(value){
			var current_href = location.href;
			if(current_href.indexOf("tableMenu") != -1){
				var new_href;
				if(current_href.indexOf("selectedTable") != -1)
					new_href = current_href.replace("selectedTable="+URLUtils.getParameter("selectedTable"),"selectedTable="+value);
				else
					new_href = current_href.concat("&selectedTable="+value);
			}

			location.href = new_href;
		},

		expandProgramViewHandler: function(value) {
			var new_href;
			var current_href = location.href;
			var program = decodeURIComponent(URLUtils.getParameter('program'));
			var expandProgramMenu = URLUtils.getParameter('expandProgramMenu');
			var selectedProgram = URLUtils.getParameter('selectedProgram');

			if(StandardFunctions.isNotNullAndNotEmpty(expandProgramMenu) || program.indexOf(',') != -1) {
				if(StandardFunctions.isNotNullAndNotEmpty(selectedProgram)) {
					new_href = current_href.replace('selectedProgram=' + selectedProgram, 'selectedProgram=' + value);
				} else {
					new_href = current_href.concat('&selectedProgram=' + value);
				}

				location.href = new_href;
			}
		},

		updateModelWithRowId: function(currentNodeModel, parentLevel, nodeLevel) {
			nodeLevel = (typeof nodeLevel == 'undefined') ? 0 : nodeLevel;
			for(var level = 0; level < currentNodeModel.length; level++) {
				var gridOptions = currentNodeModel[level].options;
				gridOptions.grid['rowId'] = (typeof parentLevel != 'undefined') ? parentLevel + "," + level : String(level);
				gridOptions.grid['rowId'] = (typeof parentLevel != 'undefined') ? parentLevel + "," + level : ((typeof parentLevel == 'undefined' && typeof gridOptions.children == 'undefined')? "0,"+level : String(level));
				gridOptions.grid['id[level]'] = gridOptions.grid['rowId'];
				gridOptions.grid['level'] = parseInt(nodeLevel) + 1;
				if(typeof gridOptions.children != 'undefined' && gridOptions.children != null && gridOptions.children.length > 0){
					var childNodes = gridOptions.children;
					this.updateModelWithRowId(childNodes,gridOptions.grid['rowId'], gridOptions.grid['level']);
				}
			}
		},

		isDataModified: function(){
			if(isDataModified){
				return true;
			}
			return false;
		},

		/**
		 * @param attribute - string value of attribute name which needs to be picked from node
		 * @param treeNodeModel - the datagrid treenode
		 * @return - attribute value picked from node
		 */
		getAttribute: function(treeNodeModel,attribute){
			return treeNodeModel.options.grid[attribute];

		},

		/**
		 * @param attribute - string value of attribute name which needs to be picked from node
		 * @param objectId - string value of object id to match with nodes, <null> if needs to choose node based on rel id
		 * @param relId - string value of rel id to match with nodes, <null> if needs to choose node based on object id
		 * @param isParentAttribute - boolean value to specify if attribute needs to be picked from parent node of chosen node
		 * @return - attribute value picked from node
		 */
		getAttributeFromNodeUsingId: function(attribute, objectId, relId, isParentAttribute) {
			if(typeof attribute == 'undefined' || attribute == null || attribute == '') {
				return null;
			}

			var retArray = this._privateGetAttributeFromNodes(attribute, this._privGetNodeById(objectId, relId), isParentAttribute);
			return (typeof retArray[0] != 'undefined' || retArray[0] != null) ? retArray[0] : '';
		},

		/**
		 * @param attribute - string value of attribute name which needs to be picked from node
		 * @param rowId - string value of row id to match with nodes
		 * @param isParentAttribute - boolean value to specify if attribute needs to be picked from parent node of chosen node
		 * @return - attribute value picked from node
		 */
		getAttributeFromNodeUsingRowId: function(attribute, rowId, isParentAttribute) {
			if(typeof attribute == 'undefined' || attribute == null || attribute == '') {
				return null;
			}

			var retArray = this._privateGetAttributeFromNodes(attribute, this._privGetNodeByRowId(rowId), isParentAttribute);
			return (typeof retArray[0] != 'undefined' || retArray[0] != null) ? retArray[0] : '';
		},

		/**
		 * @param attribute - string value of attribute name which needs to be picked from nodes
		 * @param level - string value of level to match with nodes
		 * @param type - string value of type to match with nodes
		 * @param parentId - string value of parent id to match with nodes
		 * @param isParentAttribute - boolean value to specify if attribute needs to be picked from parent node of chosen nodes
		 * @return - an array of attribute values picked from nodes
		 */
		getAttributesFromNodes: function(attribute, level, type, parentId, isParentAttribute) {
			if(typeof attribute == 'undefined' || attribute == null || attribute == '') {
				return null;
			}

			return this._privateGetAttributeFromNodes(attribute, this._privateGetNodes(level, type, parentId), isParentAttribute);
		},

		/**
		 * @param attribute - string value of attribute name which needs to be picked from nodes
		 * @param isParentAttribute - boolean value to specify if attribute needs to be picked from parent node of chosen nodes
		 * @return - an array of attribute values picked from nodes
		 */
		getAttributesFromSelectedNodes: function(attribute, isParentAttribute) {
			if(typeof attribute == 'undefined' || attribute == null || attribute == '') {
				return null;
			}

			return this._privateGetAttributeFromNodes(attribute, this._privateGetSelectedNodes(), isParentAttribute);
		},

		/**
		 * @param attribute - string value of attribute name which needs to be picked from nodes
		 * @param isParentAttribute - boolean value to specify if attribute needs to be picked from parent node of chosen nodes
		 * @return - an array of attribute values picked from nodes
		 */
		getAttributeFromAllNodes: function(attribute) {
			if(typeof attribute == 'undefined' || attribute == null || attribute == '') {
				return null;
			}

			return this._privateGetAttributeFromNodes(attribute, this._privateGetNodesBase(true), false);
		},

		_privGetNodeById: function(objectId, relId) {
			var exp = "";
			if(typeof objectId != 'undefined' && objectId != null) {
				exp += '(ittObj.options.grid.id == \'' + objectId + '\')';
			}
			if(typeof relId != 'undefined' && relId != null) {
				exp += ' && (ittObj.options.grid.relId == \'' + relId + '\')';
			}
			if(exp.startsWith(' && ')) {
				exp = exp.substring(4);
			}

			return this._privateGetNodesBase(exp);
		},

		_privGetNodeByRowId: function(rowId) {
			var retArray = [];

			if(typeof rowId != 'undefined' && rowId != null) {
				var exp = '(ittObj.options.grid.rowId == \'' + rowId + '\')';
				retArray = this._privateGetNodesBase(exp);
			}

			return retArray;
		},

		_privateGetNodes: function(level, type, parentId) {
			var exp = "";
			if(typeof level != 'undefined' && level != null) {
				exp += '(ittObj._options.grid.level == \'' + level + '\')';
			}
			if(typeof type != 'undefined' && type != null) {
				exp += ' && (ittObj.options.grid.Type == \'' + type + '\')';
			}
			if(typeof parentId != 'undefined' && parentId != null) {
				exp += ' && (ittObj._parentNode != null) && (typeof ittObj._parentNode.options.grid.id != \'undefined\') && (ittObj._parentNode.options.grid.id == \'' + parentId + '\')';
			}
			if(exp.startsWith(' && ')) {
				exp = exp.substring(4);
			}

			return this._privateGetNodesBase(exp);
		},

		_privateGetNodesBase: function(exp) {
			var retArray = [];

			var evalFunc = function(nodesArray) {
				nodesArray.forEach(function(ittObj) {
										if(eval(exp)) {
											retArray.push(ittObj); // UWA.clone(ittObj, true) - for now it is throwing maximum call stack at Object.clone, inside Core.js
										}

										if(typeof ittObj.getChildren() != 'undefined' && ittObj.getChildren() !=null && ittObj.getChildren().length > 0) {
											evalFunc(ittObj.getChildren());
										}
									});
			}

			if(typeof StandardFunctions.getDataGridModel() != 'undefined' && StandardFunctions.getDataGridModel() != null) {
				var rootNodes = StandardFunctions.getDataGridModel().getChildren();
				evalFunc(rootNodes);
			}

			return retArray;
		},

		_privateGetSelectedNodes: function() {
			var retArray = [];

			var selectedNodes = StandardFunctions.getDataGridModel().getSelectedNodes();
			if(typeof selectedNodes != 'undefined' && selectedNodes != null) {
				retArray = selectedNodes; // UWA.clone(selectedNodes, true)
			}

			return retArray;
		},

		_privateGetAttributeFromNodes: function(attribute, treeNodeModelArray, isParentAttribute) {
			var attArray = [];

			treeNodeModelArray.forEach(function(treeNodeModel) {
				if(isParentAttribute === true) {
					treeNodeModel = treeNodeModel._parentNode;
				}

				if(treeNodeModel == null) {
					attArray.push('');
				} else {
					attArray.push(treeNodeModel.options.grid[attribute]);
				}
			});

			return attArray;
		},

		selectNodeModel: function(treeNodeModel,keepSelection) {
			dgView.selectNodeModel(treeNodeModel,keepSelection);
		},

		unselectNodeModel: function(treeNodeModel) {
			dgView.unselectNodeModel(treeNodeModel);
		},

		getRowIds: function(rows){
			var payLoad = {};
			payLoad['data'] = [];

			if(typeof rows!= 'undefined' && rows != null) {
				rows.forEach(function(row) {
					payLoad.data.push({
						'id': row.id,
						'relId': row.relId
					});
				});
			}
			return payLoad;
		},

		addNodes: function(rows, parentId, rowId, rowColumns, dbSavePending) {
			var payLoad = this.getRowIds(rows);

			jQuery.ajax({
		        type: "POST",
			    url: '../../resources/v1/ui/gridview/columnValues?' + URLUtils.getQueryString(),
			    contentType: "application/json",
			    dataType: "json",
			    async: false,
			    data: JSON.stringify(payLoad),
			    success: function(result) {
			    	console.log(result);

			    	for(var i = 0; i < result.data.length; i++) {
			    		var row = result.data[i];

			    		row.dataelements['dgvStructChangesOperation'] = ',newNode';
			    		row.dataelements['dgvStructChangesNewParentId'] = parentId;
			    		row.dataelements['dgvStructChangesRelName'] = URLUtils.getParameter('editRelationship');

			    		var cols = rowColumns[row.id];
			    		if(typeof cols != 'undefined' && cols != null) {
			    			for(var col in cols) {
			    				row.dataelements[col] = cols[col];
			    			}
			    		}
			    	}

			    	var parentNode = StandardFunctions._privGetNodeById(parentId)[0];
			    	var referenceNode = (rowId != '' && typeof rowId != 'undefined') ? StandardFunctions._privGetNodeByRowId(rowId)[0] : undefined;
			    	var referenceIndex = (typeof referenceNode != 'undefined') ? parentNode.getChildren().indexOf(referenceNode) : '';
			    	StandardFunctions.addNewNode(result.data, parentNode, referenceIndex, dbSavePending);
		    	},
		    	error: function(error, backendresponse, response_hdrs){
		    		StandardFunctions.showNotification('', 'error');
				}
		    });
		},

		/*
		 * @param dbSavePending - to specify if connection to new parent is made in DB
		 * @param isNewNode - to specify if object was just created
		 */
		addNewNode: function(rows, parentNode, referenceIndex, dbSavePending, isNewNode) {
			if(typeof parentNode == 'undefined' || parentNode == null) {
				parentNode = StandardFunctions._privateGetSelectedNodes()[0];
			}

			if(dbSavePending != true) {
				dbSavePending = false;
			}

			if(parentNode) {
				for(var i = 0; i < rows.length; i++){
					var row = rows[i];
					var newNode;

					if(row instanceof TreeNodeModel) {
						newNode = StandardFunctions.cloneTreeNodeModel(row, true);
					} else {
						row.dataelements['dgEditAccess'] = row.relateddata.editAccess[0].dataelements;

						var itsChildren;

						// uncomment this on figuring out how to differentiate adding a new node with adding an exisitng node
						/*
						if((typeof isNewNode != 'undefined' && isNewNode == true) || gridType == 'NONE' || (typeof row.dataelements.hasChildren != 'undefined' && "false" == row.dataelements.hasChildren.toLowerCase())) {
							itsChildren = undefined;
						} else {
							itsChildren = [];
						}*/

						newNode = new TreeNodeModel({
							grid: row.dataelements,
							label: row.dataelements.treeLabel,
							children: itsChildren
						});
						newNode.options.grid.id = row.id;
						newNode.options.grid.type = row.type;
						newNode.options.grid.relId = row.relId;
					}

					if(dbSavePending) {
						StandardFunctions.getDataGridModel().setUseChangeTransactionMode(true);
						parentNode.options.applySort = false;
					} else {
						StandardFunctions.getDataGridModel().setUseChangeTransactionMode(false);
						parentNode.options.applySort = true;
					}

					if(dbSavePending && typeof newNode.options.grid.rowId != 'undefined' && newNode.options.grid.rowId != '') {
						newNode.options.grid['dgvOldRowId'] = newNode.options.grid.rowId;
					}

					referenceIndex = Number(referenceIndex);
					if(!isNaN(referenceIndex)) {
						parentNode.addChild(newNode, referenceIndex);
					} else {
						parentNode.addChild(newNode);
					}

					parentNode.options.expanded = true;
					parentNode.expand();

					StandardFunctions.updateModelWithRowId(parentNode.getChildren(),parentNode.options.grid.rowId, parentNode.options.grid.level);
					if(dbSavePending) {
						StandardFunctions.getDataGridModel().setUseChangeTransactionMode(false);

						//cloning 'newNode' to 'addedNode' to avoid modification of node in paste array, as modification of newNode will directly modify node in paste array and cause further errors
						StandardFunctions.structChangesMap.paste.push(StandardFunctions.cloneTreeNodeModel(newNode, true));

						delete newNode.options.grid.dgvOldRowId;
					}

//					if(referenceIndex != null) {
//						StandardFunctions.refreshColumnValues();
//					}
				}
			}
		},

		refreshColumnValues: function(columns, isExport, downloadCSV){
			return new UWA.Promise(function(resolve, reject){
			var dgModel = StandardFunctions.getDataGridModel();
			var nodesArray = StandardFunctions._privateGetNodesBase(true);
			var nodeModel = (nodesArray[0].getParent()!=undefined) ? nodesArray[0].getParent().getChildren() : nodesArray;
			StandardFunctions.updateModelWithRowId(nodeModel);
			var payLoad = {};
			payLoad['data'] = [];
			nodesArray.forEach(function(node){
				/*var data = node.options.grid;
				var keys = Object.keys(data);
				var payLoadObj = {};

				keys.forEach(function(key){
					payLoadObj[key] = data[key];

				});*/

				var payLoadObj = {};
				payLoadObj['id'] = node.options.grid.id;
				payLoadObj['relId'] = node.options.grid.relId;
				payLoadObj['dataelements'] = JSON.parse(JSON.stringify(node.options.grid));
				payLoad.data.push(payLoadObj);

			});

			var postURL = '../../resources/v1/ui/gridview/columnValues?' + URLUtils.getQueryString();
			if (columns && columns.length > 0) {
				if(columns.indexOf(".") > -1){
					postURL += "&columns=" + columns.split(".")[1] + "&appendColumns=" + columns.split(".")[0];
				}
				else
					postURL += "&columns=" + columns.join(",");
			}
			if (isExport) {
				postURL += "&reportFormat=CSV";
			}
			jQuery.ajax({
				type: "POST",
				url: postURL,
				contentType: "application/json",
				dataType: "json",
				data: JSON.stringify(payLoad),
				success: function(result) {
					console.log(result);
					console.log("refreshStructureWithoutSort result"+ result);

					dgModel.prepareUpdate();
					result.data.forEach(function(row){
						dgModel.setUseChangeTransactionMode(false);
						var allNodes = StandardFunctions._privateGetNodesBase(true);
						var targetNodeModel;
						allNodes.forEach(function(node){
							if(node.options.grid.id == row.id){
								targetNodeModel = node;
							}
						});
						var grid = null;
						if (isExport) {
							grid = {};
							for (var prop in row.dataelements) {
    						if(prop == "treeLabel"){
    							if(dgView.columns[0].Tempid != undefined){
    								grid[prop + "_export"] = row.dataelements[dgView.columns[0].Tempid.toLowerCase()];
    								grid["tree" + "_export"] = row.dataelements[dgView.columns[0].Tempid.toLowerCase()];
    							}

							}else{
    							grid[prop + "_export"] = row.dataelements[prop];
							}
						     }

						} else {
							grid = StandardFunctions.updateDateColumn(row.dataelements);
						}
						targetNodeModel.updateOptions({
							grid: grid
						});
					});
					if (isExport!= undefined && !isExport) {
						dgView.reapplySortModel();
					}

					dgModel.pushUpdate();
					if(downloadCSV) {
						StandardFunctions.exportTable();
					}
					resolve();
				},
		    	error: function(error, backendresponse, response_hdrs){
		    		StandardFunctions.showNotification('', 'error');
		    		reject()
		    	}
			});
			});
		},

		updateDateColumn: function(grid){
			var leafColumns = dgView.layout.getLeafColumns();
	        for (var i = 0; i < leafColumns.length; i++) {
	          var dataIndex = leafColumns[i].dataIndex;
	          var columnTypeRepresentation = leafColumns[i].typeRepresentation;
	          if(columnTypeRepresentation === 'date' && grid[dataIndex] == ""){
	        	  grid[dataIndex] = undefined;
	          }
	          else if (columnTypeRepresentation === 'date' && grid[dataIndex] != undefined) {
	            grid[dataIndex] = new Date(grid[dataIndex]);
	          }
	        }

	        return grid;
		},

		refreshRowByRowId: function(nodesArray){
			var dgModel = StandardFunctions.getDataGridModel();
			var payLoad = {};
			payLoad['data'] = [];

			nodesArray.forEach(function(node){
				var data = node.options.grid;
				var keys = Object.keys(data);
				var payLoadObj = {};
				keys.forEach(function(key){
					payLoadObj[key] = data[key];

				});
				payLoad.data.push(payLoadObj);

			});

			jQuery.ajax({
				type: "POST",
				url: '../../resources/v1/ui/gridview/columnValues?' + URLUtils.getQueryString(),
				contentType: "application/json",
				dataType: "json",
				data: JSON.stringify(payLoad),
				async: false,
				success: function(result) {
					console.log(result);
					console.log("refreshRowByRowId result"+ result);

					dgModel.withTransactionUpdate(function() {
						dgModel.setUseChangeTransactionMode(false);
						result.data.forEach(function(row){
							var allNodes = StandardFunctions._privateGetNodesBase(true);
							var targetNodeModel;
							allNodes.forEach(function(node){
								if(node.options.grid.id == row.id){
									targetNodeModel = node;

								}
							});
							//var targetNodeModel = StandardFunctions.getNodeByRowId(row.id)[0];
//							var grid = row.dataelements;
							var grid = StandardFunctions.updateDateColumn(row.dataelements);
							targetNodeModel.updateOptions({
								grid: grid
							});
						});
						dgView.reapplySortModel();
					});
				},
		    	error: function(error, backendresponse, response_hdrs){
		    		StandardFunctions.showNotification('', 'error');
		    	}
			});
		},

		removeRows: function(treeNodeModel, dbSavePending) {
			StandardFunctions.getDataGridModel().setUseChangeTransactionMode(false);

			if(dbSavePending == true) {
				StandardFunctions.getDataGridModel().setUseChangeTransactionMode(true);
			}
			var currentModel = treeNodeModel;
			treeNodeModel.getParent().removeChild(treeNodeModel);
			if(currentModel.getParent() != undefined && currentModel.getParent() != null && currentModel.getParent() != "")
				StandardFunctions.updateModelWithRowId(currentModel.getParent().getChildren(), treeNodeModel.getParent().options.grid.rowId);

			if(dbSavePending == true) {
				StandardFunctions.getDataGridModel().setUseChangeTransactionMode(false);
			}
		},

		cutRows: function(selectedNodes) {
			if(typeof selectedNodes == 'undefined' || selectedNodes == null || selectedNodes.length == 0) {
				selectedNodes = StandardFunctions._privateGetSelectedNodes();
			}

			if(selectedNodes.length > 0) {
				StandardFunctions.structChangesMap.copy = [];
				StandardFunctions.structChangesMap.latestOperation = 'cut';
			}

			var undoArray = [];

			var selectedNodeRowIds = StandardFunctions._privateGetAttributeFromNodes('rowId', selectedNodes);
			var selectedNodeParentIds = StandardFunctions._privateGetAttributeFromNodes('id', selectedNodes, true);
			selectedNodes.forEach(function(selectedNode, index) {
				StandardFunctions.removeRows(selectedNode, true);

				selectedNode.options.grid['dgvStructChangesOperation'] = 'cut';
				selectedNode.options.grid['dgvStructChangesOldParentId'] = selectedNodeParentIds[index];
				selectedNode.options.grid['dgvStructChangesOldRelId'] = StandardFunctions._privateGetAttributeFromNodes('relId', selectedNodes)[0];
				selectedNode.options.grid['dgvStructChangesOldRowId'] = selectedNodeRowIds[0];
				selectedNode.options.grid['dgvStructChangesOldParentRowId'] =  ""+StandardFunctions._privateGetAttributeFromNodes('rowId',selectedNodes,true)[0];

				StandardFunctions.structChangesMap.cut.push(selectedNode);
				StandardFunctions.unselectNodeModel(selectedNode);

				var undoRowDetails = {
					oldRowId: selectedNode.options.grid.rowId,
					oldParentRowId: selectedNode._parentNode.options.grid.rowId,
					oldReferenceIndex: selectedNode._parentNode.getChildren().indexOf(selectedNode),
					newRowId: ''
				};
				undoArray.push(undoRowDetails);
			});

			StandardFunctions.structChangesMap.undo.push(undoArray);
		},

		copyRows: function(selectedNodes) {
			if(typeof selectedNodes == 'undefined' || selectedNodes == null || selectedNodes.length == 0) {
				selectedNodes = StandardFunctions._privateGetSelectedNodes();
			}

			if(selectedNodes.length > 0) {
				if(StandardFunctions.structChangesMap.latestOperation == 'cut') {
					StandardFunctions.undoLastOperation();
				}

				StandardFunctions.structChangesMap.cut = [];
				StandardFunctions.structChangesMap.latestOperation = 'copy';
			}

			selectedNodes.forEach(function(selectedNode) {
				selectedNode.options.grid['dgvStructChangesOperation'] = 'copy';
				selectedNode.options.grid['dgvStructChangesOldParentId'] = selectedNode._parentNode.options.grid.id;

				StandardFunctions.structChangesMap.copy.push(selectedNode);
				StandardFunctions.unselectNodeModel(selectedNode);
			});
		},

		_privGetValidResequenceConnection: function(childNode, parentNode) {
			var validRelName;

			var cPrg = URLUtils.getParameter('connectionProgram');

			if(cPrg != 'undefined' && cPrg != null && cPrg != 'null' && cPrg != '') {
				var reRel = URLUtils.getParameter('resequenceRelationship');

				if(reRel != 'undefined' && reRel != null && reRel != 'null' && reRel != '') {
					var currentRelName;
					var currentRelId = childNode.options.grid.relId;

					jQuery.ajax({
						type: 'GET',
						url: '../../resources/v1/ui/gridview/getBusOrRelInfo?action=getRelName&relId=' + currentRelId + '&' + URLUtils.getQueryString(),
						async: false,
						cache: true,
						success: function(result) {
							//result = JSON.parse(result);

							if(result.data.length > 0) {
								currentRelName = result.data[0].dataelements.relname;
							}
						}
					});

					var reRels = reRel.split(',');
					for(var i = 0; i < reRels.length; i++) {
						if(currentRelName == reRels[i]) {
							validRelName = reRels[i];
							break;
						}
					}
				}
			}

			return validRelName;
		},

		_privGetValidNewConnection: function(childNode, parentNode) {
			var validRelName;

			var cPrg = URLUtils.getParameter('connectionProgram');
			var editRel = URLUtils.getParameter('editRelationship');

			if(cPrg != 'undefined' && cPrg != null && cPrg != 'null' && cPrg != '') {
				validRelName = true;
			} else if(editRel != 'undefined' && editRel != null && editRel != 'null' && editRel != '') {
				var possibleRels;
				var parentObjId = parentNode.options.grid.id;
				var childObjId = childNode.options.grid.id;

				jQuery.ajax({
					type: 'GET',
					url: '../../resources/v1/ui/gridview/getBusOrRelInfo?action=getPossibleRelsNames&parentObjId=' + parentObjId + '&childObjId=' + childObjId + '&' + URLUtils.getQueryString(),
					async: false,
					cache: true,
					success: function(results) {
						//result = JSON.parse(result);

						if(result.data.length > 0) {
							possibleRels = result.data[0].dataelements.possibleRelNames;
						}
					}
				});

				possibleRels = possibleRels.split(',');
				var editRels = editRel.split(',');
				for(var i = 0; i < editRels.length; i++) {
					for(var j = 0; j < possibleRels.length; j++) {
						if(possibleRels[j] == editRels[i]) {
							validRelName = editRels[i];
							break;
						}
					}
				}
			}

			return validRelName;
		},

		//pasteBelow will be passed only from pasteRowsBelow
		pasteRowsAbove: function(pasteBelow) {
			var validRelName;

			var selectedNodes = StandardFunctions._privateGetSelectedNodes();

			if(selectedNodes.length == 1 && StandardFunctions._privateGetAttributeFromNodes('level', selectedNodes)[0] != '0') {
				var lastOperation = StandardFunctions.structChangesMap.latestOperation;
				var toPaste = (lastOperation == 'cut') ? StandardFunctions.structChangesMap.cut: (lastOperation == 'copy') ? StandardFunctions.structChangesMap.copy : [];

				var toPasteNodesParentIds = StandardFunctions._privateGetAttributeFromNodes('id', toPaste, true);
				var selectedNodesParentIds = StandardFunctions._privateGetAttributeFromNodes('id', selectedNodes, true);
				var pasteAbove = StandardFunctions._privateGetAttributeFromNodes('id', selectedNodes)[0] + '|' + StandardFunctions._privateGetAttributeFromNodes('relId', selectedNodes)[0]
				  + '|' + StandardFunctions._privateGetAttributeFromNodes('rowId', selectedNodes)[0]

				for(var i = 0; i < toPaste.length; i++) {
					if(toPasteNodesParentIds[i] == selectedNodesParentIds[0] && toPaste[i].options.grid['dgvStructChangesOperation'] == 'cut') {
						validRelName = StandardFunctions._privGetValidResequenceConnection(toPaste[i], selectedNodes[0]._parentNode);
						toPaste[i].options.grid['dgvStructChangesOperation'] += ',resequenceConnection';
						toPaste[i].options.grid['dgvStructChangesRelName'] = validRelName;
					} else {
						validRelName = StandardFunctions._privGetValidNewConnection(toPaste[i], selectedNodes[0]._parentNode);
						toPaste[i].options.grid['dgvStructChangesOperation'] += ',newConnection';
						toPaste[i].options.grid['dgvStructChangesRelName'] = validRelName;
					}

					toPaste[i].options.grid['dgvStructChangesNewParentId'] = selectedNodesParentIds[0];
					toPaste[i].options.grid['dgvStructChangesNewRelId'] = StandardFunctions._privateGetAttributeFromNodes('relId', selectedNodes)[0];
					toPaste[i].options.grid['dgvStructChangesNewParentRowId'] = (StandardFunctions._privateGetAttributeFromNodes('rowId', selectedNodes, true)[0]).toString();

					toPaste[i].options.grid['paste-above'] = pasteAbove;
				}

				if(typeof pasteBelow == 'undefined') {
					pasteBelow = false;
				}
				if(typeof validRelName != 'undefined') {
					StandardFunctions._privatePasteRows(toPaste, selectedNodes[0]._parentNode, pasteBelow);
				}
			}
		},

		pasteRowsBelow: function() {
			var selectedNodes = StandardFunctions._privateGetSelectedNodes();

			if(selectedNodes.length == 1 && StandardFunctions._privateGetAttributeFromNodes('level', selectedNodes)[0] != '0') {
				StandardFunctions.pasteRowsAbove(true);
			}
		},

		cloneObject: function(target, src){
			for(var index = 0; index < src.length; index++){
				var temp = {};
				Object.assign(temp , src[index]);
				temp.options = {grid : {}};
				temp.options.grid = JSON.parse(JSON.stringify(src[index].options.grid));
				target.push(temp);
			}
			return target;
		},

		pasteRowsAsChild: function() {
			var validConnection = true;
			var validRelName;
			var selectedNodes = StandardFunctions._privateGetSelectedNodes();

			if(selectedNodes.length == 1) {
				var lastOperation = StandardFunctions.structChangesMap.latestOperation;
				var toPaste = (lastOperation == 'cut') ? StandardFunctions.structChangesMap.cut : (lastOperation == 'copy') ?
						 StandardFunctions.structChangesMap.copy : [];
				//var toPaste = UWA.clone(src,'true');
				//StandardFunctions.cloneObject(toPaste, src);

				var selectedNodeId = StandardFunctions._privateGetAttributeFromNodes('id', selectedNodes)[0];
				var toPasteParentIds = StandardFunctions._privateGetAttributeFromNodes('id', toPaste, true);
				toPasteParentIds.forEach(function(toPasteParentId) {
					if(toPasteParentId == selectedNodeId) {
						validConnection = false;
					}
				});
				var pasteAsChild = selectedNodeId + '|' + StandardFunctions._privateGetAttributeFromNodes('relId', selectedNodes)[0]
												  + '|' + StandardFunctions._privateGetAttributeFromNodes('rowId', selectedNodes)[0]

				if(validConnection) {
					for(var i = 0; i < toPaste.length; i++) {
						validRelName = StandardFunctions._privGetValidNewConnection(toPaste[i], selectedNodes[0]);
						toPaste[i].options.grid['dgvStructChangesOperation'] += ',newConnection';
						toPaste[i].options.grid['dgvStructChangesRelName'] = validRelName;
						toPaste[i].options.grid['dgvStructChangesNewParentId'] = selectedNodeId;
						toPaste[i].options.grid['dgvStructChangesNewParentRowId'] =  StandardFunctions._privateGetAttributeFromNodes('rowId', selectedNodes)[0];
						toPaste[i].options.grid['pasteAsChild'] = pasteAsChild;
					}

					if(typeof validRelName != 'undefined') {
						StandardFunctions._privatePasteRows(toPaste, selectedNodes[0]);
					}
				}
			}
		},

		_privatePasteRows: function(toPasteNodes, pasteUnderNode, pasteBelow) {
			if(toPasteNodes.length > 0) {
				var selectedNode = StandardFunctions._privateGetSelectedNodes()[0];

				if(StandardFunctions.structChangesMap.latestOperation == 'cut') {
					toPasteNodes.forEach(function(toPasteNode) {
						StandardFunctions.removeRows(toPasteNode);
					});
				}

				var referenceIndex;
				if(typeof pasteBelow != 'undefined') {
					if(pasteBelow === false) {
						referenceIndex = selectedNode._parentNode.getChildren().indexOf(selectedNode);
					} else if(pasteBelow === true) {
						referenceIndex = selectedNode._parentNode.getChildren().indexOf(selectedNode) + 1;
					}
				}
				StandardFunctions.addNewNode(toPasteNodes, pasteUnderNode, referenceIndex, true);

				var undoArray = [];
				if(StandardFunctions.structChangesMap.latestOperation == 'cut') {
					undoArray = StandardFunctions.structChangesMap.undo[StandardFunctions.structChangesMap.undo.length - 1];
					StandardFunctions.structChangesMap.undo.remove(undoArray);

					for(var i = 0; i < toPasteNodes.length; i++) {
						for(var j = 0; j < undoArray.length; j++) {
							if(undoArray[j].oldRowId == toPasteNodes[i].options.grid.dgvOldRowId) {
								undoArray[j].newRowId = toPasteNodes[i].options.grid.rowId;
							}
						}
					}
				} else {
					toPasteNodes.forEach(function(toPasteNode) {
						undoArray.push({
							oldRowId: '',
							newRowId: toPasteNode.options.grid.rowId
						});
					});
				}
				StandardFunctions.structChangesMap.undo.push(undoArray);

				StandardFunctions.structChangesMap[StandardFunctions.structChangesMap.latestOperation] = [];
				StandardFunctions.structChangesMap.latestOperation = 'paste';

				StandardFunctions.unselectNodeModel(selectedNode);
			}
		},

		undoLastOperation: function() {
			var undoArray = StandardFunctions.structChangesMap.undo[StandardFunctions.structChangesMap.undo.length - 1];
			StandardFunctions.structChangesMap.undo.remove(undoArray);
			if(typeof undoArray != 'undefined' && undoArray.length > 0){
			undoArray.forEach(function(undoRowDetails) {
				var undoRow;

				if(undoRowDetails.newRowId != '') {
					undoRow = StandardFunctions._privGetNodeByRowId(undoRowDetails.newRowId)[0];
					StandardFunctions.removeRows(undoRow);

					var loopLength = StandardFunctions.structChangesMap.paste.length;
					for(var i = loopLength - 1; i >= 0; i--) {
						if(StandardFunctions.structChangesMap.paste[i].options.grid.id == undoRow.options.grid.id) {
							StandardFunctions.structChangesMap.paste.remove(StandardFunctions.structChangesMap.paste[i]);
							break;
						}
					}
				}

				if(undoRowDetails.oldRowId != '') {
					if(typeof undoRow == 'undefined') {
						undoRow = StandardFunctions._privGetNodeByRowId(undoRowDetails.oldRowId)[0];
					} else {
						undoRow.options.grid.rowId = undoRowDetails.oldRowId;
					}

					var oldParent = StandardFunctions._privGetNodeByRowId(undoRowDetails.oldParentRowId)[0];
					StandardFunctions.addNewNode(new Array(undoRow), oldParent, undoRowDetails.oldReferenceIndex);
				}
			});
			}
		},

		triggerValidation:function(args){
		var selectedNodes = StandardFunctions.getDataGridModel().getSelectedNodes();
        var sObjectId = new Array();
        for(var i=0;i<selectedNodes.length;i++)
        {
            sObjectId.push(selectedNodes[i].options.grid.id);
        }
        showModalDialog("../common/emxTable.jsp?table=AEFValidateTrigger&program=emxTriggerValidationBase:getCheckTriggers&header=emxFramework.Label.TriggerValidation&customize=false&multiColumnSort=false&objectBased=false&SubmitURL=emxTriggerIntermediatePage.jsp&SubmitLabel=emxFramework.Button.Next&Style=dialog&CancelLabel=emxFramework.Button.Cancel&CancelButton=true&multipleObjects=true&selectedObjIds="+sObjectId.toString()+"&selection=multiple&HelpMarker=emxhelptriggervalidationrules", 850, 750, true);

		},toggleProgress:function(args){
			dgView.displayModalLoader(args);
		},removeToggleProgress:function(){
			dgView.removeModalLoader();
		},

		submitFreezePaneData: function(strURL, strTarget, strRowSelect, bPopup, bModal, iWidth, iHeight, confirmationMessage, strPopupSize, slideinWidth) {

			var deleteURLindex = strURL.indexOf("emxGenericDeleteProcess.jsp");
			var massPromoteURLindex = strURL.indexOf("emxMassPromoteDemoteProcess.jsp");
			var sbCompareURLindex = strURL.indexOf("emxStructureCompare.jsp");
			if(deleteURLindex!= -1 || massPromoteURLindex!=-1) {
				if(this.isDataModified()) {
					alert(STR_SBEDIT_SAVE_THE_CHANGES);
					return;
				}
			}

			var selectedNodes = StandardFunctions.getDataGridModel().getSelectedNodes();
			var inputvalues = new Array();
			var selectedCount = 0;
			var submitForm = document.createElement("form");
			document.getElementsByTagName('body')[0].appendChild(submitForm);
			submitForm.setAttribute('name', "emxTableForm");
			submitForm.target = "listHidden";
			submitForm.action = strURL;
			submitForm.method = "post";

			for(var i = 0; i < selectedNodes.length; i++) {
				var strVal = "|" + selectedNodes[i].options.grid.id + "|" + "|";
				var inputElem = document.createElement("input")
				inputElem.setAttribute("type", "hidden");
				inputElem.setAttribute("name", "emxTableRowId");
				inputElem.setAttribute("id", strVal);
				inputElem.setAttribute("value", strVal);
				submitForm.append(inputElem);
				selectedCount++;
			}
			//Modified for Bug : 353307
			if(strRowSelect == "rmb") {
				selectedCount = 1;
			}

			if(strRowSelect == "single" && selectedCount > 1 && strRowSelect != "rmb") {
				showError(emxUIConstants.ERR_SELECT_ONLY_ONE);
				return;
			} else if((selectedCount == 0) && strRowSelect != "none" && strRowSelect != "rmb") {
				showError(emxUIConstants.ERR_NONE_SELECTED);
				return;
			}
			if(sbCompareURLindex != -1 && selectedCount > 2) {
				alert(emxUIConstants.STR_COMPARE_SELECT_MINOBJECT);
				return;
			}
			if(confirmationMessage != null && confirmationMessage != "undefined" && confirmationMessage != "null" && confirmationMessage != "") {
				if(confirmationMessage.indexOf("${TABLE_SELECTED_COUNT}") > 0) {
					confirmationMessage = confirmationMessage.replace(new RegExp("\\$\\{TABLE_SELECTED_COUNT\\}","g"), selectedCount);
				}
				var bResponse = window.confirm(confirmationMessage);
				if(!bResponse) {
					return;
				}
			}

			if(strRowSelect == "rmb") {
				strURL += "&isFromRMB=true";
			}

			submitForm.submit();
		},

		dropCells: function(draggedRows, droppedOnRow, action, commitPaste) {
			if(draggedRows.length == 0) {
				return;
			}

			var newAttributes;
			if(action === 'Move') {
				draggedRows.forEach(function(draggedRow) {
					newAttributes = {
						dgvStructChangesOperation: 'cut,newConnection',/*'dnd:cut,newConnection',*/ //as removing dropJPO code
						dgvStructChangesOldRowId: draggedRow.options.grid.rowId,
						dgvStructChangesOldParentId: draggedRow._parentNode.options.grid.id, //as removing dropJPO code
						dgvStructChangesOldParentRowId: draggedRow._parentNode.options.grid.rowId,
						dgvStructChangesNewParentId: droppedOnRow.options.grid.id,
						/*dgvDroppedOnRowRelId: droppedOnRow.options.grid.relId,*/ //as removing dropJPO code
						dgvStructChangesNewParentRowId: droppedOnRow.options.grid.rowId
					};

					Object.assign(draggedRow.options.grid, newAttributes);

					StandardFunctions.removeRows(draggedRow, !commitPaste);
				});
			} else if(action === 'Copy') {
				draggedRows.forEach(function(draggedRow) {
					newAttributes = {
						dgvStructChangesOperation: 'copy,newConnection',/*'dnd:copy,newConnection',*/ //as removing dropJPO code
						dgvStructChangesOldRowId: draggedRow.options.grid.rowId,
						dgvStructChangesNewParentId: droppedOnRow.options.grid.id,
						/*dgvDroppedOnRowRelId: droppedOnRow.options.grid.relId,*/ //as removing dropJPO code
						dgvStructChangesNewParentRowId: droppedOnRow.options.grid.rowId
					};

					Object.assign(draggedRow.options.grid, newAttributes);
				});
			}

			if(commitPaste) {
				var editedArray = new Array();
				var editedPasteObj;
				draggedRows.forEach(function(draggedRow) {
					editedPasteObj = {
						id: draggedRow.options.grid.id,
						relId: draggedRow.options.grid.relId,
						dataelements: JSON.parse(JSON.stringify(draggedRow.options.grid))
					};
					editedArray.push(editedPasteObj);
				});

				var payLoad = {
					data: editedArray
				};
				StandardFunctions.saveEditsToDB(payLoad, function() {
					StandardFunctions.addNewNode(draggedRows, droppedOnRow, undefined, false);

					draggedRows.forEach(function(draggedRow) {
						delete draggedRow.options.grid.dgvStructChangesOperation;
						delete draggedRow.options.grid.dgvStructChangesOldRowId;
						delete draggedRow.options.grid.dgvStructChangesOldParentId;
						delete draggedRow.options.grid.dgvStructChangesOldParentRowId;
						delete draggedRow.options.grid.dgvStructChangesNewParentId;
						delete draggedRow.options.grid.dgvStructChangesNewParentRowId;
					});
				});
			} else {
				StandardFunctions.addNewNode(draggedRows, droppedOnRow, undefined, true);

				draggedRows.forEach(function(draggedRow) {
					delete draggedRow.options.grid.dgvStructChangesOperation;
					delete draggedRow.options.grid.dgvStructChangesOldRowId;
					delete draggedRow.options.grid.dgvStructChangesOldParentId;
					delete draggedRow.options.grid.dgvStructChangesOldParentRowId;
					delete draggedRow.options.grid.dgvStructChangesNewParentId;
					delete draggedRow.options.grid.dgvStructChangesNewParentRowId;
				});
			}
		},

		isNullOrEmpty: function(strValue) {
			return (typeof strValue == 'undefined') || strValue == null || strValue == '';
		},

		isNotNullAndNotEmpty: function(strValue) {
			return (typeof strValue != 'undefined') && strValue != null && strValue != '';
		},

		toggleGraphImage: function(args){
			var node = dataGridModel.getChildren()[0];
			if (dgView._eGraphInstance.getThumbnailState(node) === graphWidget.ThumbnailState.EXPANDED) {
				dgView._eGraphInstance.setAllThumbnailsState(graphWidget.ThumbnailState.COLLAPSED);
			}else{
				dgView._eGraphInstance.setAllThumbnailsState(graphWidget.ThumbnailState.EXPANDED);
			}
		},

		rotateGraph: function(){
			dgView._eGraphInstance.swapLayoutOrientation();
		},

		toggleMiniMap: function() {
			dgView._eGraphInstance.swapOverviewVisibility();
		},

		addEditRow: function(args, position, state) {
			var selectedNodes = StandardFunctions._privateGetSelectedNodes();

			if(selectedNodes.length == 1) {
				var parentNode = selectedNodes[0]._parentNode;
				var referenceIndex;
				var children = parentNode.getChildren();
				if(children instanceof Array) {
					if(position === 'above') {
						referenceIndex = children.indexOf(selectedNodes[0]);
					} else if(position === 'below') {
						referenceIndex = children.indexOf(selectedNodes[0]) + 1;
					}
				}

				//implementation of Default Program/Function pending

				var colValues = {
					dgvInlineRow: 'true',
					dgEditAccess: new Object()
				};
				dgView.layout.getLeafColumns().forEach(function(column) {
					colValues[column.id] = (typeof column.defaultValue != 'undefined') ? column.defaultValue : '';
					colValues.dgEditAccess[column.id] = 'true';
				});

				var emptyNode = new TreeNodeModel({
					grid: colValues
				});
				StandardFunctions.addNewNode(new Array(emptyNode), parentNode, referenceIndex, true);
				StandardFunctions.unselectNodeModel(selectedNodes[0]);

				if(state == 'existing') {
					StandardFunctions.structChangesMap.paste.remove(emptyNode); // add (as normal paste) after lookup entries
					StandardFunctions.structChangesMap.lookupEntries.push(emptyNode);

					//changing Save button to 'Lookup entries'
					var saveButton = StandardFunctions.getToolbarReference().getNodeModelByID('DataGridSave');
					var dgvTempLabel = saveButton.options.label;
					saveButton.updateOptions({
						label: 'Lookup entries...',
						grid: {
							_dgvTempLabel: dgvTempLabel,
							data: {
								argument: {
									href: 'javascript:StandardFunctions.lookupEntries()'
								}
							}
						}
					});
				}
			}
		},

		insertRowAbove: function(args) {
			StandardFunctions.addEditRow(args, 'above', 'new');
		},

		insertRowBelow: function(args) {
			StandardFunctions.addEditRow(args, 'below', 'new');
		},

		lookupRowAbove: function(args) {
			StandardFunctions.addEditRow(args, 'above', 'existing');
		},

		lookupRowBelow: function(args) {
			StandardFunctions.addEditRow(args, 'below', 'existing');
		},

		removeInsertedRow: function(args) {

		},

		validInlineRows: function(rows) {
			var validRows = true;

			var attValues = StandardFunctions._privateGetAttributeFromNodes('dgvInlineRow', rows);
			for(var i = 0; i < rows.length; i++) {
				var attValue = attValues[i];
				if(attValue === 'true') {
					dgView.layout.getLeafColumns().forEach(function(column) {
						if(column.dgvColValRequired === 'true' && (typeof rows[i].options.grid[column.id] == 'undefined' || rows[i].options.grid[column.id] == '')) {
							validRows = false;
							return;
						}
					});

					if(!validRows) {
						return validRows;
					}
				}
			}

			return validRows;
		},

		lookupEntries: function(args) {
			if(!StandardFunctions.validInlineRows(StandardFunctions.structChangesMap.lookupEntries)) {
				return;
			}

			//call webservice to generate data from lookupJPO

			if(true) { // success
				//paste the object

				//changing back to Save button
				var saveButton = StandardFunctions.getToolbarReference().getNodeModelByID('DataGridSave');
				saveButton.updateOptions({
					label: saveButton.options.grid._dgvTempLabel,
					grid: {
						data: {
							argument: {
								href: 'javascript:StandardFunctions.saveEdits()'
							}
						}
					}
				});
				delete saveButton.options.grid._dgvTempLabel;
			} else { //failure

			}
		},

		getToolbarReference: function() {
			return dgView._dgViewToolbar;
		},

		wrapText: function(args) {
			/*var lastWrapOperation = Utils.getDataFromLocalPreferences(dgView, 'wux-collectionView-dataGridView', 'lastWrapOperation');
			if(lastWrapOperation === 'wrap') {
				return;
			}*/

			var initialLoad = false;
			var contextObj;
			var localDgLayout;
			if(typeof args != 'undefined' && typeof args.context != 'undefined') {
				contextObj = args.context;
				localDgLayout = args.context.layout;
			} else {
				initialLoad = true;
				contextObj = dgView;
				localDgLayout = dgView.layout;
			}

			//used to update everything in one shot, instead of updating in an iterative way
			contextObj.prepareUpdateView();

			var localDgColumns = localDgLayout.getLeafColumns();
			for(var iteration = 0; iteration < localDgColumns.length; iteration++) {
				if(/*localDgColumns[iteration].typeRepresentation === 'string' || */localDgColumns[iteration].typeRepresentation === 'editor') {
					localDgColumns[iteration]['dgvPreviousTypeRepresentation'] = localDgColumns[iteration].typeRepresentation;

					if(contextObj.layout.setColumnTypeRepresentation != undefined){
						contextObj.layout.setColumnTypeRepresentation(iteration, 'textBlock');
					}else{
						localDgColumns[iteration].typeRepresentation = 'textBlock';
					}
					localDgLayout.setColumnAutoRowHeightFlag(iteration, true);
				}
			}

			//used to update everything in one shot, instead of updating in an iterative way
			contextObj.pushUpdateView({
				updateCellContent: true,
				updateCellLayout: true,
				updateCellAttributes: true
			}, true);

			if(!initialLoad) {
				var existingCommandProperties = StandardFunctions.getToolbarReference().getNodeModelByID('DataGridWrapCommand').options;
				var newIcon = existingCommandProperties.grid.semantics.icon.replace('iconActionWordWrapOn.png', 'iconActionWordWrapOff.png');
				var updateOptions = '[{"tooltip": "' + existingCommandProperties.strUnwrap + '"}, {"label": "' + existingCommandProperties.strUnwrap + '"}, {"icon": "' + newIcon + '"}, {"grid": {"data": {"argument": {"href": "javascript:StandardFunctions.unwrapText()"}}}}]';
				StandardFunctions.updateToolbarEntry('DataGridWrapCommand', updateOptions);
			}

			Utils.saveDataInLocalPreferences(dgView, 'wux-collectionView-dataGridView', 'lastWrapOperation', 'wrap');
			//localDgLayout.resetRowHeights();
		},

		unwrapText: function(args) {
			/*var lastWrapOperation = Utils.getDataFromLocalPreferences(dgView, 'wux-collectionView-dataGridView', 'lastWrapOperation');
			if(lastWrapOperation === 'unwrap') {
				return;
			}*/

			var contextObj;
			var localDgLayout;
			if(typeof args != 'undefined' && typeof args.context != 'undefined') {
				contextObj = args.context;
				localDgLayout = args.context.layout;
			} else {
				contextObj = dgView;
				localDgLayout = dgView.layout;
			}

			//used to update everything in one shot, instead of updating in an iterative way
			contextObj.prepareUpdateView();

			var localDgColumns = localDgLayout.getLeafColumns();
			for(var iteration = 0; iteration < localDgColumns.length; iteration++) {
				if(localDgColumns[iteration].typeRepresentation === 'textBlock' && typeof localDgColumns[iteration].dgvPreviousTypeRepresentation != 'undefined') {
					if(contextObj.layout.setColumnTypeRepresentation != undefined){
						contextObj.layout.setColumnTypeRepresentation(iteration, localDgColumns[iteration].dgvPreviousTypeRepresentation);
					}
					else{
						localDgColumns[iteration].typeRepresentation = localDgColumns[iteration].dgvPreviousTypeRepresentation;
					}

					localDgLayout.setColumnAutoRowHeightFlag(iteration, false);
				}
			}

			//used to update everything in one shot, instead of updating in an iterative way
			contextObj.pushUpdateView({
				updateCellContent: true,
				updateCellLayout: true,
				updateCellAttributes: true
			}, true);

			var existingCommandProperties = StandardFunctions.getToolbarReference().getNodeModelByID('DataGridWrapCommand').options;
			var newIcon = existingCommandProperties.grid.semantics.icon.replace('iconActionWordWrapOff.png', 'iconActionWordWrapOn.png');
			var updateOptions = '[{"tooltip": "' + existingCommandProperties.strWrap + '"}, {"label": "' + existingCommandProperties.strWrap + '"}, {"icon": "' + newIcon + '"}, {"grid": {"data": {"argument": {"href": "javascript:StandardFunctions.wrapText()"}}}}]';
			StandardFunctions.updateToolbarEntry('DataGridWrapCommand', updateOptions);

			Utils.saveDataInLocalPreferences(dgView, 'wux-collectionView-dataGridView', 'lastWrapOperation', 'unwrap');
			//localDgLayout.resetRowHeights();
		},

		checkWrap: function(command) {
			var lastWrapOperation = Utils.getDataFromLocalPreferences(dgView, 'wux-collectionView-dataGridView', 'lastWrapOperation');

			command.dataelements['strWrap'] = command.dataelements.tooltip;
			command.dataelements['strUnwrap'] = command.dataelements.label;

			if(StandardFunctions.isNullOrEmpty(lastWrapOperation) || lastWrapOperation === 'unwrap') {
				command.dataelements.tooltip = command.dataelements.strWrap;
				command.dataelements.label = command.dataelements.strWrap;
			} else if(lastWrapOperation === 'wrap') {
				command.dataelements.tooltip = command.dataelements.strUnwrap;
				command.dataelements.label = command.dataelements.strUnwrap;
				command.dataelements.icon = command.dataelements.icon.replace('iconActionWordWrapOn.png', 'iconActionWordWrapOff.png');
				command.dataelements.action.argument.href = 'javascript:StandardFunctions.unwrapText()';

				StandardFunctions.wrapText();
			}

			delete command.dataelements.jsBeforeLoad;
		},

		/**
		 * API to update the toolbar entry such as icon, tooltip, label
		 * @param {String} - id of the command or menu
		 * @param {String} - stringified JSON array with the list of properties(key/value pairs) to be updated
		 */

		updateToolbarEntry: function(entryId, jsonPropArray){
			var toolbarEntry;
			var toolbarInstance = StandardFunctions.getToolbarReference();
			toolbarEntry = toolbarInstance.getNodeModelByID(entryId);
			jsonPropArray = JSON.parse(jsonPropArray);
			if(typeof toolbarEntry == "undefined"){
			// toolbarEntry is undefined means the id does not belong to a main menu
			// the entry can be a submenu or does not exist
				try{

					jsonPropArray.forEach(function(jsonProp){
						console.log(jsonProp);
						toolbarInstance.updateNodeModel(entryId,jsonProp);
					});
				}
				catch(e){
					console.log("exception-"+e);
					console.log("could not find submenu toolbar entry with the id-"+entryId);
				}
			}
			else{
			//the entry is a main menu
				try{
					jsonPropArray.forEach(function(jsonProp){
						toolbarEntry.updateOptions(jsonProp)
					});
				}catch(e){
					console.log("exception-"+e);
				}

			}
		},

		updateUrl: function(frameRef, param, newValue){
			frameRef.urlUtils.changeParamValue(param, newValue);
		},

		cloneTreeNodeModel: function(treeNodeModelObject, withChildren) {
			var itsChildren = treeNodeModelObject.options.children;

			var existingChildren = treeNodeModelObject.getChildren();
			if(withChildren === true && typeof existingChildren != 'undefined' && existingChildren != null && existingChildren.length > 0) {
				itsChildren = new Array();
				for(var i = 0; i < existingChildren.length; i++) {
					var existingChild = existingChildren[i];
					itsChildren.push(StandardFunctions.cloneTreeNodeModel(existingChild, true));
				}
			}

			return new TreeNodeModel({
				grid: UWA.clone(treeNodeModelObject.options.grid),
				label: UWA.clone(treeNodeModelObject.options.label),
				children: itsChildren
			});
		}

	};

	return StandardFunctions;

});
