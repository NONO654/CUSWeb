<%-- emxRouteSearchRolesResultsFS.jsp -- Frameset for Role Search Result page
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSearchRolesResultsFS.jsp.rca 1.19 Wed Oct 22 16:18:08 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<jsp:useBean id="emxCommonRouteSearchRolesResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  framesetObject fs = new framesetObject();
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null) {
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  String tableBeanName    = "emxCommonRouteSearchRolesResultsFS";
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
  String sRoleList        = emxGetParameter(request, "roleList");
  String sCallpage        = emxGetParameter(request, "callPage");
  String PageHeading      = "emxComponents.SearchRole.SelectRoles";
  String HelpMarker       = "emxhelpselectuserresults";
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String parentFieldDisp  = emxGetParameter(request,"fieldDisp");
  String multiSelect      = emxGetParameter(request,"multiSelect");
  String mainSearchPage   = emxGetParameter(request,"mainSearchPage");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  
  String strOrgId         = emxGetParameter(request,"orgId");
  if(strOrgId == null || "null".equals(strOrgId))
  {
    strOrgId = "";
  }

  if (sRoleList == null){
    sRoleList="";
  }

  fs.setDirectory(appDirectory);
  fs.setBeanName(tableBeanName);

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(640);
  contentURL.append("emxRouteSearchRolesResults.jsp");

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
  contentURL.append("&roleList=");
  contentURL.append(sRoleList);
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
  contentURL.append("emailAddress=");
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
  contentURL.append("&form=");
  contentURL.append(parentForm);
  contentURL.append("&field=");
  contentURL.append(parentField);
  contentURL.append("&fieldDisp=");
  contentURL.append(parentFieldDisp);
  contentURL.append("&multiSelect=");
  contentURL.append(multiSelect);
  contentURL.append("&mainSearchPage=");
  contentURL.append(mainSearchPage);
  contentURL.append("&targetSearchPage=");
  contentURL.append(targetSearchPage);
  contentURL.append("&showWarning=false");
  contentURL.append("&orgId=");
  contentURL.append(strOrgId);

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,true,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();

  fs.createHeaderLink("emxComponents.Button.NewSearch",
                      "newSearch()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      0);
  fs.createCommonLink("emxComponents.Button.Done",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);
  fs.writePage(out);
%>
