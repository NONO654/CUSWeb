
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>

<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%
    initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
	String i18_title = getSafeNLS("Access.Command.Result");
	//get entered parameters
	String commandPattern = request.getParameter("commandPattern");
	
	//pack result as argument to a JPO method
	HashMap hMap = new HashMap();
	hMap.put("commandPattern", commandPattern);
	String [] progArgs;

	try{
		progArgs = JPO.packArgs(hMap);
		//set list of resulted policies through a JPO
		JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"setCommandList", progArgs);

        // forwarding to emxTable JSP
%>
        <jsp:forward page="../common/emxTable.jsp">
            <jsp:param name="table"       value="emxPLMOnlineAdminCommandResultTable"/>
            <jsp:param name="objectBased" value="false"/>
            <jsp:param name="header"      value="<%=i18_title%>"/>
            <jsp:param name="program"     value="emxPLMOnlineAdminPersonViewProgram:getCommandNamesForTable"/>
        </jsp:forward>
<%

	}
	catch(Exception e)
	{
		out.print("Exception has come: "+ e);
		System.out.print("Exception has come: "+ e);
	}
%>
