<%--  emxEngrMarkupSavePostProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	String massUpdateAction = (String)session.getAttribute("massUpdateAction");
	Hashtable htConflicts = (Hashtable)session.getAttribute("ConflictList");
	requestMap.put("massUpdateAction",massUpdateAction);
	requestMap.put("ConflictList", htConflicts);

	HashMap paramMap = new HashMap(6);

	Enumeration paramNames = emxGetParameterNames(request);

	while(paramNames.hasMoreElements())
	{
		String paramName = (String)paramNames.nextElement();
		String paramValue = emxGetParameter(request,paramName);
		paramMap.put(paramName, paramValue);
	}

	HashMap programMap = new HashMap(2);
	programMap.put("paramMap", paramMap);
	programMap.put("requestMap", requestMap);

	String[] methodargs = JPO.packArgs(programMap);
	String strJPOName = "emxPartMarkup";
	String strMethodName = "createMarkupfromAffectedItem";

	try{
		HashMap returnMap = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);
	}catch(Exception e){
	    session.setAttribute("error.message", e.getMessage());
		throw e;
	}

	%>

<script language="Javascript">
	//getTopWindow().closeWindow();
	var contentFrame = parent.openerFindFrame(getTopWindow(), "detailsDisplay");
	if(contentFrame){
		contentFrame.location.href = contentFrame.location.href;
	}
	getTopWindow().closeWindow();
	getTopWindow().getWindowOpener().closeWindow();
</script>





