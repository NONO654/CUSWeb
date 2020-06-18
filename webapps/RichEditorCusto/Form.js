//=================================================================
// JavaScript Form.js
// rich text related functions specific to Form.
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
// quickreview HAT1 ZUD  15:12:16  :  HL -  To enable Content column for Test Cases. 
// quickreview QYG       16:05:03    javascript refactoring, split from RichTextEditorForm.js
// quickreview KIE1 ZUD  18:01:18  : IR-568781-3DEXPERIENCER2018x : R420-iOS11_FUN075788: Inconsistency in the edit toolbar menus available on the creation page,Structure view and Properties page and in widget
// quickreview KIE1 ZUD 18:11:21 :IR-646433-3DEXPERIENCER2019x: Not able to modify properties of a ‘Requirement’ on Mozilla Firefox.

if(localStorage['debug.AMD']) {
	var _RichEditorForm_js = _RichEditorForm_js || 0;
	_RichEditorForm_js++;
	console.info("AMD: RichEditorCusto/Form.js loading " + _RichEditorForm_js + " times.");
}

	define('DS/RichEditorCusto/Form', [
	       'DS/RichEditorCusto/Util', 
	       'DS/RichEditorCusto/RichEditorCusto', 
	       'DS/RichEditor/RichEditor',
	       'css!DS/RichEditorCusto/assets/css/Form.css'], function(Util, RichEditorCusto, RichEditor){
		if(localStorage['debug.AMD']) {
			console.info("AMD: RichEditorCusto/Form.js dependency loaded.");
		}
		    // Attach some methods to treat the saved data
		$.getScript("../webapps/RichEditorCusto//Util.js", function (){
			emxUICore.instrument(window, 'saveCreateChanges',setRichTextContent, null);
		    jQuery(function() {
		        emxUICore.instrument(window, 'submitPage', setRichTextContent, null);
		        
		    	//$('form').attr('enctype', 'multipart/form-data'); //not supported
			});
		   	
		});
	    
		if(localStorage['debug.AMD']) {
			console.info("AMD: RichEditorCusto/Form.js finish.");
		}
		return {};
	});
//var richEditor;
//require(['DS/RichEditor/RichEditor'], function(RichEditor){
//	richEditor = new RichEditor();
//});

var timeStamp = typeof timeStamp == "string" ? timeStamp : jQuery("#timeStamp").val();
var fromCreateForm = location.href.indexOf("emxCreate.jsp") >= 0; 

function containsRichTextField() {
    try {
        var fieldsArr = FormHandler.Fields.ToArray();
        for ( var i = 0; i < fieldsArr.length; i++) {
            var settingRTF = fieldsArr[i].Settings.Get('isRichTextField');
            if ((settingRTF != undefined && settingRTF.Value == 'true'))
                return true;
        }
    } catch (ex) {
        // NOP
    }
    return false;
}

var currentRichTextEditor = null;
var formatToSave = '';
var editorDivIDCK = '';
var objId = '';

var divTextEditor = "";
var idDivEditor = "";
var idDivEditorTextArea = "";
var utilPath = "../productline/RichEditUtil.jsp?mode=";
var richEditRestPath = "../resources/richeditor/res/";

//Gets the CK editor Create and Edit view.
function getRichTextEditor(divEditor, mode, objectIDToLoad, relIdToLoad, lud, contentType) 
{
	//Setting Editor div variables
	divTextEditor = divEditor;
	idDivEditor = "#" + divTextEditor;
	idDivEditorTextArea = idDivEditor + "  " + "textarea";
	
	objId = objectIDToLoad;
    formatToSave = HTML_FORMAT;
    jQuery('#loadingGifFormRMT').css("display", "none");
    getHTMLFromObject(mode, objectIDToLoad);
}


function getHTMLFromObject(mode, objectID) {
	if(!objectID) { //new object
		refreshContentCellWithHTML(mode, objectID, "");
		return;
	}
    $.ajax({
            type : "GET",
            url: richEditRestPath + "HTML?objectId=" + objectID,
            cache: false,
            dataType : "text",
            success : function(txt) {
            	var r = JSON.parse(txt);
            	var html = r.html;
            	if(!html) {
            		html = "";
            	}
        		require(['DS/RichEditor/RichEditor'], function(RichEditor){
        			var richEditor = new RichEditor();
	            	if((r.flags & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) == 0) {
	            		html = richEditor.nls["Msg_NoPreview"];
	            	}
	                refreshContentCellWithHTML(mode, objectID, html, r.flags, r.persistedFormat);
        		});
            }
        });
}

function refreshContentCellWithHTML(mode, strObjIDToLoad, htmlContent, flags, format) {
	require(['DS/RichEditor/RichEditor'], function(RichEditor){
	var richEditor = new RichEditor();

	function wordHandler(){
		window.uniqueId = window.uniqueId || strObjIDToLoad;
		if(!window.uniqueId){
			uniqueId = Math.random();
		}
		window.CKControlsDict = window.CKControlsDict || {};
		var type = jQuery("input[name='TypeActualDisplay']").val();
		if(type === "Requirement Proxy") {
			alert("This operation is not supported.")
			return;
		}
		richEditor.openRichTextInWord({
			uid : uniqueId,
			onClose : function(objectId, ooxml, html){
						jQuery('#NewRichTextEditor').html(html);
						window.CKControlsDict['CKEDITOR_ooxml_'] = ooxml;
						window.CKControlsDict['CKEDITOR_html_'] = html;
    				},
    		isNew : strObjIDToLoad == "",
    		ooxml : window.CKControlsDict['CKEDITOR_ooxml_'],
    		type: type
		});

	}
    if (mode == 'View' || 
    		strObjIDToLoad && ((flags & richEditor.RICH_TEXT_STREAM_CONST.READY_FOR_EDITING) == 0 || 
    			(flags & richEditor.RICH_TEXT_STREAM_CONST.READ_ONLY) != 0)) {
        if (jQuery(idDivEditor).length > 0){
            jQuery(idDivEditor).append(htmlContent);
			
			// VMA10 - IR-671006- Added to reflect same color and bg-color in span as in CKEditor
	 var arrSpans =  $(".richTextContainer span");
  for(var  i = 0;  i< arrSpans.length ; i++)
	  {

	   
	  if(arrSpans[i].attributes[0].value.substring(0,5) == "color")
		{
		  var textColor = arrSpans[i].attributes[0].value.substring(0,13) +" !important;";
		  arrSpans[i].attributes[0].value= textColor;
		  
		}else if(arrSpans[i].attributes[0].value.substring(0,16)=="background-color")
		{try{
			 var bgColor = arrSpans[i].parentElement.attributes[0].value;
			 var colorNew = arrSpans[i].attributes[0].value.substring(0,24) +"; "+bgColor;
			  arrSpans[i].attributes[0].value= colorNew;
		}catch(err){
			
		}
		}
	  }
			
			
            if(preferredEditor=="Word" && !richEditor.isMobile() && (flags & richEditor.RICH_TEXT_STREAM_CONST.READ_ONLY) != 0){ //EditInWord
        		jQuery(idDivEditor).on('dblclick', wordHandler)
    			jQuery(idDivEditor).attr("title", richEditor.nls["Tooltip_OpenInWord"]);
            }
        }
        //if (jQuery('#RichTextEditor_html').length > 0)
        //    jQuery('#RichTextEditor_html').append(htmlContent);
    } else if (mode == 'Edit') {
	    	if(preferredEditor=="Word" && !richEditor.isMobile()){ //EditInWord
	        		if(jQuery('#loadingGifFormRMT').length > 0){
	        			jQuery('#loadingGifFormRMT').remove();
	        		}
		    		jQuery('#NewRichTextEditor').on('dblclick', wordHandler)
			    		.css('border', '1px solid #b4b6ba')
			    		.css('position', 'relative')
			    		.on('mouseover', function(){
			    			if(jQuery('#NewRichTextEditor').html().trim() == ''){
			    				var button = jQuery('<button type="button" class="btn-default">' + richEditor.nls["Label_EditInWord"] + '</button>')
			    								.on('click', wordHandler);
			    				jQuery('#NewRichTextEditor').html(button);
			    			}
			    		})
			    		.on('mouseleave', function(){
			    			if(jQuery('button', '#NewRichTextEditor').length > 0){
			    				jQuery('#NewRichTextEditor').empty();
			    			}
			    			jQuery('#NewRichTextEditor').attr("title", richEditor.nls["Tooltip_EditInWord"]);
			    		});
	    		if(strObjIDToLoad){
	    			jQuery('#NewRichTextEditor').html(htmlContent);
	    			if(location.href.indexOf('fromRTE=true') > 0) {
		    			wordHandler();
	    			}
	    		}
	    	}
	    	else{
	    		if(strObjIDToLoad) {
	            	var isHTMLEditable = true;
	            	//RTF or DOCX data that may require conversion to RCO, or may contain elements not supported by HTML editor
		            if(format.indexOf("DOCX") >=0 || format.indexOf("RTF") >= 0) {
		            	if(htmlContent.toLowerCase().indexOf('<img ') >= 0)
		            	{
		                    $.ajax({
		                        type : "GET",
		                        url: "../resources/richeditor/res/HTMLConvert?objectId=" + strObjIDToLoad + "&" + csrfParams,
		                        cache: false,
		                        dataType : "text",
		                        success : function(txt) {
		                        	var r = JSON.parse(txt);
		                        	var html = r.html;
		                        	if(!html) {
		                        		html = "";
		                        	}
		                        	isHTMLEditable = r.isHTMLEditable; 
		                        	
		                        	//can be edited with HTML editor or no other choice
		                        	if(isHTMLEditable || preferredEditor != "Word") {
			                        	htmlContent = html;
		                        	}
		                        },
		                        async: false
		                    });
		            	}
		            }
	            	if(!isHTMLEditable && preferredEditor == "Word") { //not editable on mobile
	                    if (jQuery(idDivEditor).length > 0)
	                        jQuery(idDivEditor).append(htmlContent);

	                	alert(richEditor.nls["Msg_NoHTMLEditing"]);
	                	return;
	            	}

	    		}
	
            	var editorDivID = strObjIDToLoad.replace(/\./g, '');
		        if (jQuery(idDivEditor).length > 0){
		            jQuery(idDivEditor).append(
		                    "<textarea style='display:none;' id=\"CKEDITOR_"
		                            + editorDivID + "\" name=\"CKEDITOR_" + editorDivID
		                            + "\">" + htmlContent + "</textarea>");
		        }
		        else if (jQuery('#RichTextEditor_html').length > 0)
		            jQuery('#RichTextEditor_html').append(
		                    "<textarea style='display:none;' id=\"CKEDITOR_"
		                            + editorDivID + "\" name=\"CKEDITOR_" + editorDivID
		                            + "\">" + htmlContent + "</textarea>");
	
		        require(['DS/CKEditor/CKEditor'], function(){ //CKUpgrade
	                launchCKEDITORForForm(editorDivID, htmlContent); //++VMA10 ZUD : argument htmlContent added for IR-721371-3DEXPERIENCER2019x
		        });
		    }
    }
	});
}

var richEditor;
require(['DS/RichEditor/RichEditor'], function(RichEditor){
	richEditor = new RichEditor();
});

function launchCKEDITORForForm(editorDivID, htmlContent) { //++VMA10 ZUD : parameter htmlContent added for IR-721371-3DEXPERIENCER2019x
    // JX5 Embedded SB & CATIA creation form
    var isSlideInCreationForm = location.href.indexOf("targetLocation=slidein") > 0; 

    //var currentEditor = CKEDITOR.instances['CKEDITOR_' + editorDivID];
    if (CKEDITOR.instances && CKEDITOR.instances['CKEDITOR_' + editorDivID]) {
        CKEDITOR.instances['CKEDITOR_' + editorDivID].destroy();
    }
    
    /* FIX for a css issue about the toolbar */
    CKEDITOR.on("instanceReady", function(event) {
    	jQuery('.cke_top').attr('style', 'float: none !important;');
    	jQuery('.cke_bottom').attr('style', 'float: none !important;');
    	jQuery('.cke_resizer').attr('style', 'float: right !important;');
        
		// Special case for IE as the width is incorrect (due to default CSS style)
    	//if (isIE) {
    		//var widthForIE = jQuery(idDivEditor).width();
    		//jQuery('.cke_inner').width(widthForIE);
    		//jQuery(".cke_contents").width(widthForIE);
    	//}
		
        /* To avoid the default style in IE, 350 is the default CKEditor size */
    	if (jQuery(".cke_inner").width() < 350 && !fromCreateForm) {
    		jQuery(".cke_inner").css("width", "inherit");
    		jQuery(".cke_contents").css("width", "inherit");
    	}
    	
    	// Bypass for CATIA because onclick event is not supported
        if (!isSlideInCreationForm && fromCreateForm) {
        	if (jQuery(".cke_inner").width() < 500) {
        		jQuery(".cke_inner").css("width", "inherit");
        		jQuery(".cke_contents").css("width", "inherit");
        	}
    		
        	var ckeButtons = jQuery(".cke_button");
        	for (var i = 0; i < ckeButtons.length; i++) {
            	ckeButtons.eq(i).unbind("click").click(function () {
            		eval(jQuery(this).attr("onmouseup").replace("return false;", ""));
            	});
            }
        }
    });

    var defaultToolbar = "Basic";
    
    var maximizedToolbarName = "Maximized";
    if (fromCreateForm) {
    	maximizedToolbarName = "MaximizedCreation";
    }
    if(richEditor.isMobile())
    {
    	maximizedToolbarName = "MaximizedCreation";
    }
    // Bypass for CATIA because onclick event is not supported
    if (!isSlideInCreationForm && fromCreateForm) {
    	defaultToolbar = "CATIA";
    }
    
    // Custom plugins
    var extraPlugins = ['maximize', 'panelbutton', 'colorbutton', 'quicktable', 'toolbarswitch', 'base64image', 'lineutils', 'widget', 'rcowidget'],
                             extraPluginsConfig = ['colorbutton', 'quicktable', 'toolbarswitch', 'base64image', 'rcowidget'].join(',');
    
	var CKEDITOR_EXTRA_PLUGIN_PATH = '../../RichEditorCusto/assets/ckeditor/plugins/';
    //extraPlugins.map(function(plugin){
    //	CKEDITOR.plugins.addExternal(plugin, CKEDITOR_EXTRA_PLUGIN_PATH + plugin + '/', 'plugin.js');
    //});
    CKEDITOR.plugins.addExternal('rcowidget', CKEDITOR_EXTRA_PLUGIN_PATH + 'rcowidget' + '/', 'plugin.js'); //CKUpgrade
    
    // Customize link
	CKEDITOR.on('dialogDefinition', function(ev) {
	    // Take the dialog name and its definition from the event data.
	    var dialogName = ev.data.name;
	    var dialogDefinition = ev.data.definition;

	    // Check if the definition is from the dialog we're
	    // interested on (the "Link" dialog).
	    if (dialogName == 'link') {
	    	
	    	// Set the default target and remove the others
	    	var target = dialogDefinition.getContents('target').get('linkTargetType');
	    	target['default'] = '_blank';
	    	
	    	target.items[0] = target.items[3];
	    	var length = target.items.length;
	    	
	    	for (var i = 0; i < length - 1; i++) {
	    		target.items.pop();
	    	}
	    	
	    	// Set the default link type
	    	var linkType = dialogDefinition.getContents('info').get('linkType').items;
	    	linkType[1] = linkType[2];
	    	linkType.pop();
	    }
	});
	
    CKEDITOR.replace('CKEDITOR_' + editorDivID, {
    	extraPlugins: extraPluginsConfig,
    	customConfig: '../../RichEditorCusto/assets/ckeditor/config.js',
//    	language: CKEDITORSettings.CKEDITORLang,
        toolbar : defaultToolbar, 
        smallToolbar: defaultToolbar,
        maximizedToolbar: maximizedToolbarName,
        height: 200 // The height 100% is not supported by CKEditor
        			//Unnecessary scroll bar removal, height increased.
    });
    editorDivIDCK = editorDivID;  
	
	//++VMA10 ZUD : added for IR-721371-3DEXPERIENCER2019x
	 CKEDITOR.instances['CKEDITOR_'+editorDivID].element.setValue(htmlContent);
	 //VMA10 ZUD :: IR-721371-3DEXPERIENCER2019x
}

function isTextCaseDescriptionXHTML() {
    try {
        var fieldsArr = FormHandler.Fields.ToArray();
        for ( var i = 0; i < fieldsArr.length; i++) {
            var settingRTPLC = fieldsArr[i].Settings.Get('isDescriptionXHTML');
            if ((settingRTPLC != undefined && settingRTPLC.Value == 'true'))
                return true;
        }
    } catch (ex) {
        // NOP
    }
    return false;
}


//Called on "Create" and "Create and Close" button click

function setRichTextContent() {
	if(preferredEditor=="Word" && fromCreateForm){ //EditInWord
        window.objectCreationType = "ooxml"; //"html!docx";
        window.objectCreationObjectId = "";
        window.objectCreationContentData = CKControlsDict['CKEDITOR_ooxml_'];
        window.objectCreationContentText = "";
        window.serverURLWithRoot = serverURLWithRoot;
        window.objectCreationCsrfParams = csrfParams;
        return;
// clear rich text if creation is a success
//        if(preferredEditor=="Word"){
//        	CKControlsDict['CKEDITOR_ooxml_'] = '';
//        	jQuery('#NewRichTextEditor').html('');
//        }
	}
	if(preferredEditor=="Word"){
		formatToSave = "ooxml"; //"html!docx";
	}

    var formName = 'editDataForm';
    if (fromCreateForm)
        formName = 'emxCreateForm';

    var objectId = '';
    var savedFormat = '';
    var richText = '';
    var contentText = '';

    if (formatToSave == HTML_FORMAT) {
        richText = CKEDITOR.instances['CKEDITOR_' + editorDivIDCK].getData();

        //Test Case Description in mandatory field.
        if(richText == "" && isTextCaseDescriptionXHTML())
        {
        	alert("Must enter valid value of Description.");
        	return false;
        }
        //JX5 content text is not correctly formatted
        var temp = document.createElement("div");
        temp.innerHTML = richText;
   	//++VMA10 added for IR-689358-3DEXPERIENCER2019
        textData = temp.innerHTML;
        textData = temp.textContent || temp.innerText;
        for (var i = 0; i < temp.childNodes.length; i++) {
        	var tag =  temp.childNodes[i];
        	if(tag.tagName=="TABLE")
			{
				if(tag.align=="center")
				{
					tag.style.margin = "auto";
				}
			}
        }
        /*temp.childNodes.
        forEach(
	        		function(tag)
	        		{
	        			if(tag.tagName=="TABLE")
	        			{
	        				if(tag.align=="center")
	        				{
	        					tag.style.margin = "auto";
	        				}
	        			}
	        		}
        		)*/
        richText = temp.innerHTML
        
	//--VMA10
  
      // Always encode in base64 in order to bypass the default input filtering
        // We have our own input filtering on the server side
        var UTF8Input = strToUTF8Arr(richText);
        richText = base64EncArr(UTF8Input);

        savedFormat = HTML_FORMAT;
    }

    if(preferredEditor!="Word") { //EditInWord
        var UTF8InputContentText = strToUTF8Arr(textData);
        contentText = base64EncArr(UTF8InputContentText);
    }

    // > 4 MO
    if (checkMaxSize(richText, false) == false)
        return false;
    
    if (!fromCreateForm) {
        // Get the object ID, clean the input field, and clear the editor
        //objectId = jQuery('#NewRichTextEditorPLC').attr('onload').split('"')[3];

    	objectId = objId;
    	if(preferredEditor=="Word"){//EditInWord
    		richText = CKControlsDict['CKEDITOR_ooxml_'];
    	}
        else if (typeof CKEDITOR != 'undefined') {
            CKEDITOR.instances['CKEDITOR_' + editorDivIDCK].setData('');
            jQuery(document.forms[formName]).find(idDivEditorTextArea).val('');
        }

        var data = new FormData();
        data.append('type', formatToSave);
        data.append('objectId', objectId);
        data.append('contentText', contentText);
        data.append('contentData', richText);

        jQuery.ajax({
            type: 'POST',
            cache: false,
            contentType: false,
            processData: false,
            url: richEditRestPath + "setRichContent" + "?" + csrfParams,
            data: data,
            complete: function(data) {
            	// In case we have a RCO inside
	        	syncRCOContent();
	        	if(preferredEditor=="Word"){//EditInWord
	        		require(['DS/RichEditor/RichEditor'], function(RichEditor){
	        			var richEditor = new RichEditor();
	        			richEditor.cleanup(objectId);
	        		});
	        	}
            },
            error: function(xhr, status, error){
            	var message = typeof xhr.responseText == 'string' ? JSON.parse(xhr.responseText).status : xhr.responseText; 
            	alert(error + ":" + message);
            },
            dataType: 'text',
            async: false
        });
    } else {
        window.objectCreationType = formatToSave;
        window.objectCreationObjectId = objectId;
        window.objectCreationContentData = richText;
        window.objectCreationContentText = contentText;
        window.objectCreationCsrfParams = csrfParams;

    //    CKEDITOR.instances['CKEDITOR_'].setData('');
        jQuery(document.forms[formName]).find(idDivEditorTextArea).val('');
    }
}


function hideContentField() {
    if (jQuery('label[for="RichTextEditor"]').length != 0) {
        jQuery('label[for="RichTextEditor"]').parent().parent().css("display", "none");
        jQuery(idDivEditor).parent().parent()
                .parent().css("display", "none");
    }
}


if(localStorage['debug.AMD']) {
	console.info("AMD: RichEditorCusto/Form.js global finish.");
}

