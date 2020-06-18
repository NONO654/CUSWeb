/*!==========================================================================
 *  JavaScript Report Functions
 *  
 *  emxMetricsPolicyChooserUtils.js
 *
 *  This file contains the code for Validation of Policy Chooser etc. 
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 * 
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetricsPolicyChooserUtils.js.rca 1.5 Wed Oct 22 16:11:56 2008 przemek Experimental $
 *============================================================================
 */

function validatePolicy(policyForm){
    var checkedValue      = "";
    var bAllowNoSelection = "false";
    var state             = "";
    var val               = "";
    var valInt            = "";
    for ( var i = 0; i <policyForm.elements.length; i++ ) {
        if (policyForm.elements[i].type == "checkbox" || policyForm.elements[i].type == "radio"){
            if( policyForm.elements[i].checked && policyForm.elements[i].name.indexOf('policy') > -1){
                var valPolState = policyForm.elements[i].value;
                var interValArr = valPolState.split(";");
                val = interValArr[0];
                var policyVal = val.substring(0,val.indexOf("|"));
                var state1 = val.substring(val.indexOf("|")+1,val.length);
                if (state==""){
                    state = state1;
                    valInt = interValArr[1];
                }
                if ((state!="") && (state != state1)){
                    alert(STR_SELECT_POLICIESWITHSAMESTATE);
                    checkedValue="";
                    return false;
                }
                checkedValue += policyVal + ",";
            }
        }
    }  
    if(checkedValue == "" && "true" != bAllowNoSelection) {
        alert(STR_METRICS_SELECT_POLICY);
        return false;    
    }
    return true;
}

function doCheck(){
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++){
        if (objForm.elements[i].name.indexOf('policy') > -1){
            objForm.elements[i].checked = chkList.checked;
        }
    }
}

function updateCheck(selectType) {
    if(selectType == "checkbox"){ 
        var objForm = document.forms[0];
        var chkList = objForm.chkList;
        chkList.checked = false;
    }
}

function checkPolicy(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual) {
    if(validatePolicy(policyForm)){ 
        parent.window.getWindowOpener().doDone(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual);
        self.closeWindow();
    }
}

function doCancel(){
    self.closeWindow();
}




