<%--  emxTeamCreateNewFolderDialogFS.jsp   -   Create Frameset for New TopLevel Folder
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamPreDefinedFolderDialogFS.jsp.rca 1.13 Wed Oct 22 16:06:06 2008 przemek Experimental przemek $
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamPreDefinedFolderDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  framesetObject fs     = new framesetObject();
  String tableBeanName  = "emxTeamPreDefinedFolderDialogFS";
  String initSource     = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");
  String Directory = appDirectory;

  fs.setDirectory(Directory);
  fs.useCache(false);
  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamPreDefinedFolderDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;
  contentURL += "&beanName=" + tableBeanName;

  fs.setBeanName(tableBeanName);

  String PageHeading = "emxTeamCentral.CreatePreDifindFolderDailog.SelectPreDifndFolder";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpselectpredefinedfolder";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)

  String strRelProjectVaults    = Framework.getPropertyValue(session, "relationship_ProjectVaults");
  String strTypeProjectVault    = Framework.getPropertyValue(session, "type_ProjectVault");
  BusinessObject boProject      = new BusinessObject(objectId);

  Hashtable hashCategoriesTable = new Hashtable();
  Enumeration categoriesEnum        = null;
  boolean isSelected = false;

  String catList = JSPUtil.getApplicationProperty(context,application, "emxTeamCentral.DefaultCategories");

  StringTokenizer catToken = new StringTokenizer(catList, ";");
  String cat = "";
  String catName = "";
  String catDesc = "";
  while (catToken.hasMoreTokens())
  {
    cat     = catToken.nextToken();
    catName = i18nNow.getI18nString("emxTeamCentral.AddCategoriesDialog."+cat,"emxTeamCentralStringResource",sLanguage);
    catDesc = i18nNow.getI18nString("emxTeamCentral.AddCategoriesDialog."+cat+"Desc","emxTeamCentralStringResource",sLanguage);
    hashCategoriesTable.put(catName, catDesc);
  }
  Pattern relPattern = new Pattern(strRelProjectVaults);
  Pattern typePattern = new Pattern(strTypeProjectVault);
  SelectList typeselectList = new SelectList();
  typeselectList.addId();
  typeselectList.addName();
  typeselectList.addDescription();

  boProject.open(context);
  ExpansionWithSelect expandWSelectProject = boProject.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                             typeselectList,new StringList(),false, true, (short)1);
  boProject.close(context);

  RelationshipWithSelectItr relWSelectProjectVaultItr = new RelationshipWithSelectItr(expandWSelectProject.getRelationships());

  while(relWSelectProjectVaultItr.next()) {
    Hashtable vaultHashTable    = relWSelectProjectVaultItr.obj().getTargetData();
    String strVaultName         = (String)vaultHashTable.get("name");
    String strVaultDescription  = (String)vaultHashTable.get("description");

    if(hashCategoriesTable.containsKey(strVaultName)) {
      hashCategoriesTable.remove(strVaultName);
    }
  }
  if ( hashCategoriesTable != null ){
    categoriesEnum = hashCategoriesTable.keys();
  }

  if (categoriesEnum.hasMoreElements()) {

   fs.createCommonLink("emxTeamCentral.Button.Done",
                    "submitForm()",
                    "role_ExchangeUser,role_CompanyRepresentative",
                    false,
                    true,
                    "common/images/buttonDialogDone.gif",
                    false,
                    3);
  }

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>
