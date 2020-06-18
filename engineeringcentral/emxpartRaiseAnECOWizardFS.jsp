<%--  emxpartRaiseAnECOWizardFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@ include file="emxEngrFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String objectId           = emxGetParameter(request,"objectId");

  String checkedButtonValue = emxGetParameter(request, "checkedButtonValue");
  session.removeAttribute("ReasonForChange_KEY");  //IR-069928V6R2012
  fs.setDirectory(appDirectory);
  fs.setSuiteKey(suiteKey);

  // Specify URL to come in middle of frameset
  String contentURL = "emxpartRaiseAnECOWizard.jsp";
  String Relationship=emxGetParameter(request,"Relationship");

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&jsTreeID=" + jsTreeID + "&objectId=" + objectId+"&checkedButtonValue="+checkedButtonValue+"&Relationship="+Relationship;

  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.RaiseECO.RaiseAnECO";

  // Marker to pass into Help Pages
  String HelpMarker = "emxhelpecrraise";

  // Role based access
  String roleList ="role_GlobalUser";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);


  fs.createFooterLink("emxFramework.Command.Next",
                      "submitForm()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      3);

  fs.createFooterLink("emxFramework.Command.Cancel",
                      "parent.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  fs.writePage(out);
%>
