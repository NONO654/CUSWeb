<%--  CPVTypesDisplay.jsp

   (c) Dassault Systemes, 1993-2017.  All rights reserved.

--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@page import = "com.dassault_systemes.pprRestServices.utils.JsonUtil"%>

<head>
<%
	try{
		String values = emxGetParameter(request, "values");
		String languageStr = emxGetParameter(request, "languageStr");
		HashMap argsMap = new HashMap();
		argsMap.put("values",values);
		argsMap.put("languageStr",languageStr);
		
		Object displayTypesList = JPO.invoke(context, "DELJMyDeskUtil", null, "setDisplayNamesOfPreferredTypes", JPO.packArgs(argsMap), Object.class);
		Map mapReturn = new HashMap();
		
		mapReturn.put("displayTypes",displayTypesList);
		out.clear();
		response.setContentType("application/json; charset=UTF-8");
		out.write(JsonUtil.convertToJsonString(mapReturn));
		return;

	}catch(Exception ex){
		if (ex.toString() != null && (ex.toString().trim()).length() > 0){
			emxNavErrorObject.addMessage(ex.toString().trim());
			%><%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%><%
		}
	}
%>
</head>
</html>
