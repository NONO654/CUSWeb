<%--  emxVPMProductExportFS.jsp   -   FS page to get Name of product to Export
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    emxVPMProductExportFS.jsp
     - emxVPMProductExportContent.jsp
       - emxVPMProductExportProcessing.jsp

    RCI - Wk13 2010 - Creation

--%>

<%@include file="../emxUIFramesetUtil.inc"%>



<%
  // Frameset
  framesetObject fs = new framesetObject();

  // Title
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey = "emxVPMCentral.Command.VPMProductExport.Title";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPLMWebMgtStringResource", request.getHeader("Accept-Language")) ; 

  // Specify URL to come in middle of frameset
  String contentURL= "emxVPMProductExportContent.jsp";

  fs.setPageTitle("ENOVIA - Web Core Modeler UI");
  fs.setStringResourceFile("emxFrameworkStringResource");  
     

  fs.initFrameset(msgTitle,		//pageHeading
                  "",				//helpMarker
                  contentURL.toString(),	//contentURL
                  false,					//UsePrinterFriendly
                  true,						//IsDialogPage
                  false,					//ShowPagination
                  false);					//ShowConversion


  fs.createFooterLink("emxFramework.Button.Submit", // display String 
                       "checkInput()",  // URL to go to our JavaScript method ( 
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





