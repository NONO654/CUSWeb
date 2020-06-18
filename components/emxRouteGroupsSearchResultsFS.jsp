<%-- emxRouteGroupsSearchResultsFS.jsp -- Frameset for Role Search Result page
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $ Exp $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<jsp:useBean id="emxRouteGroupsSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%

  framesetObject fs = new framesetObject();
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null) {
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  String tableBeanName    = "emxRouteGroupsSearchResultsFS";
  String loginName        = emxGetParameter(request,"loginName");
  String password         = emxGetParameter(request,"password");
  String confirmpassword  = emxGetParameter(request,"confirmpassword");
  String firstName        = emxGetParameter(request,"firstName");
  String middleName       = emxGetParameter(request,"middleName");
  String lastName         = emxGetParameter(request,"lastName");
  String companyName      = emxGetParameter(request,"companyName");
  String location         = emxGetParameter(request,"location");
  String businessUnit     = emxGetParameter(request,"businessUnit");
  String workPhoneNumber  = emxGetParameter(request,"workPhoneNumber");
  String homePhoneNumber  = emxGetParameter(request,"homePhoneNumber");
  String pagerNumber      = emxGetParameter(request,"pagerNumber");
  String emailAddress     = emxGetParameter(request,"emailAddress");
  String faxNumber        = emxGetParameter(request,"faxNumber");
  String webSite          = emxGetParameter(request,"webSite");
  String objectId         = emxGetParameter(request,"objectId");
  String sName            = emxGetParameter(request,"txtName");
  String sTopChecked      = emxGetParameter(request,"chkTopLevel");
  String sSubChecked      = emxGetParameter(request,"chkSubLevel");
  String sGroupList        = emxGetParameter(request, "groupList");
  String sCallpage        = emxGetParameter(request, "callPage");
  String PageHeading      = "emxComponents.AddGroups.SelectGroups";
  String HelpMarker       = "emxhelpselectuserresults";
  String scope     = emxGetParameter(request, "scope");
  String keyValue     = emxGetParameter(request, "keyValue");
  /*Simple Route Creation*/
 String fromPage     = emxGetParameter(request, "fromPage");
 if(fromPage==null)
 {
    fromPage="";
 }
  String restrictMembers = "";
	if(keyValue==null || keyValue.equals(""))
	{
		restrictMembers   =   emxGetParameter(request,"restrictMembers");
	 }
   String routeId = emxGetParameter(request,"routeId");

  if (sGroupList == null){
    sGroupList="";
  }

  fs.setDirectory(appDirectory);
  fs.setBeanName(tableBeanName);

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(640);
  contentURL.append("emxRouteGroupsSearchResults.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&txtName=");
  contentURL.append(sName);
  contentURL.append("&chkTopLevel=");
  contentURL.append(sTopChecked);
  contentURL.append("&chkSubLevel=");
  contentURL.append(sSubChecked);
  contentURL.append("&groupList=");
  contentURL.append(sGroupList);
  contentURL.append("&loginName=");
  contentURL.append(loginName);
  contentURL.append("&password=");
  contentURL.append(password);
  contentURL.append("&confirmpassword=");
  contentURL.append(confirmpassword);
  contentURL.append("&firstName=");
  contentURL.append(firstName);
  contentURL.append("&middleName=");
  contentURL.append(middleName);
  contentURL.append("&companyName=");
  contentURL.append(companyName);
  contentURL.append("&location=");
  contentURL.append(location);
  contentURL.append("&workPhoneNumber=");
  contentURL.append(workPhoneNumber);
  contentURL.append("&homePhoneNumber=");
  contentURL.append(homePhoneNumber);
  contentURL.append("&pagerNumber=");
  contentURL.append(pagerNumber);
  contentURL.append("&emailAddress=");
  contentURL.append(emailAddress);
  contentURL.append("&faxNumber=");
  contentURL.append(faxNumber);
  contentURL.append("&webSite=");
  contentURL.append(webSite);
  contentURL.append("&lastName=");
  contentURL.append(lastName);
  contentURL.append("&callPage=");
  contentURL.append(sCallpage);
  contentURL.append("&businessUnit=");
  contentURL.append(businessUnit);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);
  contentURL.append("&showWarning=false");
  contentURL.append("&scope="); 
  contentURL.append(scope);
  contentURL.append("&keyValue="); 
  contentURL.append(keyValue);
  contentURL.append("&routeId=");
  contentURL.append(routeId);
  contentURL.append("&restrictMembers=");
  contentURL.append(restrictMembers);
  contentURL.append("&fromPage=");
  contentURL.append(fromPage);



  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,true,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();

  if(scope==null || scope.equals("") || scope.equals("null"))
{
  fs.createHeaderLink("emxComponents.Button.NewSearch",
                      "newSearch()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      0);
 
  fs.createCommonLink("emxComponents.Common.Done",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);
}
  fs.createCommonLink("emxComponents.Common.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);
  fs.writePage(out);
%>
