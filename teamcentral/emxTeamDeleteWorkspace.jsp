<%--  emxTeamDeleteWorkspace.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamDeleteWorkspace.jsp.rca 1.12 Tue Oct 28 23:00:44 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@page import="com.matrixone.apps.common.Workspace" %>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

 <script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
  <script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<html>
<body>
<form name="processForm">
<%
  /*10-7-0-0 Conversion Start*/
  //below two lines are added for the bug 322991
  	String sProjectIdes[] = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
    String sProjectIds = FrameworkUtil.join(sProjectIdes, ";");
  /*10-7-0-0 Conversion End*/
  String submitted = emxGetParameter(request,"submitted");
 if(submitted==null ||submitted.equals(""))
 {
	 String strConfirmMsg = EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.MyWorkspaceSummary.MsgConfirm");
%>
	<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=sProjectIds%></xss:encodeForHTMLAttribute>"/>   
    <input type="hidden" name="submitted" value="true" />
    </form>  
    <script language="javascript">
     if(confirm("<%=strConfirmMsg%>")){
	 document.processForm.action = 'emxTeamDeleteWorkspace.jsp?submitted=true';
	 document.processForm.submit();
     
     }
    </script>
    </html>
<%
 }
 else
 {
  StringTokenizer sProjectIdsToken = new StringTokenizer(sProjectIds,";",false);
  String sProjectId = "";
  %>
  
  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
  
  <%
  BusinessObject boProject = null;
  String sMsg = i18nNow.getI18nString("emxTeamCentral.WorkspaceDelete.MsgConnected","emxTeamCentralStringResource",sLanguage);
  boolean bCanDelete = true;
  while (sProjectIdsToken.hasMoreTokens()) {
    sProjectId = sProjectIdsToken.nextToken();

    if ((!TeamUtil.canProjectDeleted(context, session, sProjectId))) {
      bCanDelete = false;
      boProject = new BusinessObject(sProjectId);
      boProject.open(context);
      sMsg += boProject.getName()+",";
      boProject.close(context);
    }
  }
  if (bCanDelete) {
    sMsg = i18nNow.getI18nString("emxTeamCentral.WorkspaceDelete.MsgOwner","emxTeamCentralStringResource",sLanguage);
    sProjectIdsToken = new StringTokenizer(sProjectIds,";",false);
    while (sProjectIdsToken.hasMoreTokens()) {
      sProjectId = sProjectIdsToken.nextToken();
      boProject = new BusinessObject(sProjectId);
      boProject.open(context);
      String sCurrentUser = context.getUser();
      if (!(sCurrentUser.equals(boProject.getOwner().getName()))) {
        bCanDelete = false;
        sMsg += boProject.getName()+",";
      }else{
    	  %>
      	<script language="javascript">
      	  getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, sProjectId)%>", false);
      	</script>

     <%
      }
      boProject.close(context);
    }
  }

  sMsg = sMsg.substring(0, sMsg.length()-1);

  if (!bCanDelete) {
%>
    <script language="Javascript">
      alert("<%=XSSUtil.encodeForJavaScript(context, sMsg)%>");
      parent.window.location.href = parent.window.location.href;
    </script>
<%
  } else {
    Workspace.workspaceDelete(context,sProjectIds);
    
%>
    <script language="Javascript">
     getTopWindow().refreshTablePage();
    </script>
<%
  }
}
%>
