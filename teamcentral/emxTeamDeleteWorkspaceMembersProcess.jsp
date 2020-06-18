<%--  emxTeamDeleteWorkspaceMembersProcess.jsp   -  Deleting the Selected Members and dosconnecting the route members.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamDeleteWorkspaceMembersProcess.jsp.rca 1.25 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamProfileUtil.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "emxTeamGrantAccess.inc"%>
<%@include file = "emxTeamStartUpdateTransaction.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  // read the objId and ProjectId passed in
  String objId[]         = emxGetParameterValues(request, "chkItem1");
  String jsTreeID        = emxGetParameter(request, "jsTreeID");
  String objectId        = emxGetParameter(request, "objectId");
  String workspaceId     = emxGetParameter(request, "workspaceId");
  String sSelectPersonId = emxGetParameter(request, "personIds");
  StringTokenizer sPersonIdsToken =null;
  String sPersonId	=	"";

  /*10-7-0-0 Conversion Start*/
  if(objId==null || objId.length==0)
  {
    objId=emxGetParameterValues(request, "emxTableRowId");
  }
 /*10-7-0-0 Conversion End*/
// For Roles, the function that generates the rows for the table
// (emxWorkspaceBase_mxJPO.constructWorkspaceAccessList())
// creates a row id of "Role:<Role Name>".
        HashMap requestMap = new HashMap();
        requestMap.put("objectId",objectId);
        requestMap.put("jsTreeID",jsTreeID);
        requestMap.put("workspaceId",workspaceId);
        requestMap.put("objId",objId);
        requestMap.put("sSelectPersonId",sSelectPersonId);
		try{
        HashMap resultMap = (HashMap)JPO.invoke(context, "emxWorkspace", new String[0], "deleteWorkspaceMembers",JPO.packArgs(requestMap), HashMap.class);
        sSelectPersonId = (String)resultMap.get("sSelectPersonId");
        String netName = (String)resultMap.get("netName");
        if (!"".equals(netName))
        {
    %>
    <script language="javascript">
      alert("<%=XSSUtil.encodeForJavaScript(context, netName) + " " %>" + "<emxUtil:i18nScript localize="i18nId">emxTeamCentral.AccessSummary.RemoveTemplateOwner</emxUtil:i18nScript>");
      parent.location.reload();
    </script>

    <%
       }

%>

<%@ include file="emxTeamCommitTransaction.inc" %>

<%
  } catch(Exception e){
    session.putValue("error.message",e.getMessage());
%>

<%@ include file="emxTeamAbortTransaction.inc" %>

<%
  }
%>
 <script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
  <script language="javascript">
//29 dec    var tree = getTopWindow().tempTree;
      //29 dec
<%
    sPersonIdsToken = new StringTokenizer(sSelectPersonId,";",false);
    while (sPersonIdsToken.hasMoreTokens()) {
      sPersonId = sPersonIdsToken.nextToken();
%>
   getTopWindow().deleteObjectFromTrees("<%=sPersonId%>", false);
<%
    }
%>
var detailsDisplay = openerFindFrame(getTopWindow(), 'detailsDisplay');
  if(detailsDisplay){
	  detailsDisplay.location.href = detailsDisplay.location.href;
	  }
  </script>



