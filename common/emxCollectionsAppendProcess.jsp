<%--  emxCollectionsAppendProcess.jsp   -  This page appends to a collection
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsAppendProcess.jsp.rca 1.5 Wed Oct 22 15:48:20 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<!-- Import the java packages -->
<%@ page import="com.matrixone.apps.domain.util.SetUtil" %>

<%
 StringList memberIds = new StringList();
 String collectionName = "";

 // Look for the  'emxTableRowId' from config table first
 String[] emxTableRowIds = emxGetParameterValues(request,"emxTableRowId"); 
 
 int sRowIdsCount = emxTableRowIds.length;
 
 if (sRowIdsCount > 0) {
   for(int count=0; count < sRowIdsCount; count++)
   {
     memberIds.addElement(emxTableRowIds[count]);
   }
   
 } else {
    // Loop through parameters and pass on to summary page
    for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
    {
       String name = (String) names.nextElement();
       if (name.startsWith("checkBox") || name.startsWith("emxTableRowId"))
       {
         String value = emxGetParameter(request, name);
         if (!value.equals("-1"))
           memberIds.addElement(value);
       }
    }
 }

 collectionName = (String)session.getAttribute("CollectionName");
 SetUtil.append(context, collectionName, memberIds);
%>

<script language="Javascript">
   getTopWindow().getWindowOpener().getTopWindow().refreshTreeDetailsPage();
   parent.window.closeWindow();
</script>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
