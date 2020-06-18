<%--  emxMemberListtUtil.jsp

Copyright (c) 1999-2018 Dassault Systemes. 

All Rights Reserved.
This program contains proprietary and trade secret information
of MatrixOne, Inc.  Copyright notice is precautionary only and
does not evidence any actual or intended publication of such program
    
static const char RCSID[] = "$Id: emxMemberListUtil.jsp.rca 1.19 Wed Oct 22 16:18:31 2008 przemek Experimental przemek $";
--%>

<%@ page import="java.util.*"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxMemberListUtilAppInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<!-- Java Logic Section Begin -->

<%
    String actionURL="";//For refreshing the Table Page.
    String objectId="";//MemberList Object Id

    String memberId = emxGetParameter(request,"memberId");
    com.matrixone.apps.common.MemberList memberlist = (com.matrixone.apps.common.MemberList)DomainObject.newInstance(context,PropertyUtil.getSchemaProperty(context,"type_MemberList"));
    String action = request.getParameter("action")==null? "":request.getParameter("action");
    boolean isRemoved = false;
    //Added ParentOID for the Query String
    String parentOID = request.getParameter("parentOID")==null? "":request.getParameter("parentOID");
    if (action.equals("create"))
    {
      String distributionListName = emxGetParameter(request, "DistributionListName");
      String distributionListDescription = emxGetParameter(request, "DistributionListDescription");
      String scope = emxGetParameter(request, "Scope");
      String owningBU = emxGetParameter(request, "businessUnitId");
      session.setAttribute("owningBU", owningBU);
      String defaultCompanyId = emxGetParameter(request, "hdefCompanyId");
      String autoName = request.getParameter("autoName");
                String userVault = emxGetParameter(request, "hVault");
      boolean checkBoxAutoName = false;
      if(autoName!=null){
        if(autoName.equals("true"))checkBoxAutoName = true;
          }else{
            checkBoxAutoName = false;
          }
      //Create a HashTable of BusinessUnit  
      Hashtable relationsList = new Hashtable();
      relationsList.put("OwningBU",owningBU);
      relationsList.put("Scope",scope);
      relationsList.put("Description",distributionListDescription);
      relationsList.put("CompanyId",defaultCompanyId);
      // Added By Ramesh May 23
      objectId = "";
      // Added By Ramesh May 23
      //Pass the parameters to the MemberList Bean's create method
      try{
        if(memberId == null || "null".equals(memberId) || memberId.trim().length() == 0)
        {
          objectId = memberlist.create(context,memberlist.TYPE_MEMBER_LIST,distributionListName,"-",memberlist.POLICY_MEMBER_LIST,userVault,checkBoxAutoName,relationsList);
        }
        else
        {
          objectId = memberId;
          com.matrixone.apps.common.MemberList memberListToModify = new com.matrixone.apps.common.MemberList(memberId);
          objectId = memberListToModify.modify(context,distributionListName,checkBoxAutoName,relationsList);
        }

      }catch(Exception e)
      {
        session.setAttribute("error.message", e.toString());
      }
      
      StringBuffer url = new StringBuffer(512);
      //Checks if Object Id is Null
      if(objectId != null && !objectId.equals("")){
        url.append("../components/emxMemberListCreateFS.jsp?functionality=CreateDistributionListStep2&suiteKey=eServiceSuiteComponents&topLinks=true&bottomLinks=true&objectId=");
                                url.append(XSSUtil.encodeForURL(context, objectId));
                                url.append("&parentOID=");
                                url.append(XSSUtil.encodeForURL(context, parentOID));
                                url.append("&distributionListName=");
                                url.append(XSSUtil.encodeForURL(context, distributionListName));
                                url.append("&distributionListDescription=");
                                url.append(XSSUtil.encodeForURL(context, distributionListDescription));
                                url.append("&scope=");
                                url.append(XSSUtil.encodeForURL(context, scope));
                                url.append("&owningBU=");
                                url.append(XSSUtil.encodeForURL(context, owningBU));
                                url.append("&defaultCompanyId=");
                                url.append(XSSUtil.encodeForURL(context, defaultCompanyId));
                                url.append("&autoName=");
                                url.append(XSSUtil.encodeForURL(context, autoName));
                                url.append("&checkBoxAutoName=");
                                url.append(checkBoxAutoName);
                                url.append("&showWarning=false");
      }else{
    	  //XSSOK
        url.append("emxMemberListCreateFS.jsp?functionality=CreateDistributionListStep1&suiteKey=eServiceSuiteComponents&topLinks=false&bottomLinks=false");
      }
%>
<script language="javascript">
  //XSSOK
  parent.location.href="<%=url.toString()%>";
</script> 
<%
  }
  
  //For Deleting the Selected MemberList Objects
  if(action.equals("deleteDL"))
  {
    //Delete called
    String[] objectIds = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
    if(objectIds != null)
    {
    try
      {
        memberlist.delete(context,objectIds);
		for(int i = 0; i < objectIds.length;i++){
        	 %>
           	<script language="javascript">
           	  getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, objectIds[i])%>", false);
           	</script>

          <%
        }
      }catch(Exception e)
      {
        session.setAttribute("error.message", e.getMessage());
      }
    }
  }

  //May 06 added : Deletes the MemberList Object if the Window is closed in the 2nd Step.
  //"deleteObject" used as a check to close the window
  if(action.equals("deleteObject"))
  {
    //Delete called
    String[] objectIds = request.getParameterValues("emxTableRowId");//Get the selected MemberList Object Id's
    if(objectIds != null)
    {
      try
      {
        memberlist.delete(context,objectIds);
      }catch(Exception e)
      {
        session.setAttribute("error.message", e.getMessage());
      }
    }
  }
  
  //Remove the selected persons from the Memberlist
  if(action.equals("remove")){
    String[] objectIds = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));//Get the Person Object Id
    objectId = (String) emxGetParameter(request, "objectId")==null? "":(String) emxGetParameter(request, "objectId");
    //if (objectId.equals(""))objectId=request.getParameter("objectId");
    if(objectIds != null)
    {
      try
      {
        memberlist.setId(objectId);
        memberlist.removeMembers(context,objectIds,objectId);
        isRemoved = true;
      }catch(Exception e)
        {
          session.setAttribute("error.message", e.getMessage());
        }
    }
  }

  
  
  if(action.equals("removeMembers")){
    
    String[] objectIds = request.getParameterValues("emxTableRowId");//Get the Person Object Id
    objectId = (String) emxGetParameter(request, "objectId")==null? "":(String) emxGetParameter(request, "objectId");
    if (objectId.equals(""))objectId=request.getParameter("objectId");
    if(objectIds != null)
    {
      try
      {
        memberlist.setId(objectId);
        memberlist.removeMembers(context,objectIds,objectId);
      }catch(Exception e)
      {
        session.setAttribute("error.message", e.getMessage());
      }
    }
  }
  
  
  
  //For Activating and Deactivating the selected MemberLists
  if(action.equals("Activate")||action.equals("Inactivate"))
  {
    
    //Get Table Row Id's
    String[] objectIds = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
    try
    {
      if(objectIds != null)
        {
          if(action.equals("Activate")){

            memberlist.activate(context,objectIds);
          }
          else if(action.equals("Inactivate")){
            memberlist.inactivate(context,objectIds);
          }
        }
    }catch(Exception e)
    {
      session.setAttribute("error.message", e.getMessage());
    }

  }     
%>

<!-- HTML Section Begin -->

  <script language="javascript" src="../common/scripts/emxUICore.js"></script>
  <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
  <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    var action = "<%=XSSUtil.encodeForJavaScript(context, action)%>";
    var isRemoved = "<%=isRemoved %>";
    if(action == "deleteDL" ||action == "Activate" ||action == "Inactivate")
    {
      
      refreshTablePage();
    }  else if(action=="remove" && isRemoved == "true")
    {
      var selectedMembers = "<%=XSSUtil.encodeForJavaScript(context, ComponentsUIUtil.arrayToString(emxGetParameterValues(request, "emxTableRowId"), "~"))%>";
      parent.emxEditableTable.removeRowsSelected(selectedMembers.split("~"));
    }
    else if(action=="removeMembers")
    {
      parent.window.document.location.href="../components/emxMemberListCreateFS.jsp?functionality=CreateDistributionListStep2&suiteKey=eServiceSuiteComponents&topLinks=true&bottomLinks=true&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>";
    }//May 06 added : if deleteObject close the parent window
    else if(action == "deleteObject"){
      window.closeWindow();
    }
    else{
      if (parent.window.getWindowOpener().parent.frames[1].frames[1] != null)
    	  //XSSOK
        parent.window.getWindowOpener().parent.frames[1].frames[1].document.location.href = "<%=actionURL%>";
      else
    	 //XSSOK
        parent.window.getWindowOpener().parent.location.href = "<%=actionURL%>";
      
      window.closeWindow();
    }
    
    
  </script> 
  <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
  

<!-- HTML Section End -->
