<%--  emxENCProcessRawMaterials.jsp  - 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.services.IPartService"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.input.IPartIngress"%>

<%@include file = "emxDesignTopInclude.inc"%>
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
		// For Make From
		if("AddRawMaterial".equals(mode)){
	        JPO.invoke(context,"enoPartManagement",null,"addRawMaterials",JPO.packArgs(programMap),void.class); 
		} 
		else if("RemoveRawMaterial".equals(mode)){
	        JPO.invoke(context,"enoPartManagement",null,"removeRawMaterials",JPO.packArgs(programMap),void.class);
		}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="Javascript">
<%
if("AddRawMaterial".equals(mode)){
%>
	getTopWindow().getWindowOpener().window.location.href = getTopWindow().getWindowOpener().window.location.href;
	getTopWindow().closeWindow();
<% }else if("RemoveRawMaterial".equals(mode)){
%>
parent.document.location.href=parent.document.location.href ;
<%}
%>

</script>
