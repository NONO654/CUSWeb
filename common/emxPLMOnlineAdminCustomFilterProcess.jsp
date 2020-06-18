
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%@page import  ="java.util.*"%>
<%@page import  ="com.matrixone.apps.domain.util.MapList;"%>

<%
	//get table Id
	String tableID = Request.getParameter(request, "tableID");
	//get typed name in filter
	String searchName = Request.getParameter(request, "searchName");

	// Get business object list from session level Table bean
	// HashMap tableData = tableBean.getTableData(tableID);
	
	//get list of object names in table
	MapList namesList = tableBean.getObjectList(tableID);
	//HashMap requestMap = tableBean.getRequestMap(tableID);

	//maplist to contain new filtered names
	MapList filteredNamesList = new MapList();
	
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

	//step through each object name from table
	for (int i = 0; i < namesList.size(); i++)
	{
		//get name
		String name =	(String)((HashMap)namesList.get(i)).get("name");
		//System.out.println(name);
		//System.out.println(name.matches(matchName));

		//if it matches, then add it to new filtered list
		if(name.matches(matchName))
		{
			HashMap hm = new HashMap();

			hm.put("name",name);
			hm.put("id",(String)((HashMap)namesList.get(i)).get("id"));

            filteredNamesList.add(hm);
			
		}

	}
	//set new filtered list of objects to table
	tableBean.setFilteredObjectList(tableID, filteredNamesList);
%>

<script language="javascript">
parent.refreshTableBody();
</script>
