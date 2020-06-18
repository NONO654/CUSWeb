<%--  emxEngrAddExistingSpecsAndMarkupsConnect.jsp   - The Processing page for add an existing specification.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.engineering.PartDefinition,java.util.HashMap" %>

<jsp:useBean id="specBean" class="com.matrixone.apps.engineering.PartDefinition" scope="session"/>
<%	
	String addExistingSpecification = emxGetParameter(request, "AddExistingSpecification");
	String languageStr = request.getHeader("Accept-Language");
	String message = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.PleaseMakeASelection",languageStr);

	String objectId = emxGetParameter(request, "objectId");
	String frameName = emxGetParameter(request, "frameName");
	String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
	
	if(selectedItems != null){
		String relType = emxGetParameter(request, "srcDestRelName");
		boolean isConnected = false;
		HashMap requestMap = new HashMap();
		requestMap.put("objectId",objectId);
		requestMap.put("selectedItems",selectedItems);
		requestMap.put("relType",relType);
		try{
		    new PartDefinition().connectSpec(context,requestMap);
		}catch(Exception ex){
		 if (ex.toString() != null && (ex.toString().trim()).length() > 0)
		     emxNavErrorObject.addMessage(ex.toString().trim());
		}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "emxDesignBottomInclude.inc"%>
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="Javascript">
		if('true' == "<xss:encodeForJavaScript><%=addExistingSpecification%></xss:encodeForJavaScript>")
			{
			if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN){
				findFrame(getTopWindow(),"<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>").refreshSBTable();
			}
			else{
				window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
			}
			getTopWindow().closeWindow();
			}
		else{
		  //refresh the calling structure browser and close the search window
		  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
		  //parent.document.location.href = parent.document.location.href;
		  getTopWindow().closeWindow();
		}
		</script>
<%
	}
	else{
%>
		<script language="Javascript">
		//XSSOK
			alert("<%=message%>");
		</script>
<% 	    
	}
%>


