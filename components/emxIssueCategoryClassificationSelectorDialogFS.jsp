<%--  emxIssueCategoryClassificationSelectorDialogFS

  Frameset for Issue Category Classification Selector Page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

  static const char RCSID[] = $Id: emxIssueCategoryClassificationSelectorDialogFS.jsp.rca 1.10 Wed Oct 22 16:18:01 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>

<%--Breaks without the useBean--%>
<jsp:useBean id="issue" scope="page" class="com.matrixone.apps.common.Issue"/>

<%@ page import = "com.matrixone.apps.domain.util.MapList"%>
<%@ page import = "java.util.List"%>
<%
try{
  //Getting the parameters from URL
  String strObjectId   = emxGetParameter(request,"objectId");
  String strFormName = emxGetParameter(request,"formName");
  String strFrameName  = emxGetParameter(request,"frameName");
  String strFieldNameDisplay  = emxGetParameter(request,"fieldNameDisplay");
  String strFieldNameActual   = emxGetParameter(request,"fieldNameActual");

  //Setting the directory name
  String strDirectory  = "components";

  //Defining new frameset
  framesetObject fs = new framesetObject();
  fs.setDirectory(strDirectory);

  fs.setStringResourceFile("emxComponentsStringResource");

  // see if Category Classifications are there to determine if done button  should be shown
  StringList busSelects =  new StringList();

  List issueCategoryList = new MapList();
    fs.setObjectId(strObjectId);

  //The information needed by the query
  busSelects.add(issue.SELECT_ID);
  busSelects.add(issue.SELECT_NAME);
  issueCategoryList = issue.getIssueCategories(context, busSelects);


  // Specify URL to come in middle of frameset(This is to be changed)
  String contentURL = "emxIssueCategoryClassificationSelectorDialog.jsp";
  // add these parameters to each content URL, and any others the App needs

  // Page Heading & Help Page
  String strPageHeading = "emxComponents.Common.SelectCostCategories";
  String strHelpMarker = "emxhelpissuecategory";
  fs.initFrameset(strPageHeading,strHelpMarker,contentURL,false,true,false,false);

  //For Button
  String strSubmit = "emxComponents.Button.Done";
  String strCancel = "emxComponents.Button.Cancel";

  //To check whether there are any category and classification objects
  if(!issueCategoryList.isEmpty()) {

 //StringBuffer to store the URL to be passed.
 StringBuffer sbtargetProcessPage = new StringBuffer(150);
 sbtargetProcessPage.append("../components/emxIssueCategoryClassificationProcess.jsp?objectId=");
 sbtargetProcessPage.append(strObjectId);
 sbtargetProcessPage.append("%26formName=");
 sbtargetProcessPage.append(strFormName);
 sbtargetProcessPage.append("%26frameName=");
 sbtargetProcessPage.append(strFrameName);
 sbtargetProcessPage.append("%26fieldNameDisplay=");
 sbtargetProcessPage.append(strFieldNameDisplay);
 sbtargetProcessPage.append("%26fieldNameActual=");
 sbtargetProcessPage.append(strFieldNameActual);

 String targetProcessPage = sbtargetProcessPage.toString();

    //alert message if none is selected
    String strSelectItem = i18nNow.getI18nString("emxComponents.Common.PleaseSelectAnItem","emxComponentsStringResource",request.getHeader("Accept-Language"));

    //to replace single quote(') and double quote(") with blank() to avoid errors in passing the parameters.
    strSelectItem = strSelectItem.replace('\'', ' ');
 strSelectItem = strSelectItem.replace('\"', ' ');

    //To display 'Done' button

 fs.createFooterLink(strSubmit,
                         "parent.doSelect('" + targetProcessPage + "','" +
                           strSelectItem + "')", "role_GlobalUser",
                           false, true, "common/images/buttonDialogDone.gif", 0);

  }

  //To display 'Cancel' Button
//Modified for Bug No:322703 0 6/21/2007 3:23 PM Begin
fs.createFooterLink(strCancel,FrameworkUtil.encodeNonAlphaNumeric("closeWindow()",Framework.getCharacterEncoding(request)), "role_GlobalUser",
                      false, true, "common/images/buttonDialogCancel.gif", 0);
//Modified for Bug No:322703 0 6/21/2007 3:23 PM End


  fs.writeSelectPage(out);
}
catch(Exception ex) {
 ex.printStackTrace(System.out);
 session.putValue("error.message", ex.getMessage());
} // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
