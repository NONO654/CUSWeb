<%--  CPVCallJPOProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
--%>

<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>

<%@page import="com.dassault_systemes.pprRestServices.utils.JsonUtil"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>


<%
try 
{	
	// 1. Get received JSON data from request
    BufferedReader buffReader = new BufferedReader(new InputStreamReader(request.getInputStream()));
    String json = "";
    if (buffReader != null){
        json = buffReader.readLine();
    }
    
   
	Map mapInput = JsonUtil.jsonToMap(json);
	String sProgram = (String)mapInput.get("program");
	String sMethod = (String)mapInput.get("method");
	Map mapObj = (Map)mapInput.get("data");
	Map mapContextObj = (Map)mapInput.get("context");
		
	// 3. Call process
	context.start(false);
	HashMap args = new HashMap();
	args.put("mapObj",mapObj);
	Map returnMapData = (Map)JPO.invoke(context, sProgram, null, sMethod, JPO.packArgs(args), Map.class);	
	context.abort();
    
	// 4. Set output
	Map returnOutput = new HashMap();
	returnOutput.put("data",returnMapData);
	returnOutput.put("context",mapContextObj);

	// 5. Return output
    out.clear();
    response.setContentType("application/json; charset=UTF-8");    
    out.print(JsonUtil.convertToJsonString(returnOutput));
	out.flush();
	
} catch (Exception ex) {
	
    // 5. Pass error message back
    out.clear();
    response.setContentType("application/json; charset=UTF-8");
    out.print("{result: 'error',  message: '" + ex.getMessage() + "'}");
	out.flush();
    ex.printStackTrace();
}
%>
