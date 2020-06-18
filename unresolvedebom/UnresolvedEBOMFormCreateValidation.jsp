<%--  UnresolvedEBOMFormCreateValidation.jsp   - page to include the custom webform validation functions.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<!-- XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxUnresolvedEBOMStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding()); 
%>
function checkPositiveReal(fieldname){
    var fieldname = "";
    if(!fieldname) {
        fieldname=this;
    }

    if( isNaN(fieldname.value) || fieldname.value < 0 )
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
        fieldname.focus();
        return false;
    }
    return true;
}

function applicabiltyTabLink(){
	var strProductID = document.forms[0]["ProductOID"].value;
	if(strProductID == ""){
		alert("<emxUtil:i18nScript localize="i18nId">emxUnresolvedEBOM.Alert.SelectProduct</emxUtil:i18nScript>");
	}
	else{
		var url ="../common/emxPortal.jsp?portal=PUEECOPortal&header=Applicability&HelpMarker=emxhelppartchangemgtpv&objectId="+strProductID; 
		showModalDialog(url,850,630);
	}
}

//Start for Next Gen UI--this function will be loaded in Create PUEECO page which enables RDE,RME fields if RDO field is not empty else disables.
function preProcessInCreatePUEECO(update){
    //Default RDO Population
    if(!update) {
    	//XSSOK
        document.emxCreateForm.DesignResponsibilityOID.value = "<%=defaultRDOId %>";
        //XSSOK
        document.emxCreateForm.DesignResponsibilityDisplay.value = "<%=defaultRDOName %>";
        //XSSOK
        document.emxCreateForm.DesignResponsibility.value = "<%=defaultRDOName %>";
    }
    var  fieldRDO      = document.emxCreateForm.DesignResponsibilityDisplay.value;
    var  displayField  = fieldRDO != ""?false:true;

    document.emxCreateForm.ResponsibleManufacturingEngineerDisplay.disabled=displayField;
    document.emxCreateForm.btnResponsibleManufacturingEngineer.disabled=displayField;
    document.emxCreateForm.ResponsibleDesignEngineerDisplay.disabled=displayField;
    document.emxCreateForm.btnResponsibleDesignEngineer.disabled=displayField;
	
}

//this function was the onChange handler for RDO field in Create PUEECO page,which enables RDE,RME fields if RDO field is changed and is not empty else disables.
function updateRDOForCreatePUEECO() {
    preProcessInCreatePUEECO(true);
    if(document.emxCreateForm.ResponsibleDesignEngineer.value != "" 
        && document.emxCreateForm.ResponsibleDesignEngineer.value != "Unassigned") {
        basicClear('ResponsibleDesignEngineer');
    }
    
    if(document.emxCreateForm.ResponsibleManufacturingEngineer.value != "" 
        && document.emxCreateForm.ResponsibleManufacturingEngineer.value != "Unassigned") {
        basicClear('ResponsibleManufacturingEngineer');
    }

}//End for Next Gen UI
