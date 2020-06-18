//=================================================================
// JavaScript Type Chooser Utility Functions
// Version 1.0
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================

    var objTypeChooser = new emxUITypeChooser(bAbstractSelect, bMultiSelect, bShowIcons, OBSERVE_HIDDEN);

    //add types
    for (var i=0; i < arrTypes.length; i++){
        objTypeChooser.addType(arrTypes[i]);
    }

	for (var i=0; i < excludeTypes.length; i++){
        objTypeChooser.addNotType(excludeTypes[i]);
    }

    var objToolbar = new emxUIToolbar;
    objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", COMMON_HELP, "javascript:openHelp(\"" + HELP_MARKER + "\", \"" + SUITE_DIR + "\", \"" + LANGUAGE_STRING + "\", \"" + LANGUAGE_ONLINE_STR + "\",'',\"" + SUITE_KEY + "\")"));

    function doLoad() {
        toolbars.init('divToolbar');
        objTypeChooser.setContainer(document.getElementById("divTree"));
        objTypeChooser.init(); //URL and parameters are handled by JavaScript
        //doFilter();
    }

    function doFilter() {
        var objSel = document.getElementById("selFilter");
        var objTxt = document.getElementById("txtFilter");
        var objChk = document.getElementById("chkTopLevelOnly");
        var objBtn = document.getElementById("btnFilter");

        objBtn.disabled = objChk.disabled = objTxt.disabled = objSel.disabled = true;

        document.body.style.cursor = "wait";

    setTimeout(function () {
         objTypeChooser.applyFilter(objSel.options[objSel.selectedIndex].value, objTxt.value,objChk.checked);
         objBtn.disabled = objChk.disabled = objTxt.disabled = objSel.disabled = false;
         document.body.style.cursor = "";
        }, 100);
    }

    function doDone() {
      if (objTypeChooser.getValue() != "") {

        //get selected value
        var strSelected = objTypeChooser.getValue();

        //declare actual values and translated values
        var arrActuals = new Array;
        var arrTranslations = new Array;

        //split the string into an array at each comma
        var arrItems = strSelected.split(",");

        //go through array and create the strings
        for (var i=0; i < arrItems.length; i++) {

          //make sure this item is not blank
          if (arrItems[i] != "") {
            //split this item at the pipe
            var arrTemp = arrItems[i].split("|");

            //add to arrays if not duplicates
            if (arrActuals.find(arrTemp[0]) == -1)
                arrActuals[arrActuals.length] = arrTemp[0];

            if (arrTranslations.find(arrTemp[1]) == -1)
                arrTranslations[arrTranslations.length] = arrTemp[1];
          }
        }

        //create strings from the arrays
        var strActuals = null;
        var strTranslations = null;
        // Pass back the abs & translated values.
        if(objForm.name=="full_search"){
        	strTranslations = arrTranslations.join(emxUIConstants.STR_REFINEMENT_SEPARATOR);
        	strActuals = arrActuals.join(emxUIConstants.STR_REFINEMENT_SEPARATOR);
        	txtTypeDisp.value = strTranslations;
        	txtType.value = strActuals;
        	var aFrame =findFrame(getTopWindow().getWindowOpener(), "windowShadeFrame");
      		if(aFrame&& aFrame.location.href.indexOf("emxFullSearch.jsp")>-1 ){
      			//objForm = emxUICore.getNamedForm(aFrame,"full_search");
      			aFrame.FullSearch.addToFilters("TYPE", strActuals);
      			
      		}else{
        	getTopWindow().getWindowOpener().FullSearch.addToFilters("TYPE", strActuals);
        	}
		} else {
        	strTranslations =arrTranslations.join(",");
        	strActuals = arrActuals.join(",");
        	txtTypeDisp.value = strTranslations;
        	//ixk: in FF>4 when we have two form fields with same name we get an array instead of object
        	if((txtType[0] != null)&& isMinFF4 && (txtType[0].tagName != "OPTION")){
        		txtType[0].value = strActuals;
        	}else{
        		txtType.value = strActuals;
        	}
		}
        setTimeout(function(){
        	 if (bReload && getTopWindow().getWindowOpener().reload) {
                 getTopWindow().getWindowOpener().reload();
               }

               //Is there a callback function??
               if((typeof getTopWindow().callbackFunction) != "undefined") {
                   getTopWindow().callbackFunction();
               }

               getTopWindow().closeWindow();
        },50);
      } else {
        alert(SELECT_TYPE_MSG);
      }
    }

    function doCancel() {
      getTopWindow().closeWindow();
    }
