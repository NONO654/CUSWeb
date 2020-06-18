 <%--  emxComponentsSearchResultsFS.jsp  - Frameset page for search result

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsSearchResultsFS.jsp.rca 1.6 Wed Oct 22 16:17:43 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<jsp:useBean id="emxComponentsSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxComponentsSearchResultsFS";

  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  String strFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
  String strFieldNameActual = emxGetParameter(request,"fieldNameActual");
  String strParentForm = emxGetParameter(request,"formName");

  
  String sCity         = (String) emxGetParameter(request, "txt_City");
  String sState        = (String) emxGetParameter(request, "txt_State");
  String sPostalCode   = (String) emxGetParameter(request, "txt_PostalCode");
  String sLocationName = (String) emxGetParameter(request, "txt_LocationName");
  String sMultiSelect = emxGetParameter(request,"multiselect");
  String sTarget = emxGetParameter(request,"target");


  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsSearchLocationResults.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?beanName=" + tableBeanName;
  contentURL += "&txt_LocationName=" + sLocationName + "&formName=" + strParentForm;
  contentURL += "&txt_PostalCode=" + sPostalCode+"&txt_State="+sState+"&txt_City="+sCity;
  contentURL += "&fieldNameDisplay=" + strFieldNameDisplay;
  contentURL += "&fieldNameActual="+strFieldNameActual;
  contentURL += "&multiselect="+sMultiSelect+ "&target="+sTarget;

  // Needs to encode double times, else single/double bytes chars are not retrieved in results page
  contentURL = FrameworkUtil.encodeURLParamValues(contentURL);
  contentURL = FrameworkUtil.encodeURLParamValues(contentURL);


  fs.setBeanName(tableBeanName);

  // Page Heading  - Internationalized
  String PageHeading = "emxComponents.Common.SelectLocation";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpsearchresults";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.removeDialogWarning();
  fs.setStringResourceFile("emxComponentsStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";


  fs.createHeaderLink("emxComponents.Command.NewSearch",
                        "newSearch()",
                        roleList,
                        false,
                        true,
                        "default",
                        0);

  fs.createCommonLink("emxCommonButton.Done",
                      "submitForm()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);


  fs.createCommonLink("emxCommonButton.Cancel",
                      "parent.window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>
