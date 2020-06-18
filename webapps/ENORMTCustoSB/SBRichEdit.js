//=================================================================
// JavaScript RichEdit.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//quickreview QYG           05:03:16    javascript refactoring, split from RichTextEditorStructure.js
//quickreview HAT1 ZUD      07:11:16    IR-437134-3DEXPERIENCER2018x: I can't modify Link type on HMTL Content View
//quickreview HAT1 ZUD      07:11:16    IR-441325-3DEXPERIENCER2018x: Hyperlink has no options of Target when modifying again.
//quickreview HAT1 ZUD      16:12:14    IR-357389-3DEXPERIENCER2018x fix R417-FUN048114: On mobile device (IPAD & Samsung galaxy Note) keyboard pop up everytime user click on any control given in toolbar of CKEditor of content attribute.
//quickreview HAT1 ZUD      17:02:16    IR-437663-3DEXPERIENCER2017x: Please translate the word of some tooltips into Japanese version 2.
//quickreview KIE1 ZUD	    17:03:09   IR-506731-3DEXPERIENCER2018x: R419-STP: XHTML editor is KO for customized object on structure browser
//quickreview KIE1 ZUD	    17:12:21   IR-568781-3DEXPERIENCER2018x: R420-iOS11_FUN075788: Inconsistency in the edit toolbar menus available on the creation page,Structure view and Properties page and in widget
//quickreview KIE1 ZUD	    19:05:08   IR-666677-3DEXPERIENCER2019x : RSP import with Reqtify, performance issue expanding the RSP tree

if(localStorage['debug.AMD']) {
	var _SBRichEdit_js = _SBRichEdit_js || 0;
	_SBRichEdit_js++;
	console.info("AMD: ENORMTCustoSB/SBRichEdit.js loading " + _SBRichEdit_js + " times.");
}

define('DS/ENORMTCustoSB/SBRichEdit', ['DS/RichEditorCusto/Util', 'DS/RichEditorCusto/RichEditorCusto'], function(Util, RichEditorCusto){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/SBRichEdit.js dependency loaded.");
	}
	
	// ONLY FOR SB AND SCE, if a RichTextColumn is present
	if (containsRichTextColumn()) {
	    // To manage RichText data with common operations
	    emxUICore.instrument(window, 'applyEdits2', null, eraseEditedRichText);
	    emxUICore.instrument(window, 'resetEdits', null, eraseEditedRichTextReset);
	    emxUICore.instrument(emxEditableTable, 'undo', null, undoRichTextChanges);

	}
	
	//To avoid conflict with BPS function
	emxUICore.instrument(window, 'getValue', function(obj) {
		if (obj == undefined) {
			var value = 1; // Default value in case of failure
			try {
				// Anonymous functions. Here we need to get the caller by getting the instrument function,
				// then the actual CKEditor anonymous function.
				value = arguments.callee.caller.caller.arguments[0];
			} catch(e) {
				// NOP
			}
			return [value];
		}
		return true;
	}, null);

	emxUICore.instrument(window, 'toggleSBWrap', beforeToggleSBWrap, null);

	if (isIE) {
		emxUICore.instrument(window, 'GetNextPage', null, afterRebuildView);
	}
	emxUICore.instrument(window, 'rebuildView', null, afterRebuildView);

	// KIE1 ZUD commented for two popup for printer friendley page against IR-338263-3DEXPERIENCER2017x
	//emxUICore.instrument(window, 'fpOpenPrinterFriendlyPage', fpOpenPrinterFriendlyPageRMT, null);

	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/SBRichEdit.js finish.");
	}
	
	return {};
});

/* RichText */
function containsRichTextColumn() {
    try {
        for (var i = 0; i < colMap.columns.length; i++) {
            if (colMap.columns[i].settings.isRichTextColumnRMT == 'true')
                return true;
        }
    } catch (ex) {
        // NOP
    }
    return false;
}
// VMA10 ZUD : IR-693748-3DEXPERIENCER2019x
function fpOpenPrinterFriendlyPage()
{
	fpOpenPrinterFriendlyPageRMT();
}

function trigger3DXMLEditMode(originalDiv, id3DXML, containerWidth, containerHeight) {
    $.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function(script, textStatus) {
        var id3DXMLDiv = id3DXML.replace(/\./g, ''); // FIXME size of the jquey container
        var XMLHTML = "<div id='resizable' class='ui-widget-content' style='width: " +
            containerWidth +
            "px; height: " + containerHeight + "px; padding: 0.5em;'>";
        XMLHTML += "<h3 class='ui-widget-header' style='text-align: center; margin: 0;'>" +
            id3DXML +
            "</h3>";
        XMLHTML += "<object type='application/x-3dxmlplugin' id='" + id3DXMLDiv +
            "' width='300' height='150' style='MARGIN: 0px' border='0'><param name='DocumentFile' value='D:/WS/EWST94/MajixHTML/docs/3DXML/HTML/3dxml_models/crank_shaft_fta.3dxml' /></object>";
        XMLHTML += "</div>";

        originalDiv.outerHTML = XMLHTML;

        $(function() {
            $("#resizable").resizable({
                maxHeight: 450,
                maxWidth: 550,
                minHeight: 100,
                minWidth: 100,
                aspectRatio: 16 / 9,
                resize: function(event, ui) {
                    $('#' + id3DXMLDiv).width(ui.size['width']);
                    $('#' + id3DXMLDiv).height(ui.size['height']);
                }
            });
        });
    });
}


//Append the CSS for the jQuery-UI
var cssId = 'jquery-ui-css-smoothness';
if (!document.getElementById(cssId)) {
 var head = document.getElementsByTagName('head')[0];
 var csslink = document.createElement('link');
 csslink.id = cssId;
 csslink.rel = 'stylesheet';
 csslink.type = 'text/css';
 csslink.href = '../requirements/styles/jquery-ui-smoothness.css';
 csslink.media = 'all';
 head.appendChild(csslink);
}

var RTFControlsDict = {};
var RTFEditedObjects = {};

/* JDIALOG */
var currentJDialogEditor = null;

/* CKEDITOR */
var CKControlsDict = {};


sessionStorage.setItem('checked_CKEDITOR_show_dialog', ' ');

function checked_CKEDITOR_show_dialog_function() {

    if (sessionStorage.getItem('checked_CKEDITOR_show_dialog') == ' ')
        sessionStorage.setItem('checked_CKEDITOR_show_dialog', 'checked');
    else
        sessionStorage.setItem('checked_CKEDITOR_show_dialog', ' ');
}



var dialogheight = 400,
dialogWidth = 900,
ckeditorMaximize = 670,
ckeditorRestore = 230,
ckeditorToolbar = 'Full';
//Global control for the dialog
var dialogIsMaximized = false;

//EditInWord
var richEditor;
require(['DS/RichEditor/RichEditor'], function(RichEditor){
	richEditor = new RichEditor();
});

function jDialogForCKEDITOR(strObjIDToLoad, type, format, characteristic, lud) {

    var editorDivID = strObjIDToLoad.replace(/\./g, '');
    
    if (!CKControlsDict['CKEDITOR_original_dialog_html_' + editorDivID]) {
        CKControlsDict['CKEDITOR_original_dialog_html_' + editorDivID] = $('#HTMLEditor_' + editorDivID)[
            0].outerHTML;
    }

    // If the content was edited before
    if ($('#HTMLEditor_' + editorDivID).length == 0) {
        $('#contentCell_' + editorDivID).after(CKControlsDict['CKEDITOR_original_dialog_html_' +
            editorDivID]);
    }

    if(richEditor.getPreferredEditor() == "Word" && !richEditor.isMobile()){ //EditInWord
    	editButtonCK = richEditor.nls["Label_EditInWord"];
    	if((characteristic & richEditor.RICH_TEXT_STREAM_CONST.READ_ONLY) != 0 || (characteristic & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) == 0 ){
    		editButtonCK = richEditor.nls["Label_OpenInWord"];
    	}
    }

    var buttonsjQueryHTMLView = {};
    if((characteristic & richEditor.RICH_TEXT_STREAM_CONST.READ_ONLY) == 0 && (characteristic & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) != 0 ||
    		richEditor.getPreferredEditor() == "Word" && !richEditor.isMobile()	) { //editable
        buttonsjQueryHTMLView[editButtonCK] = function() {
        	if((characteristic & richEditor.RICH_TEXT_STREAM_CONST.READ_ONLY) == 0 && (characteristic & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) != 0 ){
            	try{
                    editMode();
            	}
            	catch(ex){ //random BPS issue with localStorage
            		console.error(ex.stack);
            	}
        	}
        	//EditInWord
    		if(richEditor.getPreferredEditor() == "Word" && !richEditor.isMobile()) {
				if(type === "Requirement Proxy") {
					alert("This operation is not supported.")
					return;
				}

    			window.CKControlsDict = window.CKControlsDict || {};
        		richEditor.openRichTextInWord({
        			uid : strObjIDToLoad,
        			onClose : function(objectId, ooxml, html){
    				var editorDivID = objectId.replace(/\./g, '');
    				$('#HTMLEditor_' + editorDivID + ".ui-dialog-content").html(html);
    				window.CKControlsDict['CKEDITOR_modified_' + editorDivID] = true;
    				window.CKControlsDict['CKEDITOR_ooxml_' + editorDivID] = ooxml;
    				window.CKControlsDict['CKEDITOR_html_' + editorDivID] = html;
        		},
            		isNew : false,
            		ooxml : window.CKControlsDict['CKEDITOR_ooxml_' + editorDivID]
        		});
    		}
    		else{
                launchCKEDITORRMT(editorDivID);
    		}
        };
    }

    buttonsjQueryHTMLView[cancelButtonCK] = function() {
        currentJDialogEditor.dialog('close');
    };

    var buttonsjQueryHTMLEdit = {};
    if(richEditor.getPreferredEditor() == "Word" && !richEditor.isMobile()){ //EditInWord
        buttonsjQueryHTMLEdit[editButtonCK] = buttonsjQueryHTMLView[editButtonCK];
    }
    buttonsjQueryHTMLEdit[applyButtonCK] = function() {
        // If the content is not modified, we can leave directly
        if (CKControlsDict['CKEDITOR_modified_' + editorDivID] != true) {
            currentJDialogEditor.dialog('close');
            rebuildView();
            return;
        }

        // Sets the plain text
        var dom = document.createElement("DIV");
        //EditInWord
        if(richEditor.getPreferredEditor() == "Word" && !richEditor.isMobile()){
        	dom.innerHTML = CKControlsDict['CKEDITOR_html_' + editorDivID];
        }
        else{
        	dom.innerHTML = CKEDITOR.instances['CKEDITOR_' + editorDivID].getSnapshot();
        }
        CKControlsDict['CKEDITOR_text_' + editorDivID] = (dom.textContent || dom.innerText);

        // Inner function
        function endEditionCK() {
        	if(richEditor.getPreferredEditor() != "Word" || richEditor.isMobile()){  //EditInWord
	//++VMA10 added for IR-689358-3DEXPERIENCER2019
	            var div = document.createElement("DIV");
        		 div.innerHTML = CKEDITOR.instances['CKEDITOR_' + editorDivID].getData();
        		  for(var i=0; i<div.childNodes.length; i++) // ++VMA10 ZUD : IR-701200-3DEXPERIENCER2019x - forEach replaced with for loop because for each not working in IE
        		 {
        			 if(div.childNodes[i].tagName == "TABLE")
        			{
        				 if(div.childNodes[i].align=="center")
        				 {
        					 div.childNodes[i].style.margin = "auto";
        				 }
        			}
        			 
        		 }
        		
        		
	            CKControlsDict['CKEDITOR_html_' + editorDivID] = div.innerHTML;
	//--VMA10
        	}
        	
        	// > 4 MO
            if (checkMaxSize(CKControlsDict['CKEDITOR_html_' + editorDivID], false) == false)
            	return;
            
            updateXMLWithHTMLContent(strObjIDToLoad);
            setHTMLFromCKEDITOR(strObjIDToLoad);

            currentJDialogEditor.dialog('close');

            // Refresh the view
            rebuildView();
            
            $('#divRichTextContainer_' + editorDivID).parent().children('span:first').css('display', 'none');
        }

        // WARNING, RTF data detected, the save will delete the previous RTF content
        if (format == 'RTF' && (richEditor.getPreferredEditor() != "Word" || richEditor.isMobile())) {
                var r = window.confirm(strAlertSaveCK);
                if (r == true) {
                    endEditionCK();
                } else {
                    // NOP
                }
        } else {
            endEditionCK();
        }
    };

    buttonsjQueryHTMLEdit[cancelButtonCK] = function() {
        currentJDialogEditor.dialog('close');
        // Refresh the view
        rebuildView();
    };

    var buttonsjQueryHTML = buttonsjQueryHTMLView;

    // If we are already in edit mode
    if (editableTable.mode == "edit" && (characteristic & richEditor.RICH_TEXT_STREAM_CONST.READ_ONLY) == 0 && 
    							(characteristic & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) != 0) {
        buttonsjQueryHTML = buttonsjQueryHTMLEdit;
    }

    if(richEditor.isMobile()) {
    	ckeditorToolbar = "MaximizedCreation";
    	if(window.screen.availHeight > window.screen.availWidth) {
    		dialogheight = 400;
    		dialogWidth = 600;
    	}
        
    	// ++ HAT1 ZUD IR-357389-3DEXPERIENCER2018x FIX 
		var ckDIV = "";
       
        /* Android */
        window.addEventListener("resize", function() 
        {
        	ckDIV = $('.ui-dialog.ui-widget.ui-widget-content.ui-corner-all.ui-front.richTextContainer.ui-dialog-buttons.ui-draggable.ui-resizable')[0];

        	if(ckDIV == undefined)
        	{	
        		ckDIV = $('.ui-dialog.ui-widget.ui-widget-content.ui-corner-all.ui-front.richTextContainer.ui-dialog-buttons')[0];
        		
        	}
        	if(ckDIV != undefined)
        	{
	        	if(isLandScape())
	            {
	            	if(isKeyBoard())
	        		{
	            		ckDIV.style.top = "-55px";
	            		$(".cke_wysiwyg_frame.cke_reset").closest("div").css( "height", "55px" );
	        		}
	            }
	        	
	            if(!isKeyBoard() && (ckDIV.style.top == "-55px"))
	        	{
	                var strHeight1 = $(".ui-dialog-content.ui-widget-content.ui-dialog-normal").css("height");
	                if(strHeight1 == undefined)
	                {
		                strHeight1 = $(".ui-dialog-content.ui-widget-content.ui-dialog-maximized").css("height");
		                ckDIV.style.top = "0px";
	                }
	                else
                	{
		            	ckDIV.style.top = "25px";
                	}
	                var height1 = strHeight1.replace("px", "");
	                height1 = height1 - 60;
	                
	                $(".cke_wysiwyg_frame.cke_reset").closest("div").css( "height", height1+"px");
	            }
        	}
	    }, false);
	    	        
	    function isLandScape()
	    {
	    	return (window.screen.availHeight < window.screen.availWidth);
	    }
	    
	    function isKeyBoard()
	    {
	    	if(window.innerHeight < 300)
	    		return true;
	    	else
	    		return false;
	    }
    	// -- HAT1 ZUD IR-357389-3DEXPERIENCER2018x FIX 
    
    }

    // Dialog-extend options
    var dialogExtendOptions = {
        "closable": true,
        "maximizable": true,
        "minimizable": false,
        "beforeMaximize": function(evt) {
            	dialogIsMaximized = true;
                var id = evt.target.id.substring("HTMLEditor_".length);
                if (window.CKEDITOR && CKEDITOR.instances['CKEDITOR_' + id] != undefined)
				{
					CKEDITOR.instances['CKEDITOR_' + id].resize('100%', ckeditorMaximize);
					//++ VMA10 ZUD added-> IR-562729-3DEXPERIENCER2019x
					var val =evt.target.children[1].children[1].children[1].getAttribute('style').split('height: ')[1].split('px')[0];
					val = parseInt(val);
					val= val-30;
					var height = "height: "+val+"px;";
					evt.target.children[1].children[1].children[1].setAttribute('style', height);
					evt.target.children[1].children[1].children[1].getAttribute('style');							
						
				}
         },
        "beforeRestore": function(evt) {
            	dialogIsMaximized = false;
                var id = evt.target.id.substring("HTMLEditor_".length);
                if (window.CKEDITOR && CKEDITOR.instances['CKEDITOR_' + id] != undefined)
                    CKEDITOR.instances['CKEDITOR_' + id].resize('100%', ckeditorRestore + 30);
        }

    };

    var dialogOptions = {
        modal: true,
        resizable: false,
        height: dialogheight,
        width: dialogWidth,
        dialogClass: 'richTextContainer',
        buttons: buttonsjQueryHTML,
        close: function() {
        	dialogIsMaximized = false;

            try {
                CKEDITOR.instances['CKEDITOR_' + editorDivID].destroy(false);
            } catch (e) {
                // NOP
            }

            try {
                currentJDialogEditor.dialog('destroy').remove();
            } catch (e) {
                // NOP
            }
        }
    };

    currentJDialogEditor = $('#HTMLEditor_' + editorDivID).dialog(dialogOptions).dialogExtend(
        dialogExtendOptions);
    if((characteristic & richEditor.RICH_TEXT_STREAM_CONST.READ_ONLY) != 0 || (characteristic & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) == 0) { //readonly
    	return;
    }

    $('.ui-dialog-buttonpane button:contains(' + editButtonCK + ')').click(function() { //switch buttons to edit mode
//        if (CKControlsDict['Loaded'] != true) //comment out for EditInWord
//            return;
        currentJDialogEditor.dialog('option', 'buttons', buttonsjQueryHTMLEdit);
    });

	if(richEditor.getPreferredEditor() != "Word" || richEditor.isMobile()) {
	    // Runs CKEDitor
	    launchCKEDITORRMT(editorDivID, lud);
	}
	else{ //EditInWord
	    var htmlContent = '';
	    if (CKControlsDict['CKEDITOR_html_' + editorDivID] != undefined) {
	        htmlContent = CKControlsDict['CKEDITOR_html_' + editorDivID];
	    } else {
	        if (CKControlsDict['CKEDITOR_original_html_' + editorDivID] == null) {
	            CKControlsDict['CKEDITOR_original_html_' + editorDivID] = $('#HTMLEditor_' + editorDivID).html();
	        }
	        htmlContent = CKControlsDict['CKEDITOR_original_html_' + editorDivID];
	    }
	    $('.ui-dialog #HTMLEditor_' + editorDivID).html(htmlContent);
	}
}

function launchCKEDITORRMT(editorDivID, lud) {
    if (editableTable.mode != "edit") {
        return false;
    }
	require(['DS/CKEditor/CKEditor'], function(){//CKUpgrade
        CKControlsDict['Loaded'] = true;
    	launchCKEDITORRMTAync(editorDivID, lud);
	});
}

function launchCKEDITORRMTAync(editorDivID, lud) {
    if (CKControlsDict['Loaded'] != true) {
        return false;
    }

    var htmlContent = '';
    if (CKControlsDict['CKEDITOR_html_' + editorDivID] != undefined) {
        htmlContent = CKControlsDict['CKEDITOR_html_' + editorDivID];
    } else {
        if (CKControlsDict['CKEDITOR_original_html_' + editorDivID] == null) {
            CKControlsDict['CKEDITOR_original_html_' + editorDivID] = $('#HTMLEditor_' + editorDivID).html();
        }
        
        var convertorVersion = $("#objectInfo_" + editorDivID).children("#convertorVersion").text();
        var objectId = $("#objectInfo_" + editorDivID).children("#objectID").text();
        if(convertorVersion.indexOf("DOCX") >=0 || convertorVersion.indexOf("RTF") >= 0) {
            var characteristic =  parseInt(convertorVersion.split(';')[1]);
        	var isHTMLEditable = true;
        	//RTF or DOCX data that may require conversion to RCO, or may contain elements not supported by HTML editor
        	if(CKControlsDict['CKEDITOR_original_html_' + editorDivID].toLowerCase().indexOf('<img ') >= 0)
        	{
                $.ajax({
                    type : "GET",
                    url: "../resources/richeditor/res/HTMLConvert?objectId=" + objectId + "&tStamp=" + lud + "&" + csrfParams,
                    cache: true,
                    dataType : "text",
                    success : function(txt) {
                    	var r = JSON.parse(txt);
                    	var html = r.html;
                    	if(!html) {
                    		html = "";
                    	}
                    	isHTMLEditable = r.isHTMLEditable;
                    	if(isHTMLEditable || richEditor.getPreferredEditor() != "Word") {
                        	CKControlsDict['CKEDITOR_original_html_' + editorDivID] = html;
                    	}
                    },
                    async: false
                });
        	}
        	if(!isHTMLEditable && richEditor.getPreferredEditor() == "Word") {//not editable on mobile
            	alert(richEditor.nls["Msg_NoHTMLEditing"]);
            	return;
        	}
        }
        htmlContent = CKControlsDict['CKEDITOR_original_html_' + editorDivID];
    }

    $('.ui-dialog #HTMLEditor_' + editorDivID).html(
        "<textarea data-original-title=' ' style='display:none;' id=\"CKEDITOR_" + editorDivID +
        "\" name=\"CKEDITOR_" + editorDivID + "\">" + htmlContent + "</textarea>");

    var currentEditor = CKEDITOR.instances['CKEDITOR_' + editorDivID];
    if (currentEditor) {
        // In a jquery dialog, we have to set a flag to false to avoid a crash when you try to reopen the dialog
        try {
            CKEDITOR.instances['CKEDITOR_' + editorDivID].destroy(false);
        } catch (e) {
            // NOP
        }
    }
    
    // ++ HAT1 ZUD: HL -  To enable Content column for Test Cases. 
    // Custom plugins
    var extraPlugins = ['maximize', 'panelbutton', 'colorbutton', 'quicktable', /* 'toolbarswitch', */ 'base64image', 'lineutils', 'widget', 'rcowidget'],
                             extraPluginsConfig = ['colorbutton', 'quicktable', /* 'toolbarswitch', */ 'base64image', 'rcowidget'].join(',');
    
	var CKEDITOR_EXTRA_PLUGIN_PATH = '../../RichEditorCusto/assets/ckeditor/plugins/';
    //extraPlugins.map(function(plugin){
    //	CKEDITOR.plugins.addExternal(plugin, CKEDITOR_EXTRA_PLUGIN_PATH + plugin + '/', 'plugin.js');
    //});
    CKEDITOR.plugins.addExternal('rcowidget', CKEDITOR_EXTRA_PLUGIN_PATH + 'rcowidget' + '/', 'plugin.js'); //CKUpgrade
    
    // -- HAT1 ZUD: HL -  To enable Content column for Test Cases. 
        
    // Customize link
	CKEDITOR.on('dialogDefinition', function(ev) {
	    // Take the dialog name and its definition from the event data.
	    var dialogName = ev.data.name;
	    var dialogDefinition = ev.data.definition;

	    // Check if the definition is from the dialog we're
	    // interested on (the "Link" dialog).
	    if (dialogName == 'link') {
	    	if(dialogDefinition.getContents('target') !=null)
			{
				// Set the default target and remove the others
				var target = dialogDefinition.getContents('target').get('linkTargetType');
				target['default'] = '_blank';
				
				var length = target.items.length;
				// ++ HAT1 ZUD: IR-441325-3DEXPERIENCER2018x fix
				if(length > 3)
				{
					target.items[0] = target.items[3];
					for (var i = 0; i < length - 1; i++) 
					{
						target.items.pop();
					}
				}
				// -- HAT1 ZUD: IR-441325-3DEXPERIENCER2018x	    	
	    	}
	    	// Set the default link type
	    	var linkType = dialogDefinition.getContents('info').get('linkType').items;
	    	// ++ HAT1 ZUD: IR-437134-3DEXPERIENCER2018x:FIX
	    	if(linkType.length >2)
	    	{	
	    		linkType[1] = linkType[2];
	    		linkType.pop();
	    	}
	    	// -- HAT1 ZUD: IR-437134-3DEXPERIENCER2018x

	    }
	});
	
	var CKEDitorHeight = ckeditorRestore;
	if (dialogIsMaximized)
		CKEDitorHeight = ckeditorMaximize;
			
    // HAT1 ZUD: HL -  To enable Content column for Test Cases. 			
    CKControlsDict['CKEDITOR_' + editorDivID] = CKEDITOR.replace('CKEDITOR_' + editorDivID, {
    	extraPlugins: extraPluginsConfig,
        customConfig: '../../RichEditorCusto/assets/ckeditor/config.js',
        toolbar: ckeditorToolbar,
        //smallToolbar: ckeditorToolbar,
        //maximizedToolbar: ckeditorToolbar,
        height: CKEDitorHeight // The height 100% is not supported by CKEditor
    });

    CKControlsDict['CKEDITOR_' + editorDivID].on('change', function() {
        CKControlsDict['CKEDITOR_modified_' + editorDivID] = true;
    });
}

function setHTMLFromCKEDITOR(objectId) {
    var editorDivID = objectId.replace(/\./g, '');

    RTFEditedObjects[objectId + '_b'] = true;
    $('#contentCell_' + editorDivID).html(CKControlsDict['CKEDITOR_html_' + editorDivID]);
    RTFEditedObjects[objectId + '_d'] = $('#divRichTextContainer_' + editorDivID)[0].outerHTML;

    // Refresh the view
    var  newpostDataXML = emxUICore.createXMLDOM();
    newpostDataXML.loadXML('<mxRoot><htmlContent><![CDATA[' + RTFEditedObjects[objectId + '_d'] + ']]></htmlContent></mxRoot>');
    refreshCellWithHTMLContentRMT(newpostDataXML, objectId, $('#contentCell_' + editorDivID));

    turnOffProgress();
}

/*
 * When the RichText is modified, we call this function to update the
 * postDataXML to save the new RichText content.
 */
function updateXMLWithHTMLContent(strObjectId) {

    var editorDivID = strObjectId.replace(/\./g, '');

    var RTFRowObject = getElement("object");
    RTFRowObject.setAttribute("rowId", dataObjectRTFDict[strObjectId + '_id']);
    RTFRowObject
        .setAttribute("objectId", dataObjectRTFDict[strObjectId + '_o']);
    RTFRowObject.setAttribute("relId", dataObjectRTFDict[strObjectId + '_r']);
    RTFRowObject.setAttribute("parentId", dataObjectRTFDict[strObjectId + '_p']);
    RTFRowObject.setAttribute("markup", "changed");
    RTFRowObject.setAttribute("level", "1");

    var RTFColumn = getElement("column");
    RTFColumn.setAttribute("name", "RichTextContent");
    RTFColumn.setAttribute("isRichTextColumnRMT", "true");
    RTFColumn.setAttribute("edited", "true");
    var encodedDataToSend = CKControlsDict['CKEDITOR_html_' + editorDivID];

    //EditInWord
    var ooxml = CKControlsDict['CKEDITOR_ooxml_' + editorDivID];
    if(richEditor.getPreferredEditor() == "Word" && !richEditor.isMobile()) {
    	encodedDataToSend = ooxml; 
    }
    else{
	    // Always encode in base64 in order to bypass the default input filtering
	    // We have our own input filtering on the server side
	    var UTF8Input = strToUTF8Arr(encodedDataToSend);
	    encodedDataToSend = base64EncArr(UTF8Input);
    }

    //JX5 content text is not correctly formatted
    var domElement =  document.createElement("div");
    domElement.innerHTML = CKControlsDict['CKEDITOR_html_' + editorDivID];
    var cText = domElement.textContent || domElement.innerText || CKControlsDict['CKEDITOR_text_' + editorDivID];
    
    var UTF8InputContentText = strToUTF8Arr(cText);
    encodedDataToSendContentText = base64EncArr(UTF8InputContentText);
    //
    
    //IR-556378-3DEXPERIENCER2018x: encode whole string with base64 to bypass default input filtering and use our own input filtering
    var allText = serverURLWithRoot + ((richEditor.getPreferredEditor() == "Word" && !richEditor.isMobile()) ? "|ooxml|" : "|html|") + encodedDataToSend + "|" + //EditInWord
	encodedDataToSendContentText;
    var contentText = oXML.createTextNode(base64EncArr(strToUTF8Arr(allText)));
    RTFColumn.appendChild(contentText);

    RTFRowObject.appendChild(RTFColumn);
    postDataXML.firstChild.appendChild(RTFRowObject);

    var rowToUpdate = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id='" + dataObjectRTFDict[
        strObjectId + '_id'] + "']");
    rowToUpdate.setAttribute('status', 'changed');

    var rowChildList = rowToUpdate.childNodes;
    var nbColumns = 0;

    for (nbColumns = 0; nbColumns < colMap['columns'].length; nbColumns++) {
        if (colMap['columns'][nbColumns].settings['isRichTextColumnRMT'] == 'true') {
            break;
        }
    }

    rowChildList[nbColumns].appendChild(oXML.createTextNode(' '));
    rowChildList[nbColumns].setAttribute('edited', 'true');
    rowChildList[nbColumns].setAttribute('d', ' ');
    rowChildList[nbColumns].setAttribute('newA', ' ');
}



/** Load RTF Data **/
function loadStructureRichTextData() {
    loadRichTextData(0);
    
	  // ++VMA10 - Added to reflect same color and bg-color in span as in CKEditor
  var arrSpans =  $(".cke_contents span");
  for(var  i = 0;  i< arrSpans.length ; i++)
	{ 

	  
	  if(arrSpans[i].attributes[0].value.substring(0,5) == "color")
		{
		  var textColor = arrSpans[i].attributes[0].value.substring(0,13) +" !important;";
		  arrSpans[i].attributes[0].value= textColor;
		  
		}else if(arrSpans[i].attributes[0].value.substring(0,16)=="background-color")
		{
		try{
			 var bgColor = arrSpans[i].parentElement.attributes[0].value;
			 var colorNew = arrSpans[i].attributes[0].value.substring(0,24) +"; "+bgColor;
			 arrSpans[i].attributes[0].value= colorNew;
			}catch(err){
			
			}
		}
	}
	/*--VMA10*/
}

var loadingImage = [];
var ObjIdAlreadyInProcess = new Map();
var MapForRefreshCheck = new Map();

function loadRichTextData(startIndex) {

    // We load 5 images at the same time here
    var LOADING_LIMIT = 15;
	var ObjectIdList = [];
	var CurrentImageList = new Map();
    // From emxUICore.instrument
    if (startIndex == undefined)
        startIndex = 0;

    if (startIndex == 0) 
		loadingImage = jQuery(".richTextPlaceHolder");
	

    if (startIndex >= loadingImage.length || loadingImage.length == 0)
        return;
	var ObjId = "";
	var timeStamp = 0;
    for (var i = 0; i <= LOADING_LIMIT && startIndex < loadingImage.length; i++) {
        var currentElement = loadingImage.eq(startIndex);
		ObjId = currentElement.attr("data-objectId");
		if(ObjIdAlreadyInProcess.size == 0 || !(ObjIdAlreadyInProcess.get(ObjId) == "InProcess"))
		{

			ObjectIdList[i] = ObjId;
			CurrentImageList.set(ObjectIdList[i],currentElement);
			ObjIdAlreadyInProcess.set(ObjectIdList[i],"InProcess");
			MapForRefreshCheck.set(ObjectIdList[i],"InProcess");
			startIndex += 1;
			//Compute Time Stamp for list
			timeStamp = timeStamp + parseInt(CurrentImageList.get(ObjId).attr("data-timeStamp"));
		}
        // Style for RichText if necessary
        currentElement.parent().css("vertical-align", "top");
    }
	if(ObjectIdList.length > 0)
		getHTMLContentFromObjectList(CurrentImageList , ObjectIdList,timeStamp);
	/*getHTMLContentFromRTF(currentElement, currentElement.attr("data-objectId"),
            currentElement.attr("data-timeStamp"), currentElement.attr("data-convertor"));*/
			

    setTimeout(function() {
        loadRichTextData(startIndex);
    }, TIMEOUT_VALUE * 4);
}

/* 
 * JX5 Start : When bps wrap command is called, make sure the rich text is not expanded
 */
function beforeToggleSBWrap() {

    // Check the session storage setting
    if (sessionStorage.getItem('structureBrowser_is_expanded_RT') == null)
        sessionStorage.setItem('structureBrowser_is_expanded_RT', 'false');


    // The Rich Text is expanded, we need to collapse it
    if (sessionStorage.getItem('structureBrowser_is_expanded_RT') !== 'false') {
        expandRichTextContentFromDynaTree(true);
        sessionStorage.setItem('structureBrowser_is_expanded_RT', 'false');
    }

}

// JX5 end

/* Decorator */
function mouseoverForSBRMT() {
	jQuery('#bodyTable,#treeBodyTable').on('mouseover', '.richTextContainer', function(event) {
		$(this).find('.richTextIconRMT').show();
	});
	
	jQuery('#bodyTable,#treeBodyTable').on('mouseout', '.richTextContainer', function(event) {
		$(this).find('.richTextIconRMT').hide();
	});
}

/** To allow the user to see the RTF content within the printer friendly page **/
function fpOpenPrinterFriendlyPageRMT() {
    var aRowNodes = emxUICore.selectNodes(oXML,
        "/mxRoot/rows//r[not(@calc) and not(@rg)]");
    outputFormat = "HTML";

    // Added for structure compare
    if (isStructureCompare != "TRUE" && calRowsPresent != "true") {
        fillupColumns(aRowNodes, 0, aRowNodes.length, outputFormat);
    }

    var XSLT = "emxFreezePanePrinterFriendly.xsl";
    var XSLT_DOM = emxUICore.getXMLData(XSLT);
    var strHTML = emxUICore.transformToText(oXML, XSLT_DOM);
    var strFeatures = "scrollbars=yes,toolbar=yes,location=no,resizable=yes";
    var win = showNonModalDialog('emxBlank.jsp','','',true,true,'Medium');
    //var win = window.open('emxBlank.jsp', '_blank', strFeatures);
    win.document.open('text/html', '_blank');

    var position = strHTML.indexOf('emxUICore.js"></script>') + 23;
    var scriptsToInsert = '<script>var csrfParams="' + csrfParams + '"</script>' +
        '<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>' +
        '<script src="../webapps/AmdLoader/AmdLoader.js"></script>' + 
        '<script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>' + 
        '<script src="../webapps/WebappsUtils/WebappsUtils.js"></script>' + 
        '<script type="text/javascript">require(["DS/ENORMTCusto/ENORMTCusto"]);</script>';

    win.document.write([strHTML.slice(0, position), scriptsToInsert, strHTML.slice(position)].join(''));
 //KIE1 ZUD TSK447636     
    //alert("before win.document.closeWindow(); ");
    win.document.closeWindow();

    var isMoz = strUserAgent.indexOf("gecko") > -1;
    if (isMoz) {
        win.document.oncontextmenu = function() {
            return false;
        };
    } else {
        win.document.location.reload();
    }
    return false;
}

//ck
//create Form Load, close form Requirement 
/* ONLY FOR IE, please use a real browser */
function afterRebuildView() {
    require(['DS/RichEditorCusto/RichEditorCusto'], function(RichEditorCusto){
        jQuery('div#mx_divBody').find('figure.rcowidget').on('dblclick', RichEditorCusto.downloadRCO);
    })

	if (!isIE)
		return;
	
	var richTextColumn = colMap['columns']['RichTextContent'];
	if (!richTextColumn)
		return;
	
	var tds = jQuery('#bodyTable td[position="' + richTextColumn.index + '"]');
	if (tds.length == 0)
		tds = jQuery('#treeBodyTable td[position="' + richTextColumn.index + '"]');
	
	for (var i = 0; i < tds.length; i++) {
		
		var placeHolder = jQuery('.richTextPlaceHolderIE', tds[i]);
		if (placeHolder.length != 1)
			continue;
		
		// Create a DOM from HTML
		var dom = jQuery(placeHolder[0].textContent).get(0);
		
		// Remove the old content
		tds[i].removeChild(placeHolder[0]);
		
		// Set the new DOM
		tds[i].appendChild(dom);
	}
	syncAllRowsSB();
}

//ck
//Req Structure view.
/*
 * RTF Control for SB Author: T94
 */

var dataObjectRTFDict = {};
function getHTMLContentFromObjectList(jCurrentImageList, objectIDList, timeStampObject) {
    $.ajax({
        type : "GET",
        url: "../resources/richeditor/res/HTMLForList?objectIdList=" + objectIDList + "&tStamp=" + timeStampObject,
        cache: true,
        dataType : "text",
        success : function(txt) {
			//alert(txt);
			
			var objList = JSON.parse(txt);
			var data = objList.RequirementIds;
			data = JSON.parse(data);
			for(var i in data)
			{
				var r = JSON.parse(data[i]);
				var html = r.html;
				if(!html) {
					html = "";
					}

				if((r.flags & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) == 0) {
        		html = richEditor.nls["Msg_NoPreview"];
				}
        	
        	var format = r.persistedFormat + ";" + r.flags;
        	
        	var strType = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='" + objectIDList[i] + "']").getAttribute('type');
        	var strObjectName = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='" + objectIDList[i] + "']/c/text()").nodeValue;
   
			strObjectName = encodeXML(strObjectName);
   
            var conversionIDDiv = objectIDList[i].replace(/\./g, "");
            html = "<div style=\"display:none;\" id=\"objectInfo_" + conversionIDDiv + "\">"
                                + "<div id='objectID'>" + objectIDList[i] + "</div>"
                                + "<div id='objectType'>" + strType + "</div>"
                                + "<div id='lud'>" + r.lud + "</div>"
                                + "<div id='convertorVersion'>" + format + "</div>" 
                            + "</div>" 
                            + "<div title=\"" + strObjectName + "\" style='display:none;' id=\"WORDEditor_" + conversionIDDiv + "\" >"
                            + "</div>"
                            + "<div title=\"" + strObjectName + "\" style='display:none;' id=\"HTMLEditor_" + conversionIDDiv + "\">" + html
                            + "</div>"
                            + "<div id='contentCell_" + conversionIDDiv + "' class='cke_contents cke_reset'>" + html + "</div>";

            var newpostDataXML = emxUICore.createXMLDOM();
            newpostDataXML.loadXML('<mxRoot><htmlContent><![CDATA[' + html + ']]></htmlContent></mxRoot>');
            emxUICore.checkDOMError(newpostDataXML);
            refreshCellWithHTMLContentRMT(newpostDataXML, objectIDList[i], jCurrentImageList.get(objectIDList[i]));
			
			 // Style for RichText if necessary
            jCurrentImageList.get(objectIDList[i]).parent().css("display", "block");
				
			}  	
        }
    });
}

function encodeXML(xmlValue)
{
	xmlValue = xmlValue.replace(/</g, '&lt;');
	xmlValue = xmlValue.replace(/>/g, '&gt;');
	xmlValue = xmlValue.replace(/&/g, '&amp;');
	xmlValue = xmlValue.replace(/'/g, '&apos;');
	xmlValue = xmlValue.replace(/"/g, '&quot;');
	
	return xmlValue;
}
function getHTMLContentFromRTF(jCurrentImage, objectID, timeStampObject, convertorVersion) {
    $.ajax({
        type : "GET",
        url: "../resources/richeditor/res/HTML?objectId=" + objectID + "&tStamp=" + timeStampObject,
        cache: true,
        dataType : "text",
        success : function(txt) {
        	var r = JSON.parse(txt);
        	var html = r.html;
        	if(!html) {
        		html = "";
        	}
        	if((r.flags & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) == 0) {
        		html = richEditor.nls["Msg_NoPreview"];
        	}
        	
        	var format = r.persistedFormat + ";" + r.flags;
        	
        	var strType = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='" + objectID + "']").getAttribute('type');
        	var strObjectName = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='" + objectID + "']/c/text()").nodeValue;
			strObjectName = encodeXML(strObjectName);	
			
            var conversionIDDiv = objectID.replace(/\./g, "");
            html = "<div style=\"display:none;\" id=\"objectInfo_" + conversionIDDiv + "\">"
                                + "<div id='objectID'>" + objectID + "</div>"
                                + "<div id='objectType'>" + strType + "</div>"
                                + "<div id='lud'>" + r.lud + "</div>"
                                + "<div id='convertorVersion'>" + format + "</div>" 
                            + "</div>" 
                            + "<div title=\"" + strObjectName + "\" style='display:none;' id=\"WORDEditor_" + conversionIDDiv + "\" >"
                            + "</div>"
                            + "<div title=\"" + strObjectName + "\" style='display:none;' id=\"HTMLEditor_" + conversionIDDiv + "\">" + html 
                            + "</div>"
                            + "<div id='contentCell_" + conversionIDDiv + "' class='cke_contents cke_reset'>" + html + "</div>";

            var newpostDataXML = emxUICore.createXMLDOM();
            newpostDataXML.loadXML('<mxRoot><htmlContent><![CDATA[' + html + ']]></htmlContent></mxRoot>');
            emxUICore.checkDOMError(newpostDataXML);
            refreshCellWithHTMLContentRMT(newpostDataXML, objectID, jCurrentImage);
            // Style for RichText if necessary
            jCurrentImage.parent().css("display", "block");
        }
    });
}


function refreshCellWithHTMLContentRMT(oXMLHTML, oClientData, oHTTP) {
	
	delete MapForRefreshCheck.delete(oClientData);
	if(MapForRefreshCheck.size ==0)
	{
		ObjIdAlreadyInProcess.clear();
		MapForRefreshCheck.clear();
	}
    var valuePath = "/mxRoot/htmlContent/text()";
    var value = emxUICore.selectSingleNode(oXMLHTML, valuePath).nodeValue;

    // Printer friendly case
    if (typeof currentColumnPosition == 'undefined') {
        oHTTP.replaceWith(value);
        return true;
    }

    var jRow = oHTTP.parents("tr:first");

    // If the row is not there, it means the irch text is already loaded
    if (jRow.length == 0)
    	return;
    
    oHTTP.parents("td:first").children('span:first').css('display', 'none');
    
    // Save some data about the current object, and the current row
    dataObjectRTFDict[oClientData + '_id'] = jRow.attr("id");
    dataObjectRTFDict[oClientData + '_o'] = oClientData;
    dataObjectRTFDict[oClientData + '_r'] = jRow.attr("r");
    dataObjectRTFDict[oClientData + '_p'] = jRow.attr("r");

    dataObjectRTFDict[oClientData + '_td'] = oHTTP.parents("td:first").children(':first');

    var richTextColumn = colMap['columns']['RichTextContent'],
    objectData = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='" + oClientData + "']");
    
    var objectDataChildNodes = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o='" + oClientData + "']/child::c");
    
    if (value.indexOf('richTextContainer') == -1)
    	value = setDivDecorator(value, oClientData);
    
    if (RTFEditedObjects[oClientData + '_b'] == true) {
        value = RTFEditedObjects[oClientData + '_d'];
        value = value.replace('iconActionRichTextEditorHTML.png', 'iconActionEdit.gif');
        value = value.replace('iconActionRichTextEditor.png', 'iconActionEdit.gif');
    }
    
    var children = objectDataChildNodes[richTextColumn.index - 1].childNodes;
    
    // Remove the old content
    if (children.length == 1) {
    	objectDataChildNodes[richTextColumn.index - 1].
		removeChild(objectDataChildNodes[richTextColumn.index - 1].firstChild);
    }
    else {
	    for (var i = 0; i < children.length; i++) {
	    	try {
	    		children[i].getAttribute('class');
	    	} catch(e) {
	    		continue;
	    	}
	    	
	    	if (children[i].getAttribute('class') == 'richTextContainer' || children[i].getAttribute('class') == 'richTextPlaceHolderIE')
	    		objectDataChildNodes[richTextColumn.index - 1].
	    		removeChild(children[i]);
	    }
    }
    
    if (!isIE) {
    	var parser = new DOMParser();
    	var xmlDoc = parser.parseFromString(value, 'text/html')
    	// Get html, body, and richText
        var xmlNode = xmlDoc.firstChild.childNodes[1].firstChild;
        objectDataChildNodes[richTextColumn.index - 1].appendChild(xmlNode);
    } else {
	    var xmlDoc = XMLHelper.CreateXMLDocument();
	    xmlDoc.async = false;
	    xmlDoc.loadXML('<div class="richTextPlaceHolderIE"><![CDATA[' + value + ']]></div>');
	    
	    // Get html
	    var xmlNode = xmlDoc.firstChild;
	    objectDataChildNodes[richTextColumn.index - 1].appendChild(xmlNode);
    }
    
    objectDataChildNodes[richTextColumn.index - 1].setAttribute('a', 'richText');
    
    var newCell = jQuery(value);
    dataObjectRTFDict[oClientData + '_td'].replaceWith(newCell);
    dataObjectRTFDict[oClientData + '_td'] = newCell;
    
    if (jRow.attr("id") != undefined) {
        var jTreeRow = jQuery("#" + jRow.attr("id").replace(/\,/g, '\\,'), jQuery("#mx_divTreeBody")).first();
        var jBodyRow = jQuery("#" + jRow.attr("id").replace(/\,/g, '\\,'), jQuery("#mx_divTableBody")).first();

        var newHeight = Math.max(jTreeRow.height(), jBodyRow.height());

        jTreeRow.height(newHeight);
        jBodyRow.height(newHeight);
    }
}


function setDivDecorator(strHTML, objectID) {
    // Get information about the current object
    var strType = $('#objectType', strHTML).html();
    var lud = $('#lud', strHTML).html();
    var convertorVersion = $('#convertorVersion', strHTML).html();
	var strTypeOnToolTip = "";
    strType = strType != null ? strType : '';
    
    // ++ HAT1 ZUD 16:12:13  IR-437663-3DEXPERIENCER2017x fix
    if(strType == "Requirement")
    	strTypeOnToolTip = requirementType;
    else if(strType == "Comment")
    	strTypeOnToolTip = commentType;
    else if(strType == "Test Case")
    	strTypeOnToolTip = testCaseType;
    
    // -- HAT1 ZUD 16:12:13  IR-437663-3DEXPERIENCER2017x fix

    
    lud = lud != null ? lud : 0;
    convertorVersion = convertorVersion != null ? convertorVersion : '';

    // Inner function
    function showRichTextIcon(format, editorDivID, characteristic) {
        var richTextIcon =
            "<div class='richTextIconRMT' style='display: inline-block; position: absolute; top: 0px; right: " +
            "0px; left: auto; margin-left: 0; display:none;'>" +
            "<a href=\"#\" onclick=\"openRTFEditorRMT('" + objectID + "', '" + strType + "'," + lud +
            ", '" + format + "'," + characteristic + "); return false; \">";

        /* We use 2 different icons, one for RTF content, and another one for HTML content */
        if (format == 'HTML')
            richTextIcon += "<img title='XHTML' id='iconRichText_" + editorDivID +
            "' src='../requirements/images/iconActionRichTextEditorHTML.png' /></a></div></div>";
        else if (format == 'RTF')
            richTextIcon += "<img title='RTF' id='iconRichText_" + editorDivID +
            "' src='../requirements/images/iconActionRichTextEditor.png' /></a></div></div>";
        else 
            richTextIcon += "<img title='DOCX' id='iconRichText_" + editorDivID +
            "' src='../requirements/images/iconActionRichTextEditorDOCX.png' /></a></div></div>";

        return richTextIcon;
    }

    // If the RichText has to be expanded
    var heightRTContainer = '55px';
    if (sessionStorage.getItem('structureBrowser_is_expanded_RT') == 'true') {
        heightRTContainer = 'none';
    }
    var editorDivID = objectID.replace(/\./g, '');

    //var isHTML = convertorVersion == 'None' || (convertorVersion == 'New' && richEditor.getPreferredEditor() != "Word");
    //var format = isHTML ? 'XHTML' :
    //				convertorVersion == 'Aspose.RTF' ? 'RTF' : 'DOCX';
    var format = convertorVersion.split(';')[0];
    var characteristic =  parseInt(convertorVersion.split(';')[1]);

    var functionDblClickToEdit = '\"openRTFEditorRMT(\'' + objectID + '\', \'' + strType + '\', \'' +
        lud + '\', \'' + format + '\',' + characteristic + ')\"';
    var decoratedHTML = "<div class='richTextContainer' title='" + dblclkString + " " + strTypeOnToolTip + " - " +
    	format + "' id='divRichTextContainer_" + editorDivID + "' style='max-height:" +
        heightRTContainer + "; min-height: 20px; min-width: " +
        "50px; overflow: hidden; position: relative;' ondblclick=" + functionDblClickToEdit + ">";
    decoratedHTML += strHTML;
    decoratedHTML += showRichTextIcon(format, editorDivID, characteristic);
    return decoratedHTML;
}

//function eraseEditedRichText()
//Moved to ..productline/RichtextEditorCommon.js


function eraseEditedRichTextReset() {
  for (var elem in RTFControlsDict) {
      RTFControlsDict[elem].CancelEditing();
  }

  CKControlsDict = {};
  RTFEditedObjects = {};
}

function undoRichTextChanges(aRowsChecked, withValidation) {
  for (var i = 0; i < aRowsChecked.length; i++) {
      var objectId = aRowsChecked[i].getAttribute("o");
      var editorDivID = objectId.replace(/\./g, '');

      RTFEditedObjects[objectId + '_b'] = false;
      removeXMLWithRTFContent(objectId);

      if (RTFControlsDict['WORDEditor_' + editorDivID] != undefined) {
          RTFControlsDict['WORDEditor_' + editorDivID].CancelEditing();
      } else if (CKControlsDict['CKEDITOR_html_' + editorDivID] != undefined) {
          CKControlsDict['CKEDITOR_html_' + editorDivID] = undefined;
      }
  }
}

//ck
//Requirement structure view save
/** For RichText, before an applyEdit **/
function eraseEditedRichText() {

	
  if (!checkErrorAfterApplyEdit())
      return false;

  // We can end the edition for all controls
  for (var elem in RTFControlsDict) {
      RTFControlsDict[elem].FinishEditing();
  }

  RTFEditedObjects = {};
}

function openRTFEditorRMT(strObjIDToLoad, strType, lud, format, characteristic) {	

    $.cachedScript("../requirements/scripts/plugins/jquery.ui-RMT.js").done(function() {
        $.cachedScript("../requirements/scripts/plugins/jquery.dialogextend-RMT.js").done(
        		
            function() {
                var newContent = getPostDataXMLRTFData(strObjIDToLoad);
                jDialogForCKEDITOR(strObjIDToLoad, strType, format, characteristic, lud);
            });
    });
}

//ck
//Req Structure view.

function getPostDataXMLRTFData(objectId) {

  var childList = postDataXML.firstChild.childNodes;
  for (var i = 0; i < childList.length; i++) {
      if (objectId == childList[i].getAttribute("objectId")) {
          var rowChildList = childList[i].childNodes;
          for (var j = 0; j < rowChildList.length; j++) {
              if (rowChildList[j].getAttribute("isRichTextColumnRMT") == "true") {
                  return rowChildList[j].text;
              }
          }
      }
  }
  return null;
}

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/SBRichEdit.js global finish.");
}
