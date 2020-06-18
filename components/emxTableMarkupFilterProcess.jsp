<!--
  emxTableMarkupFilterProcess.jsp
 Copyright (c) 2007-2018 Dassault Systemes. All Rights Reserved.
 This program contains proprietary and trade secret information of
 Dassault Systemes. Copyright notice is precautionary only and does
 not evidence any actual or intended publication of such program.
-->

<%@include file = "../common/emxNavigatorInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%@ page import="com.matrixone.apps.domain.*" %>

<%
String tableID = Request.getParameter(request, "tableID");
String selectedState = Request.getParameter(request,"filterState");
String selectedOwner=Request.getParameter(request,"filterowner");
MapList relBusObjList = tableBean.getObjectList(tableID);

HashMap tableData = tableBean.getTableData(tableID);
HashMap requestMap = tableBean.getRequestMap(tableData); 


String objectId=(String)requestMap.get("objectId");


DomainObject domobj=new DomainObject();
domobj.setId(objectId);


MapList filteredObjPageList = new MapList();



String relpattern="";
String typepattern="";
relpattern=PropertyUtil.getSchemaProperty(context,"relationship_PartMarkup");
typepattern=PropertyUtil.getSchemaProperty(context,"type_BOMMarkup");
	

StringList selectStmts = new StringList(3);
selectStmts.addElement(DomainConstants.SELECT_ID);
selectStmts.addElement(DomainConstants.SELECT_OWNER);
selectStmts.addElement(DomainConstants.SELECT_CURRENT);
    	
StringList selectRelStmts = new StringList(1);
selectRelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);

	

String sWhere="";

// Enters If Loop if selectedState filter is Other than All
if(!selectedState.equalsIgnoreCase("All"))
{
	// Enters If Loop if Owner is other than All
	if(!selectedOwner.equalsIgnoreCase("All"))
	{
		sWhere="current=="+"\""+selectedState+"\""+"&&"+"owner=="+"\""+selectedOwner+"\"";
	}
	//Enters Else Loop if Owner is All
	else
	{
		sWhere="current=="+"\""+selectedState+"\"";
	}
 
}
//Enters Else Loop if selectedState filter is All
else
{	//Enters If Loop if Owner is other than All
	if(!selectedOwner.equalsIgnoreCase("All"))
	{
		sWhere="owner=="+"\""+selectedOwner+"\"";
	}
	// Enters Else Loop if State and  owner are All
	else
	{
		sWhere=null;
	}

		
}

filteredObjPageList = domobj.getRelatedObjects(context,
									relpattern,
									typepattern,
									selectStmts,
									selectRelStmts,
									false,
									true,
									(short)1,
									sWhere,
									null);
         

// Set the MapList to the table
tableBean.setFilteredObjectList(tableID,filteredObjPageList);
%>
<script language="JavaScript">
parent.refreshTableBody();
</script>

