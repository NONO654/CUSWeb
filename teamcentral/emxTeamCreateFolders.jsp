<%--  emxTeamCreateFolders.jsp  --  Creating Workspace object
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamCreateFolders.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@ include file = "emxTeamUtil.inc" %>
<%@ include file = "eServiceUtil.inc" %>
<%@include file = "emxTeamStartUpdateTransaction.inc"%>
<%@include file = "../components/emxComponentsTreeUtilInclude.inc" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String strProjectId   = emxGetParameter(request, "objectId");
  String strFolderName  = emxGetParameter(request, "NameDisplay");
  String strFolderDesp  = emxGetParameter(request, "Description");
  String jsTreeID       = emxGetParameter(request,"jsTreeID");
  String callPage       = emxGetParameter(request,"callPage");
  String targetLocation = emxGetParameter(request, "targetLocation");	
  String strPolicyProjectVault    = PropertyUtil.getSchemaProperty( context, "policy_ProjectVault");
  String strRelProjectVaults      = PropertyUtil.getSchemaProperty( context, "relationship_ProjectVaults");
  String strTypefolder            = PropertyUtil.getSchemaProperty( context, "type_ProjectVault");

  boolean isDSCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionDesignerCentral",false,null,null);
  Hashtable hashRouteWizFirst = (Hashtable)session.getAttribute("hashRouteWizFirst");
  boolean bExists = false;
  String folderId = "";
  Workspace workspace        = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
  workspace.setId(strProjectId);

  try{
	  if (hashRouteWizFirst != null){
    BusinessObject boProject            = new BusinessObject(strProjectId);
    boProject.open(context);
    //change
   // String strProjectRevision           = boProject.getRevision();
   // strProjectRevision                 += "-" + boProject.getName();
    String strProjectVault              = boProject.getVault();

    //Modified for Duplicate Folder Names R2010x
    MQLCommand mqlCmd = new MQLCommand();

    mqlCmd.executeCommand(context, "print bus $1 select $2 dump $3",strProjectId, "physicalid","|");
    String strProjectRevision = mqlCmd.getResult();
    strProjectRevision = strProjectRevision.substring(0,strProjectRevision.indexOf("\n"));
    //Addition ends for Duplicate Folder Names R2010x
    //change
    RelationshipType projectVaultsRelType = new RelationshipType(strRelProjectVaults);
    // Creating a Category and connect this to the Current Project
    BusinessObject boNewCategory = new BusinessObject(strTypefolder, strFolderName, strProjectRevision, strProjectVault);

    if (workspace.isFolderExists(context, strFolderName)) {
      bExists = true;
      String i18NCategory = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", new Locale( request.getHeader("Accept-Language")), "emxTeamCentral.AddCategories.Category");
      String i18NNotUnique = i18nNow.getI18nString("emxTeamCentral.AddCategories.NotUnique","emxTeamCentralStringResource",request.getHeader("Accept-Language"));
      session.setAttribute("error.message", i18NCategory +"  "+ boNewCategory.getName() +"  "+ i18NNotUnique);
    }
    if(!bExists) {
      boNewCategory.create(context, strPolicyProjectVault);
      folderId = boNewCategory.getObjectId();
      SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();
      
      String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");
      if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
        MailUtil.setTreeMenuName(context, treeMenu );
      }

      subscriptionMgr.publishEvent(context, workspace.EVENT_FOLDER_CREATED, boNewCategory.getObjectId());

      if (strFolderDesp != null && !strFolderDesp.equals("")) {
        boNewCategory.setDescription(context, strFolderDesp);
        boNewCategory.update(context);
      }
      //connecting the new Category to the Project
      boNewCategory.connect( context, projectVaultsRelType, false, boProject);
    }
    boNewCategory.close(context);
    boProject.close(context);
    //Code for Tracking if the Folder is created in Workspace Wizard or not
     
      if (hashRouteWizFirst != null)
      {
        hashRouteWizFirst.put("newFolderIds" , folderId);
        session.setAttribute("hashRouteWizFirst" , hashRouteWizFirst);
      }
  	}else{
  		folderId = emxGetParameter(request, "newObjectId");
  	}
%>
	<%@ include file = "emxTeamCommitTransaction.inc" %>
<%
  } catch (Exception ex){
      bExists = true;
      session.setAttribute("error.message",ex.getMessage());
%>
    <%@  include file="emxTeamAbortTransaction.inc" %>
<%
  }

  if(!bExists) {
%>
  <script language="javascript">
		//XSSOK – isDSCInstalled - value not read from request
		var isDSCInstalled = "<%=isDSCInstalled%>";	
		if (isDSCInstalled == "true"){
			if(parent.window.getWindowOpener() != null){
				 parent.window.getWindowOpener().parent.getTopWindow().location.replace(parent.window.getWindowOpener().parent.getTopWindow().location);
				if("<%= XSSUtil.encodeForJavaScript(context,targetLocation) %>" != "slidein"){
				 parent.window.closeWindow();
				}
		}   
		}   
  
       var tree = null;
       if(parent.window.getWindowOpener() != null){
		tree = parent.window.getWindowOpener().getTopWindow().tempTree;
		}
        if (tree != null && tree != 'undefined') {
         // to refresh Structure Tree
          var conTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
          var isDSCInstalled = "<%=isDSCInstalled%>";
          if (isDSCInstalled == "true" && conTree==null) { 
            getTopWindow().window.getWindowOpener().parent.getTopWindow().location.replace(parent.window.getWindowOpener().parent.getTopWindow().location);            
          } else {
            getTopWindow().getWindowOpener().getTopWindow().addStructureNode("<%=XSSUtil.encodeForJavaScript(context, folderId)%>", "<%=XSSUtil.encodeForJavaScript(context,strProjectId)%>",conTree.getSelectedNode().nodeID , "<%=XSSUtil.encodeForJavaScript(context,appDirectory)%>");
          }
            if("<%= XSSUtil.encodeForJavaScript(context,targetLocation) %>" != "slidein"){
          getTopWindow().closeWindow();
		    }	          
        } else {
          var frameContent = openerFindFrame(getTopWindow(), "content");
          var newNode = "";
   loadTreeNode("<%=XSSUtil.encodeForJavaScript(context, folderId)%>","<%=XSSUtil.encodeForJavaScript(context, strProjectId)%>",newNode,"<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", true);
       	  if("<%= XSSUtil.encodeForJavaScript(context,targetLocation) %>" != "slidein"){
   parent.window.closeWindow();      
        }
        }
<%
      } else {
%>
 alert("<%=XSSUtil.encodeForJavaScript(context,(String)session.getAttribute("error.message"))%>");
 parent.document.location.href=parent.document.location.href;
<%
    }
%>
</script>

