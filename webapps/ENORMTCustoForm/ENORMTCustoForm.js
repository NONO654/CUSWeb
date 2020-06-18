//=================================================================
// JavaScript ENORMTCustoForm.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"

// quickreview T25 DJH 13:10:25  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding tokens included.
// quickreview T94     03:09:15  :  IR-350187 issue with multiples textarea and CKEditor
// quickreview JX5 T94 10:12:15  :  IR-390868-3DEXPERIENCER2017x : Req Edition, Content text tooltip not displayed properly 
// quickreview HAT1 ZUD 16:02:03    HL -  To enable Content column for Test Cases. 
// quickreview QYG     16:05:03:    javascript refactoring, split from RichTextEditorForm.js
// quickreview HAT1 ZUD 16:05:03 :  Populating title as per autoName of Name in Web form.
// quickreview HAT1 ZUD 16:05:17 :  IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated.
// quickreview HAT1 ZUD 16:05:25 :  IR-445639-3DEXPERIENCER2017x: 	R419-STP: "Autoname" check box is not available on Creation form of Requirement objects.
// quickreview KIE1 HAT1 16:06:29 :  IR-453225-3DEXPERIENCER2017x: R419-FUN058646:In TRM application 3DSpace, RMC & widgets, title is display as "type + sequence + autonumbering" instead of "type + autonumbering" .
// quickreview KIE1 ZUD 18:11:21 :IR-646433-3DEXPERIENCER2019x: Not able to modify properties of a ‘Requirement’ on Mozilla Firefox.



/* Contains non-rich text related functions for the WebForms : Properties, SlideIn, ... */

if(localStorage['debug.AMD']) {
	var _ENORMTCustoForm_js = _ENORMTCustoForm_js || 0;
	_ENORMTCustoForm_js++;
	console.info("AMD: ENORMTCustoForm/ENORMTCustoForm.js loading " + _ENORMTCustoForm_js + " times.");
}

// ++ HAT1 ZUD: IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated. 
	define('DS/ENORMTCustoForm/ENORMTCustoForm', ['DS/RichEditorCusto/Util'], function()
	{
		if(localStorage['debug.AMD']) 
		{
			console.info("AMD: ENORMTCustoForm/ENORMTCustoForm.js dependency loaded.");
		}
		
		if(fromCreateForm)
		{
			$.getScript("../webapps/RichEditorCusto//Util.js", function (){
			emxUICore.instrument(window, 'saveCreateChanges',
					RefreshTitleSlidein, null);
		
			});
			//Creation WebForm- populating title field
			$(document).ready(function() {
				autoFillTitle();
			  			
			});
		}
		
		$.getScript("../webapps/RichEditorCusto//Util.js", function (){
			emxUICore.instrument(emxUICorePopupMenu.prototype, 'show', null, doCustomizeToolBarForRMT);
		    if(fromWebForm){
		    	emxUICore.instrument(window, 'doLoad', null, afterDoLoad);
		    }
		});	
	    
	    //HAT1 ZUD:  IR-433769-3DEXPERIENCER2017x fix
	    function RefreshTitleSlidein(isForCreate)
	    {  
	    	if(isForCreate)
	       {    	    // ++ HAT1 ZUD: IR-445639-3DEXPERIENCER2017x: fix
	            jQuery("iframe[name='formCreateHidden']").on("load", function(){
	              if(!jQuery("iframe[name='formCreateHidden']")[0].contentWindow.DisplayErrorMsg ) {
	
	                     window.document.location.href = window.document.location.href;
	              }
	            });
	    	    // -- HAT1 ZUD: IR-445639-3DEXPERIENCER2017x: fix
	    	}
	    }
	
		 // ++ HAT1 ZUD   Populating title as per autoName of Name in Web form.
		 function autoFillTitle()
		 {
		 	//To get autoName count.
		
			if(document.getElementsByName('Name')){	 // checked due to IE issue IR-709096-3DEXPERIENCER2019x
				var Name_Title       = document.getElementsByName('Name');
				var Name = Name_Title[0].value;
				var TitleCount =  Name.substring(Name.indexOf(autonameSeparator) + 1); //Name.split("-")[1];
				var title = TitleCount.substring(TitleCount.indexOf(autonameSeparator) + 1); 
				
				//getting type
				var titleTypeDisplay = document.getElementsByName("TypeActualDisplay");
				//populating Title with type and autoName count.
				if(titleTypeDisplay.length > 0)
				{
					document.getElementById('Title').value = titleTypeDisplay[0].value + "" + title;
				}
			}
		 }
		 // -- HAT1 ZUD   Populating title as per autoName of Name in Web form.
	 
		if(localStorage['debug.AMD']) 
		{
		   	console.info("AMD: ENORMTCustoForm/ENORMTCustoForm.js finish.");
		} 
		return {};
	});
// ++ HAT1 ZUD: IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated. 

if (!isSBEmbedded && getTopWindow().objStructureFancyTree) {
	getTopWindow().objStructureFancyTree.isActive = false; // NO tree for the forms
}

var timeStamp = rmt_timeStamp;

//HAT1 ZUD: To enable content column for Test Case.
//function checkMaxSize () - Moved to RichEditorCusto.js

/**
 * Hide promote/demote command in Edit mode
 */
function doCustomizeToolBarForRMT() {
    var urlToLoad = location.href;
    var isEditMode = false;
    if (urlToLoad.indexOf('mode=Edit') > 0) {
        isEditMode = true;
    }
    var toolbarItems = $(toolbars).first().attr('items');
    for (var i = 0; i < toolbarItems.length; i++) {
        var object = toolbarItems[i];
        var identifier = object.id;
        if (identifier == undefined || identifier == '')
            identifier = object.dynamicName;
        switch (identifier) {
        case 'RMTRequirementPropertiesTopActionBar':
            for (var j = 0; j < object.menu.items.length; j++) {
                var subObject = object.menu.items[j];
                if (subObject.icon != null) {
                    if (subObject.icon.indexOf('Demote') >= 0
                            || subObject.icon.indexOf('Promote') >= 0) {
                        if (isEditMode == false) {
                            $(subObject.rowElement).show();
                        } else {
                            $(subObject.rowElement).hide();
                        }
                    }
                }
            }
        }
    }
}
/* not being used

//Hide the policy field if needed
if (!'true'==isSimplifiedForm){
    emxUICore.addEventHandler(window, "load", hidePolicyField);
}

function hidePolicyField() {
    if (jQuery('label[for="Policy"]').length != 0) {
        jQuery('label[for="Policy"]').parent().parent().css("display", "none");
        jQuery('select[name="Policy"]').parent().parent().parent().parent()
                .parent().css("display", "none");
    }
}

//Add a handler for the double click in the web form
function addHandlerForDoubleClick() {
    $('.field').dblclick(function() {
        var urlToLoad = referer;

        // To switch between view mode and edit mode
        if (referer.indexOf('mode=view') > 0)
            urlToLoad = referer.replace('mode=view', 'mode=Edit');
        if (urlToLoad.indexOf('mode=Edit') < 1)
            urlToLoad += '&mode=Edit';
        toggleMode(urlToLoad);
    });
}
*/

//resize textbox width for create form
function adjustTextFieldWidth() {
		jQuery(".createInputField input[type='text']").each(function(){
			var that = this;
			if(!jQuery(that).closest("td").is(jQuery(that).closest(".createInputField"))){
			var siblingWidth =  jQuery(that).closest("td").width() - jQuery(this).width();
			var parentWidth = jQuery(that).closest(".createInputField").width();
			jQuery(that).css("width", parentWidth - siblingWidth - 20);
			}
		});
}
jQuery(function(){
	var fromCreateForm = location.href.indexOf("emxCreate.jsp") >= 0; 
	if(fromCreateForm) {
        adjustTextFieldWidth();
        jQuery(window).on("resize", function(){
            adjustTextFieldWidth();
        });
	}
});

//resize textbox width for edit form
function afterDoLoad(){
	jQuery(".inputField input[type='text']").each(function(){
		var that = this;
		
		if(jQuery(that).siblings(":not(input[type='hidden'])").length == 0 ) {
			jQuery(that).css("width", "calc(100% - 1em)");
		}
	});
}


//HAT1 ZUD: To enable content column for Test Case.
//Rest of the functions are Moved to RichEditorCusto/Form.js

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoForm/ENORMTCustoForm.js global finish.");
}

