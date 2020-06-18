<%--  emxCollectionDeleteProcess.jsp   -  The process page for deleting a
      collection.

   Copyright (c) 199x-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsDeleteProcess.jsp.rca 1.3 Wed Oct 22 15:48:05 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<!-- Import the java packages -->

<%
 String sCollections = emxGetParameter(request, "Collections");
 String sDeleteMembers = emxGetParameter(request, "deleteRadio");
 boolean deleteMembers = false;

 if (sDeleteMembers.equals("true"))
   deleteMembers = true;

 StringTokenizer stok = new StringTokenizer(sCollections,"|",false);
 while(stok.hasMoreTokens())
 {
   String sCollectionName = stok.nextToken();
   try
   {
     SetUtil.delete(context, sCollectionName, deleteMembers);
   }
   catch(FrameworkException fx)
   {
     fx.printStackTrace();
   }
 }

%>

<script language="Javascript">
   parent.window.closeWindow();
   parent.window.getWindowOpener().location.reload();
</script>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
