<%--  emxVPMProductCreate.FSjsp   -   FS page for Create CAD Product dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>


<%
  // Frameset
  framesetObject fs = new framesetObject();

  // objectId
  String objectId    = emxGetParameter(request,"objectId"); 
  String languageStr = request.getHeader("Accept-Language");
  String HelpMarker  = "";

  // Title
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPMCentral.Command.VPMProductCreate.Title";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPLMProductEditorStringResource", request.getHeader("Accept-Language")) ; 

  // Specify URL to come in middle of frameset
  String failed = request.getParameter("failed");
  if(failed ==null || "null".equals(failed)){
      failed ="0";
  }

  // Specify URL to come in middle of frameset
  String contentURL= "emxVPMProductCreateType.jsp?failed="+failed;

  StringBuffer validateURL = new StringBuffer();
  
  fs.setPageTitle("ENOVIA - Web Core Modeler UI");

  fs.setStringResourceFile("emxFrameworkStringResource");  
     

  fs.initFrameset(msgTitle,		//pageHeading
                  HelpMarker,				//helpMarker
                  contentURL.toString(),	//contentURL
                  false,					//UsePrinterFriendly
                  true,						//IsDialogPage
                  false,					//ShowPagination
                  false);					//ShowConversion


  fs.createFooterLink("emxFramework.Button.Submit", // display String 
                       "checkInput()",  // URL to go to our JavaScript method
                      "role_GlobalUser", // roles 
                      false, //popup
                      true,  // true if JavaScript method
                      "emxUIButtonDone.gif", //Icon  used  for  links
                      0); // size  0-6,  popped  up  window  size 

  fs.createFooterLink("emxFramework.Button.Cancel",
                      "parent.window.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "emxUIButtonCancel.gif",
                      0);
                      

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
  
%>





