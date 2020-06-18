<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
    This is an exact copy of emxTeamCreateDubFolders.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    The include file paths have been changed to point to team central.
    The emx prefix has been changed to sma where appropriate
    We are passing emxTableRowId
--%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.matrixone.apps.common.UserTask"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "../teamcentral/emxTeamStartUpdateTransaction.inc"%>
<%@include file = "../teamcentral/eServiceUtil.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>

<%
  String strSubcategoryName           = emxGetParameter(request, "txtName").trim();
  String strSubcategoryDesc           = emxGetParameter(request, "txtMessage").trim();
  String strCategoryId                = emxGetParameter(request, "objectId").trim();
  String callPage                     = emxGetParameter(request,"callPage");
  String strObjectId                  = emxGetParameter(request, "objectId");
  String workspaceId                  = emxGetParameter(request,"workspaceId");
  String parentRowId                  = emxGetParameter(request, "emxTableRowId");
  String objID                        = "";
  String strProjectId                 = "";
  String i18NCategory                 = "";
  String i18NNotUnique                = "";
  String treeUrl                      = null;

  boolean isDSCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionDesignerCentral",false,null,null);

  boolean bExists                     = false;

  BusinessObject boNewSubCategory     = null;
  SubscriptionManager subscriptionMgr = null;
  matrix.db.Relationship rel = null; 

  try {
    //To get the workspace object
    strProjectId                       = UserTask.getProjectId(context,strCategoryId);
    Workspace workspace                = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
    workspace.setId(strProjectId);
    WorkspaceVault workspaceVault      = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
    workspaceVault.setId(strCategoryId);

    workspace.open(context);
    workspaceVault.open(context);

    // Creating a Sub Category and connect this to Parent Category with Sub Vault Relationship
   	//<--!Added for the Bug No:339243 08/06/2007 10:00AM Start-->
	String folderName = workspaceVault.getInfo(context,DomainConstants.SELECT_NAME);
	//<--!Ended for the Bug No:339243 08/06/2007 10:00AM End-->

	//<--!Modifieded for the Bug No:339243 08/06/2007 10:00AM Start-->
    if ((workspaceVault.isSubFolderExists(context, strSubcategoryName))) {
        bExists = true;
        i18NCategory = EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.AddCategories.SubCategory");
        i18NNotUnique = EnoviaResourceBundle.getProperty(context,"emxTeamCentralStringResource",context.getLocale(),"emxTeamCentral.AddCategories.NotUnique");
        session.putValue("error.message", i18NCategory +"  "+ strSubcategoryName +"  "+ i18NNotUnique);
		} 
	//<--!Modied for the Bug No:339243 08/06/2007 10:00AM End-->
	else {
      String strNewSubCategoryId = FrameworkUtil.autoRevision(context, workspace.TYPE_WORKSPACE_VAULT, strSubcategoryName, workspace.POLICY_WORKSPACE_VAULT, workspace.getVault());
      boolean boolTree = false;
      String treeMenu = SimulationUtil.getProperty(context, "eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");
      if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )){
          boolTree = true;
      }
      if(boolTree == true){
        MailUtil.setTreeMenuName(context, treeMenu );
      }
      // Publish workspace  Event 'Folder Created'.
      subscriptionMgr = workspace.getSubscriptionManager();
      subscriptionMgr.publishEvent(context, workspace.EVENT_FOLDER_CREATED, strNewSubCategoryId);

      if(boolTree == true){
        MailUtil.setTreeMenuName(context, treeMenu );
      }
      // Publish workspace Vault  Event 'Folder Created'.
      subscriptionMgr = workspaceVault.getSubscriptionManager();
      subscriptionMgr.publishEvent(context, workspaceVault.EVENT_FOLDER_CREATED, strNewSubCategoryId);

      DomainObject subVault =  new DomainObject(strNewSubCategoryId);
      rel = workspaceVault.connectTo(context, workspaceVault.RELATIONSHIP_SUBVAULTS, subVault);
      subVault.setDescription(context, strSubcategoryDesc);
      objID = subVault.getInfo(context, subVault.SELECT_ID);
      treeUrl = UINavigatorUtil.getCommonDirectory(application) + "/emxTree.jsp?objectId=" + objID +"&emxSuiteDirectory="+appDirectory+"&mode=insert&AppendParameters=true&folderId=" + strObjectId + "&workspaceId=" + workspaceId;
    }

   workspaceVault.close(context);
   workspace.close(context);
%>
    <%@ include file = "../teamcentral/emxTeamCommitTransaction.inc" %>
<%
  } catch (Exception ex){

    bExists = true;
    session.putValue("error.message",ex.getMessage());
%>
    <%@  include file="../teamcentral/emxTeamAbortTransaction.inc" %>
<%
  }
%>

<%
    if(!bExists && parentRowId!=null) {
        String relId = rel.getName();
        String action="ADD";
        String message="";

        // Form a lineage set for the TOC from the parentRowId.
        // This may be a partial lineage, since we don't have the
        // complete lineage available.
        String[] parts = parentRowId.split("\\|");
        parts[0] = parts[2];
        parts[2] = objID;
        parts[3] = "";
        String lineage = FrameworkUtil.join(parts, "|");
%>
      <script type="text/javascript">
          refreshDetailsTable("<%=objID%>","<%=strCategoryId%>");
          var frame = null;
          if ( getTopWindow().getWindowOpener() )
              frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"smaHomeHeader");
          else
              frame = findFrame(getTopWindow(),"smaHomeHeader");
      
          if ( frame != null )
          {
              frame.location.href =
                  "../simulationcentral/smaHomeContentHeader.jsp" + 
                  "?objectId=<%=objID%>&lineageOIDs=<%=lineage%>";
          }
      </script>
<%
      // Convert parent ID and added content to an appropriate javascript
      // code that either adds the entities or displays an error message.
      StringList contentData = new StringList();
      contentData.add(objID + "|" + relId);
      String sXML = StructureBrowserUtil.convertToXMLString(
          context, action, message, parentRowId, contentData, 
              "smaHomeTOCContent", true );
%>
      <%= sXML %>
<%
      }
      else if(!bExists && parentRowId==null)
      {
          %>
          <script type="text/javascript">
              refreshDetailsTable("<%=objID%>","<%=strCategoryId%>");
              getTopWindow().closeWindow();
          </script>
          <%
      }
      else {
        String parentRowId1 = emxGetParameter(request, "emxTableRowId");
%>		
    <script type="text/javascript">
        document.location.href="../simulationcentral/smaTeamCreateSubFoldersWorkspaceDialog.jsp?objectId=<%=strCategoryId%>&callPage=<%=callPage%>&emxTableRowId=<%=parentRowId1%>";
    </script>
<%
    }
%>

