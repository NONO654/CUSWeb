/*!==========================================================================
 *  JavaScript Report Functions
 *  
 *  emxMetricsObjectCountUtils.js
 *
 *  This file contains the code for populating the select boxes of the dialog page etc
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 * 
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetricsObjectCountUtils.js.rca 1.9 Wed Oct 22 16:11:55 2008 przemek Experimental $
 *============================================================================
 */
 
function validateReport(){
    var thisForm = document.forms[0];
    if(thisForm.txtTypeDisplay.value == ""){
        alert(STR_METRICS_SELECT_TYPE);
        turnOffProgress();
        return false;
    }    
    if(thisForm.lstGroupBy.value == "SelectOne"){
        alert(STR_METRICS_SELECT_GROUPBY);
        turnOffProgress();
        return false;
    }
    if(fromAndToDate()){
        alert(STR_METRICS_FROMDATE);
        turnOffProgress();
        return false;    
    }
    if(thisForm.vaultSelction[2].checked==true){
        if (thisForm.vaultsDisplay.value =="") {
            alert (STR_METRICS_SELECTVAULT);
            turnOffProgress ();
            return false;
        }
    }
    return true;
}


function setSelectedVaultOption(){
    document.MetricsObjectCountReportForm.vaultSelction[2].checked=true;
    showChooser('../common/emxVaultChooser.jsp?fieldNameActual=vaults&fieldNameDisplay=vaultsDisplay&incCollPartners=true');
}


function clearVault(){
    document.forms[0].vaultsDisplay.value='';
    document.forms[0].vaults.value='';
}

//Added for Note Status feature
function clearContainedIn(){
   document.forms[0].txtContainedIn.value='';
   document.forms[0].txtActualContainedIn.value='';
}

function disableRevision(){
    if(document.forms[0].latestRevision.checked) {
            document.forms[0].txtRev.value = "";
            document.forms[0].txtRev.disabled = true;
            document.forms[0].latestRevision.value = "last";
    } else {
            document.forms[0].txtRev.value = "*";
            document.forms[0].txtRev.disabled = false;
            document.forms[0].latestRevision.value = "";
    }
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

