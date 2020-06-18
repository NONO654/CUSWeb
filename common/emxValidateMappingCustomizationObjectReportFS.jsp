<%--  emxValidateMappingCustomizationObjectFS.jsp   -   FS page for Creating Sync Objects validation page
   Copyright (c) 1992-2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxHelpAboutFS.jsp.rca 1.8 Wed Oct 22 15:47:49 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectName = emxGetParameter(request,"objectName");

  // ----------------- Do Not Edit Above ------------------------------
		String ObjId = request.getParameter("ObjId");
  // Add Parameters Below

  // Specify URL to come in middle of frameset
  String contentURL = "";
  
  // add these parameters to each content URL, and any others the App needs
  StringBuffer contentURLBuffer = new StringBuffer(100);
  contentURLBuffer.append("emxValidateMappingCustomizationObjectReport.jsp");
  contentURLBuffer.append("?suiteKey=");
  contentURLBuffer.append(suiteKey);
  contentURLBuffer.append("&ObjId="+ObjId+"");
  
  contentURL=FrameworkUtil.encodeHref(request,contentURLBuffer.toString());

  // Page Heading - Internationalized
  String PageHeading = "emxVPLMSynchro.CustomSync.ValidationErrors";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "false";
  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL,
                  true,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxVPLMSynchroStringResource");
  String roleList = "role_GlobalUser";
                    
  fs.createFooterLink("emxVPLMSynchro.CustomSync.Done",
                      "parent.window.close()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

