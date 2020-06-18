<%-- emxPageHistory.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPageHistory.jsp.rca 1.7 Wed Oct 22 15:47:48 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>

<%
  framesetObject fs = new framesetObject();
  String appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.Directory");
  if(appDirectory == null || "".equals(appDirectory) || "null".equals(appDirectory))
  {
    appDirectory = "common";  
  }
  fs.setDirectory(appDirectory);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
	initSource = "";
  }
  String suiteKey = emxGetParameter(request,"suiteKey");
  // Specify URL to come in middle of frameset
  StringBuffer contentURLBuf = new StringBuffer(80);
  contentURLBuf.append("emxPageHistoryBody.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURLBuf.append("?suiteKey=");
  contentURLBuf.append(suiteKey);
  contentURLBuf.append("&initSource=");
  contentURLBuf.append(initSource);
  
  //String contentURL=FrameworkUtil.encodeHref(request,contentURLBuf.toString());
  String finalURL=contentURLBuf.toString();

  // Page Heading - Internationalized
  String PageHeading = i18nNow.getI18nString("emxFramework.PageHistory.Pagehistory", "emxFrameworkStringResource", request.getHeader("Accept-Language"));

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = emxGetParameter(request, "HelpMarker");
  if (HelpMarker == null || HelpMarker.trim().length() == 0) {
	  HelpMarker = "emxhelphistorypassword";
  }


  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  finalURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";
                    

  fs.createHeaderLink("emxFramework.PageHistory.Refresh", 
		  				"refreshContentFrame()",
          				roleList, 
          				false,
          				true, 
          				"iconActionRefresh.gif",
          				0);
  
  fs.createFooterLink("emxFramework.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
