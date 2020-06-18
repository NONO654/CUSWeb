<%-- emxTeamSearchRolesResultsFS.jsp -- Frameset for Role Search Result page
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamSearchRolesResultsFS.jsp.rca 1.12 Wed Oct 22 16:06:23 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamSearchRolesResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  framesetObject fs = new framesetObject();
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null) {
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
 
  // Specify URL to come in middle of frameset
  String contentURL       = "emxTeamSearchRolesResults.jsp";
  String tableBeanName    = "emxTeamSearchRolesResultsFS";
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
  String organizationId   = emxGetParameter(request,"objectId");
  String sName            = emxGetParameter(request,"txtName");
  String sTopChecked      = emxGetParameter(request,"chkTopLevel");
  String sSubChecked      = emxGetParameter(request,"chkSubLevel");
  String sRoleList        = emxGetParameter(request, "roleList");
  String sCallpage        = emxGetParameter(request, "callPage");
  String PageHeading      = "emxTeamCentral.CreatePerson.SelectRoles";
  String HelpMarker       = "emxhelpfindroles";
  

  if (sRoleList == null){
    sRoleList="";
  }
  fs.setDirectory(appDirectory);
  fs.useCache(false);
  fs.setBeanName(tableBeanName);
  
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId="+organizationId+"&txtName="+sName+"&chkTopLevel="+sTopChecked+"&chkSubLevel="+sSubChecked+ "&roleList=" + sRoleList;
  contentURL += "&loginName=" + loginName + "&password=" + password + "&confirmpassword=" + confirmpassword;
  contentURL += "&firstName=" + firstName + "&middleName=" + middleName +"&companyName=" + companyName;
  contentURL += "&location=" + location + "&workPhoneNumber=" + workPhoneNumber +"&homePhoneNumber=" + homePhoneNumber;
  contentURL += "&pagerNumber=" + pagerNumber +"&emailAddress="+ emailAddress + "&faxNumber=" +faxNumber;
  contentURL += "&webSite=" + webSite + "&lastName=" + lastName+"&callPage="+sCallpage ;
  contentURL += "&businessUnit=" + businessUnit;
  contentURL += "&beanName=" + tableBeanName;


  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitform()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);
  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);
  fs.writePage(out);
%>
