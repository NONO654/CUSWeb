<%--  emxTeamDeleteWorkspaceTemplate.jsp - Delete the Selected Workspace Templates
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamDeleteWorkspaceTemplate.jsp.rca 1.7 Wed Oct 22 16:06:26 2008 przemek Experimental przemek $
--%>

<%@include file   = "../emxUICommonAppInclude.inc"%>
<%@ include file  = "emxTeamCommonUtilAppInclude.inc" %>


<html>
<body>

<form name = "DeleteWorkspaceTemplate">

<%
  String sObjectId   = emxGetParameter(request, "objectId");
  String sFlag       = emxGetParameter(request, "flag");
  String contextUser = context.getUser();
  String[] stemplateIdArray =null;


  //To get the selected Workspace Template Ids For the First time
  if(sFlag != null && "true".equals(sFlag))  {
    stemplateIdArray  = emxGetParameterValues(request, "RowIds");
  } else {
	String[] sArrayWorkspaceTemplateIds = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
    for(int i=0; i<sArrayWorkspaceTemplateIds.length; i++) {
%>
  <input type= "hidden" name = "RowIds" value ="<xss:encodeForHTMLAttribute><%=sArrayWorkspaceTemplateIds[i]%></xss:encodeForHTMLAttribute>" />

<%
    }
  }

%>
<%@ include file  = "../common/enoviaCSRFTokenInjection.inc" %>
<input type= "hidden" name = "objectId" value ="<xss:encodeForHTMLAttribute><%=sObjectId%></xss:encodeForHTMLAttribute>"/>
<input type= "hidden" name = "flag" value ="true" />
</form>

</body>
</html>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
//For the First time to confirm Deletion
if(sFlag == null || "".equals(sFlag) || "null".equals(sFlag))  {
%>

<script language="javascript">
if(confirm("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.common.DeleteMsg</emxUtil:i18nScript>")) {
    	document.DeleteWorkspaceTemplate.action = 'emxTeamDeleteWorkspaceTemplate.jsp?flag=true';
    	document.DeleteWorkspaceTemplate.submit();
}

</script>

<%
  //After the Confirmation for Workspace Template Deletion
} else {
  String sWorkspaceTemplateNames = "";
  boolean bDelete = true;
  %>
  
  <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
  
  <%  
  if(stemplateIdArray != null) {

    //WorkspaceTemplate boWorkspaceTemplate = (WorkspaceTemplate)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_TEMPLATE,DomainConstants.TEAM);
    WorkspaceTemplate boWorkspaceTemplate = null;
    //To check whether User has access to delete the selected Workspace Template
    for (int i = 0; i < stemplateIdArray.length; i++)
    {
      boWorkspaceTemplate = new WorkspaceTemplate(stemplateIdArray[i]);
      boWorkspaceTemplate.open(context);
      if( !(boWorkspaceTemplate.getOwner().getName()).equals(contextUser)) {
        sWorkspaceTemplateNames = boWorkspaceTemplate.getName()+ ","+sWorkspaceTemplateNames;
        bDelete = false;
      }
      boWorkspaceTemplate.close(context);
    }

    try {
      //to Delete the Workspace Template
      if(bDelete) {
        WorkspaceTemplate.deleteWorkspaceTemplates (context , stemplateIdArray);
		for (int i = 0; i < stemplateIdArray.length; i++)
        {%>
        	<script language="javascript">
        	  getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, stemplateIdArray[i])%>", false);
        	</script>

       <% }
      } else {
        //To throw Error Msg in case if the User does n't have access to delete
        sWorkspaceTemplateNames = sWorkspaceTemplateNames.substring(0,sWorkspaceTemplateNames.length()-1);
        //String sErrorMsg =i18nNow.getI18nString ("emxTeamCentral.WorkspaceTemplateDelete.ErrorMsg1","emxTeamCentralStringResource",sLanguage)+ " \\\" " +sWorkspaceTemplateNames+" \\\" "+i18nNow.getI18nString("emxTeamCentral.WorkspaceTemplateDelete.ErrorMsg2","emxTeamCentralStringResource",sLanguage);
       String sErrorMsg =i18nNow.getI18nString ("emxTeamCentral.WorkspaceTemplateDelete.ErrorMsg1","emxTeamCentralStringResource",sLanguage);
       sErrorMsg+=" "+"\""+sWorkspaceTemplateNames+"\""+" ";
       sErrorMsg+=i18nNow.getI18nString("emxTeamCentral.WorkspaceTemplateDelete.ErrorMsg2","emxTeamCentralStringResource",sLanguage);
        session.putValue("error.message",sErrorMsg);
      }
    } catch (Exception ex ) {
              session.putValue("error.message",ex.getMessage());
%>
              <%@  include file="emxTeamAbortTransaction.inc" %>
<%
    }
  }
%>
//to Reload the Page
<script language="javascript">
	var frame = findFrame(getTopWindow(),'content');
	frame.location.href =  frame.location.href;
</script>

<%
}
%>
