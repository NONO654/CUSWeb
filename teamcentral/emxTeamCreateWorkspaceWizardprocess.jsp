<%--  emxTeamCreateWorkSpaceWizardProcess.sp   -  Creating the WorkSpace Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateWorkspaceWizardprocess.jsp.rca 1.28 Wed Oct 22 16:06:21 2008 przemek Experimental przemek $

 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamGrantAccess.inc"%>
<%@include file = "emxTeamProfileUtil.inc"%>
<%@include file = "../components/emxComponentsSetCompanyKeyInRPE.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%!
    private static final String  S_PROTOCOL = "ftp://";
    private static final String  S_FORMAT   = "generic";
    private static final String  S_HOST     = "localhost";
    private static final boolean B_UNLOCK   = true;
%>
<%
    String projectName        = emxGetParameter(request,"projectName");
    String description        = emxGetParameter(request,"txtdescription");
    String projectId          = emxGetParameter(request,"objectId");
    String sWsTemplateId      = emxGetParameter(request, "templateId");
    String sWsTemplateName    = emxGetParameter(request, "templateDisplay");
    String buyerDeskId        = emxGetParameter(request,"txtBuyerDeskId");
    String treeUrl            = null;

    // determine if we are appending or replacing the object
    boolean B_APPEND           = false;

    String strUser             = context.getUser();
    // Multiple-Comapnies in a Single Vault feature fix,
    // create the Worksapce in the Owner's default vault
    String strCompanyVault     = context.getVault().getName();

    String strAlreadyExists    = "";
    BusinessObject busProject  = null;
    String boBuyerDeskId       = null;
    String strProjectId        = null;
    boolean bError             = false;

    if(projectId == null){
     projectId = "";
    }

    Pattern relPat             = new Pattern(DomainObject.RELATIONSHIP_WORKSPACE_BUYER_DESK);
    Pattern typePat            = new Pattern(DomainObject.TYPE_BUYER_DESK);
    Workspace workspace        = (Workspace)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);

    try
    {
        if (projectId != null && !"null".equals(projectId) && !"".equals(projectId))
        {
            workspace.setId(projectId);
            workspace.open(context);
            if(!workspace.isWorkspaceExists(context,strCompanyVault,projectName ))
            {
                workspace.change(context, workspace.getTypeName(), projectName, workspace.getRevision(), workspace.getVault(), workspace.getPolicy().getName());
                workspace.setDescription(description);
                workspace.update(context);
                if ( buyerDeskId != null && !"".equals(buyerDeskId) ) {
                    BusinessObject  oldBuyerDesk = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context, workspace ,relPat.getPattern(),typePat.getPattern(),false, true);
                    oldBuyerDesk.open(context);
                    boBuyerDeskId = oldBuyerDesk.getObjectId();
                    oldBuyerDesk.close(context);
                    if(boBuyerDeskId == null || "null".equals(boBuyerDeskId) || "".equals(boBuyerDeskId)){
                        workspace.addBuyerDesk(context, buyerDeskId);
                    } else {
                        boBuyerDeskId = boBuyerDeskId.trim();
                        String[] selObjects = {boBuyerDeskId};
                        workspace.removeBuyerDesks(context, selObjects);
                        workspace.addBuyerDesk(context, buyerDeskId);
                    }
                }
            } else {
                // description is still editable.
                workspace.setDescription(description);
                workspace.update(context);
            }
        } else {
            // Check for the Project Already exists or not
            boolean inCreateMode = false;
            ContextUtil.pushContext(context);
            matrix.db.Query query=new matrix.db.Query();
            query.setBusinessObjectType(DomainConstants.TYPE_WORKSPACE);
            query.setBusinessObjectName(projectName);
            query.setBusinessObjectRevision("*");
            query.setOwnerPattern("*");
            query.setVaultPattern(strCompanyVault);
            query.setWhereExpression("");
            query.setExpandType(false);
            query.setObjectLimit((short)0);
            query.setSearchFormat("*");
            query.setSearchText("");
            MapList maplist1 = FrameworkUtil.toMapList(query.select(context, DomainConstants.EMPTY_STRINGLIST));
            ContextUtil.popContext(context);

            if (maplist1.size()==0){
                strProjectId = TeamUtil.autoRevision(context,session, workspace.TYPE_PROJECT, projectName,workspace.POLICY_PROJECT, strCompanyVault);
                projectId = strProjectId;
                workspace.setId(strProjectId);
                workspace.open(context);
                //Set the description
                workspace.setDescription(description);
                workspace.update(context);

                //To connect context user to Workspace .
                DomainAccess.createObjectOwnership(context, strProjectId, com.matrixone.apps.domain.util.PersonUtil.getPersonObjectID(context), "Full", DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);

                //To Connect Workspce with Workspace Template Object
                if((sWsTemplateId != null && !"null".equals(sWsTemplateId)) && (!sWsTemplateId.equals(""))) {
                   DomainObject workspaceTemplateObj = DomainObject.newInstance(context,sWsTemplateId,DomainConstants.TEAM);
                   workspace.connectWorkspaceTemplate(context,workspaceTemplateObj,true,true,strCompanyVault);
                }

            } else {
               bError = true;
               session.putValue("error.message", workspace.TYPE_PROJECT + " " + projectName + " " + i18nNow.getI18nString("emxTeamCentral.Common.AlreadyExists","emxTeamCentralStringResource",sLanguage));
            }
        }

        if(!bError && buyerDeskId != null && !"".equals(buyerDeskId)) {
            workspace.addBuyerDesk(context, buyerDeskId);
            workspace.addBuyerDeskPersons(context,strCompanyVault,buyerDeskId);
        }
        workspace.close(context);

        treeUrl = UINavigatorUtil.getCommonDirectory(context)+
                  "/emxTree.jsp?AppendParameters=true&objectId="+ XSSUtil.encodeForURL(context, strProjectId) +
                  "&mode=insert"+
                  "&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory);

%>
      <%@ include file = "emxTeamCommitTransaction.inc" %>
<%
    } catch (Exception ex){
        bError = true;
        session.putValue("error.message",ex.getMessage());
%>
        <%@  include file="emxTeamAbortTransaction.inc" %>
<%
    }
%>
<html>
  <body>
    <form name="newForm" target="_parent">
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="workspaceDesc" value="<xss:encodeForHTMLAttribute><%=description%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=sWsTemplateId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=sWsTemplateName%></xss:encodeForHTMLAttribute>"/>
<% if(!bError){
%>
      <input type="hidden" name="workspaceName" value="<xss:encodeForHTMLAttribute><%=projectName%></xss:encodeForHTMLAttribute>"/>
<%  }
%>
    </form>

    <script language="javascript">
<%
    if(!bError){
%>
      document.newForm.action = "emxTeamCreateWorkspaceToplevelFoldersFS.jsp";
<%
    } else if(bError){
%>
      document.newForm.action = "emxTeamCreateWorkspaceWizardDialogFS.jsp";
<%
    } else {
%>
      //XSSOK
      var tree = parent.window.getWindowOpener().getTopWindow().tempTree;
	  //XSSOK
      parent.window.getWindowOpener().parent.location.href = "<%= treeUrl %>";
<%
  }
%>
      document.newForm.submit();

    </script>
  </body>
</html>

