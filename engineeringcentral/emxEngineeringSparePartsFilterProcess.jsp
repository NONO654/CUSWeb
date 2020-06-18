<%-- emxEngineeringSparePartsFilterProcess.jsp --
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
    String objectId = emxGetParameter(request, "objectId");
    String SparePartsOnEBOM = emxGetParameter(request, "SparePartsOnEBOM");
%>
    <script language="Javascript">
    //XSSOK
    var contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:SPARE_PART=Yes&showInitialResults=true&table=ENCPartSparePart&selection=multiple&hideHeader=true&suiteKey=EngineeringCentral&submitLabel=emxFramework.Command.Done&submitAction=refreshCaller&cancelLabel=emxFramework.Command.Cancel&submitURL=../engineeringcentral/emxpartConnectSparePartProcess.jsp&excludeOIDprogram=emxENCFullSearch:excludeConnectedSpareOIDs&HelpMarker=emxhelpfullsearch&objectId="+"<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
    var svalue = "<%=XSSUtil.encodeForJavaScript(context,SparePartsOnEBOM)%>";
    if(svalue == "true"){
    	contentURL = contentURL+"&includeOIDprogram=emxENCFullSearch:includeBOMConnectedSpareOIDs";
    	showModalDialog(contentURL,"570","570","true");
    }
    else{
	    var sparePartOption = window.parent.document.getElementById('ENCSparePartOptionCheckBox').checked;   	
	    if(sparePartOption) {
	        contentURL = contentURL+"&toolbar=ENCSparePartsFilterToolBar&includeOIDprogram=emxENCFullSearch:includeBOMConnectedSpareOIDs&ENCSparePartOptionCheckBox=true";
	    } else {
	        contentURL=contentURL+"&ENCSparePartOptionCheckBox=false";
	    }
    
		//this.top.location.href	= contentURL;
		getTopWindow().location.href	= contentURL;
    }
  
</script>
