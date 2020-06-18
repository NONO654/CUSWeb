
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%
    initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
	String i18_title = getSafeNLS("Access.Rule.Result");
	//get entered parameters
	String rulePattern = request.getParameter("rulePattern");
	
	//pack result as argument to a JPO method
	HashMap hMap = new HashMap();
	hMap.put("rulePattern", rulePattern);
	String [] progArgs;

	try{
		progArgs = JPO.packArgs(hMap);
		//set list of resulted rules through a JPO
		JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"setRuleList", progArgs);

        // forwarding to emxTable JSP
%>
        <jsp:forward page="../common/emxTable.jsp">
            <jsp:param name="table"       value="emxPLMOnlineAdminRuleResultTable"/>
            <jsp:param name="objectBased" value="false"/>
            <jsp:param name="header"      value="<%=i18_title%>"/>
            <jsp:param name="program"     value="emxPLMOnlineAdminPersonViewProgram:getRuleNamesForTable"/>
        </jsp:forward>
<%
	}
	catch(Exception e)
	{
		out.print("Exception has come: "+ e);
		System.out.print("Exception has come: "+ e);
	}
%>
