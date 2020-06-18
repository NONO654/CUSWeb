<%--  emxComponentsAddExistingPersonSearchDialogFS.jsp  -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%

String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
String lbcAccess         = emxGetParameter(request,"lbcAccess");
if(lbcAccess == null || lbcAccess.isEmpty() || lbcAccess.equalsIgnoreCase("") || lbcAccess.equalsIgnoreCase("false")){
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}
}

  String objectId         = emxGetParameter(request,"objectId");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String multiSelect      = emxGetParameter(request,"multiSelect");
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String AddPerson        = emxGetParameter(request,"AddPerson");
  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany = emxGetParameter(request,"defaultCompany");

  // Only 2 lines added - Nishchal
  String keyValue=emxGetParameter(request,"keyValue");
  String callPage = emxGetParameter(request,"callPage");

  // we need to get the type of the object that we want to connect the eople to so that
  // we know what relationship to use later
  BusinessObject busObj = new BusinessObject(objectId);
  busObj.open(context);
  String sObjectTypeName    = busObj.getTypeName();
  String typeAlias = FrameworkUtil.getAliasForAdmin(context, "type", sObjectTypeName, true);
  busObj.close(context);

  // Modified for the page heading - Nishchal 
  String searchMessage = "";
  if("emxComponentsObjectAccessUsersDialog".equalsIgnoreCase(callPage))
  {
      searchMessage = "emxComponents.AddPeople.SearchPeople";
  }
  else
  {
      searchMessage = "emxComponents.Common.Search";
  }

  // Specify URL to come in middle of frameset
  String contentURL    = "emxComponentsAddExistingPersonSearchDialog.jsp";

  // Added keyvalue parameter to the url - Nishchal
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?objectId=" + objectId + "&searchMessage=" + searchMessage + "&targetSearchPage=" + targetSearchPage;
  contentURL += "&form=" + parentForm + "&field=" + parentField;
  contentURL += "&multiSelect=" + multiSelect + "&typeAlias=" + typeAlias;
  contentURL += "&showCompanyAsLabel=" + showCompanyAsLabel + "&defaultCompany=" + XSSUtil.encodeForURL(context,defaultCompany) + "&lbcAccess=" +XSSUtil.encodeForURL(context,lbcAccess)+"&keyValue=" + keyValue + "&callPage=" + callPage;

  searchFramesetObject fs = new searchFramesetObject();

  String suiteKey     = emxGetParameter(request,"suiteKey");

  String searchHeading = "emxFramework.Suites.Display." + suiteKey;

  fs.initFrameset(searchMessage,contentURL,searchHeading,false);

  // Setup query limit
  String sQueryLimit = JSPUtil.getCentralProperty(application,
                                                  session,
                                                  "eServicespecificationCentral",
                                                  "QueryLimit");

  if (sQueryLimit == null || sQueryLimit.equals("null") || sQueryLimit.equals("")){
    sQueryLimit = "";
  }
  else {
    Integer integerLimit = new Integer(sQueryLimit);
    int intLimit = integerLimit.intValue();
    fs.setQueryLimit(intLimit);
  }

  fs.setDirectory(appDirectory);
  fs.setHelpMarker("emxhelpselectuser");
  fs.setStringResourceFile("emxComponentsStringResource");

  // TODO!
  // Narrow this list and add access checking
  String roleList = "role_GlobalUser";

  fs.createSearchLink("emxComponents.Common.FindPerson", com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);

  fs.writePage(out);

%>
