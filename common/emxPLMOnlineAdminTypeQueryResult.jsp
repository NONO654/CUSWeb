
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%@ page import="com.dassault_systemes.vplmposadminservices.NLSCatalog" %>
	
<%
    NLSCatalog myNLS = new NLSCatalog("emxPLMOnlineAdminSecurityReport",request.getLocale());
	String i18_title = myNLS.getMessage("Access.Type.Result");
	//get entered parameters
	String typePattern = request.getParameter("typePattern");
	
	//Load all Types
	ArrayList typeList = new ArrayList(); 
		
	try{
			typeList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getReferenceNames", null, ArrayList.class);
	}
	catch(Exception e)
	{
		out.print("Exception has come: "+ e);
	}

	//get typed name in filter
	String searchName = typePattern;

	//string to contain new filtered names
	String filteredNames = "";
	
	//java pattern string to match name 
	String matchName = "";
	//array to contain parts of typed string in filter
	String[] nameParts = null;

	//if it contains "*"
	if(searchName.contains("*"))
	{
		//split it by "*"
		nameParts = searchName.split("\\*");
		//if it starts with "*", then build match name string
		if(searchName.startsWith("*"))
			matchName += ".*";

		//update match name string for each part
		for(int i = 0; i < nameParts.length; i++)
		{
			if(!nameParts[i].equals(""))
				matchName += nameParts[i] + ".*" ;
		}
		matchName = matchName.substring(0, matchName.length() - 2);

		//if it ends with "*", then update match name string
		if(searchName.endsWith("*"))
				matchName += ".*";

	}
	else
		//else keep it same as typed string
		matchName = searchName;

	//System.out.println(matchName);

	//step through each name
	for (int i = 0; i < typeList.size(); i++)
	{
		//get name
		String name =	(String)typeList.get(i);
		//System.out.println(name);
		//System.out.println(name.matches(matchName));

		//if it matches, then add it to new filtered list
		if(name.matches(matchName))
		{
			filteredNames += name + ",";
		}
	}
	//remove last comma
	if(filteredNames.length() > 0)
		filteredNames = filteredNames.substring(0, filteredNames.length() - 1);

	//pack result as argument to a JPO method
	HashMap hMap = new HashMap();
	hMap.put("typePattern", filteredNames);
	String [] progArgs;

	try{
		progArgs = JPO.packArgs(hMap);
		//set list of resulted policies through a JPO
		JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"setTypeList", progArgs);

        // forwarding to emxTable JSP
%>
        <jsp:forward page="../common/emxTable.jsp">
            <jsp:param name="table"       value="emxPLMOnlineAdminTypeResultTable"/>
            <jsp:param name="objectBased" value="false"/>
            <jsp:param name="header"      value="<%=i18_title%>"/>
            <jsp:param name="program"     value="emxPLMOnlineAdminPersonViewProgram:getTypeNamesForTable"/>
        </jsp:forward>
<%
	}
	catch(Exception e)
	{
		out.print("Exception has come: "+ e);
		System.out.print("Exception has come: "+ e);
	}
%>
