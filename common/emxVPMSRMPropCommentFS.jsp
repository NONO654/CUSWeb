<%--  emxVPMSRMPropCommentFS.jsp   -   FS page to manage Comments thru proposals
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    emxVPMSRMPropCommentFS.jsp
     - emxVPMSRMPropCommentContent.jsp
       - emxVPMSRMPropCommentProcessing.jsp

    RCI - Wk37 2010 - Creation

--%>

<%@include file="../emxUIFramesetUtil.inc"%>



<%
  // Frameset
  framesetObject fs = new framesetObject();

  String objectId = emxGetParameter(request,"objectId");
  String rowIds[] = emxGetParameterValues(request,"emxTableRowId");
  String hiddenParams="";

   // Title
  String titleKey = emxGetParameter(request,"titleKey");
  if(titleKey==null || titleKey.length()==0) titleKey="emxVPMCentral.Command.VPMSRMComment.Title";
  String msgTitle = UINavigatorUtil.getI18nString(titleKey, "emxVPLMWebMgtStringResource", request.getHeader("Accept-Language"));  


  // Specify URL to come in middle of frameset
  if (rowIds != null)
  {
	for (int k = 0; k < rowIds.length; k++){
		String itemId = rowIds[k];
                System.out.println("itemId = " +itemId);
		if(k==rowIds.length-1)
                hiddenParams += itemId;
		else
		hiddenParams += itemId + ",";
	}
  }

  
  StringBuffer contentURL = new StringBuffer("emxVPMSRMPropCommentContent.jsp");
  contentURL.append("?objectId=");
  contentURL.append(objectId);
  contentURL.append("&emxTableRowId=");
  contentURL.append(hiddenParams);
System.out.println("contentURL = " +contentURL.toString());

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





