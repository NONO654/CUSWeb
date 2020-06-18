<%--  emxCollectionItemsMoveCopyProcess.jsp   - To Move / Copy the items from one collection to another collection.

   Copyright (c) 2004-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxCollectionItemsMoveCopyProcess.jsp.rca 1.2.3.2 Wed Oct 22 15:48:36 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>

<%
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String strSelectedCollectionItems = emxGetParameter(request,"CollectionItems");
  String reloadURL = "";
  String strMode = emxGetParameter(request,"mode");
  String strCollectionName = emxGetParameter(request,"setRadio");
  String strfrmCollectionName = emxGetParameter(request,"fromCollectionName");
  
  try 
  {
       
         StringList strlCollectionItems = FrameworkUtil.split(strSelectedCollectionItems,"|");
         String strMemberId = "";
         String strTemp = "";
         StringList strlobjectIds = new StringList();
         for(int i=0;i<strlCollectionItems.size();i++)
         {
             strMemberId = (String)strlCollectionItems.get(i);
		     strlobjectIds.add(strMemberId);
         }
         if(strMode.equals("Copy"))
         {
	         SetUtil.append(context,strCollectionName,strlobjectIds);
         }
         else if(strMode.equals("Move"))
         {
             SetUtil.append(context,strCollectionName,strlobjectIds);
             SetUtil.removeMembers(context,strfrmCollectionName,strlobjectIds,false);
         }
  }
catch(Exception e)
{
   throw e;
}

%>

<script language="Javascript">
getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
getTopWindow().closeWindow();
</script>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

