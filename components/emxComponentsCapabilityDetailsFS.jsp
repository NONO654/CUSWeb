<%-- emxComponentsCapabilityDetailsFS.jsp   -

   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCapabilityDetailsFS.jsp.rca 1.10 Wed Oct 22 16:18:29 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%@include file="emxComponentsProfileAccessInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxComponentsStringResource");

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null)
  {
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------
  // Add Parameters Below
  String objectId = emxGetParameter(request,"objectId");
  String strRelId = emxGetParameter(request,"relId");
  fs.setObjectId(objectId);

  Relationship processRelObject = new Relationship(strRelId);
  processRelObject.open(context);
  BusinessObject busParent = processRelObject.getFrom();
  busParent.open(context);
  String strOrgId   = busParent.getObjectId();
  busParent.close(context);
  processRelObject.close(context);

  // If this is the company that the current user represents (Company Rep) or the
  // current user is a Host rep, OR Buyer Admin then the current user has edit access.
  
  boolean hasAccess = hasAccessToCommand (context,session, objectId,strRelId,"role_BuyerAdministrator",null);

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsCapabilityDetails.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId + "&relId=" + strRelId;

  String PageHeading  = "emxComponents.Common.Properties";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcapabilityproperties";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);

  if (hasAccess)
  {
    fs.createCommonLink("emxComponents.Button.EditDetails",
                      "editDetails()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      true,
                      4);
  }
  // ----------------- Do Not Edit Below ------------------------------
  fs.setCategoryTree(emxGetParameter(request, "categoryTreeName"));
  fs.writePage(out);

%>





