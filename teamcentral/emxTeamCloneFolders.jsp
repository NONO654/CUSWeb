<%--   emxTeamCloneFolders.jsp -- To clone the Folder object
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: emxTeamCloneFolders.jsp.rca 1.27 Wed Oct 22 16:06:07 2008 przemek Experimental przemek $";
--%>
<%@page import="com.matrixone.apps.domain.DomainAccess"%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file ="emxTeamCommonUtilAppInclude.inc" %>
<%@ include file = "eServiceUtil.inc"%>
<%@ include file = "emxTeamUtil.inc" %>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../components/emxComponentsTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String sFolderId              = emxGetParameter(request, "objectId");
  String strFolderName          = emxGetParameter(request, "Name");
  String strFolderDesp          = emxGetParameter(request, "Description");
  String strTypefolder          = Framework.getPropertyValue( session, "type_ProjectVault");
  String attrCount              = Framework.getPropertyValue( session, "attribute_Count" );
  String strProjectRevision     = "";
  String strProjectVault        = "";
  String strProjectId           = "";
  String newFolderId            = "";
  String originalFolderName     = "";
  BusinessObject boProject      = null;
  boolean bExists               = false;
  String sTempId                = "";
  strFolderName                 = strFolderName.trim();

  Workspace ParentObject         = (Workspace) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE, DomainConstants.TEAM);
  WorkspaceVault BaseObject      = (WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT, DomainConstants.TEAM);

  BaseObject.setId(sFolderId);
  String  sParentId = BaseObject.getInfo(context,"to[" + BaseObject.RELATIONSHIP_SUBVAULTS + "].from.id");

  if(sParentId == null || sParentId.equals("")) {
      sParentId = BaseObject.getInfo(context,"to[" + BaseObject.RELATIONSHIP_WORKSPACE_VAULTS+ "].from.id");
      sTempId = sParentId;
      ParentObject.setId(sParentId);
  } else {
    BaseObject.setId(sParentId);
  }
  if(sTempId == null){
    sTempId = "";
  }  

  if((strFolderName==null) || strFolderName.equals("")) {
    BusinessObject boFolder = new BusinessObject(sFolderId);
    boFolder.open(context);
    strFolderName="Copy of "+boFolder.getName();
    boFolder.close(context);
  }

  if((strFolderDesp==null) || strFolderDesp.equals("")) {
    strFolderDesp ="";
  }

  BusinessObject ObjFolder = new BusinessObject(sFolderId);
  ObjFolder.open(context);
  originalFolderName = ObjFolder.getName();
  //To get the project id to get the project revision and vault
  strProjectId =UserTask.getProjectId(context,sFolderId);
  boProject= new BusinessObject(strProjectId);
  boProject.open(context);

  strProjectRevision   = boProject.getRevision();

  BusinessObject ParentObj = new BusinessObject(sParentId);
  ParentObj.open(context);


  if(ParentObj.getTypeName().equals(strTypefolder)) {
    strProjectRevision += "-" + ParentObj.getName();
  } else {
    strProjectRevision += "-" + boProject.getName();
  }

  ParentObj.close(context);
  strProjectVault = boProject.getVault();
  boProject.close(context);


  if(!sTempId.equals("") && ParentObject.getInfo(context, ParentObject.SELECT_TYPE).equals(BaseObject.TYPE_PROJECT)) {
    ParentObject.open(context);
    bExists =ParentObject.isFolderExists(context, strFolderName);
    ParentObject.close(context);

  } else {
    BaseObject.open(context);
    bExists = BaseObject.isSubFolderExists(context, strFolderName);
    BaseObject.close(context);
  }

  if (bExists) {
    String i18NCategory =  EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", new Locale( request.getHeader("Accept-Language")) ,"emxTeamCentral.AddCategories.Category");
    String i18NNotUnique = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", new Locale( request.getHeader("Accept-Language")) ,"emxTeamCentral.AddCategories.NotUnique");
    session.setAttribute("error.message", i18NCategory +"  "+ strFolderName +"  "+ i18NNotUnique);
  }

  if(!bExists) {

    //Clone the folder object
    BusinessObject boCloneObj = ObjFolder.clone(context,strFolderName.trim(),strProjectRevision,strProjectVault);
    boCloneObj.open(context);
    newFolderId   = boCloneObj.getObjectId();
    //to Update the Descriprion
    boCloneObj.setDescription(context, strFolderDesp);
    boCloneObj.update(context);
    try {
    	DomainAccess.updateOwnershipOnClone(context, sFolderId, newFolderId);
    }catch(Exception e){}
    //To clone the subfolders and connect them to the cloned object
    CloneFolders(context,session, application, sFolderId,boCloneObj.getObjectId(),strFolderName);
    //Cloned Folder should be "0". (Count is Attribute name of DB)
    AttributeList attrList = new AttributeList();
    attrList.addElement( new Attribute( new AttributeType(attrCount), "0"));
    boCloneObj.setAttributes(context, attrList);

    //get Workspace object for Subscriptions
    ParentObject.setId(strProjectId);
    ParentObject.open(context);
    SubscriptionManager subscriptionMgr = ParentObject.getSubscriptionManager();
    ParentObject.close(context);
    String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");
    if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
         MailUtil.setTreeMenuName(context, treeMenu );
    }
    subscriptionMgr.publishEvent(context, ParentObject.EVENT_FOLDER_CREATED, newFolderId);
    boCloneObj.close(context);
  }

%>

<%!
 static public void CloneFolders(matrix.db.Context context, HttpSession session, ServletContext application, String sfolderId,String sCloneId,String strFolderName) throws Exception {

  String sFolderObjId = sfolderId;
  String sOrgFolName  = strFolderName;
  String sCloneObjId  = sCloneId;
  String strTypeProjectVault = "type_ProjectVault";
  String strProjectVaultType = Framework.getPropertyValue( session, strTypeProjectVault );
  String copyOf="";
  String strSubVaultsRel = Framework.getPropertyValue( session, "relationship_SubVaults");


  BusinessObject ObjFolder        = new BusinessObject(sFolderObjId);
  ObjFolder.open(context);
  String orgFolderName            = ObjFolder.getName();
  String strProjectId             = UserTask.getProjectId(context,sFolderObjId);
  BusinessObject boProject        = new BusinessObject(strProjectId);
  boProject.open(context);
  String strProjectRevision       = boProject.getRevision();
  String strProjectVault          = boProject.getVault();
  boProject.close(context);


  //To check whether folder has any subfolders to clone
  Pattern relSubVaultPattern = new Pattern(strSubVaultsRel);
  Pattern typeCategoryPattern = new Pattern(strProjectVaultType);
  SelectList typeCategorySelectList = new SelectList();
  typeCategorySelectList.addName();
  typeCategorySelectList.addId();
  typeCategorySelectList.addOwner();

  SelectList selListRelationship = new SelectList();
  selListRelationship.addName();
  selListRelationship.addRevision();
  selListRelationship.addOwner();
  selListRelationship.addId();



  ExpansionWithSelect expandWSelectCategory = ObjFolder.expandSelect(context,relSubVaultPattern.getPattern(),typeCategoryPattern.getPattern(),
                                           typeCategorySelectList,selListRelationship,false, true, (short)1);
  if((expandWSelectCategory.getRelationships()).size() ==0){
    return ;
  }  
  else {
  BusinessObject ObjPntCloneFolder = new BusinessObject(sCloneObjId);
  ObjPntCloneFolder.open(context);

  RelationshipWithSelectItr relWSelectSubCategoryItr = new RelationshipWithSelectItr(expandWSelectCategory.getRelationships());
    //Used For naming the cloned foleders

  //get Workspace object for Subscriptions
  Workspace ws = null;
  try{
      ws = (Workspace)DomainObject.newInstance(context, strProjectId, DomainConstants.TEAM);
   }catch(Exception ex)
  { }

  while(relWSelectSubCategoryItr.next()) {
    String parentVaultName = "";
    strProjectRevision = boProject.getRevision();
    //String folderAutoNameId = autoName(context, session, strProjectVaultType,strProjectRevision, "policy_ProjectVault", strProjectVault);
    BusinessObject obSubVault = relWSelectSubCategoryItr.obj().getTo();
    obSubVault.open(context);
    if((sOrgFolName.equals(orgFolderName)))
    {
    copyOf="Copy of ";
    }

    String folderAutoNameId= copyOf+sOrgFolName+"-"+obSubVault.getName();
    String sFolderId=obSubVault.getObjectId();

    DomainObject domObj           = DomainObject.newInstance(context, ObjPntCloneFolder);
    parentVaultName               = domObj.getInfo(context, domObj.SELECT_NAME);
    strProjectRevision           += "-" + parentVaultName;

    BusinessObject boChildCloneObj = obSubVault.clone(context,folderAutoNameId,strProjectRevision,strProjectVault);
    boChildCloneObj.open(context);

    String sChdCloneId= boChildCloneObj.getObjectId();
    try {
	  ContextUtil.pushContext(context);
      boChildCloneObj.disconnect(context, new RelationshipType(strSubVaultsRel),false, ObjFolder);
      boChildCloneObj.connect(context, new RelationshipType(strSubVaultsRel), false, ObjPntCloneFolder);
    }    catch(Exception exp) { }
	finally {
		  ContextUtil.popContext(context);
	}
        AttributeList attrList = new AttributeList();
        String attrCount  = Framework.getPropertyValue( session, "attribute_Count" );
        attrList.addElement( new Attribute( new AttributeType(attrCount), "0"));
        boChildCloneObj.setAttributes(context, attrList);
        try {
        	DomainAccess.updateOwnershipOnClone(context, sFolderId, sChdCloneId);
        }catch(Exception e){}
     SubscriptionManager subscriptionMgr = ws.getSubscriptionManager();

     String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_ProjectVault");
     if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
          MailUtil.setTreeMenuName(context, treeMenu );
     }
     subscriptionMgr.publishEvent(context, ws.EVENT_FOLDER_CREATED, sChdCloneId);

    //To clone the subfolders and connect them to the cloned object
    CloneFolders(context,session, application, sFolderId,sChdCloneId,sOrgFolName);
  }
  return;
}
}

%>
<html>
  <body>
  <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="javascript">

<%
     if(!bExists) {
%>
       var frameContent = openerFindFrame(getTopWindow(), "content");
       var selObjId = "<%=XSSUtil.encodeForJavaScript(context,sParentId)%>";
       var tree1  = frameContent.getTopWindow().objStructureTree;
       var SelectedNodeParent = tree1.getSelectedNode();
       var tempNodeID = "";      
       loadTreeNode("<%=XSSUtil.encodeForJavaScript(context,newFolderId)%>", selObjId, tempNodeID , "<%=XSSUtil.encodeForJavaScript(context,appDirectory)%>", true);
       parent.window.closeWindow();
<%
   } else {
%>
         alert("<%=XSSUtil.encodeForJavaScript(context, (String)session.getAttribute("error.message"))%>");
         parent.document.location.href=parent.document.location.href;
<%
  }
%>

   </script>
  </body>
</html>
