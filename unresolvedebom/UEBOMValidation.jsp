<%--  UEBOMValidation.jsp   - page to include the custom webform validation functions.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<!--XSSOK-->
<emxUtil:localize id="i18nId" bundle="emxUnresolvedEBOMStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<script language="Javascript">
function clearRelatedFields()
{
      basicClear('ResponsibleDesignEngineer');
      basicClear('ResponsibleManufacturingEngineer');
      basicClear('RDEngineer');         
}

function clearRDO()
{
	basicClear('RDO');
	clearRelatedFields();
}
//Start for Next Gen UI-this function will be loaded in Edit PUEECO page which enables RDE,RME fields if RDO field is not empty else disables.
function preProcessInEditPUEECO(update){
	
   	var editForm = document.forms["editDataForm"];
    var fieldRDO      = editForm.RDODisplay.value
    var displayField  = fieldRDO != "" ? false : true;
    if(!update) {
        if(editForm.RDOfieldValueOID != null)
            editForm.RDOOID.value = editForm.RDOfieldValueOID.value;
    }
    
    editForm.ResponsibleManufacturingEngineerDisplay.disabled=displayField;
    editForm.btnResponsibleManufacturingEngineer.disabled=displayField;
    editForm.ResponsibleDesignEngineerDisplay.disabled=displayField;
    editForm.btnResponsibleDesignEngineer.disabled=displayField;
 }

//this function was the onChange handler for RDO field in edit PUEECO page,which enables RDE,RME fields if RDO field is changed and not empty else disables.
function updateRDOForEditPUEECO() {
	
	preProcessInEditPUEECO(true);
    var editForm = document.forms["editDataForm"];
    if(editForm.ResponsibleDesignEngineer.value != "" 
        && editForm.ResponsibleDesignEngineer.value != "Unassigned") {
        basicClear('ResponsibleDesignEngineer');
    }
    
    //alert(document.emxCreateForm.ResponsibleManufacturingEngineer.value);
    if(editForm.ResponsibleManufacturingEngineer.value != "" 
        && editForm.ResponsibleManufacturingEngineer.value != "Unassigned") {
        basicClear('ResponsibleManufacturingEngineer');
    }

}
//End for Next Gen UI

//2012x Cancel PUEECO--Starts
function validateCancelPUEECO() {
	
    if (confirm("<emxUtil:i18nScript localize="i18nId">emxUnresolvedEBOM.CancelPUEECODialog.CancelPUEECOConfirm</emxUtil:i18nScript>")){
        return true;
    }
    return false;

 }

function preProcessInCancelPUEECO() {
    var editForm = document.forms["editDataForm"];
    editForm.Warning.disabled=true;
    
}
//2012x Cancel PUEECO--Ends
</script>
