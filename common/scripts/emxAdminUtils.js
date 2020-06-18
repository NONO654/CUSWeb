//=================================================================
// JavaScript Methods for Registration of Admin, State and Viewer property
// emxAdminUtils.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//
// static const char RCSID[] = $Id: emxAdminUtils.js.rca 1.14 Wed Oct 22 15:48:15 2008 przemek Experimental przemek $
//=================================================================

// variable used to detect if a form has been submitted
//
var clicked = false;

// variable used to detect if a form has been refreshing
//
var refresh = false;

// A variable to check if the registration page's values have been submitted or not

var registrationChanged = false;  

var childWindow=null;

function openHelp(pageTopic, directory, langStr) {
	 alert("Help functionality is not being implemented here");
//    directory = directory.toLowerCase();
//	alert("111111111111");
//    var url = "../doc/" +  directory + "/" + langStr + "/wwhelp/wwhimpl/js/html/wwhelp.htm?context=" + directory + "&topic=" + pageTopic;
//    if(!checkURL(url)){
//    	alert("111111111111");
//        url = "../doc/" +  directory + "/" + langStr + "/ENOHelp.htm?context=" + directory + "&topic=" + pageTopic;
//    }
//    if ((childWindow == null) || (childWindow.closed))
//    {
//        childWindow = window.open(url,"helpwin","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
//        childWindow.focus();
//    } else {
//        childWindow.location.replace(url);
//        childWindow.focus();
//    }
//    return;
}

function checkURL(url){
    var xmlhttp = emxUICore.createHttpRequest();
    xmlhttp.open("GET", url, false);
    xmlhttp.send(null);
    return xmlhttp.status==200;
}

// function jsDblClick() - sets var clicked to true.
// Used to prevent double click from resubmitting a
// form in IE 
//
function jsDblClick() {
    if(!clicked) {
        clicked = true;
        return true;
    }
    else {
        return false;
    }
}   

// added to show the Reload Cache confirmation message  

function showConfirmMsg(){
    if (!(refresh)){
        var theForm = document.forms[0];
        if(registrationChanged){
            var msg = confirm(STR_RELOAD_CACHE);
            if(msg){
                registrationChanged = false;
                theForm.target = parent.getWindowOpener().frames[1].name; // returns 'hiddenframe'
                theForm.action = "emxReloadCache.jsp";
                theForm.submit();
                window.closeWindow();
            }
            else{
                registrationChanged = false;
                window.closeWindow();
            }
        }else{
            window.closeWindow();
        }
    }
}

//Change Admin Property functions begin

function getLists(){
    //get the form
    var theForm = document.forms[0];
    if(jsDblClick()){
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if(trimWhitespace(theForm.lstAdminType.options[theForm.lstAdminType.selectedIndex].value)!=''){
            turnOnProgress();
            theForm.hdnMode.value               = "list";
            theForm.hdnAdminTypeIndex.value     = theForm.lstAdminType.selectedIndex;
            theForm.action                      = "emxRegistrationAdminProcess.jsp";
            theForm.submit();
        }else{
            clicked  = false;
        }
    }else{
        if(trimWhitespace(theForm.hdnAdminTypeIndex.value).length != 0){
            theForm.lstAdminType.selectedIndex = theForm.hdnAdminTypeIndex.value;
        }     
    }
}

function getProperties(){
    if(jsDblClick()){
        //get the form
        var theForm = document.forms[0];
        //method to disable other buttons in the form
        disableAdminButtons(theForm,'properties');
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if(trimWhitespace(theForm.lstAdminType.options[theForm.lstAdminType.selectedIndex].value)!='') {
            if(theForm.lstregisteredadmins.selectedIndex>=0){
                turnOnProgress();
                theForm.hdnMode.value               = "properties";
                theForm.hdnregisteredadmins.value   = theForm.lstregisteredadmins.options[theForm.lstregisteredadmins.selectedIndex].text;
                theForm.action                      = "emxRegistrationAdminProcess.jsp";
                theForm.submit();
            }else{
                clicked  = false;    
                alert(STR_ITEM_REGISTERED_ADMINS);
                enableAdminButtons(theForm,'properties');
            }
        }else{
            clicked  = false;
            alert(STR_ITEM_ADMIN_TYPE);
            enableAdminButtons(theForm,'properties');
        }
    }
}

function createSubmit(){
    if(jsDblClick()){
        //get the form
        var theForm = document.forms[0];
        //method to disable other buttons in the form
        disableAdminButtons(theForm,'create');
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if (validateForm(theForm,'create')){
            theForm.hdnMode.value           = "create";
            theForm.hdnRegListIndex.value   = theForm.lstunregisteredadmins.selectedIndex;
            theForm.hdnUnRegListIndex.value = theForm.lstunregisteredadmins.selectedIndex;
            theForm.action                      = "emxRegistrationAdminProcess.jsp";
            turnOnProgress();
            // a flag to check if any changes are done in the page or not
            registrationChanged = true; 
            theForm.submit();
        } else {//method to enable other buttons in the form
            enableAdminButtons(theForm,'create');
        }
    }
}

function transferSubmit(){
    if(jsDblClick()){
        //get the form
        var theForm = document.forms[0];
        //method to disable other buttons in the form
        disableAdminButtons(theForm,'transfer');
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if (validateForm(theForm,'transfer')){
            theForm.hdnMode.value               = "transfer";
            theForm.hdnRegListIndex.value       = theForm.lstregisteredadmins.selectedIndex;
            theForm.hdnUnRegListIndex.value     = theForm.lstunregisteredadmins.selectedIndex;
            theForm.hdnregisteredadmins.value   = theForm.lstregisteredadmins.options[theForm.lstregisteredadmins.selectedIndex].text;
            theForm.action                      = "emxRegistrationAdminProcess.jsp";
            turnOnProgress();
            // a flag to check if any changes are done in the page or not
            registrationChanged = true;
            theForm.submit();
        } else {//method to enable other buttons in the form
            enableAdminButtons(theForm,'transfer');
        }
    }
}

function updateSubmit(){
    if(jsDblClick()){
        //get the form
        var theForm = document.forms[0];
        //method to disable other buttons in the form
        disableAdminButtons(theForm,'update');
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if (validateForm(theForm,'update')){
            theForm.hdnMode.value               = "update";
            theForm.hdnregisteredadmins.value   = theForm.lstregisteredadmins.options[theForm.lstregisteredadmins.selectedIndex].text;
            theForm.hdnRegListIndex.value       = theForm.lstregisteredadmins.selectedIndex;
            theForm.action                      = "emxRegistrationAdminProcess.jsp";
            turnOnProgress();
            // a flag to check if any changes are done in the page or not
            registrationChanged = true;
            theForm.submit();
        } else {//method to enable other buttons in the form
            enableAdminButtons(theForm,'update');
        }
    }
}

function deleteSubmit(){
    if(jsDblClick()){
        //get the form
        var theForm = document.forms[0];
        //method to disable other buttons in the form
        disableAdminButtons(theForm,'delete');
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if (validateForm(theForm,'delete')){
            theForm.hdnMode.value               = "delete";
            theForm.hdnRegListIndex.value       = theForm.lstregisteredadmins.selectedIndex;
            theForm.hdnregisteredadmins.value   = theForm.lstregisteredadmins.options[theForm.lstregisteredadmins.selectedIndex].text;
            theForm.action                      = "emxRegistrationAdminProcess.jsp";
            turnOnProgress();
            // a flag to check if any changes are done in the page or not
            registrationChanged = true;
            theForm.submit();
        } else {//method to enable other buttons in the form
            enableAdminButtons(theForm,'delete');
        }
    }
}

function clearfields(theForm){
    theForm.txtSymbolicName.value   = "";
    theForm.txtApplication.value    = "";
    theForm.txtVersion.value        = "";
    theForm.txtInstaller.value      = "";
    theForm.txtInstalledDate.value  = theForm.hdnCurrentDate.value;
    theForm.txtOriginalName.value   = "";
}

//called on onselect/onchange of the Registered Admins to disable 
//the properties fields
function disablefields(){
    var theForm = document.forms[0];
    clearfields(theForm);
    //enablefields(theForm, 'true');
}

function enablefields(theForm, enable){
    theForm.txtSymbolicName.disabled    = enable;
    theForm.txtApplication.disabled     = enable;
    theForm.txtVersion.disabled         = enable;
    theForm.txtInstaller.disabled       = enable;
    theForm.txtInstalledDate.disabled   = enable;
    theForm.txtOriginalName.disabled    = enable;
}

function validate(theForm){
    var symbolicName = theForm.txtSymbolicName.value;
    if(symbolicName.indexOf('_')>0){
        var strTemp = symbolicName.substring(0,symbolicName.indexOf('_')+1);
        if ((trimWhitespace(strTemp)!='') && (strTemp==theForm.lstAdminType.options[theForm.lstAdminType.selectedIndex].text + '_')){
            return true;
        }else{
            return false;
        }
    }else{
        return false;
    }
    return true;
}

function validateForm(theForm, mode){
    if (trimWhitespace(theForm.lstAdminType.options[theForm.lstAdminType.selectedIndex].value)==''){
        alert(STR_ITEM_ADMIN_TYPE);
        clicked  = false;
        return false;
    }
    if(mode=='delete'){
        if (theForm.lstregisteredadmins.selectedIndex<0){
            alert(STR_ITEM_REGISTERED_ADMINS_DELETE);
            clicked  = false;
            return false;
        }
    }else if(mode=='create'){
        if (theForm.lstunregisteredadmins.selectedIndex<0){
            alert(STR_ITEM_UNREGISTERED_ADMINS_CREATE);
            clicked  = false;
            return false;
        }else if(validateBadChars(theForm)){
            clicked  = false;
            return false;
        }else if(!(validate(theForm))){
            alert(STR_STATE_PROPERTY_FORMAT + " " + theForm.lstAdminType.options[theForm.lstAdminType.selectedIndex].text +'_XYZ');
            theForm.txtSymbolicName.select();
            theForm.txtSymbolicName.focus();
            clicked  = false;
            return false;
        }
    }else if(mode=='transfer'){
        if (theForm.lstregisteredadmins.selectedIndex<0){
            alert(STR_ITEM_REGISTERED_ADMINS_TRANSFER);
            clicked  = false;
            return false;
        }else if(theForm.lstunregisteredadmins.selectedIndex<0){
            alert(STR_ITEM_UNREGISTERED_ADMINS_TRANSFER);
            clicked  = false;
            return false;
        }else if(trimWhitespace(theForm.txtSymbolicName.value).length != 0){
            if(validateBadChars(theForm)){
                clicked  = false;
                return false;
            }else if(!(validate(theForm))){
                alert(STR_STATE_PROPERTY_FORMAT + " " + theForm.lstAdminType.options[theForm.lstAdminType.selectedIndex].text +'_XYZ');
                theForm.txtSymbolicName.select();
                theForm.txtSymbolicName.focus();
                clicked  = false;
                return false;
            }
        }
    }else if(mode=='update'){
        if (theForm.lstregisteredadmins.selectedIndex<0){
            alert(STR_ITEM_REGISTERED_ADMINS_UPDATE);
            clicked  = false;
            return false;
        }else if(validateBadChars(theForm)){
            clicked  = false;
            return false;
        }else if(!(validate(theForm))){
            alert(STR_STATE_PROPERTY_FORMAT + " " + theForm.lstAdminType.options[theForm.lstAdminType.selectedIndex].text +'_XYZ');
            theForm.txtSymbolicName.select();
            theForm.txtSymbolicName.focus();
            clicked  = false;
            return false;
        }
    }
    return true;
}

function validateBadChars(theForm){
    if(trimWhitespace(theForm.txtSymbolicName.value).length == 0){
        alert(STR_REQUIRED_SYMBOLICNAME);
        theForm.txtSymbolicName.focus();
        return true;
    }else if(!(checkField(theForm.txtSymbolicName.value))){
        theForm.txtSymbolicName.select();
        theForm.txtSymbolicName.focus();
        return true;
    }else if(trimWhitespace(theForm.txtApplication.value).length == 0){
        alert(STR_REQUIRED_APPLICATION);
        theForm.txtApplication.focus();
        return true;
    }else if(!(checkField(theForm.txtApplication.value))){
        theForm.txtApplication.select();
        theForm.txtApplication.focus();
        return true;
    }else if(trimWhitespace(theForm.txtVersion.value).length == 0){
        alert(STR_REQUIRED_VERSION);
        theForm.txtVersion.focus();
        return true;
    }else if(!(checkField(theForm.txtVersion.value))){
        theForm.txtVersion.select();
        theForm.txtVersion.focus();
        return true;
    }else if(trimWhitespace(theForm.txtInstaller.value).length == 0){
        alert(STR_REQUIRED_INSTALLER);
        theForm.txtInstaller.focus();
        return true;
    }else if(!(checkField(theForm.txtInstaller.value))){
        theForm.txtInstaller.select();
        theForm.txtInstaller.focus();
        return true;
    }else if(trimWhitespace(theForm.txtInstalledDate.value).length == 0){
        alert(STR_REQUIRED_INSTALLEDDATE);
        return true;
    }else if(trimWhitespace(theForm.txtOriginalName.value).length == 0){
        alert(STR_REQUIRED_ORIGINALNAME);
        theForm.txtOriginalName.focus();
        return true;
    }else if(!(checkField(theForm.txtOriginalName.value))){
        theForm.txtOriginalName.select();
        theForm.txtOriginalName.focus();
        return true;
    }
        //}else if(!(checkField(theForm.txtInstalledDate.value))){
        //theForm.txtInstalledDate.select();
        //theForm.txtInstalledDate.focus();
        //return true;

}

//Change State Property

function getStates(){
    //get the form
    var theForm = document.forms[0];
    if(jsDblClick()){
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if(trimWhitespace(theForm.lstpolicy.options[theForm.lstpolicy.selectedIndex].value)!=''){
            turnOnProgress();
            theForm.hdnMode.value= "list";
            theForm.hdnPolicyIndex.value = theForm.lstpolicy.selectedIndex;
            theForm.action = "emxRegistrationStateProcess.jsp";
            theForm.submit();
        }else{
            clicked  = false;
        }
    }else{
        if(trimWhitespace(theForm.hdnPolicyIndex.value).length != 0){
            theForm.lstpolicy.selectedIndex = theForm.hdnPolicyIndex.value;
        }     
    }
}

function submitForm(mode){
    if(jsDblClick()){
        theForm = document.forms[0];
        //method to disable other buttons in the form
        disableStateButtons(theForm,mode);
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        if(validateStateForm(theForm,mode)){
            theForm.hdnMode.value = mode;
            theForm.hdnPropertyIndex.value= theForm.lstpropertystates.selectedIndex;
            theForm.hdnStateIndex.value= theForm.lststatenames.selectedIndex;
            theForm.action = "emxRegistrationStateProcess.jsp";
            turnOnProgress();
            // a flag to check if any changes are done in the page or not
            registrationChanged = true;
            theForm.submit();
        } else {//method to enable other buttons in the form
            enableStateButtons(theForm,mode);
        }
    }
}

function validateStateForm(theForm, mode){
    if (trimWhitespace(theForm.lstpolicy.options[theForm.lstpolicy.selectedIndex].value)==''){
        clicked  = false;
        alert(STR_ITEM_POLICY);
        return false;
    }
    if(mode=='delete'){
        if (theForm.lstpropertystates.selectedIndex<0){
            alert(STR_ITEM_PROPERTY_STATE_DELETE);
            clicked  = false;
            return false;
        }
    }else{
        if(mode=='create'){
            if(theForm.lststatenames.selectedIndex<0){
                clicked  = false;
                alert(STR_ITEM_STATE_CREATE);
                return false;
            }else if(trimWhitespace(theForm.txtSymbolicName.value).length == 0){
                clicked  = false;
                alert(STR_REQUIRED_SYMBOLICNAME);
                theForm.txtSymbolicName.focus();
                return false;
            }else if(!(checkField(theForm.txtSymbolicName.value))){
                clicked  = false;
                theForm.txtSymbolicName.select();
                theForm.txtSymbolicName.focus();
                return false;
            }else if(!(validateState(theForm))){
                clicked  = false;
                alert(STR_ITEM_STATE_FORMAT);
                theForm.txtSymbolicName.select();
                theForm.txtSymbolicName.focus();
                return false;
            }
        }else if(mode=='update'){
            if(theForm.lststatenames.selectedIndex<0){
                clicked  = false;
                alert(STR_ITEM_STATE_UPDATE);
                return false;
            }else if(theForm.lstpropertystates.selectedIndex<0){
                clicked  = false;
                alert(STR_ITEM_PROPERTY_STATE_UPDATE);
                return false;
            }
        }
    }
    return true;
}

function validateState(theForm){
    var symbolicName = theForm.txtSymbolicName.value;
    if(symbolicName.indexOf('_')>0){
        var strTemp = symbolicName.substring(0,symbolicName.indexOf('_')+1);
        if ((trimWhitespace(strTemp)!='') && (strTemp=='state_')){
            return true;
        }else{
            return false;
        }
    }else{
        return false;
    }
    return true;
}

//Viewer script starts here

function getViewers(){
    //get the form
    var theForm = document.forms[0];
    if(jsDblClick()){
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";
        turnOnProgress();
        theForm.hdnMode.value= "list";
        theForm.hdnFormatIndex.value = theForm.lstformats.selectedIndex;
        theForm.action = "emxRegistrationViewerProcess.jsp";
        theForm.submit();
    }else{
        if(trimWhitespace(theForm.hdnFormatIndex.value).length != 0){
            theForm.lstformats.selectedIndex = theForm.hdnFormatIndex.value;
        }     
    }
}


function assignViewer(strmode){
    if(jsDblClick()){
        //get the form
        var theForm = document.forms[0];
        var AssignSelectedIndex = '';
        var AssignValues        = ''; 
        //method to disable other buttons in the form
        disableViewerButtons(theForm,strmode);
        if ((theForm.lstformats.selectedIndex<0) || (trimWhitespace(theForm.lstformats.options[theForm.lstformats.selectedIndex].value)=='')){
            clicked=false;
            alert(STR_ITEM_SELECT_FORMAT);
            enableViewerButtons(theForm,strmode);
            return false;
        }    
        if (strmode=='assign'){
            if(theForm.lstunassignedviewers.selectedIndex<0){
                clicked=false;
                alert(STR_ITEM_ASSIGN);
                enableViewerButtons(theForm,strmode);
                return false;
            }else{
                for(var i=0;i<theForm.lstunassignedviewers.options.length;i++){
                    if(theForm.lstunassignedviewers.options[i].selected){
                        AssignValues = AssignValues + theForm.lstunassignedviewers.options[i].value +  "|";
                        AssignSelectedIndex = AssignSelectedIndex + i +  "|";

                        var optAssign = new Option(theForm.lstunassignedviewers.options[i].text,theForm.lstunassignedviewers.options[i].value);
                        theForm.lstassignedviewers.options.add(optAssign);
                    }
                }
                for(var i=theForm.lstunassignedviewers.options.length-1;i>-1;i--){
                    if(theForm.lstunassignedviewers.options[i].selected){
                        theForm.lstunassignedviewers.options[i] = null;
                    }
                }
            }
        }else{
            if(theForm.lstassignedviewers.selectedIndex<0){
                clicked=false;
                alert(STR_ITEM_UNASSIGN);
                enableViewerButtons(theForm,strmode);
                return false;
            }else{    
                for(var i=0;i<theForm.lstassignedviewers.options.length;i++){
                    if(theForm.lstassignedviewers.options[i].selected){
                        AssignValues = AssignValues + theForm.lstassignedviewers.options[i].value +  "|";
                        AssignSelectedIndex = AssignSelectedIndex + i +  "|";

                        var optUnAssign = new Option(theForm.lstassignedviewers.options[i].text,theForm.lstassignedviewers.options[i].value);
                        theForm.lstunassignedviewers.options.add(optUnAssign);
                    }
                }
                for(var i=theForm.lstassignedviewers.options.length-1;i>-1;i--){
                    if(theForm.lstassignedviewers.options[i].selected){
                        theForm.lstassignedviewers.options[i] = null;
                    }
                }
            }
        }
        turnOnProgress();
        theForm.hdnAssignedValues.value   = AssignValues.substring(0,AssignValues.length-1);
        theForm.hdnAssignedIndex.value    = AssignSelectedIndex.substring(0,AssignSelectedIndex.length-1);
        theForm.hdnMode.value             = strmode;
        theForm.action                    = "emxRegistrationViewerProcess.jsp";
        // a flag to check if any changes are done in the page or not
        registrationChanged = true;
        theForm.submit();
    }
}



function submitViewerForm(mode){
    if(jsDblClick()){
        theForm = document.forms[0];
        //method to disable other buttons in the form
        disableViewerButtons(theForm,mode);
        // If the page needs to do some pre-processing before displaying the results
        // Use the "adminHidden" frame for target
        theForm.target = "AdminHidden";

        if(validateViewerForm(theForm,mode)){
            turnOnProgress();
            theForm.hdnMode.value = mode;
            if(mode!='create'){
                theForm.hdnViewerServlet.value = theForm.lstviewerservlet.options[theForm.lstviewerservlet.selectedIndex].text;
            }
            theForm.hdnViewerServletIndex.value = theForm.lstviewerservlet.selectedIndex;
            theForm.action = "emxRegistrationViewerProcess.jsp";
            // a flag to check if any changes are done in the page or not
            registrationChanged = true;
            theForm.submit();
        } else {//method to enable other buttons in the form
            enableViewerButtons(theForm,mode);
        }
    }
}

function validateViewerForm(theForm, mode){
    if(mode=='delete'){
        if (trimWhitespace(theForm.lstviewerservlet.options[theForm.lstviewerservlet.selectedIndex].value)==''){
            clicked=false;
            alert(STR_ITEM_DELETE_VIEWER);
            return false;
        }
    }else{
        if(mode=='create'){
            if(trimWhitespace(theForm.txtViewerTip.value).length == 0){
                clicked=false;
                alert(STR_ITEM_CREATE_MODIFY_VIEWERTIP);
                theForm.txtViewerTip.select();
                theForm.txtViewerTip.focus();
                return false;
            }else if(!(checkField(theForm.txtViewerTip.value))){
                clicked=false;
                theForm.txtViewerTip.focus();
                theForm.txtViewerTip.select();
                return false;
            }
            var strViewerName = prompt(STR_ITEM_VIEWER_NAME, "");
            if (strViewerName==null){
                clicked=false;
                return false;
            }else if ((strViewerName == "") || (strViewerName == " ")) {
                alert(STR_ITEM_VIEWER_NAME);
                clicked=false;
                return false;
            }else{
                theForm.hdnViewerServlet.value = strViewerName;
                if(!((checkField(strViewerName)) && checkFieldMaxLength(strViewerName))){
                    clicked=false;
                    return false;
                }else{
                    return true;
                }
            }
        }else if(mode=='update'){
            if(trimWhitespace(theForm.lstviewerservlet.options[theForm.lstviewerservlet.selectedIndex].value)=='') {
                clicked=false;
                alert(STR_ITEM_DELETE_VIEWER);
                return false;
            }else if(trimWhitespace(theForm.txtViewerTip.value)==''){
                clicked=false;
                alert(STR_ITEM_CREATE_MODIFY_VIEWERTIP);
                theForm.txtViewerTip.select();
                theForm.txtViewerTip.focus();
                return false;
            }else if(!(checkField(theForm.txtViewerTip.value))){
                clicked=false;
                theForm.txtViewerTip.select();
                theForm.txtViewerTip.focus();
                return false;
            }
        }
    }
    return true;
}

function getViewerTip(){
    theForm = document.forms[0];
    theForm.txtViewerTip.value = theForm.lstviewerservlet.options[theForm.lstviewerservlet.selectedIndex].value;
}


function checkField(field){
    var badCharacters = checkStringForChars(field, ARR_NAME_BAD_CHARS, true);
    if(badCharacters.length != 0) {
      alert(STR_ITEM_BAD_CHARS + badCharacters);
      return false;
    }
    return true;
}

function disableAdminButtons(theForm,mode) {
     if(mode=='create') {
         theForm.RetrieveRegistration.disabled = true;
         theForm.btnTransferRegistration.disabled = true;
         theForm.btnUpdateRegistration.disabled = true;
         theForm.btnDeleteRegistration.disabled= true;
     } else if(mode=='delete') {
         theForm.RetrieveRegistration.disabled = true;
         theForm.btnCreateRegistration.disabled = true;
         theForm.btnTransferRegistration.disabled = true;
         theForm.btnUpdateRegistration.disabled = true;
     } else if(mode=='update') {
         theForm.RetrieveRegistration.disabled= true;
         theForm.btnCreateRegistration.disabled = true;
         theForm.btnTransferRegistration.disabled = true;
         theForm.btnDeleteRegistration.disabled = true;
     } else if(mode=='transfer') {
         theForm.RetrieveRegistration.disabled = true;
         theForm.btnCreateRegistration.disabled = true;
         theForm.btnUpdateRegistration.disabled = true;
         theForm.btnDeleteRegistration.disabled = true;
     } else if(mode=='properties') {
         theForm.btnTransferRegistration.disabled = true;
         theForm.btnCreateRegistration.disabled = true;
         theForm.btnUpdateRegistration.disabled = true;
         theForm.btnDeleteRegistration.disabled = true;
     }

}


function enableAdminButtons(theForm,mode) {
     if(mode=='create') {
         theForm.RetrieveRegistration.disabled = false;
         theForm.btnTransferRegistration.disabled = false;
         theForm.btnUpdateRegistration.disabled = false;
         theForm.btnDeleteRegistration.disabled = false;
     } else if(mode=='delete') {
         theForm.RetrieveRegistration.disabled = false;
         theForm.btnCreateRegistration.disabled = false;
         theForm.btnTransferRegistration.disabled = false;
         theForm.btnUpdateRegistration.disabled = false;
     } else if(mode=='update') {
         theForm.RetrieveRegistration.disabled = false;
         theForm.btnCreateRegistration.disabled = false;
         theForm.btnTransferRegistration.disabled = false;
         theForm.btnDeleteRegistration.disabled = false;
     } else if(mode=='transfer') {
         theForm.RetrieveRegistration.disabled = false;
         theForm.btnCreateRegistration.disabled = false;
         theForm.btnUpdateRegistration.disabled = false;
         theForm.btnDeleteRegistration.disabled = false;
     } else if(mode=='properties') {
         theForm.btnTransferRegistration.disabled = false;
         theForm.btnCreateRegistration.disabled = false;
         theForm.btnUpdateRegistration.disabled = false;
         theForm.btnDeleteRegistration.disabled = false;
     }
}

function disableStateButtons(theForm,mode) {
     if(mode=='create') {
         theForm.Update.disabled = true;
         theForm.Remove.disabled = true;
     } else if(mode=='delete') {
         theForm.Create.disabled = true;
         theForm.Update.disabled = true;
     } else if(mode=='update') {
         theForm.Create.disabled = true;
         theForm.Remove.disabled = true;
     }

}

function enableStateButtons(theForm,mode) {
     if(mode=='create') {
         theForm.Update.disabled = false;
         theForm.Remove.disabled = false;
     } else if(mode=='delete') {
         theForm.Create.disabled = false;
         theForm.Update.disabled = false;
     } else if(mode=='update') {
         theForm.Create.disabled = false;
         theForm.Remove.disabled = false;
     }
}

function disableViewerButtons(theForm,mode) {
     if(mode=='create') {
         theForm.Modify.disabled          = true;
         theForm.Delete.disabled          = true;
         theForm.AssignViewers.disabled   = true;
         theForm.UnassignViewers.disabled = true;

     } else if(mode=='delete') {
         theForm.Create.disabled          = true;
         theForm.Modify.disabled          = true;
         theForm.AssignViewers.disabled   = true;
         theForm.UnassignViewers.disabled = true;

     } else if(mode=='update') {
         theForm.Create.disabled          = true;
         theForm.Delete.disabled          = true;
         theForm.AssignViewers.disabled   = true;
         theForm.UnassignViewers.disabled = true;
     }
     else if(mode=='assign') {
         theForm.Create.disabled          = true;
         theForm.Modify.disabled          = true;
         theForm.Delete.disabled          = true;
         theForm.UnassignViewers.disabled = true;
     }
     else if(mode=='unassign') {
         theForm.Create.disabled          = true;
         theForm.Modify.disabled          = true;
         theForm.Delete.disabled          = true;
         theForm.AssignViewers.disabled   = true;
     }
}

function enableViewerButtons(theForm,mode) {
     if(mode=='create') {
         theForm.Modify.disabled          = false;
         theForm.Delete.disabled          = false;
         theForm.AssignViewers.disabled   = false;
         theForm.UnassignViewers.disabled = false;

     } else if(mode=='delete') {
         theForm.Create.disabled          = false;
         theForm.Modify.disabled          = false;
         theForm.AssignViewers.disabled   = false;
         theForm.UnassignViewers.disabled = false;

     } else if(mode=='update') {
         theForm.Create.disabled          = false;
         theForm.Delete.disabled          = false;
         theForm.AssignViewers.disabled   = false;
         theForm.UnassignViewers.disabled = false;
     }
     else if(mode=='assign') {
         theForm.Create.disabled          = false;
         theForm.Modify.disabled          = false;
         theForm.Delete.disabled          = false;
         theForm.UnassignViewers.disabled = false;
     }
     else if(mode=='unassign') {
         theForm.Create.disabled          = false;
         theForm.Modify.disabled          = false;
         theForm.Delete.disabled          = false;
         theForm.AssignViewers.disabled   = false;
     }
}

function checkFieldMaxLength(field){
    if(!isValidLength(field,0,STR_ITEM_MAX_CHAR_LENGTH)) {
      alert(STR_ITEM_ALERT_MAX_CHAR_LENGTH + " " +STR_ITEM_MAX_CHAR_LENGTH);
      return false;
    }
    return true;
}
