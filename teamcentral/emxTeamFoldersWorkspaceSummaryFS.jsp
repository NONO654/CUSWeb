<%-- emxTeamFoldersWorkspaceSummaryFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamFoldersWorkspaceSummaryFS.jsp.rca 1.17 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamFoldersWorkspaceSummaryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String objectId     = emxGetParameter(request,"objectId");
  String initSource   = emxGetParameter(request,"initSource");
  
  String attributeBracket = "attribute[";
   
  framesetObject fs   = new framesetObject();  
  fs.setDirectory(appDirectory);
  fs.useCache(false);
  String tableBeanName = "emxTeamFoldersWorkspaceSummaryFS";    
  if (initSource == null){
    initSource = "";
  }  

  // Specify URL to come in middle of frameset
  StringBuffer sbContentURL = new StringBuffer("emxTeamFoldersWorkspaceSummary.jsp");
  sbContentURL.append("?suiteKey=");
  sbContentURL.append(suiteKey);
  sbContentURL.append("&initSource=");
  sbContentURL.append(initSource);
  sbContentURL.append("&jsTreeID=");
  sbContentURL.append(jsTreeID);
  sbContentURL.append("&objectId=");
  sbContentURL.append(objectId);
  sbContentURL.append("&beanName=");
  sbContentURL.append(tableBeanName);  

  fs.setBeanName(tableBeanName);
  
  Workspace workspace = (Workspace)DomainObject.newInstance(context, objectId, DomainConstants.TEAM);
  
  StringBuffer sbAttrCreateFolder= new StringBuffer(attributeBracket);
  sbAttrCreateFolder.append(DomainObject.ATTRIBUTE_CREATE_FOLDER);
  sbAttrCreateFolder.append("].value");
  
  StringBuffer sbAttrProjectAccess = new StringBuffer(attributeBracket);
  sbAttrProjectAccess.append(DomainObject.ATTRIBUTE_PROJECT_ACCESS);
  sbAttrProjectAccess.append("].value");
  
  StringBuffer sbProjectMember     = new StringBuffer("to[");
  sbProjectMember.append(DomainObject.RELATIONSHIP_PROJECT_MEMBERSHIP);
  sbProjectMember.append("].from.name");

  try {    
    //Getting the Current Access.
    Access access = workspace.getAccessMask(context);
    if(!AccessUtil.hasReadAccess(access)) {
      throw new MatrixException(i18nNow.getI18nString("emxTeamCentral.Common.PageAccessDenied", "emxTeamCentralStringResource",request.getHeader("Accept-Language")));
    }

    String sOwner           = "";
    String sCreateFolder    = "";
    String myProjectAccess  = "";

    //Getting Context User Name
    String sUser       = context.getUser();

    StringList sList = new StringList();
    sList.add(sbAttrCreateFolder.toString());
    sList.add(sbAttrProjectAccess.toString());
    sList.add(DomainObject.SELECT_OWNER);
    sList.add(sbProjectMember.toString());

    StringBuffer sbWhere = new StringBuffer(sbProjectMember.toString());
    sbWhere.append("=='");
    sbWhere.append(sUser);
    sbWhere.append("'");
    MapList memberList = workspace.getWorkspaceMembers(context,sList,sbWhere.toString());
    Iterator memberItr = memberList.iterator();
    
    Map memberMap = null;
    while(memberItr.hasNext()) {
      memberMap        = (Map)memberItr.next();
      sCreateFolder    = (String)memberMap.get(sbAttrCreateFolder.toString());
      myProjectAccess  = (String)memberMap.get(sbAttrProjectAccess.toString());
      sOwner           = (String)memberMap.get(DomainObject.SELECT_OWNER);
    }

    String PageHeading  = "emxTeamCentral.Name.Folders";
    String HelpMarker   = "emxhelpfolders";

    //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
    fs.initFrameset(PageHeading,HelpMarker,sbContentURL.toString(),true,false,true,false);

    fs.setStringResourceFile("emxTeamCentralStringResource");
    fs.setObjectId(objectId);

    //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
    // checking if the person is Lead or Owner or he has Create Vault Attribute Value as "Yes" with Add/AddRemove Access.
    if("Project Lead".equals(myProjectAccess) || sUser.equals(sOwner)||("Yes".equals(sCreateFolder)&& (AccessUtil.hasAddAccess(access)|| AccessUtil.hasAddRemoveAccess(access)))) {
      fs.createCommonLink("emxTeamCentral.Button.CreateNew",
                          "showEditDialogPopup()",
                          "role_ExchangeUser,role_CompanyRepresentative",
                          false,
                          true,
                          "default",
                          true,
                          3);
    }
    // checking if the person is Lead or Owner or he has Create Vault Attribute Value as "Yes" with Remove/AddRemove Access.
    if("Project Lead".equals(myProjectAccess) || sUser.equals(sOwner)||("Yes".equals(sCreateFolder)&& (AccessUtil.hasRemoveAccess(access)|| AccessUtil.hasAddRemoveAccess(access)))) {
      fs.createCommonLink("emxTeamCentral.Button.DeleteSelected",
                          "showDeleteDialogPopup()",
                          "role_ExchangeUser,role_CompanyRepresentative",
                          false,
                          true,
                          "default",
                          false,
                          0);
    }
    fs.writePage(out);
  } catch(Exception e) {
    throw new MatrixException(i18nNow.getI18nString("emxTeamCentral.Common.PageAccessDenied", "emxTeamCentralStringResource",request.getHeader("Accept-Language")));
  }
%>
