<%-- emxCustomTableUtility.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxCustomTableUtility.jsp.rca 1.14.3.2 Wed Oct 22 15:48:34 2008 przemek Experimental przemek $

--%>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>


<%
	response.setHeader("Cache-Control", "no-cache");
	String strMode = emxGetParameter(request,"mode");
	String strTimeStamp = emxGetParameter(request,"timeStamp");
	String isStructureCompare = emxGetParameter(request, "IsStructureCompare");
	
	if ("TRUE".equalsIgnoreCase(isStructureCompare)){
		indentedTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;
	}
	
	String uiType = emxGetParameter(request,"uiType");
	String strCurrentTableName ="";
	HashMap requestMap = null;
	out.clear();
	if(uiType!=null && uiType.equalsIgnoreCase("table"))
	{
	    requestMap = tableBean.getRequestMap(strTimeStamp);
	    strCurrentTableName =  (String)requestMap.get("table");
	}
	else if(uiType!=null && uiType.equalsIgnoreCase("structureBrowser"))
	{
	    requestMap = indentedTableBean.getRequestMap(strTimeStamp);
	    strCurrentTableName =  (String)requestMap.get("selectedTable");
	}
	boolean isUserTable = ((Boolean)requestMap.get("userTable")).booleanValue();
    if(strMode.equalsIgnoreCase("alt"))
	{
	    if(isUserTable)
	    {
		    response.getWriter().write("userTable"); 
		}
		else
		{
		    java.util.List derivedTableNamesList = com.matrixone.apps.framework.ui.UITableCustom.getDerivedTableNames(context,strCurrentTableName);
			if(derivedTableNamesList!=null && derivedTableNamesList.size()>0)
			{
			    response.getWriter().write("derivedTable");
			}
			else
			{
			    response.getWriter().write("systemTable");
			}
			    
		}
	}
	else if(strMode.equalsIgnoreCase("toggle"))
	{
	   	String customSortColumns = "";
		String customSortDirections = "";
		
		if(uiType!=null && "table".equalsIgnoreCase(uiType))
		{
		    String strNxtTableName = (String)tableBean.toggle(context,strCurrentTableName);
		    response.getWriter().write("javascript:void(refreshTable('"+XSSUtil.encodeForJavaScript(context,strNxtTableName)+ "','','','"+XSSUtil.encodeForJavaScript(context,strTimeStamp)+"','"+XSSUtil.encodeForJavaScript(context,uiType)+"'))@");
	 	
		}
		
		else
		{
			if(uiType!=null && "structureBrowser".equals(uiType))
			{
			    String strNxtTableName = (String)indentedTableBean.toggle(context,strCurrentTableName);
			    response.getWriter().write("javascript:void(refreshSBTable('"+XSSUtil.encodeForJavaScript(context,strNxtTableName)+ "','','','true','"+XSSUtil.encodeForJavaScript(context,strTimeStamp)+"','"+XSSUtil.encodeForJavaScript(context,uiType)+"'))@");
			}
		}
	}


	else if(strMode.equalsIgnoreCase("sort"))
	{
		String strSortColumnName = emxGetParameter(request,"sortColumnName");
		String strSortDirection = emxGetParameter(request,"sortDirection");
		if(isUserTable)
		{
		   	  requestMap.put("customSortColumns",strSortColumnName);
		   	  requestMap.put("customSortDirections",strSortDirection);
		   	   
		}
	}
    
	else if(strMode.equalsIgnoreCase("postRefresh"))
	{
		java.util.Set keySet = requestMap.keySet();
		java.util.Iterator itr  = keySet.iterator();
		int i=0;
		while(itr.hasNext())
		{
		    i++;
		    try
		    {
			    String key = (String)itr.next();
			    String value = (String)requestMap.get(key);
			    response.getWriter().write(key+"="+value);
			    if(i!=requestMap.size())
			        response.getWriter().write("&");
			    
		    }
		    catch(Exception e)
		    {
		        // no need to catch the exception as we need only string parameters from requestMap.
		    }
		}
		response.getWriter().write("@");
		
	}
	
%>
