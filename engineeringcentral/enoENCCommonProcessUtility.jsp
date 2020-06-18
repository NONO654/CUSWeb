<%--  enoENCCommonProcessUtility.jsp  - 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.services.IPartService"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.input.IPartIngress"%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
	String objectId = emxGetParameter(request, "objectId");

	String mode = emxGetParameter(request, "EngMode");
	
	String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");
	
   	HashMap<Object,Object> programMap = new HashMap<Object,Object>();
   	programMap.put("objectId", objectId);
   	programMap.put("emxTableRowId", selPartIds);		
	
	String errorMsg = "";
	
	if ( "AddRawMaterial".equals(mode) ) {
		try {
        	JPO.invoke(context, "enoPartManagement", null, "addRawMaterials", JPO.packArgs(programMap), void.class);
		} catch (MatrixException mx) {
			errorMsg = mx.toString().replaceAll("^.*:", "").trim();
		}
	}
	
	else if ( "RemoveRawMaterial".equals(mode) ) {
		try {
        	JPO.invoke(context, "enoPartManagement", null, "removeRawMaterials", JPO.packArgs(programMap), void.class);
		} catch (MatrixException mx) {
			errorMsg = mx.toString().replaceAll("^.*:", "").trim();
		}
	}
%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">

	if ("<%= errorMsg %>" != "") {
		alert ("<%= errorMsg %>");
		var fullSearchReference = findFrame(getTopWindow(), "structure_browser");
		if (fullSearchReference != null) { fullSearchReference.setSubmitURLRequestCompleted(); }
	}

	else {
<%
		if ( "AddRawMaterial".equals(mode) ) {
%>
			getTopWindow().getWindowOpener().window.location.href = getTopWindow().getWindowOpener().window.location.href;
			getTopWindow().closeWindow();
<% 
		}

		else if ( "RemoveRawMaterial".equals(mode) ) {
%>
			parent.document.location.href=parent.document.location.href;	
<%
		}
%>
	}

</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>


