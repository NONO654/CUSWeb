<%-- emxFilterOnDiscussion.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFilterOnDiscussion.jsp.rca 1.2.5.4 Wed Oct 22 15:48:03 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.MessageUtil" %> 
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
try{

        String timeStamp=emxGetParameter(request, "timeStamp");
        String keywords=emxGetParameter(request,"APPDiscussionKeywordFilter");
        keywords=keywords.trim();
        HashMap tabeldata=tableBean.getTableData(timeStamp);
        MapList objectList=tableBean.getObjectList(tabeldata);

        if(!"*".equals(keywords) && !"".equals(keywords))
        {
            MapList filteredList=MessageUtil.searchDiscussionsOnKeywords(context,objectList,keywords);
            tableBean.setFilteredObjectList(timeStamp,filteredList);
            objectList=tableBean.getObjectList(tabeldata);
        }
        else{
            tableBean.setFilteredObjectList(timeStamp,objectList);
        }
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
parent.refreshTableBody();
</script>
