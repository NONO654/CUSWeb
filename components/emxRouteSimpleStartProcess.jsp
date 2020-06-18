<%--  emxRouteWizardStartProcess.jsp  --  Starting the Route process

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSimpleStartProcess.jsp.rca 1.1.2.6 Wed Oct 22 16:18:08 2008 przemek Experimental przemek $

 --%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>


<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
    String keyValue               =emxGetParameter(request,"keyValue");
    formBean.processForm(session,request,"keyValue");
    Route route                   = (Route)DomainObject.newInstance(context , DomainConstants.TYPE_ROUTE);
    Document document             = (Document)DomainObject.newInstance(context , DomainConstants.TYPE_DOCUMENT);
    DomainObject RouteScope       = null;
    String routeId                = (String) formBean.getElementValue("routeId");
    String projectId              = (String) formBean.getElementValue("objectId");
    
    String sState                 = (String)formBean.getElementValue("routeStart");
    String folderId               = (String) formBean.getElementValue("folderId");
    String workspaceId            = (String) formBean.getElementValue("workspaceId");
    String portalMode             = (String) formBean.getElementValue("portalMode");
    String treeUrl                = null;
    String sRoute                 = i18nNow.getI18nString("emxFramework.Command.Route", "emxComponentsStringResource", sLanguage);
    String typeWorkspace          = PropertyUtil.getSchemaProperty( context,"type_Project");
    String typeWorkspaceVault     = PropertyUtil.getSchemaProperty( context,"type_ProjectVault");
    String attrDueDateOffset      = PropertyUtil.getSchemaProperty( context,"attribute_DueDateOffset");
    String attrDueDateOffsetFrom  = PropertyUtil.getSchemaProperty( context,"attribute_DateOffsetFrom");
    String OFFSET_FROM_ROUTE_START_DATE  = "Route Start Date";
    String OFFSET_FROM_TASK_CREATE_DATE  = "Task Create Date";
    boolean bPublishWorkspace     = false;
    String url                    = "";
    if("null".equals(sState) || sState == null){
      sState = "";
    }
    if(sState.equals("start")) {
       try
       {
          route.setId(routeId);
          route.open(context);
          String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.emxTreeAlternateMenuName.type_InboxTask");
          if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu ))
          {
            MailUtil.setTreeMenuName(context, treeMenu );
          }
          ContextUtil.startTransaction(context, true);
          route.promote(context);
	      route.close(context);
          ContextUtil.commitTransaction(context);
          try
          {
             ContextUtil.pushContext(context);
             InboxTask.setTaskTitle(context, routeId);
             ContextUtil.popContext(context);
          }catch(Exception ex){
             session.putValue("error.message",ex.getMessage());
          }
          treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.emxTreeAlternateMenuName.type_Route");
          boolean validTreeMenu=false;
          if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
            validTreeMenu=true;
          }
          //THIS CODITION IS KEPT IF ROUTE IS CREATED UNDER COMMON
          if(projectId != null && !"null".equals(projectId) && !"".equals(projectId))
          {
             String sScopeObjId = route.getInfo(context,"to["+route.RELATIONSHIP_ROUTE_SCOPE+"].from.id");
             if(sScopeObjId != null && !"null".equals(sScopeObjId) && !"".equals(sScopeObjId))
             {
             RouteScope = DomainObject.newInstance(context , sScopeObjId);
             if(RouteScope.getType(context).equals(typeWorkspace))
             {
                bPublishWorkspace = true ;
             }
             //Workspace Vault
             if(typeWorkspaceVault.equals(RouteScope.getType(context)))
             {
                WorkspaceVault workspaceVault = (WorkspaceVault)DomainObject.newInstance(context , DomainConstants.TYPE_WORKSPACE_VAULT);

                workspaceVault.setId(sScopeObjId);
               if(validTreeMenu) 
                {
                   MailUtil.setTreeMenuName(context, treeMenu );
                }
                String projectId1 = UserTask.getProjectId(context,sScopeObjId);
        if(projectId1 != null && !"".equals(projectId1))
        {
          bPublishWorkspace =true;  
           projectId = projectId1;
        }
        else
        {
                  bPublishWorkspace = false;
                }
      }else{
       
            projectId = sScopeObjId;
    
      }
    
        if(bPublishWorkspace)
    {
    Workspace workspace           = (Workspace)DomainObject.newInstance(context , DomainConstants.TYPE_PROJECT);

      workspace.setId(projectId);
          if(validTreeMenu) {
            MailUtil.setTreeMenuName(context, treeMenu );
          }
        }
     }
   }//THIS CODITION IS KEPT IF ROUTE IS CREATED UNDER COMMON
      //getting the ids of the connected contents
      StringList listContentIds = route.getInfoList(context,"to["+route.RELATIONSHIP_OBJECT_ROUTE+"].from.id");
      if(listContentIds == null){
        listContentIds = new StringList();
      }
      Iterator contentItr = listContentIds.iterator();

      while(contentItr.hasNext()){
        String sDocId = (String)contentItr.next();
        document.setId(sDocId);
        if(validTreeMenu) {
          MailUtil.setTreeMenuName(context, treeMenu );
        }
      }
      if(validTreeMenu) {
        MailUtil.setTreeMenuName(context, treeMenu );
      }


     
        ContextUtil.commitTransaction(context);
     

    } catch (Exception ex ) {
        boolean clientTaskMessagesExists = false;
        clientTaskMessagesExists = MqlNoticeUtil.checkIfClientTaskMessageExists(context);
        if(!clientTaskMessagesExists) {
      		session.putValue("error.message", ex.getMessage());
        }
      // Abort the transaction
      ContextUtil.abortTransaction(context);
    }
  } // if route selects start

formBean.clear();
formBean.removeFormInstance(session,request);
String treePage = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId="+ XSSUtil.encodeForURL(context, routeId);


if(projectId!=null && !"null".equals(projectId) && !"".equals(projectId))   
{
 %>
 <script>
    var detailsDisplay = openerFindFrame(getTopWindow(),"detailsDisplay");
    if(detailsDisplay){
  	detailsDisplay.location.href = detailsDisplay.location.href;
}
     window.closeWindow();
</script>
<%
} 
else 
{
%>
<script language="javascript">
var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
//XSSOK
frameContent.document.location.href =  "<%=treePage%>" ;
frameContent.focus();
getTopWindow().closeWindow();
</script>
<%
}
%>




