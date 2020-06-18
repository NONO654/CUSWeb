//=================================================================
// JavaScript RichEditorCusto.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
/* Contains RichText code common to Form and Structure Browser) */
/*
 *                          MM:DD:YY
 * @quickreview HAT1 ZUD 15:12:16 : HL -  To enable Content column for Test Cases.                          
 * @quickreview QYG      05:03:16   javascript refactoring, split from RichTextEditorCommon.js
 * @quickreview ZUD      12:14:16   For Adding UUID in CKEDITOR
 */
if(localStorage['debug.AMD']) {
	var _RichEditorCusto_js = _RichEditorCusto_js || 0;
	_RichEditorCusto_js++;
	console.info("AMD: RichEditorCusto/RichEditorCusto.js loading " + _RichEditorCusto_js + " times.");
}


define('DS/RichEditorCusto/RichEditorCusto', ['DS/RichEditorCusto/Util',
       'DS/UIKIT/SuperModal', 
       'UWA/Utils',
       'i18n!DS/RichEditorCusto/assets/nls/RichEditorCusto.json',
       'css!DS/RichEditorCusto/assets/css/RichEditor.css'
    ], 
    function(Util, SuperModal,UWA, RichEditorCustoNLS){
	
		if(localStorage['debug.AMD']) {
			console.info("AMD: RichEditorCusto/RichEditorCusto.js dependency loaded.");
		}

		function downloadRCO(event){
			if(window.editableTable && editableTable.mode != 'view') {
				return;
			}
			var objectId;
			if(window.editableTable){
				objectId = jQuery(this).closest("tr[o]").attr("o");
				if(!objectId){
					var editorId = jQuery(this).closest(".ui-dialog-content").attr("id");
					if(editorId) {
						editorId = editorId.substring("HTMLEditor_".length);
						objectId = $("#objectInfo_" + editorId).children("#objectID").text();
					}
				}
			}else{
				objectId = jQuery("input[name='objectId']").val();
			}
			
			var data = jQuery(this).closest('figure.rcowidget').attr('data-rcowidget-saved');
			var wdata = JSON.parse(data.replace(/\|/g, '"'))
			var superModal = new SuperModal({ renderTo: document.body });
			superModal.confirm(RichEditorCustoNLS.Msg_Download, RichEditorCustoNLS.Title_Confirm, function (result) {
				if(result) {
					// ++VMA10 ZUD : IR-706896-3DEXPERIENCER2019x
					var fileName = wdata['rcoFileName'];
					fileName = fileName.replace(/</g, '&lt;');
					fileName = fileName.replace(/>/g, '&gt;');
					fileName = fileName.replace(/&/g, '&amp;');
					fileName = fileName.replace(/'/g, '&apos;');
					fileName = fileName.replace(/"/g, '&quot;');
									
					callCheckout(objectId, 'download', fileName, 'rco' ,'null', 'null', 'structureBrowser', 'APPDocuemntSummary', '');								
					// -- VMA10 ZUD : IR-706896-3DEXPERIENCER2019x
				}
		    });
	
	        event.stopPropagation();
			event.preventDefault();
	        event.stopImmediatePropagation();
	        //return false;
		}
		if(/* window.editableTable && editableTable.mode == 'view' || */ location.href.indexOf('emxForm.jsp') >= 0 && location.href.indexOf('mode=Edit') < 0){
			jQuery(window.editableTable ? '#mx_divBody' : document).on('dblclick', 'figure.rcowidget', downloadRCO);
		}
		
		
		return {
			downloadRCO : downloadRCO
		};
	}
);

var serverURLWithRoot = window.location.protocol + "//" + window.location.host + "/" + window.location.pathname.split( '/' )[1];
var RTF_FORMAT = 'rtf.gz.b64';
var HTML_FORMAT = 'html';

var CKEDITORSettings = new Object();

//dummy function required by toolbarswitch plugin
function CKeditor_OnComplete() {
	
}

//ck
//Create form Req and Test Case
//Args -
function checkMaxSize(string, restrictiveMode) {

    var MAX_SIZE = 3.8 * 1024 * 1024;

    if (restrictiveMode)
        MAX_SIZE = 1.8 * 1024 * 1024;

    if (string.length > MAX_SIZE) {
        alert(alertMaxSizeCK);
        return false;
    }

    return true;
}

//ck
//Properties form Req save 
//Args -

/**
 * Creates the RCO if needed.
 * @returns {Boolean} - false is not created
 */
function syncRCOContent() {

	// Loading ON
	getTopWindow().turnOnProgress();

    var aRcuListRaw = sessionStorage.getItem('rco_ckeditor_list');
    if (aRcuListRaw == undefined || aRcuListRaw == null || aRcuListRaw.length == 0)
        return false;

    var aRcuList = aRcuListRaw.split(' ');
    for (var i = 0; i < aRcuList.length; i++) {
    	if(!sessionStorage.getItem(aRcuList[i])) {
    		continue;
    	}
        var dataRcu = JSON.parse(sessionStorage.getItem(aRcuList[i]));
        var argsURL = '?objectId=' + dataRcu['rcoCurrentObjectId'] + '&filePath=' + encodeURIComponent(dataRcu['rcoPathTempFile']) +
                 '&refDocName=' + encodeURIComponent(dataRcu['rcoFileName']) + '&' + csrfParams;
        $.ajax({
            type: 'GET',
            url: '../resources/richeditor/res/checkinRCOFromTempFile' + argsURL,
            dataType: 'text',
            success: function(result) {
            	var objectId = JSON.parse(result).objectId;
            	// If you are inside a form
            	if (typeof rebuildView != 'undefined') {
            		
            		// Refresh the row to get the new richtext
                	var rowsToUpdate = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o='" + objectId + "']"),
                	rowsIdToUpdate = new Array();
                	for (var i = 0; i < rowsToUpdate.length; i++) {
                		rowsIdToUpdate.push(rowsToUpdate[i].getAttribute('id'));
                	}
                	emxEditableTable.refreshRowByRowId(rowsIdToUpdate);
            		rebuildView();
                	
                	// Refresh the HTML saved by CKEditor
                	var objectIdDiv = objectId.replace(/\./g, '');
                	function refreshCKeditorHTML() {
                		var content = jQuery('#contentCell_' + objectIdDiv).eq(0);
                		if (content.length == 0) {
                			setTimeout(refreshCKeditorHTML, 100);
                		} else {
                			CKControlsDict['CKEDITOR_html_' + objectIdDiv] = content.html();
                			
                			// Loading off
                			getTopWindow().turnOffProgress();
                		}
                	}
                	refreshCKeditorHTML();
            	}
            },
	        error: function(xhr, status, error){
	        	var message = typeof xhr.responseText == 'string' ? JSON.parse(xhr.responseText).status : xhr.responseText; 
	        	if(message.startsWith("Failed: ")) {
	        		message = message.substring("Failed: ".length);
	        	}
	        	alert(error + ":" + message);
            }
        });
        sessionStorage.removeItem(aRcuList[i]);
    }
    sessionStorage.removeItem('rco_ckeditor_list');
}



if(localStorage['debug.AMD']) {
	console.info("AMD: RichEditorCusto/RichEditorCusto.js global finish.");
}
