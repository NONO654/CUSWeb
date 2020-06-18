<%--  emxComponentsPeopleDetailsFS.jsp   -   Display Details of BusinessUnits
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPeopleDetailsFS.jsp.rca 1.12 Wed Oct 22 16:18:01 2008 przemek Experimental przemek $
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%@include file="emxComponentsProfileAccessInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
  fs.useCache(false);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID         = emxGetParameter(request,"jsTreeID");
  String suiteKey         = emxGetParameter(request,"suiteKey");
  String objectId         = emxGetParameter(request,"objectId");
  String relId            = emxGetParameter(request,"relId");
  if(jsTreeID == null){ jsTreeID = "";}
  if(suiteKey == null){ suiteKey = "Components";}
  if(relId == null){ relId = "";}
  
  
  // added to refresh the summary page with error message if meeting username & passwd not there
  String errorMessage     = emxGetParameter(request,"errorMessage");

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsPeopleDetails.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + XSSUtil.encodeForURL(context,objectId) + "&relId=" + relId + "&errorMessage=" + errorMessage;


  // Page Heading - Internationalized
  String PageHeading = "emxComponents.Common.PropertiesPageHeadingWithoutRev";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppersonproperties";

  boolean hasAccess  = false;  
  hasAccess   = hasAccessToCommand (context,session, objectId,"role_BuyerAdministrator",null);

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");

  fs.setObjectId(objectId);

  DomainObject domObject = new DomainObject(objectId);  
  String sLicensedHours = domObject.getInfo(context,"attribute["+DomainObject.ATTRIBUTE_LICENSED_HOURS+"]");
  String commandLabel = "0".equals(sLicensedHours)?  "emxComponents.Common.SwitchToCasaulUser" : "emxComponents.Common.SwitchToFullUser" ;
  boolean isOnPremise = FrameworkUtil.isOnPremise(context);
  if(hasAccess && isOnPremise)
  {
    fs.createCommonLink("emxComponents.Button.EditDetails",
                      "showEditDialogPopup()",
                      "role_GlobalUser",
                      false,
                      true,
                      "../common/images/iconActionEdit.png",
                      true,
                      3);

    fs.createCommonLink("emxComponents.Common.ActivateDeActivate",
                      "activatedeactivatePerson()",
                      "role_GlobalUser",
                      false,
                      true,
                      "../common/images/iconActionActivateDeActivate.png",
                      true,
                      3);
    fs.createCommonLink(commandLabel,
			            "switchUser("+ sLicensedHours +")",
			            "role_GlobalUser",
			            false,
			            true,
                      "default",
                      true,
                      3);                      
    
  }
  fs.setCategoryTree(emxGetParameter(request, "categoryTreeName"));
  fs.writePage(out);
%>
