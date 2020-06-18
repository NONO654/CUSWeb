<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
    This is an exact copy of emxTeamCreateFolders.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    The include file paths have been changed to point to team central.
    The emx prefix has been changed to sma where appropriate
    We are not passing emxTableRowId
--%>

<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc" %>
<%@ include file = "../teamcentral/emxTeamUtil.inc" %>
<%@ include file = "../teamcentral/eServiceUtil.inc" %>
<%@include file = "../teamcentral/emxTeamStartUpdateTransaction.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<%
  String strProjectId   = emxGetParameter(request, "ObjectId");
  String strFolderName  = emxGetParameter(request, "folderName");
  String strFolderDesp  = emxGetParameter(request, "folderDescription");
  String jsTreeID       = emxGetParameter(request,"jsTreeID");

  String strPolicyProjectVault    = PropertyUtil.getSchemaProperty( context, "policy_ProjectVault");
  String strRelProjectVaults      = PropertyUtil.getSchemaProperty( context, "relationship_ProjectVaults");
  String strTypefolder            = PropertyUtil.getSchemaProperty( context, "type_ProjectVault");

  boolean isDSCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionDesignerCentral",false,null,null);

  boolean bExists = false;
  String folderId = "";
  matrix.db.Relationship rel = null; 

  try{
    BusinessObject boProject            = new BusinessObject(strProjectId);
    boProject.open(context);
    //change
    Workspace workspace        = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
    workspace.setId(strProjectId);
    String strProjectRevision           = boProject.getRevision();
    strProjectRevision                 += "-" + boProject.getName();
    String strProjectVault              = boProject.getVault();
        
    //change
    RelationshipType projectVaultsRelType = new RelationshipType(strRelProjectVaults);
    // Creating a Category and connect this to the Current Project
    BusinessObject boNewCategory = new BusinessObject(strTypefolder, strFolderName, strProjectRevision, strProjectVault);

    if (workspace.isFolderExists(context, strFolderName)) {
      bExists = true;
      String i18NCategory = EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.AddCategories.Category");
      String i18NNotUnique = EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.AddCategories.NotUnique");
      session.putValue("error.message", i18NCategory +"  "+ boNewCategory.getName() +"  "+ i18NNotUnique);
    }
    if(!bExists) {
      boNewCategory.create(context, strPolicyProjectVault);
	  folderId = boNewCategory.getObjectId();
      SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();
	  
      String treeMenu = SimulationUtil.getProperty(context, "eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");
      if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
        MailUtil.setTreeMenuName(context, treeMenu );
      }

      subscriptionMgr.publishEvent(context, workspace.EVENT_FOLDER_CREATED, boNewCategory.getObjectId());

      if (strFolderDesp != null && !strFolderDesp.equals("")) {
        boNewCategory.setDescription(strFolderDesp);
        boNewCategory.update(context);
      }
      //connecting the new Category to the Project
      rel = boNewCategory.connect( context, projectVaultsRelType, false, boProject);
    }
    boNewCategory.close(context);
    boProject.close(context);
    //Code for Tracking if the Folder is created in Route Wizard or not
      Hashtable hashRouteWizFirst = (Hashtable)session.getValue("hashRouteWizFirst");
      if (hashRouteWizFirst != null)
      {
        hashRouteWizFirst.put("newFolderIds" , folderId);
        session.putValue("hashRouteWizFirst" , hashRouteWizFirst);
      }
%>
    <%@ include file = "../teamcentral/emxTeamCommitTransaction.inc" %>
    
   
<%
  } catch (Exception ex){
      session.putValue("error.message",ex);
%>
    <%@  include file="../teamcentral/emxTeamAbortTransaction.inc" %>
<%
  }
  
  if(!bExists) {
      String relId = rel.getName();
      String parentRowId = emxGetParameter(request, "emxTableRowId");
      String action="ADD";
      String message="";
      if (null == parentRowId)
          parentRowId = strProjectId;
        // Form a lineage set for the TOC from the parentRowId.
        // This may be a partial lineage, since we don't have the
        // complete lineage available.
        String[] parts = parentRowId.split("\\|");
        if(parts.length!=1)
        {
        parts[0] = parts[2];
        parts[2] = folderId;
        parts[3] = "";
        }
        String lineage = FrameworkUtil.join(parts, "|");
%>
    <script type="text/javascript">
        exitComposeShorCut();
        refreshDetailsTable("<%=folderId%>","<%=strProjectId%>");
        var frame = null;
        if ( getTopWindow().getWindowOpener() )
            frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"smaHomeHeader");
        else
            frame = findFrame(getTopWindow(),"smaHomeHeader");
    
        if ( frame != null )
        {
            frame.location.href =
                "../simulationcentral/smaHomeContentHeader.jsp" + 
                "?objectId=<%=folderId%>&lineageOIDs=<%=lineage%>";
        }
    </script>
<%
    // Convert parent ID and added content to an appropriate javascript
    // code that either adds the entities or displays an error message.
    StringList contentData = new StringList();
    contentData.add(folderId + "|" + relId);
    String sXML = StructureBrowserUtil.convertToXMLString(
        context, action, message, parentRowId, contentData, 
            "smaHomeTOCContent", true );
%>
    <%= sXML %>
<%
      } else {
          String parentRowId = emxGetParameter(request, "emxTableRowId");
%>
  <form name="newForm" target="_parent" action="smaTeamCreateFoldersWorkspaceDialogFS.jsp" >
    <input type="hidden" name="objectId" value="<%=strProjectId%>">
    <input type="hidden" name="folderName" value="<%=strFolderName%>">
    <input type="hidden" name="emxTableRowId" value="<%=parentRowId%>">
  </form>
  <script language="javascript">
    document.newForm.submit();
  </script>
<%
    }
%>
