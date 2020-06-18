<%
   response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
 
%>

<%@ page import="com.matrixone.apps.framework.ui.emxPagination" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List"%>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.lang.String" %>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%
	
	if (!context.isTransactionActive())
		ContextUtil.startTransaction(context, true);

	String xmlReturn = "<root>";
	
	String objectId = emxGetParameter(request,"objectId");
	String columnName = emxGetParameter(request,"columnName");
	
	String retVal = null;
	
	Map argsHash = new HashMap();
	argsHash.put("objectId", objectId);
	argsHash.put("columnName", columnName);
			
	String[] args = JPO.packArgs(argsHash);
			
	retVal =(String) JPO.invoke(context, "emxParameterEdit", null, "getDefaultUnit", args, String.class);
	
    xmlReturn = xmlReturn + "<DefaultUnit>" + retVal+"</DefaultUnit>";
    
	xmlReturn = xmlReturn + "</root>";
	response.getWriter().write(xmlReturn);

%>



