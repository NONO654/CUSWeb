<%-- emxFilterOnDiscussion.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFilterOnAccessRequest.jsp.rca 1.1.7.5 Wed Oct 22 16:18:37 2008 przemek Experimental przemek $
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.MessageUtil" %> 
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%

try
{
        String timeStamp = emxGetParameter(request, "timeStamp");
        String strStateFilter = emxGetParameter(request,"APPAccessRequestStateFilter");
        String strStatusFilter = emxGetParameter(request,"APPAccessRequestStatusFilter");
        //HashMap tabeldata=tableBean.getTableData(timeStamp);
        //MapList objectList=tableBean.getObjectList(tabeldata);
        HashMap tabeldata=indentedTableBean.getTableData(timeStamp);
        MapList objectList=indentedTableBean.getObjectList(tabeldata);

		 Map map = new HashMap(2);
		 map.put("APPAccessRequestStateFilter", strStateFilter);
		 map.put("APPAccessRequestStatusFilter", strStatusFilter);

		 String[] args = JPO.packArgs(map);
		 String[] constructor = { null };
		 
		 MapList mapList = (MapList) JPO.invoke(context, "emxCommonAccessRequest", constructor, "getAllAccessRequests", 
													args, MapList.class);
		 indentedTableBean.setFilteredObjectList(timeStamp, mapList);
    }
    catch(Exception e)
    {
		e.printStackTrace();
        if(e.toString() != null && (e.toString().trim()).length()>0)
            {
               emxNavErrorObject.addMessage(e.toString().trim());
            }
    }
%>
<script language="JavaScript">
//parent.refreshTableBody();
getTopWindow().refreshTablePage();
</script>
