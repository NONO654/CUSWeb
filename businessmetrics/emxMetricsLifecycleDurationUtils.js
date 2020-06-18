/*!==========================================================================
 *  JavaScript Report Functions
 *  
 *  emxMetricsLifecycleDurationUtils.js
 *
 *  This file contains the code for populating the select boxes of the dialog page etc
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 * 
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetricsLifecycleDurationUtils.js.rca 1.12 Wed Oct 22 16:11:55 2008 przemek Experimental $
 *============================================================================
 */

function updateValues(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual) {
    
    var checkedValue = "";
    var displayValues = "";
    var state = "";
    var val = "";
    var valInt = "";
    
    for ( var i = 0; i <policyForm.elements.length; i++ ) {
        if (policyForm.elements[i].type == "checkbox" || policyForm.elements[i].type == "radio"){
            if( policyForm.elements[i].checked && policyForm.elements[i].name.indexOf('policy') > -1){
                var valPolState = policyForm.elements[i].value;
                var interValArr = valPolState.split(";");
                val = interValArr[0];
                var policyVal = val.substring(0,val.indexOf("|"));
                var policyStates = val.substring(val.indexOf("|")+1,val.length);
                if (state==""){
                    state=policyStates;
                    valInt = interValArr[1];
                }
                checkedValue += policyVal + ",";
                displayValues += policyForm.elements[i+1].value + ",";
            }
        }
    }  
    checkedValue = checkedValue.substring(0,checkedValue.length-1);
    displayValues = displayValues.substring(0,displayValues.length-1);

    if(fieldNameDisplay != null && fieldNameDisplay != "" &&
    fieldNameDisplay != "undefined" && fieldNameDisplay != "null")
    {
        eval("document.forms[0]."+fieldNameDisplay+"\.value = \""+ displayValues +"\";");
        eval("document.forms[0]."+fieldNameActual+"\.value = \""+ checkedValue +"\";");
    }           
    
    //get translated vault names
    var stateValueArr = state.split("|");
    var stateInterValueArr = valInt.split(":");
    var commaSeperatedState = "";
    if(document.forms[0].lstTargetState.options){
        document.forms[0].lstTargetState.options.length = 0;
        document.forms[0].lstFromState.options.length = 0;
        document.forms[0].lstToState.options.length = 0;
    }
    for(var j=0; j < stateValueArr.length; j++) {
        var stateDisplayValue = "";
        var stateActualValue = "";
        stateActualValue = stateValueArr[j];
        stateDisplayValue = stateInterValueArr[j];
        
        commaSeperatedState = commaSeperatedState + stateActualValue + ",";
        
        var optTargetState = new Option(stateDisplayValue,stateActualValue);
        var optFromState  = new Option(stateDisplayValue,stateActualValue);
        var optToState  = new Option(stateDisplayValue,stateActualValue);
        
        document.forms[0].lstTargetState.options.add(optTargetState);
        document.forms[0].lstFromState.options.add(optFromState);
        document.forms[0].lstToState.options.add(optToState);

        //for selecting the last state in the Target and To state combo boxes.
        if(j==stateValueArr.length-1){
            document.forms[0].lstTargetState.selectedIndex = j;
            document.forms[0].lstToState.selectedIndex = j;
        }
    }
    var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
    contentFrame.document.forms[0].hdnAllStates.value = commaSeperatedState;
}

function processFunction(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual){
   if(validatePolicy(policyForm)){
        doDone(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual);
   }
}

// The doDone() is called from the child window, emxMetricsPolicyChooserUtils.js
// The "Target State", "From" and "To" states select boxes of the Lifecycle Report Dialog 
// page are built in the updateValues() of emxMetricsLifecycleDurationUtils.js
// This approach was followed since IE has a bug which will prevent building  
// of Select boxes of parent window from child windows.
function doDone(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual) {
    updateValues(policyForm,policyDisplayMap,fieldNameDisplay,fieldNameActual);
}

function validateReport(){
    var ContentFrame = findFrame(getTopWindow(),"metricsReportContent");
    var form = document.forms[0];
    
    if(form.txtTypeDisplay.value == ""){
        alert(STR_METRICS_SELECT_TYPE);
        turnOffProgress();
        return false;
    }
    if((form.txtPolicyDisplay.value == "") && (form.btnPolicy.disabled == true)){
        alert(STR_METRICS_NO_POLICY);
        turnOffProgress();
        return false;
    } else if(form.txtPolicyDisplay.value == "") {
        alert(STR_METRICS_SELECT_POLICY);
        turnOffProgress();
        return false;
    }
     if(fromAndToDate()){
        alert(STR_METRICS_FROMDATE);
        turnOffProgress();
        return false;    
    }
    if(form.optPeriod[0].checked==true){
        if ((form.txtFromDate.value =="") || (form.txtToDate.value =="")){
            alert (STR_METRICS_SELECTDATE);
            turnOffProgress ();
            return false;
        }
        if(parseInt(form.txtFromDate_msvalue.value) > parseInt(form.txtToDate_msvalue.value)){
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
        }else if(form.txtPeriod.value > 500){
            alert(STR_METRICS_LARGE_NUMBER);
            turnOffProgress();
            return false;
        }else if(form.txtPeriod.value == 0 || form.txtPeriod.value < 0){
            alert(STR_METRICS_NEGATIVE_NUMBER);
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
    if((form.lstFromState.value == "") && (form.lstToState.value == "") && (form.lstTargetState.value == "") && (form.txtPolicyDisplay.value != "")){
        alert(STR_METRICS_NO_STATES);
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
function fromAndToDate(){
       for (var i=0;i<document.forms[0].elements.length;i++) {
           var objElement = document.forms[0].elements[i];
           if((objElement.name).indexOf("comboDescriptor_")>=0){
               if((objElement.options[objElement.options.selectedIndex].value).indexOf("InBetween") >= 0){
                    var fromDate = document.forms[0].elements[i+2].value;
                    var toDate = document.forms[0].elements[i+4].value;
                    if(fromDate > toDate){
                        return true
                    }
               }
           }
        }
        return false;
}

function set3DValue(){
    if(document.forms[0].draw3D.checked) {
        document.forms[0].draw3D.value = "true";
    }else{  
        document.forms[0].draw3D.value = "false";
    }
}

function updatePolicyAndStates(){
    var dialogFormName = document.forms [0].name
    var emxType = arguments[0];
    if((typeof emxType) == "undefined"){
        emxType = document.getElementById("txtTypeActual").value;
    }  
    // this is submitting in hidden frame....The frame "metricsReportHidden"
    // is present in the emxMetricsReport.jsp
    document.forms [0].target = "metricsReportHidden"; 
    document.forms [0].action = "emxMetricsLifecycleDurationReportGetValues.jsp?Type="+emxType;
    document.forms [0].submit ();  
	updateType();
}
function clearContainedIn(){
			   document.forms[0].txtContainedIn.value='';
			   document.forms[0].txtActualContainedIn.value='';
			}
