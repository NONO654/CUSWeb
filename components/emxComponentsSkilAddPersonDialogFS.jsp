<%--  emxComponentsAddExistingPersonRolesDialogFS.jsp  - Frameset page for adding a persons roles

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsSkilAddPersonDialogFS.jsp.rca 1.7 Wed Oct 22 16:17:52 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<jsp:useBean id="emxComponentsSkilAddPersonDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxComponentsAddExistingPersonRolesDialogFS";

  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  String objectId         = emxGetParameter(request,"objectId");
  String typeAlias        = emxGetParameter(request,"typeAlias");
  String queryLimit       = emxGetParameter(request,"queryLimit");
  String strUserName      = emxGetParameter(request,"userName");
  String strFirstName     = emxGetParameter(request,"firstName");
  String strLastName      = emxGetParameter(request,"lastName");
  String strCompanyName   = emxGetParameter(request,"companyName");
  
  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany = emxGetParameter(request,"defaultCompany");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  
  String selectedPeople[] = emxGetParameterValues(request, "selectedPeople");
  session.setAttribute("selectedPeople", selectedPeople);

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsSkilAddPersonDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?selectedPeople=" + selectedPeople + "&objectId=" + objectId;
  contentURL += "&typeAlias=" + typeAlias + "&queryLimit=" + queryLimit;
  contentURL += "&userName=" + strUserName + "&firstName=" + strFirstName;
  contentURL += "&lastName=" + strLastName + "&companyName=" + strCompanyName;
  contentURL += "&beanName=" + tableBeanName + "&showCompanyAsLabel= " + showCompanyAsLabel;
  contentURL += "&defaultCompany="+defaultCompany+"&targetSearchPage="+targetSearchPage;

  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue))
  {
    contentURL += "&mx.page.filter=" + filterValue;
    fs.setFilterValue(filterValue);
  }

  fs.setBeanName(tableBeanName);

  // Page Heading  - Internationalized
  String PageHeading = "emxComponents.Common.EditPersonCompetency";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpskillsedit";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.removeDialogWarning();
  fs.setStringResourceFile("emxComponentsStringResource");

  // TODO!
  // Narrow this list and add access checking
 
  String roleList = "role_GlobalUser";

  fs.createCommonLink("emxComponents.Command.Previous",
                      "selectPrevious()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);
 
 
  fs.createCommonLink("emxComponents.Command.Done",
                      "selectDone()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);


  fs.createCommonLink("emxComponents.Command.Cancel",
                      "parent.window.close()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>
