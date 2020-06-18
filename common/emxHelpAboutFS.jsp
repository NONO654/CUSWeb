<%--  emxHelpAboutFS.jsp.jsp   -   FS page for Creating Collection Details
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxHelpAboutFS.jsp.rca 1.8 Wed Oct 22 15:47:49 2008 przemek Experimental przemek $
--%>

<link rel="stylesheet" type="text/css" href="../common/mobile/styles/emxUIMobile.css">
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
     initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectName = emxGetParameter(request,"objectName");

  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below
  
  // 2/22/11-oeo- IR 0939999V6R2012
  // Only Administration Manager can see Infrastructure section.
  Vector userRoles = UICache.getUserRoles(context);
  String strAdminMgrRole = PropertyUtil.getSchemaProperty(context,"role_AdministrationManager");
  boolean isAdminManager = userRoles.contains(strAdminMgrRole);
 
  // Specify URL to come in middle of frameset
  String contentURL = "";
  
  // add these parameters to each content URL, and any others the App needs
  StringBuffer contentURLBuffer = new StringBuffer(100);
  contentURLBuffer.append("emxHelpAbout.jsp");
  contentURLBuffer.append("?suiteKey=");
  contentURLBuffer.append(suiteKey);
  contentURLBuffer.append("&initSource=");
  contentURLBuffer.append(initSource);
  contentURLBuffer.append("&jsTreeID=");
  contentURLBuffer.append(jsTreeID);

  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue)) 
  {
	  // oeo - Reset filter to all if Infrastructure and non-admin user.
	  if (!filterValue.equals("Infrastructure") || (filterValue.equals("Infrastructure") && isAdminManager)) {
		  contentURLBuffer.append("&mx.page.filter=");
          contentURLBuffer.append(filterValue);
          fs.setFilterValue(filterValue);
	  }
  }
  
  contentURL=FrameworkUtil.encodeHref(request,contentURLBuffer.toString());

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.About.About";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpabout";
  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL,
                  true,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");
  String Schema ="emxFramework.AdvancedHelp.Schema";
  String HotFixesInstalled ="emxFramework.AdvancedHelp.HotFixesInstalled";
  String Infrastructure ="emxFramework.AdvancedHelp.Infrastructure";
  String ApplicationVersion ="emxFramework.AdvancedHelp.ApplicationVersion";
  String ConversionsRun ="emxFramework.AdvancedHelp.ConversionsRun";
  String All ="emxFramework.AdvancedHelp.All";
  
  fs.addFilterOption(All,"All");
  fs.addFilterOption(ApplicationVersion,"ProductVersion");
  fs.addFilterOption(Schema,"Schema");
  
  if (isAdminManager)
	  fs.addFilterOption(Infrastructure,"Infrastructure");
  
  fs.addFilterOption(HotFixesInstalled,"HotFixesInstalled");
  fs.addFilterOption(ConversionsRun,"ConversionsRun");
  
  
  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";
                    
  fs.createFooterLink("emxFramework.Common.Done",
                      "parent.window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
