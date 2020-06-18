//=================================================================
// JavaScript Methods for emxSearchGeneral.jsp
// Version 1.0
//
// Copyright (c) 1992-2016 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//  static const char RCSID[] = $Id: emxLibrarySearchGeneral.js.rca 1.5 Wed Oct 22 16:02:25 2008 przemek Experimental przemek $

//=================================================================

    var showAdvanced        = getTopWindow().pageControl.getShowingAdvanced();
    var showingAdvanced     = showAdvanced;
    var typeChanged         = !showAdvanced;

    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIForm");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIMenu");

 function doSearch(){

        //get the form
        var theForm = document.forms[0];
        //set form target
        theForm.target = "searchView";

        if(validateForm(document.forms[0])){
            var type = theForm.txtTypeActual.value;
            var table = theForm.table.value;
            var Style = theForm.Style.value;
            var program = theForm.program.value; 
            var toolbar = theForm.toolbar.value; 
            var header = theForm.header.value;
            var selection = theForm.selection.value;
            var listMode = theForm.listMode.value;
            var CancelButton = theForm.CancelButton.value; 
            var HelpMarker = theForm.HelpMarker.value;
            var suiteKey = theForm.suiteKey.value;
            //Added for the Bug No: 341474 1 11/20/2007
			var QueryLimit = theForm.QueryLimit.value;
			//Added for the Bug No: 341474 1 11/20/2007

            //Modified for the Bug No: 341474 1 11/20/2007
			theForm.action = "../common/emxTable.jsp?txtTypeActual="+type+"&table="+table+"&Style="+Style+"&program="+program+"&toolbar="+toolbar+"&header="+header+"&selection="+selection+"&listMode="+listMode+"&CancelButton="+CancelButton+"&HelpMarker="+HelpMarker+"&suiteKey="+suiteKey+"&QueryLimit="+QueryLimit;
			//Modified for the Bug No: 341474 1 11/20/2007

			theForm.submit();
	}
    }

function validateForm(form){
	if(form.txtTypeDisplay.value == ""){
		alert(getTopWindow().STR_SEARCH_SELECT_TYPE);
		turnOffProgress();
		return false;
	}

	if(form.vaultSelction[2].checked == true)
	{
	   if(form.vaultsDisplay.value == "")
	   {
		  alert(getTopWindow().STR_SEARCH_SELECT_VAULT);
		  turnOffProgress();
		  return false;
	   }
	   form.vaultSelction[2].value = form.vaults.value;
	}

	return true;
}

function doSubmit(){
	//find footer
	var footer = findFrame(getTopWindow(),"searchFoot");

	//call doFind Method
	footer.doFind();
}

function clearType(){
	document.forms[0].txtTypeDisplay.value='';
	document.forms[0].txtTypeActual.value='';
}

function clearVault(){
	document.forms[0].vaultsDisplay.value='';
	document.forms[0].vaults.value='';
}

function disableRevision(){
	if(document.forms[0].latestRevision.checked) {
			document.forms[0].txtRev.value = "*";
			document.forms[0].txtRev.disabled = true;
	} else {
			document.forms[0].txtRev.disabled = false;
	}
}


function doLoad() {

	if (document.forms[0].elements.length > 0) {
		var objElement = document.forms[0].elements[0];

		if (objElement.focus) objElement.focus();
		if (objElement.select) objElement.select();
	}
	var type = getTopWindow().pageControl.getType();
	type = (type == null)? document.getElementById("txtTypeActual").value : type;
	getTopWindow().pageControl.setType(type);
	if(showAdvanced){
		typeChanged = true;
		toggleMore();
	}

}

function updateType(){
	var emxType = arguments[0];

	//if emxType == null get emyType from form
	if((typeof emxType) == "undefined"){
		emxType = document.getElementById("txtTypeActual").value;
	}

	if (getTopWindow().pageControl && emxType != getTopWindow().pageControl.getType()){
		typeChanged = true;
		document.getElementById("txtTypeActual").value = emxType;
		getTopWindow().pageControl.setType(emxType);
		if (getTopWindow().pageControl.getShowingAdvanced() == false){
			return;
		}else{
			var objDiv = document.getElementById("divMore");
			if(getTopWindow().getAdvancedSearch(typeChanged,objDiv)){
				typeChanged = false;
			}
		}
	}
}

function toggleMore() {

		var objDiv = document.getElementById("divMore");
		if(getTopWindow().getAdvancedSearch(typeChanged,objDiv)){

			var imgMore = document.getElementById("imgMore");
			var theForm = document.forms[0];

			objDiv.style.display = (objDiv.style.display == "none" ? "" : "none");
			imgMore.src = (objDiv.style.display == "none" ? "../common/images/utilSearchPlus.gif" : "../common/images/utilSearchMinus.gif");
			getTopWindow().pageControl.setShowingAdvanced(objDiv.style.display == "none" ? false : true);
			//if div is closed clear it
			if(!getTopWindow().pageControl.getShowingAdvanced()){
				removeFormElements();
				objDiv.innerHTML = "";
			}
		}
}

function removeFormElements(){
	var theForm = document.forms[0];
	var formLen = theForm.elements.length;

	for(var i = formLen-1; i >=0 ; i--){
		var objParent = theForm.elements[i].parentNode;


		//alert("element name: " + theForm.elements[i].nodeName +
		//        "\nparentNode: " + objParent.nodeName);

		isDivMore(theForm.elements[i]);
		if(isInDivMore){
			objParent.removeChild(objParent.childNodes[0]);
			isInDivMore = false;
		}
	}
   return theForm;
}

var isInDivMore = false;
function isDivMore(o){
	if(o.parentNode != null){
		if(o.parentNode && o.parentNode.id == "divMore"){
			isInDivMore = true;
			return;
		}
		isDivMore(o.parentNode);
	}
}

function setSelectedVaultOption(vaultChooserURL){
	document.SearchForm.vaultSelction[2].checked=true;
	showChooser(vaultChooserURL);
}
