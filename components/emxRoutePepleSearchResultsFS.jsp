 <%--  emxRoutePepleSearchResultsFS.jsp  -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRoutePepleSearchResultsFS.jsp.rca 1.12 Wed Oct 22 16:18:14 2008 przemek Experimental przemek $
--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<jsp:useBean id="emxRoutePepleSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />


<%
//added fro 307166
  String jsTreeID = emxGetParameter(request,"jsTreeID");
//till here
  String tableBeanName = "emxRoutePepleSearchResultsFS";
  String strFirstName   = emxGetParameter(request,"firstName");
  String strLastName    = emxGetParameter(request,"lastName");
  String strUserName    = emxGetParameter(request,"userName");
  String strCompanyName = emxGetParameter(request,"companyName");
  String multiSelect = emxGetParameter(request,"multiSelect");
  String supplierOrgId = emxGetParameter(request,"supplierOrgId");
  String keyValue = emxGetParameter(request,"keyValue");
  String routeId = emxGetParameter(request,"routeId");
  String flag              = emxGetParameter(request,"flag"); 
  String chkSubscribeEvent = emxGetParameter(request,"chkSubscribeEvent"); 
  String restrictMembers   =   emxGetParameter(request,"restrictMembers");
  String PageHeading = "emxComponents.AddPeople.SelectPeople" ;

  String fromPage = emxGetParameter(request,"fromPage"); 
    // icon launches new window with help frameset inside

  String HelpMarker = "emxhelpcreateroutewizard2";

  // Specify URL to come in middle of frameset
  String contentURL = "emxRoutePeopleSearchResults.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL+="?UserName="+strUserName;
  contentURL+="&FirstName="+strFirstName;
  contentURL+="&LastName="+strLastName;
  contentURL+="&CompanyName=" + strCompanyName;

  contentURL+="&multiSelect="+multiSelect;
  contentURL += "&beanName=" + tableBeanName;
  contentURL+="&supplierOrgId="+supplierOrgId;
  contentURL+="&keyValue="+keyValue;
  contentURL+="&routeId="+routeId;
  contentURL += "&flag=" + flag ;
  contentURL += "&chkSubscribeEvent=" + chkSubscribeEvent ;
  contentURL += "&restrictMembers=" + restrictMembers ;
  contentURL += "&fromPage="+fromPage ;
  //added for 307166
  contentURL += "&jsTreeID=" + jsTreeID;
//till here
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setBeanName(tableBeanName);
  fs.useCache(false);
  // Search Heading - Internationalized

  fs.setStringResourceFile("emxComponentsStringResource");

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,true,false);

  // ----------------- Do Not Edit Below ------------------------------
  

   fs.createHeaderLink("emxComponents.Button.NewSearch",
                      "searchNew()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                       0);
 
   fs.createCommonLink("emxComponents.Button.Done",
                      "selectDone()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

   fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>

