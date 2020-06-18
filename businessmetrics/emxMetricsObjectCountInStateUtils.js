/*!==========================================================================
 *  JavaScript Report Functions
 *  
 *  emxMetricsObjectCountInStateUtils.js
 *
 *  This file contains the code for populating the select boxes of the dialog page etc
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 * 
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetricsObjectCountInStateUtils.js.rca 1.11 Wed Oct 22 16:11:58 2008 przemek Experimental $
 *============================================================================
 */

function validateReport(){
    var ContentFrame = findFrame(getTopWindow(),"metricsReportContent");
    var form = document.forms[0];
    if(form.txtTypeDisplay.value == ""){
        alert(STR_METRICS_SELECT_TYPE);
        turnOffProgress ();
        return false;
    }    
    if(form.listpolicy.value == ""){
        alert(STR_METRICS_NO_POLICY);
        turnOffProgress ();
        return false;
    }
    if(form.liststate.value == ""){
        alert(STR_METRICS_NO_STATES);
        turnOffProgress ();
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
    return true;
}


		function updatePolicy(){ // The callback function
			var theForm = document.forms[0];
			var mode = "listpolicy";
			var typename = document.getElementById("txtTypeActual").value;
			if((typeof typename) == "undefined"){
			  typename = document.getElementById("txtTypeActual").value;
			}
			// submitting in the hidden frame to a processing jsp
			theForm.target = "metricsReportHidden";   
			theForm.action = "emxMetricsObjectCountInStateReportGetValues.jsp?Typename="+typename+"&Mode="+mode;
			theForm.submit();

			updateType();


		} 


			function updateState(){ 
				var polName = document.forms[0].listpolicy.value;
				var mode = "liststate";
				document.forms[0].target = "metricsReportHidden";
				document.forms[0].action = "emxMetricsObjectCountInStateReportGetValues.jsp?Policyname="+polName+"&Mode="+mode;
				document.forms[0].submit();    
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

			function set3DValue(){
				if(document.forms[0].draw3D.checked) {
					document.forms[0].draw3D.value = "true";
				}else{  
					document.forms[0].draw3D.value = "false";
				}
			}
			function clearContainedIn(){
			   document.forms[0].txtContainedIn.value='';
			   document.forms[0].txtActualContainedIn.value='';
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



