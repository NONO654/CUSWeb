define('DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD', [ 'UWA/Core', 'DS/Core/Core', 'DS/ApplicationFrame/FrameWindow', // TODO : remove when useless
'DS/ApplicationFrame/ContextualUIManager', 'DS/WebappsUtils/WebappsUtils', 'DS/Utilities/Dom', 'DS/Tree/TreeListView', 'DS/Tree/TreeNodeModel', 'DS/Tree/TreeDocument' ], function(UWACore, WUXCore, FrameWindow, ContextualUIManager, WebappsUtils, DomUtils, TreeListView, TreeNodeModel, TreeDocument) {
	'use strict';

	var XCAD_InteractionsWEB_CAD = {
		init : function() {
			// >>> MANAGE RECIEVE MESSAGE FROM CAD >>>
			if (typeof dscef != 'undefined') {
				dscef.receivedString = function(iMsg) {// TODO: create file just for dscef.receivedString (controler) >> separate WebView / WebModel / WebControler
					console.log('XCAD_InteractionsWEB_CAD - Message received from CAD : "' + JSON.stringify(iMsg) + '"');

					var operation, operationVersion, content;
					if (typeof iMsg == 'object') {
						operation = iMsg.operation;
						operationVersion = iMsg.operationVersion;
						content = iMsg.content;
					}

					switch (operation) {
					case 'init':
						if (operationVersion == '1.0' && typeof content != 'undefined') {
							// init : function(iNodes, iFilterNotModified, restrictedCharactersForFileName, myAppsBaseUrl, userId, lang) {
							widget.XCAD_MainController.init(content.nodes,content.SaveScope,content.WorkUnder, content.filterNotModified, content.restrictedCharactersForFileName, content.myAppsBaseUrl, content.userId, content.lang, content.isAsyncSave,content.iUnreserveSaveOn,content.nbNew,content.nbMod,content.nbExc,content.nbInc,content.ShowPGP,content.PGPSaveOn);
						}
						break;
					case 'reloadWebModel':
						if (operationVersion == '1.0' && typeof content != 'undefined') {
							widget.XCAD_MainController.loadNodes(content.nodes,content.nbNew,content.nbMod,content.nbExc,content.nbInc);
						}
						break;
					case 'updateWebModel':
						if (operationVersion == '1.0' && typeof content != 'undefined') {
							widget.XCAD_MainController.updateNodes(content.nodes,content.nbNew,content.nbMod,content.nbExc,content.nbInc);
						}
						break;
					case 'DisplayDerivedOutputs':
						if (operationVersion == '1.0' && typeof content != 'undefined') {
							widget.XCAD_MainController.showDerivedOutputSidePanel(content.derivedOutputs);
						}
						break;
					case 'DisplayWarning':
						if (operationVersion == '1.0' && typeof content != 'undefined') {
							widget.XCAD_MainController.displayWarning(content.AllIncludedLocked,content.AllIncludedWithReadAccess);
						}
						break;						
					case 'UpdatePreview':
						if (operationVersion == '1.0' && typeof content != 'undefined') {
							widget.XCAD_MainController.onUpdatePreview(content.previewBase64);
						}
						break;
					default:
						console.error('XCAD_InteractionsWEB_CAD - Error : unknown operation (' + operation + ')');
					}
				}
			}
			// <<< MANAGE RECIEVE MESSAGE FROM CAD <<<
		},

		sendMessageToCad : function(iOperation, iOperationVersion, iContent) {
			var message = {
				operation : iOperation,
				operationVersion : iOperationVersion,
				content : iContent
			};
			var strMessage = JSON.stringify(message);

			if (typeof dscef != 'undefined')
				dscef.sendString(strMessage);
			else if (iOperation == 'readyForInit')
				this.fakeInit();
			else if (iOperation == 'GetDerivedOutputsList')
				this.fakeGetDerivedOutputsList();
			console.log('Message sent to CAD : "' + strMessage + '"');
		},

		// Used only to debug the widget in a browser (outside of CATIA)
		fakeInit : function() {

			var fakeNodes = [ /*{
				"Status" : ["I_UPSModified"],
				"TooltipStatus" : "test1",
				"Save" : "I_UPSToBeSaved",
				"Title" : "c",
				"Revision" : "A.1",
				"Type" : "Physical Product",
				"CAD_Type" : "",
				"Name" : "prd-16991424-00000003",
				"Description" : " _ 10:35:02 _ ",
				"Maturity" : "In Work",
				"Reserve" : "I_UPSLockedByMe",
				"Reserved_By" : "sri8",
				"Owner" : "Samy REZZOUQI",
				"Filename" : "SRI8_root1.CATProduct",
				"Bookmarks" : "",
				"NodeId" : "StringID:0",
				"Phid" : "EEBA8D757EEF489CA8824DFF401DCDF5"
			},*/ {
				"Status":[
					"I_UPSNew",
					"I_UPSWarning"
					],
				"TooltipStatus":[
					"New",
					"This document is not found."
					],
				"Action":"",
				"Save":"I_UPSExcluded",
				"Title" : "a",
				"Revision" : "",
				"Type" : "Physical Product",
				"CAD_Type" : "a",
				"Name" : "",
				"Description" : " _ 10:35:02 _ ",
				"Maturity" : "",
				"Reserve" : "I_UPSUnLocked",
				"Reserved_By" : "",
				"Owner" : "",
				"Filename" : "SRI8_root1.CATProduct",
				"Bookmarks" : "",
				"NodeId" : "StringID:1",
				"Phid" : ""
			}, {
				"Status" : ["I_UPSCachedInfo"],
				"TooltipStatus" : "test3",
				"Save" : "I_UPSNoSave",
				"Title" : "b",
				"Revision" : "A.1",
				"Type" : "Physical Product",
				"CAD_Type" : "",
				"Name" : "prd-16991424-00000004",
				"Description" : " _ 10:35:02 _ ",
				"Maturity" : "In Work",
				"Reserve" : "I_UPSUnLocked",
				"Reserved_By" : "",
				"Owner" : "Samy REZZOUQI",
				"Filename" : "SRI8_3.CATProduct",
				"Bookmarks" : "",
				"NodeId" : "StringID:2",
				"Phid" : "0B8437BEFB0D44B79EC468327E07BE37"
			}, {
				"Available_Commands":["Exclude","Revise","SaveAsNew","Duplicate","Lock"],
				"Icons":"I_UPScomponent",
				"Revision_List":["A.1","B.1 (New)"],
				"Type_List":["Physical Product"],			
				"Status" : ["I_UPSCachedInfo"],
				"TooltipStatus" : "test4",
				"Save" : "I_UPSForcedToBeSaved",
				"Title" : "SRI8_2",
				"Revision" : "B.1 (New)",
				"Type" : "Physical Product",
				"CAD_Type" : "assembly",
				"Name" : "prd-16991424-00000002",
				"Description" : " _ 10:35:02 _ ",
				"Maturity" : "In Work",
				"Reserve" : "I_UPSLockedByMe",
				"Reserved_By" : "sri8",
				"Owner" : "Samy REZZOUQI",
				"Filename" : "SRI8_2.CATProduct",
				"Bookmarks" : "",
				"NodeId" : "StringID:3",
				"Phid" : "E66D60AF67A04802A3DC863C18197612"
			} ];

			// init : function(iNodes, iFilterNotModified, restrictedCharactersForFileName, myAppsBaseUrl, userId, lang) {
			//(iNodes,iSaveScope,ChangeActionName, iFilterNotModified, iRestrictedCharactersForFileName, iMyAppsBaseUrl, iUserId, iLang, iIsAsyncSave,iUnreserveSaveOn,nbNew,nbMod,nbExc,nbInc)
			widget.XCAD_MainController.init(fakeNodes,2,"CA-4592950-00000001",false, "\\/", 'https://vdevpril435dsy.ux.dsone.3ds.com:443/3DSpace', 'all', 'en', false,false,'1','1','0','0',true);
		},

		fakeGetDerivedOutputsList : function() {
			widget.XCAD_MainController.showDerivedOutputSidePanel([ {
				name : 'DO_NotChecked',
				icon : 'I_UPSUnChecked'
			}, {
				name : 'DO_Checked',
				icon : 'I_UPSCheckBox'
			}, {
				name : 'CheckedMix',
				icon : 'I_UPSPartialCheck'
			} ]);
		}

	};

	return XCAD_InteractionsWEB_CAD;

});
