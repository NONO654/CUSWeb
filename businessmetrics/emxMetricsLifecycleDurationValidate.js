/*!==========================================================================
 *  JavaScript Report Functions
 *  
 *  emxMetricsLifecycleDurationValidate.js
 *
 *  This file contains the code for Validation Lifecycle Dialog page etc. 
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 * 
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetricsLifecycleDurationValidate.js.rca 1.6 Wed Oct 22 16:11:55 2008 przemek Experimental $
 *============================================================================
 */

function processFunction(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual){
   if(validatePolicy(policyForm)){
        parent.window.getWindowOpener().doDone(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual);
        self.closeWindow();
   }
}
  
  
function validatePolicy(policyForm){
    var checkedValue = "";
    var bAllowNoSelection= "false";
    var state = "";
    var val = "";
    var valInt = "";

    for ( var i = 0; i <policyForm.elements.length; i++ ){
        if (policyForm.elements[i].type == "checkbox" || policyForm.elements[i].type == "radio"){
            if( policyForm.elements[i].checked && policyForm.elements[i].name.indexOf('policy') > -1){
                var valPolState = policyForm.elements[i].value;
                var interValArr = valPolState.split(";");
                val = interValArr[0];
                var policyVal = val.substring(0,val.indexOf("|"));
                var state1 = val.substring(val.indexOf("|")+1,val.length);
                if (state==""){
                    state=state1;
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
    
    if(checkedValue == "" && "true" != bAllowNoSelection){
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

function updateCheck(selectType){
    if(selectType == "checkbox"){ 
        var objForm = document.forms[0];
        var chkList = objForm.chkList;
        chkList.checked = false;
    }
}


function validateReport(){
    var form = document.forms[0];
    if(form.txtTypeDisplay.value == ""){
        alert(STR_METRICS_SELECT_TYPE);
        turnOffProgress();
        return false;
    }    
    if(form.txtPolicyDisplay.value == ""){
        alert(STR_METRICS_SELECT_POLICY);
        turnOffProgress();
        return false;
    }
    if(form.optPeriod[0].checked==true){
        if ((form.txtFromDate.value =="") || (form.txtToDate.value =="")){
            alert (STR_METRICS_SELECTDATE);
            turnOffProgress ();
            return false;
        }
        if(form.txtFromDate_msvalue.value > form.txtToDate_msvalue.value){
            alert (STR_METRICS_FROMDATE);
            turnOffProgress();
            return false;
        }
    }
    if(form.optPeriod[1].checked==true){
        if(form.txtPeriod.value ==''){
            alert(STR_METRICS_PERIODVALUE);
            turnOffProgress();
            return false;
        }
        if((!(IsNumeric(form.txtPeriod))) || (form.txtPeriod.value==0)){
            form.txtPeriod.focus();
            alert(STR_METRICS_POSITIVEVALUE);
            turnOffProgress();
            return false;
        }
    }
    if(form.lstFromState.selectedIndex > form.lstToState.selectedIndex){
        alert(STR_METRICS_FROM_POLICY);
        turnOffProgress();
        return false;
    }
    return true;
}


function doCancel(){
    window.closeWindow();
}


function disablePeriod(){
    document.getElementById("txtPeriod").value='';
    document.getElementById("txtPeriod").disabled=true;
    document.getElementById("toDate").disabled=false;
    document.getElementById("fromDate").disabled=false;
    document.getElementById("txtFromDate").disabled=false;
    document.getElementById("txtToDate").disabled=false;
}


function disableDates(){
    document.getElementById("txtPeriod").disabled=false;
    document.getElementById("txtFromDate").value='';
    document.getElementById("txtToDate").value='';
    document.getElementById("txtFromDate").disabled=true;
    document.getElementById("txtToDate").disabled=true;
    document.getElementById('toDate').disabled=true;
    document.getElementById('fromDate').disabled=true;
}
