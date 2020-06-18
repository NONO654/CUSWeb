<%--  emxEngrAssigneeDelegateConnect.jsp   - The Processing page for ECR connections.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  DomainObject fromObj = DomainObject.newInstance(context);
  DomainObject toObj = DomainObject.newInstance(context);

  String[] objectId = emxGetParameterValues(request,"objectId");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  String[] arrRelIds1 = emxGetParameterValues(request, "arrRelIds1");
  
  // isTo is set to TRUE when the search results contain the TO side of the relationship
  
  String errorMessage = "";
  if(selectedItems != null)
  {
    try
    {
       String[] selectedIds=selectedItems;
       //single select - just get first item
       for (int i = 0; i < selectedItems.length; i++) {
           //if this is coming from the Full Text Search, have to parse out |objectId|relId|
           StringTokenizer strTokens = new StringTokenizer(selectedItems[i],"|");
           if ( strTokens.hasMoreTokens())
           {
               selectedIds[i] = strTokens.nextToken();
           }
	   }  
           
	   Map reqMapAffectedItems = new HashMap();
	   reqMapAffectedItems.put("strChangeObjID",objectId);
	   reqMapAffectedItems.put("strNewAssigneeID",selectedIds);
	   reqMapAffectedItems.put("arrAffectedItemRelID",arrRelIds1);
	   try
	   {
	   	 com.matrixone.apps.engineering.Change changeObject = new com.matrixone.apps.engineering.Change();
	   	 changeObject.splitDelegateAssignees(context, reqMapAffectedItems);
	   }
	   catch(Exception e)
	   {
	   }
       if (!"".equals(errorMessage))
       {
     	  session.putValue("error.message",errorMessage);
       }
    }
    catch(Exception e)
    {
%>
      <%@include file = "emxEngrAbortTransaction.inc"%>
<%
      session.putValue("error.message",e.getMessage());
    }
  }  // if ends for selectedTypes

%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
  //refresh the calling structure browser and close the search window
  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
  getTopWindow().closeWindow();
</script>

<%@include file = "emxDesignBottomInclude.inc"%>

