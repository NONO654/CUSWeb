<%@ page import="com.matrixone.apps.framework.ui.emxPagination" %>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="java.lang.String" %>

<%
	System.out.println("Begin emxProfileProcess.jsp");
	String command = emxGetParameter(request,"command");
	System.out.println("Command "+command);
	if(command.equals("clone") || command.equals("create")) {
		response.setContentType("text/xml");
		response.setContentType("charset=UTF-8");
		response.setHeader("Content-Type", "text/xml");
		response.setHeader("Cache-Control", "no-cache");
		response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
	System.out.println("OK");
   }
 
%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%
	
	if (!context.isTransactionActive())
		ContextUtil.startTransaction(context, true);
	String objectId = emxGetParameter(request,"objectId");
	
	if(command.equals("clone")){
		String name = emxGetParameter(request,"profileName");
		String description = emxGetParameter(request,"description");
		String importList = emxGetParameter(request,"importList");
		
		HashMap programMap = new HashMap();
		HashMap paramMap = new HashMap();
		programMap.put("paramMap", paramMap);
		paramMap.put("profileName",name);
		paramMap.put("objectId",objectId);
		paramMap.put("description",description);
		paramMap.put("importList",importList);
		
		String retour = (String)JPO.invoke(context, "emxImportCloneProfile", null, "cloneProfile", JPO.packArgs(programMap), String.class);
		System.out.println("Result :"+retour);
		
		String xmlReturn = "<root>";
		if(retour != null) {
			xmlReturn += "<errorProfile><![CDATA[";
			xmlReturn += retour;
			xmlReturn += "]]></errorProfile>";
		}
		xmlReturn += "</root>";
		
		response.getWriter().write(xmlReturn);
	}
	if(command.equals("create")){
		String name = emxGetParameter(request,"profileName");
		String description = emxGetParameter(request,"description");
		
		HashMap programMap = new HashMap();
		HashMap paramMap = new HashMap();
		programMap.put("paramMap", paramMap);
		paramMap.put("profileName",name);
		paramMap.put("description",description);
		
		String retour = (String)JPO.invoke(context, "emxProfileBase", null, "createProfile", JPO.packArgs(programMap), String.class);
		System.out.println("Result :"+retour);
		
		String xmlReturn = "<root>";
		if(retour != null) {
			xmlReturn += "<createdProfile><![CDATA[";
			xmlReturn += retour;
			xmlReturn += "]]></createdProfile>";
		}
		xmlReturn += "</root>";
		
		response.getWriter().write(xmlReturn);
	}
	
	System.out.println("End emxProfileProcess.jsp");
%>
