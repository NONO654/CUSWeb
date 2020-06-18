<%--  emxManufacurerEquivalentPartFormValidation.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "emxMEPCommonInclude.inc"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="matrix.db.*"%>

<% 
	response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
	String sPartType  = PropertyUtil.getSchemaProperty(context, "type_Part");
	String languageStr = request.getHeader("Accept-Language");
%>


function submitFilterButton() {
	
    var sURL = "../common/emxIndentedTable.jsp?program=jpo.manufacturerequivalentpart.Part:getFilteredMEP&table=MEPManufacturerEquivalentsPartSB&toolbar=MEPManufacturerEquivalentPartsToolbar,ENCManufacturerEquivalentStatusFilterToolbar,ENCManufacturerEquivalentFilterToolbar&suiteKey=ManufacturerEquivalentPart&header=emxManufacturerEquivalentPart.label.ManufacturerEquivalentParts&selection=multiple&HelpMarker=emxhelpmepsummary&sortColumnName=Name&sortDirection=ascending&PrinterFriendly=true";
    
    var fieldArr = ["objectId", "MEPManufacturer","MEPManufacturer_actualValue", "MEPManufacturerReset", "MEPState", "MEPStatus", "MEPPreference", "MEPName", "MEPType", "MEPTypeReset", "MEPDescription"];
    var fieldObject;
    for (var i = 0; i < fieldArr.length; i++) {
        fieldObject = document.getElementById(fieldArr[i]);
        if(fieldObject == null || fieldObject == "undefined" || fieldObject == "null")
        {
        	fieldObject = getTopWindow().document.getElementById(fieldArr[i]);        
        }
        if (fieldObject != null && fieldObject != "undefined") {
                sURL += "&" + fieldArr[i] + "=" + fieldObject.value;
        }
    }
    this.document.location.href = sURL;
}

function resetLocation(){
	document.getElementById("MEPManufacturer").value="*";
	document.getElementById("MEPManufacturer_actualValue").value="";
}

function resetType(){
	//XSSOK
	document.getElementById("MEPType").value="<%=i18nNow.getTypeI18NString(sPartType,languageStr)%>";
	//XSSOK
	document.getElementById("MEPType_actualValue").value="<%=sPartType%>";
}
